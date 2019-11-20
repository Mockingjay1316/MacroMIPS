`include "common_defs.svh"

module uart_controller (
    input logic                     rst;
    input logic                     main_clk;
    input logic                     peri_clk;
    input logic[`ADDR_WIDTH-1:0]    mem_addr;
    input logic[4:0]                mem_ctrl_signal;
    input logic[`DATA_WIDTH-1:0]    mem_wdata;

    input wire                      rxd;
    input wire                      reset_btn;

    output wire                     txd;

);

logic[7:0] ext_uart_rx;
logic[7:0] ext_uart_buffer, ext_uart_tx;
logic ext_uart_ready, ext_uart_busy, ext_uart_clear;
logic ext_uart_start, ext_uart_wavai, ext_uart_ravai, ext_uart_read_status, ext_uart_already_read_status;
uart_rstate_t uart_rstate;

async_receiver #(.ClkFrequency(50000000),.Baud(9600))   //接收模块，9600无检验位
    ext_uart_r(
        .clk(peri_clk),                                 //外部时钟信号
        .RxD(rxd),                                      //外部串行信号输入
        .RxD_data_ready(ext_uart_ready),                //数据接收到标志
        .RxD_clear(ext_uart_clear),                     //清除接收标志
        .RxD_data(ext_uart_rx)                          //接收到的一字节数据
    );

logic ext_uart_start, ext_uart_wavai, ext_uart_ravai, ext_uart_read_status, ext_uart_already_read_status;


always @(posedge peri_clk) begin
    if (reset_btn | ~rst) begin
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
        if (mem_addr[3:0] == 4'h8) begin
            ext_uart_start <= 1'b1;
        end
    end else begin
        ext_uart_start <= 1'b0;
    end
end

always @(*) begin
    if (mem_addr[3:0] == 4'hc) begin
        uart_rdata <= {30'b0, ext_uart_already_read_status^ext_uart_read_status, ~ext_uart_busy};
    end else if (mem_addr[3:0] == 4'h8) begin
        if (mem_ctrl_signal[3] & is_uart) begin
            ext_uart_tx <= mem_wdata[7:0];
        end else if (is_uart) begin
            uart_rdata <= {24'b0, ext_uart_buffer};
        end
    end
end

always @(posedge main_clk) begin                         //将缓冲区ext_uart_buffer发送出去
    if (reset_btn | ~rst) begin
        ext_uart_already_read_status <= 1'b0;
    end else if (is_uart & mem_ctrl_signal[2] && mem_addr[3:0] == 4'h8) begin
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