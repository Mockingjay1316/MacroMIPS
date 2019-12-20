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
/*
initial begin
    #2010;
    wr_en <= 1'b1;
    wr_hdata <= 0;
    wr_vdata <= 0;
    wr_data <= 0;
    forever begin
        #20;
        wr_hdata <= wr_hdata + 1;
        wr_data <= wr_data + 1;
    end
end
*/
logic[11:0] hdata, vdata, wr_hdata, wr_vdata;
logic[7:0] vga_out_data, wr_data;
logic wr_en;
assign video_red = hdata < 266 ? 3'b111 : 0; //红色竖条
assign video_green = hdata < 532 && hdata >= 266 ? 3'b111 : 0; //绿色竖条
assign video_blue = hdata >= 532 ? 2'b11 : 0; //蓝色竖条
assign video_clk = vga_clk;
//assign video_red   = vga_out_data[7:5];
//assign video_green = vga_out_data[4:2];
//assign video_blue  = vga_out_data[1:0];

vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at75 (
    .clk(vga_clk), 
    .hdata(hdata), //横坐标
    .vdata(vdata), //纵坐标
    .hsync(video_hsync),
    .vsync(video_vsync),
    .data_enable(video_de)
);
/*
vga_buff v_buff (
    .clk(peri_clk),
    .hdata,
    .vdata,
    .data_out(vga_out_data),
    .wr_en,
    .wr_hdata,
    .wr_vdata,
    .wr_data
);
*/
endmodule