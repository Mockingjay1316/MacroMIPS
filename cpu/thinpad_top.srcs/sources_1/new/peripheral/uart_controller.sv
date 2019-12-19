`include "common_defs.svh"

module uart_controller (
    input   logic       main_clk, rst,
    input   logic       peri_clk, uart_en,
    input   logic       load_from_mem,
    input   logic       is_data_read,       //1表示读数据，0表示写数据
    input   logic       data_write_en,
    input   logic       mem_byte_en,
    input   logic       mem_sign_ext,
    input   logic[31:0] pc, data_addr,
    input   logic[31:0] data_write,
    output  logic[31:0] data_read, instr_read,
    output  logic       mem_stall,
    output  logic       hard_int,

    //直连串口信号
    output  wire       txd,                //直连串口发送端
    input   wire       rxd                 //直连串口接收端
);

//直连串口接收发送演示，从直连串口收到的数据再发送出去
logic[7:0] ext_uart_rx;
logic[7:0] ext_uart_buffer, ext_uart_tx;
logic ext_uart_ready, ext_uart_busy, ext_uart_clear;
logic ext_uart_start, ext_uart_wavai, ext_uart_ravai, ext_uart_read_status, ext_uart_already_read_status;
uart_rstate_t uart_rstate;
assign hard_int = ext_uart_already_read_status^ext_uart_read_status;

async_receiver #(.ClkFrequency(50000000),.Baud(9600))   //接收模块，9600无检验位
    ext_uart_r(
        .clk(peri_clk),                                 //外部时钟信号
        .RxD(rxd),                                      //外部串行信号输入
        .RxD_data_ready(ext_uart_ready),                //数据接收到标志
        .RxD_clear(ext_uart_clear),                     //清除接收标志
        .RxD_data(ext_uart_rx)                          //接收到的一字节数据
    );

assign ext_uart_wavai = data_write_en & uart_en;
logic[1:0] counter;

always @(posedge peri_clk) begin
    if (rst) begin
        uart_rstate <= UART_RWAIT;
        ext_uart_read_status <= ext_uart_already_read_status;
    end else begin
        case(uart_rstate)
            UART_RWAIT: begin
                ext_uart_clear <= 1'b0;
                if (ext_uart_ready & ~ext_uart_clear) begin
                    uart_rstate <= UART_RREAD;
                end
                end
            UART_RREAD: begin
                uart_rstate <= UART_RACK;
                ext_uart_buffer <= ext_uart_rx;         //读入数据
                ext_uart_read_status <= ~ext_uart_read_status;
                end
            UART_RACK: begin
                uart_rstate <= UART_RWAIT;
                ext_uart_clear <= 1'b1;
                end
            default: begin
                
                end
        endcase
    end
end

always @(posedge peri_clk) begin                         //将缓冲区ext_uart_buffer发送出去
    if (!ext_uart_busy && ext_uart_wavai) begin
        if (data_addr[3:0] == 4'h8) begin
            ext_uart_start <= 1'b1;
        end
    end else begin
        ext_uart_start <= 1'b0;
    end
end

always @(*) begin
    if (data_addr[3:0] == 4'hc) begin
        data_read <= {30'b0, ext_uart_already_read_status^ext_uart_read_status, ~ext_uart_busy};
    end else if (data_addr[3:0] == 4'h8) begin
        if (data_write_en & uart_en) begin
            ext_uart_tx <= data_write[7:0];
        end else if (uart_en) begin
            data_read <= {24'b0, ext_uart_buffer};
        end
    end
end

always @(posedge main_clk) begin                         //将缓冲区ext_uart_buffer发送出去
    if (rst) begin
        ext_uart_already_read_status <= 1'b0;
    end else if (uart_en & is_data_read && data_addr[3:0] == 4'h8) begin
        ext_uart_already_read_status <= ext_uart_read_status;
    end
end

async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //发送模块，9600无检验位
    ext_uart_t(
        .clk(peri_clk),                                 //外部时钟信号
        .TxD(txd),                                      //串行信号输出
        .TxD_busy(ext_uart_busy),                       //发送器忙状态指示
        .TxD_start(ext_uart_start),                     //开始发送信号
        .TxD_data(ext_uart_tx)                          //待发送的数据
    );

endmodule