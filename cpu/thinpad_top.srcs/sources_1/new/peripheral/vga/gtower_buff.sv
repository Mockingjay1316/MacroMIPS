`include "common_defs.svh"

module gtower_buff (
    input   logic           clk, rst, wr_clk,
    input   logic[31:0]     wdata, waddr,
    input   logic           wr_en,
    output  logic[11:0]     tower_hdata, tower_vdata,
    output  logic[7:0]      data_out
);

logic[10:0] out_hptr, out_vptr;
logic[10:0] out_hptr_l1, out_vptr_l1;
logic[8:0] wloc, rloc;
assign wloc = waddr - 32'h82080000;
assign rloc = out_hptr + 20 * out_vptr;

logic[5:0] hbit, vbit;
logic[5:0] hbit_l1, vbit_l1;

always @(posedge clk) begin
    if (rst) begin
        out_hptr <= 0;
        out_vptr <= 0;
        hbit <= 0;
        vbit <= 0;
        out_hptr_l1 <= 0;
        out_vptr_l1 <= 0;
        hbit_l1 <= 0;
        vbit_l1 <= 0;
    end else begin
        hbit_l1 <= hbit;
        vbit_l1 <= vbit;
        out_hptr_l1 <= out_hptr;
        out_vptr_l1 <= out_vptr;
        if (hbit != 39) begin
            hbit <= hbit + 1;
        end else begin
            hbit <= 0;
            if (vbit != 39) begin
                vbit <= vbit + 1;
            end else begin
                vbit <= 0;
                if (out_hptr != 19) begin
                    out_hptr <= out_hptr + 1;
                end else begin
                    out_hptr <= 0;
                    if (out_vptr != 14) begin
                        out_vptr <= out_vptr + 1;
                    end else begin
                        out_vptr <= 0;
                    end
                end
            end
        end
    end
end

always_comb begin
    tower_hdata <= out_hptr_l1 * 40 + hbit_l1;
    tower_vdata <= out_vptr_l1 * 40 + vbit_l1;
end

logic[5:0] r_id;
tower_buff t_buff (
    .a(wloc),
    .d(wdata[5:0]),
    .dpra(rloc),
    .clk(wr_clk),
    .we(wr_en),
    .dpo(r_id)
);

logic[7:0] loc_color;
logic[15:0] bitmap_loc;
assign bitmap_loc = r_id * 1600 + hbit + 40 * vbit;
assign data_out = loc_color;

blk_tower_bitmap tower_bitmap (
    .addra(bitmap_loc),
    .clka(clk),
    .douta(loc_color)
);

endmodule