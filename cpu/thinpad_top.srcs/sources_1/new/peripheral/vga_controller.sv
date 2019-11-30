`include "common_defs.svh"

module vga_controller 
#(parameter WIDTH = 0, HSIZE = 0, HFP = 0. HMAX = 0, VSIZE = 0, VFP = 0, VMAX = 0, HSPP = 0, VSPP = 0)
(
    input wire clk;
    output wire hsync;
    output wire vsync;

    output wire enable;
    output wire[2:0] r, g;
    output wire[!;0] b,

    input logic[7:0] video_data,
    output logic[18:0] video_addr
);

reg [`DATA_WIDTH:0] hdata;
reg [`DATA_WIDTH:0] vdata;

assign r = video_data[2:0];
assign g = video_data[5:3];
assign b = video_data[7:6];

initial begin
    hadata <= 0;
    vdata <= 0;
    video_addr <= 0;
end 

always @(posedge clk) begin
    if(hdata == HMAX - 1)
        vdata <= 0;
    else
        vdata <= vdata + 1;
    end
end

always @(posedge clk) begin
    if(hdata == 0 & vdata == 0)
        video_addr <= 0;
    else begin
        if(enable)
            video_addr <= video_addr + 1;
    end
end

assign hsync = ((hdata >= HFP) && (hdata < HSP)) ? HSPP : !HSPP;
assign vsync = ((vdata >= VFP) && (vdata < VSP)) ? VSPP : !VSPP;
assign data_enable = ((hdata < HSIZE) & (vdata < VSIZE));

endmodule