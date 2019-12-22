`include "common_defs.svh"

module v10075_buff (
    input   logic           clk, rst, wr_clk,
    input   logic[31:0]     wdata, waddr,
    input   logic           wr_en,
    output  logic[11:0]     video10075_hdata, video10075_vdata,
    output  logic[7:0]      data_out
);

logic[10:0] out_hptr, out_vptr;
logic[10:0] out_hptr_l1, out_vptr_l1;
logic[12:0] wloc, rloc;
assign wloc = waddr - 32'h820a0000;
assign rloc = out_hptr + 100 * out_vptr;

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
        if (hbit != 7) begin
            hbit <= hbit + 1;
        end else begin
            hbit <= 0;
            if (vbit != 7) begin
                vbit <= vbit + 1;
            end else begin
                vbit <= 0;
                if (out_hptr != 99) begin
                    out_hptr <= out_hptr + 1;
                end else begin
                    out_hptr <= 0;
                    if (out_vptr != 74) begin
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
    video10075_hdata <= out_hptr * 8 + hbit;
    video10075_vdata <= out_vptr * 8 + vbit;
end

logic rpix;
video10075_buff v_buff (
    .a(wloc),
    .d(wdata[0]),
    .dpra(rloc),
    .clk(wr_clk),
    .we(wr_en),
    .dpo(rpix)
);

assign data_out = rpix ? 8'hff : 8'h00;

endmodule