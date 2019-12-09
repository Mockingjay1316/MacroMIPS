`include "common_defs.svh"

module uart_controller (
    input  logic peri_clk, main_clk, reset_btn, rst,
    input  logic[`ADDR_WIDTH-1:0] mem_addr,
    input  logic[`DATA_WIDTH-1:0] uart_wdata,
    input  logic[4:0] mem_ctrl_signal,
    output logic[`DATA_WIDTH-1:0] uart_rdata,

    input logic rxd,
    output logic txd,
    output[5:0]  hardware_int
);

logic[7:0] ext_uart_rx;
logic[7:0] ext_uart_buffer, ext_uart_tx;
logic ext_uart_ready, ext_uart_busy, ext_uart_clear;
logic ext_uart_start, ext_uart_read_status, ext_uart_already_read_status;
uart_rstate_t uart_rstate;


logic is_write_data, is_read_data;
wire rxd, txd;

assign hardware_int = {3'b000, ext_uart_already_read_status^ext_uart_read_status, 2'b00};

assign is_write_data = mem_ctrl_signal[3];
assign is_read_data = mem_ctrl_signal[2];

async_receiver #(.ClkFrequency(50000000),.Baud(9600))   //接收模块�??9600无检验位
    ext_uart_r(
        .clk(peri_clk),                                 //外部时钟信号
        .RxD(rxd),                                      //外部串行信号输入
        .RxD_data_ready(ext_uart_ready),                //数据接收到标�??
        .RxD_clear(ext_uart_clear),                     //清除接收标志
        .RxD_data(ext_uart_rx)                          //接收到的�??字节数据
    );

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


always @(posedge peri_clk) begin                         //将缓冲区ext_uart_buffer发�?�出�??
    if (!ext_uart_busy && is_write_data) begin
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
        if (is_write_data) begin
            ext_uart_tx <= uart_wdata[7:0];
        end else begin
            uart_rdata <= {24'b0, ext_uart_buffer};
        end
    end
end

always @(posedge main_clk) begin                         //将缓冲区ext_uart_buffer发�?�出�??
    if (reset_btn | ~rst) begin
        ext_uart_already_read_status <= 1'b0;
    end else if (is_read_data && mem_addr[3:0] == 4'h8) begin
        ext_uart_already_read_status <= ext_uart_read_status;
    end
end

async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //发�?�模块，9600无检验位
    ext_uart_t(
        .clk(peri_clk),                                 //外部时钟信号
        .TxD(txd),                                      //串行信号输出
        .TxD_busy(ext_uart_busy),                       //发�?�器忙状态指�??
        .TxD_start(ext_uart_start),                     //�??始发送信�??
        .TxD_data(ext_uart_tx)                          //待发送的数据
    );

endmodule