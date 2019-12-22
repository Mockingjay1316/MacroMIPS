`include "common_defs.svh"

module vga_buff (
    input   logic           clk, r_clk,
    input   logic[11:0]     hdata, vdata,
    input   logic[11:0]     wr_hdata, wr_vdata,
    input   logic[19:0]     wloc_in,
    input   logic           wr_en, loc_from_in,
    input   logic[7:0]      wr_data,
    output  logic[7:0]      data_out
);

logic[19:0] rloc, wloc;
assign rloc = hdata + 800 * vdata;
assign wloc = loc_from_in ? wloc_in : wr_hdata + 800 * wr_vdata;
/*
logic[63:0] rdata, wdata, read_wdata;

frame_buff f_buf (
    .clk,
    .we(wr_en),
    .a(wloc >> 3),
    .d(wdata),
    .dpra(rloc >> 3),
    .spo(read_wdata),
    .dpo(rdata)
);

always_comb begin
    wdata <= read_wdata;
    case(rloc[2:0])
        3'b000: data_out <= rdata[7:0];
        3'b001: data_out <= rdata[15:8];
        3'b010: data_out <= rdata[23:16];
        3'b011: data_out <= rdata[31:24];
        3'b100: data_out <= rdata[39:32];
        3'b101: data_out <= rdata[47:40];
        3'b110: data_out <= rdata[55:48];
        3'b111: data_out <= rdata[63:56];
    endcase
    case(wloc[2:0])
        3'b000: wdata[7:0]   <= wr_data;
        3'b001: wdata[15:8]  <= wr_data;
        3'b010: wdata[23:16] <= wr_data;
        3'b011: wdata[31:24] <= wr_data;
        3'b100: wdata[39:32] <= wr_data;
        3'b101: wdata[47:40] <= wr_data;
        3'b110: wdata[55:48] <= wr_data;
        3'b111: wdata[63:56] <= wr_data;
    endcase
end
*/

blk_frame_buff f_buff (
    .addra(wloc),
    .clka(clk),
    .dina(wr_data),
    .ena(1'b1),
    .wea(wr_en),
    .addrb(rloc),
    .clkb(r_clk),
    .doutb(data_out)
);

endmodule