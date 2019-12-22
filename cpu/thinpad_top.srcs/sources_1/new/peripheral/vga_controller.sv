`include "common_defs.svh"

module vga_controller (
    input   logic       main_clk, rst,
    input   logic       peri_clk, main_shift_clk,
    input   logic       vga_clk,
    input   logic       vga_en,
    input   logic       load_from_mem,
    input   logic       is_data_read,       //1表示读数据，0表示写数据
    input   logic       data_write_en,
    input   logic       mem_byte_en,
    input   logic       mem_sign_ext,
    input   logic[31:0] data_addr,
    input   logic[31:0] data_write,
    output  logic       mem_stall,

    //图像输出信号
    output  logic[2:0]  video_red,          //红色像素，3位
    output  logic[2:0]  video_green,        //绿色像素，3位
    output  logic[1:0]  video_blue,         //蓝色像素，2位
    output  logic       video_hsync,        //行同步（水平同步）信号
    output  logic       video_vsync,        //场同步（垂直同步）信号
    output  logic       video_clk,          //像素时钟输出
    output  logic       video_de            //行数据有效信号，用于区分消隐区
);

// 0x82000000 - 0x820752ff      frame buffer data
// 0x82075300                   control reg
// 0x82080000 - 0x8208012c      tower map

vga_mode_t vga_mode;

always @(posedge peri_clk) begin
    if (rst) begin
        vga_mode <= VGA_CLI;
    end
    if (data_addr == 32'h82075300) begin        //写控制寄存器
        case (data_write[7:0])
            8'd0:       vga_mode <= VGA_CLI;
            8'd1:       vga_mode <= VGA_TOWER;
            default:    vga_mode <= VGA_CLI;
        endcase
    end
end

logic[11:0] hdata, vdata, wr_hdata, wr_vdata;
logic[7:0] vga_out_data, wr_data;
logic wr_en, cli_wr_en, tower_wr_en;
logic[11:0] cli_hdata, cli_vdata;
logic[7:0] cli_data_out;
logic[11:0] tower_hdata, tower_vdata;
logic[7:0] tower_data_out;
//assign video_red = hdata < 266 ? 3'b111 : 0; //红色竖条
//assign video_green = hdata < 532 && hdata >= 266 ? 3'b111 : 0; //绿色竖条
//assign video_blue = hdata >= 532 ? 2'b11 : 0; //蓝色竖条
assign video_clk = vga_clk;
assign video_red   = vga_out_data[7:5];
assign video_green = vga_out_data[4:2];
assign video_blue  = vga_out_data[1:0];

always_comb begin
    cli_wr_en <= (data_write_en && data_addr == 32'hbfd003f8);
    tower_wr_en <= (data_write_en && data_addr >= 32'h82080000 && data_addr < 32'h8208012c);
    case(vga_mode)
        VGA_CLI: begin
            wr_en <= 1'b1;
            wr_hdata <= cli_hdata;
            wr_vdata <= cli_vdata;
            wr_data  <= cli_data_out;
            end
        VGA_TOWER: begin
            wr_en <= 1'b1;
            wr_hdata <= tower_hdata;
            wr_vdata <= tower_vdata;
            wr_data  <= tower_data_out;
            end
        default: begin end
    endcase
end

vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at75 (
    .clk(vga_clk),
    .hdata(hdata), //横坐标
    .vdata(vdata), //纵坐标
    .hsync(video_hsync),
    .vsync(video_vsync),
    .data_enable(video_de)
);

vga_buff v_buff (
    .clk(main_shift_clk),
    .r_clk(peri_clk),
    .hdata,
    .vdata,
    .data_out(vga_out_data),
    .wr_en,
    .wr_hdata,
    .wr_vdata,
    .wr_data
);

cmd_buff cmd_buff_r (
    .clk(main_shift_clk),
    .rst,
    .wr_clk(main_shift_clk),
    .wr_en(cli_wr_en),
    .wdata(data_write),
    .cli_hdata,
    .cli_vdata,
    .data_out(cli_data_out)
);

gtower_buff gtower_buff_r (
    .clk(main_shift_clk),
    .rst,
    .wr_clk(main_shift_clk),
    .wr_en(tower_wr_en),
    .wdata(data_write),
    .waddr(data_addr),
    .tower_hdata,
    .tower_vdata,
    .data_out(tower_data_out)
);

endmodule