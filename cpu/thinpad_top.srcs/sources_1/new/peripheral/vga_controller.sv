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
// 0x82090000 - 0x820904b0      video out 40  x 30
// 0x820a0000 - 0x820a1d4c      video out 100 x 75

vga_mode_t vga_mode;

always @(posedge peri_clk) begin
    if (rst) begin
        vga_mode <= VGA_CLI;
    end
    if (data_addr == 32'h82075300 && data_write_en) begin        //写控制寄存器
        case (data_write[7:0])
            8'd0:       vga_mode <= VGA_CLI;
            8'd1:       vga_mode <= VGA_TOWER;
            8'd2:       vga_mode <= VGA_PCLOGO;
            8'd3:       vga_mode <= VGA_V4030;
            8'd4:       vga_mode <= VGA_V10075;
            default:    vga_mode <= VGA_CLI;
        endcase
    end
end

logic[11:0] hdata, vdata, wr_hdata, wr_vdata;
logic[7:0] vga_out_data, wr_data;
logic wr_en, cli_wr_en, tower_wr_en, video4030_wr_en, video10075_wr_en;
logic loc_from_in;
logic[11:0] cli_hdata, cli_vdata;
logic[7:0] cli_data_out;
logic[11:0] tower_hdata, tower_vdata;
logic[7:0] tower_data_out;
logic[11:0] video4030_hdata, video4030_vdata;
logic[7:0] video4030_data_out;
logic[11:0] video10075_hdata, video10075_vdata;
logic[7:0] video10075_data_out;
logic[19:0] wloc_in;
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
    video4030_wr_en <= (data_write_en && data_addr >= 32'h82090000 && data_addr < 32'h820904b0);
    video10075_wr_en <= (data_write_en && data_addr >= 32'h820a0000 && data_addr < 32'h820a1d4c);
    loc_from_in <= 1'b0;
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
        VGA_PCLOGO: begin
            wr_en <= data_write_en && (data_addr >= 32'h82000000 && data_addr < 32'h82075300);
            loc_from_in <= 1'b1;
            wloc_in  <= data_addr[19:0];
            wr_data  <= data_write[7:0];
            end
        VGA_V4030: begin
            wr_en <= 1'b1;
            wr_hdata <= video4030_hdata;
            wr_vdata <= video4030_vdata;
            wr_data  <= video4030_data_out;
            end
        VGA_V10075: begin
            wr_en <= 1'b1;
            wr_hdata <= video10075_hdata;
            wr_vdata <= video10075_vdata;
            wr_data  <= video10075_data_out;
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
    .loc_from_in,
    .wr_en,
    .wloc_in,
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

v4030_buff v4030_buff_r (
    .clk(main_shift_clk),
    .rst,
    .wr_clk(main_shift_clk),
    .wr_en(video4030_wr_en),
    .wdata(data_write),
    .waddr(data_addr),
    .video4030_hdata,
    .video4030_vdata,
    .data_out(video4030_data_out)
);

v10075_buff v10075_buff_r (
    .clk(main_shift_clk),
    .rst,
    .wr_clk(main_shift_clk),
    .wr_en(video10075_wr_en),
    .wdata(data_write),
    .waddr(data_addr),
    .video10075_hdata,
    .video10075_vdata,
    .data_out(video10075_data_out)
);

endmodule