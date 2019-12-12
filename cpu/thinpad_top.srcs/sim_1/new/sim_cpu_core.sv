`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/06 16:02:41
// Design Name: 
// Module Name: sim_cpu_core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "common_defs.svh"

module sim_cpu_core(

);

logic clk_50M, rst, peri_clk, mem_stall;
logic[`INST_WIDTH-1:0] instr;
logic[`ADDR_WIDTH-1:0] pc, mem_addr;
logic[`DATA_WIDTH-1:0] mem_wdata, mem_rdata;
logic[4:0] mem_ctrl_signal;

initial begin
    //rst = 1'b1;
    clk_50M = 1'b0; # 10;
    clk_50M = 1'b1; # 10;
    //rst = 1'b0;
    forever begin
        clk_50M = ~clk_50M; # 10;
    end
end

initial begin
    instr = {32'h000000000}; #20;
    #1730;
    //instr = {`OP_LUI, 5'b00000, 5'b00001, 16'd23300}; #20;
    instr = {`OP_ORI, 5'b00000, 5'b00001, 16'd23300}; #20;
    //instr = {`OP_ORI, 5'b00000, 5'b00010, 16'd34467}; #20;
    //instr = {`OP_ORI, 5'b00001, 5'b00010, 16'h0042}; #20;
    //instr = {`OP_SPECIAL, 5'b00010, 5'b00001, 5'b00000, 5'b00000, `FUNCT_MULTU}; #20;
    //instr = {`OP_ORI, 5'b00000, 5'b00001, 16'h0002}; #20;
    //instr = {`OP_SPECIAL, 5'b00000, 5'b00000, 5'b00011, 5'b00000, `FUNCT_MFLO}; #20;
    //instr = {`OP_ORI, 5'b00000, 5'b00001, 16'h0002}; #20;
    //instr = {`OP_ORI, 5'b00000, 5'b00010, 16'h0002}; #20;
    instr = {`OP_COP0, 5'b00100, 5'b00001, 5'd14, 11'd0}; #20;
    instr = {32'h000000000}; #20;
    //instr = {32'h000000000}; #20;
    instr = {`OP_COP0, 1'b1, 19'd0, `FUNCT_ERET}; #20;
    instr = {32'h000000000}; #20;
    //instr = {`OP_ORI, 5'b00000, 5'b00101, 16'h0002}; #20;
    //instr = {`OP_ORI, 5'b00000, 5'b00110, 16'h0002}; #20;
    //instr = {`OP_LB, 5'b00000, 5'b00001, 16'hFF0F}; #20;
    //instr = {`OP_LBU, 5'b00000, 5'b00011, 16'hFFFF}; #20;
    //instr = {`OP_JAL, 5'b00000, 5'b00101, 16'h7FFF}; #20;
    //instr = {`OP_SPECIAL, 5'b00101, 5'b00001, 5'b00001, 5'b00000, `FUNCT_ADDU}; #20;
    //instr = {`OP_SPECIAL, 5'b11111, 5'b00000, 5'b00010, 5'b00000, `FUNCT_JALR}; #20;
    //instr = {`OP_SPECIAL, 5'b00101, 5'b00001, 5'b00001, 5'b00000, `FUNCT_ADDU}; #20;
end

main_pll pll (
    .clk_in1(clk_50M),
    .clk_out2(peri_clk),
    .locked(rst)
);

cpu_core cpu (
    .instruction(instr),
    .clk_50M(clk_50M),
    .reset_btn(~rst),
    .pc_out(pc),

    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .mem_rdata(mem_rdata),
    .mem_ctrl_signal(mem_ctrl_signal),
    .mem_stall(mem_stall)
);

sram_controller sram_ctrl (
    .main_clk(clk_50M),
    .peri_clk(peri_clk),
    .rst(~rst),
    .pc(pc),
    //.instr_read(instr),
    .data_write_en(mem_ctrl_signal[3]),
    .is_data_read(mem_ctrl_signal[2]),
    .mem_byte_en(mem_ctrl_signal[1]),
    .mem_sign_ext(mem_ctrl_signal[0]),
    .data_addr(mem_addr),
    .data_write(mem_wdata),
    .data_read(mem_rdata),
    .mem_stall(mem_stall)
);

endmodule
