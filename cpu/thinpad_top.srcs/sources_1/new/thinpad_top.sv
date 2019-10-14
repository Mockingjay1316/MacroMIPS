`include "common_defs.svh"

module thinpad_top(
    input   wire       clk_50M,            //50MHz 时钟输入
    input   wire       clk_11M0592,        //11.0592MHz 时钟输入

    input   wire       clock_btn,          //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input   wire       reset_btn,          //BTN6手动复位按钮开关，带消抖电路，按下时为1

    input   wire[3:0]  touch_btn,          //BTN1~BTN4，按钮开关，按下时为1
    input   wire[31:0] dip_sw,             //32位拨码开关，拨到“ON”时为1
    output  wire[15:0] leds,               //16位LED，输出时1点亮
    output  wire[7:0]  dpy0,               //数码管低位信号，包括小数点，输出1点亮
    output  wire[7:0]  dpy1,               //数码管高位信号，包括小数点，输出1点亮

    //CPLD串口控制器信号
    output  wire       uart_rdn,           //读串口信号，低有效
    output  wire       uart_wrn,           //写串口信号，低有效
    input   wire       uart_dataready,     //串口数据准备好
    input   wire       uart_tbre,          //发送数据标志
    input   wire       uart_tsre,          //数据发送完毕标志

    //BaseRAM信号
    inout   wire[31:0] base_ram_data,      //BaseRAM数据，低8位与CPLD串口控制器共享
    output  wire[19:0] base_ram_addr,      //BaseRAM地址
    output  wire[3:0]  base_ram_be_n,      //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output  wire       base_ram_ce_n,      //BaseRAM片选，低有效
    output  wire       base_ram_oe_n,      //BaseRAM读使能，低有效
    output  wire       base_ram_we_n,      //BaseRAM写使能，低有效

    //ExtRAM信号
    inout   wire[31:0] ext_ram_data,       //ExtRAM数据
    output  wire[19:0] ext_ram_addr,       //ExtRAM地址
    output  wire[3:0]  ext_ram_be_n,       //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output  wire       ext_ram_ce_n,       //ExtRAM片选，低有效
    output  wire       ext_ram_oe_n,       //ExtRAM读使能，低有效
    output  wire       ext_ram_we_n,       //ExtRAM写使能，低有效

    //直连串口信号
    output  wire       txd,                //直连串口发送端
    input   wire       rxd,                //直连串口接收端

    //Flash存储器信号，参考 JS28F640 芯片手册
    output  wire[22:0] flash_a,            //Flash地址，a0仅在8bit模式有效，16bit模式无意义
    inout   wire[15:0] flash_d,            //Flash数据
    output  wire       flash_rp_n,         //Flash复位信号，低有效
    output  wire       flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧写
    output  wire       flash_ce_n,         //Flash片选信号，低有效
    output  wire       flash_oe_n,         //Flash读使能信号，低有效
    output  wire       flash_we_n,         //Flash写使能信号，低有效
    output  wire       flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1

    //USB 控制器信号，参考 SL811 芯片手册
    output  wire       sl811_a0,
    //inout  logic[7:0] sl811_d,            //USB数据线与网络控制器的dm9k_sd[7:0]共享
    output  wire       sl811_wr_n,
    output  wire       sl811_rd_n,
    output  wire       sl811_cs_n,
    output  wire       sl811_rst_n,
    output  wire       sl811_dack_n,
    input   wire       sl811_intrq,
    input   wire       sl811_drq_n,

    //网络控制器信号，参考 DM9000A 芯片手册
    output  wire       dm9k_cmd,
    inout   wire[15:0] dm9k_sd,
    output  wire       dm9k_iow_n,
    output  wire       dm9k_ior_n,
    output  wire       dm9k_cs_n,
    output  wire       dm9k_pwrst_n,
    input   wire       dm9k_int,

    //图像输出信号
    output  wire[2:0]  video_red,          //红色像素，3位
    output  wire[2:0]  video_green,        //绿色像素，3位
    output  wire[1:0]  video_blue,         //蓝色像素，2位
    output  wire       video_hsync,        //行同步（水平同步）信号
    output  wire       video_vsync,        //场同步（垂直同步）信号
    output  wire       video_clk,          //像素时钟输出
    output  wire       video_de            //行数据有效信号，用于区分消隐区
);

logic rst, peri_clk, bus_clk, main_clk;
logic[`INST_WIDTH-1:0] instr;
logic[`ADDR_WIDTH-1:0] pc, mem_addr;
logic[`DATA_WIDTH-1:0] mem_wdata, sram_rdata, uart_rdata, reg_out, mem_rdata;
logic[4:0] mem_ctrl_signal;
logic is_uart, mem_stall;

main_pll pll (
    .clk_in1(clk_50M),
    .clk_out1(bus_clk),
    .clk_out2(peri_clk),
    .clk_out3(main_clk),
    .locked(rst)
);

cpu_core cpu (
    .clk_50M(main_clk),
    .clk_11M0592(clk_11M0592),

    .clock_btn(clock_btn),
    .reset_btn(reset_btn | ~rst),
    .mem_stall(mem_stall),

    .leds(leds),
    .dpy0(dpy0),
    .dpy1(dpy1),

    .pc_out(pc),
    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .reg_out(reg_out),
    .mem_rdata(mem_rdata),
    .mem_ctrl_signal(mem_ctrl_signal),
    .is_uart(is_uart),
    .instruction(instr)
);

sram_controller sram_ctrl (
    .main_clk(main_clk),
    .peri_clk(peri_clk),
    .rst(~rst),
    .pc(pc),
    .instr_read(instr),
    .data_write_en(mem_ctrl_signal[3]),
    .load_from_mem(mem_ctrl_signal[4]),
    .is_data_read(mem_ctrl_signal[2]),
    .mem_byte_en(mem_ctrl_signal[1]),
    .mem_sign_ext(mem_ctrl_signal[0]),
    .data_addr(mem_addr),
    .data_write(mem_wdata),
    .data_read(sram_rdata),
    .mem_stall(mem_stall),

    .base_ram_data(base_ram_data),
    .base_ram_addr(base_ram_addr),
    .base_ram_be_n(base_ram_be_n),
    .base_ram_ce_n(base_ram_ce_n),
    .base_ram_oe_n(base_ram_oe_n),
    .base_ram_we_n(base_ram_we_n),

    .ext_ram_data(ext_ram_data),
    .ext_ram_addr(ext_ram_addr),
    .ext_ram_be_n(ext_ram_be_n),
    .ext_ram_ce_n(ext_ram_ce_n),
    .ext_ram_oe_n(ext_ram_oe_n),
    .ext_ram_we_n(ext_ram_we_n)
);

ila_0 ila (
    .clk(main_clk),
    .probe0(is_uart),
    .probe1(ext_uart_busy),
    .probe2(mem_rdata),
    .probe3(uart_rdata),
    .probe4(ext_uart_wavai),
    .probe5(ext_uart_start),
    .probe6(ext_uart_tx),
    .probe7(mem_stall),
    .probe8(mem_ctrl_signal),
    .probe9(pc),
    .probe10(mem_addr),
    .probe11(reg_out),
    .probe12(instr)
);

assign mem_rdata = is_uart ? uart_rdata : sram_rdata;

//直连串口接收发送演示，从直连串口收到的数据再发送出去
logic[7:0] ext_uart_rx;
logic[7:0] ext_uart_buffer, ext_uart_tx;
logic ext_uart_ready, ext_uart_busy;
logic ext_uart_start, ext_uart_wavai, ext_uart_ravai, ext_uart_read_status, ext_uart_already_read_status;

async_receiver #(.ClkFrequency(60000000),.Baud(9600))   //接收模块，9600无检验位
    ext_uart_r(
        .clk(peri_clk),                                 //外部时钟信号
        .RxD(rxd),                                      //外部串行信号输入
        .RxD_data_ready(ext_uart_ready),                //数据接收到标志
        .RxD_clear(ext_uart_ready),                     //清除接收标志
        .RxD_data(ext_uart_rx)                          //接收到的一字节数据
    );

assign ext_uart_wavai = mem_ctrl_signal[3] & is_uart;
logic[1:0] counter;

always @(posedge ext_uart_ready) begin                         //接收到缓冲区ext_uart_buffer
    if (reset_btn) begin
        ext_uart_read_status <= 1'b0;
    end else begin
        ext_uart_read_status <= ~ext_uart_read_status;
        ext_uart_buffer <= ext_uart_rx;
    end
end

always @(posedge peri_clk) begin                         //将缓冲区ext_uart_buffer发送出去
    if (!ext_uart_busy && ext_uart_wavai) begin
        ext_uart_start <= 1;
    end else begin
        ext_uart_start <= 0;
    end
end

always @(*) begin
    if (mem_addr[3:0] == 4'hc) begin
        uart_rdata <= {30'b0, ext_uart_already_read_status^ext_uart_read_status, ~ext_uart_busy};
    end else if (mem_addr[3:0] == 4'h8) begin
        if (mem_ctrl_signal[3] & is_uart) begin
            //ext_uart_wavai <= 1;
            ext_uart_tx <= mem_wdata[7:0];
        end else begin
            ext_uart_already_read_status <= ext_uart_read_status;
            uart_rdata <= {24'b0, ext_uart_buffer};
        end
    end
end

async_transmitter #(.ClkFrequency(60000000),.Baud(9600)) //发送模块，9600无检验位
    ext_uart_t(
        .clk(peri_clk),                                 //外部时钟信号
        .TxD(txd),                                      //串行信号输出
        .TxD_busy(ext_uart_busy),                       //发送器忙状态指示
        .TxD_start(ext_uart_start),                     //开始发送信号
        .TxD_data(ext_uart_tx)                          //待发送的数据
    );

endmodule
