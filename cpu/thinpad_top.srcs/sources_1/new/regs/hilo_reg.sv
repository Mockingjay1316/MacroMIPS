`include "common_defs.svh"

module hilo_reg (
    input   logic       clk, rst,
    input   hilo_op_t   hilo_op,
    output  logic[31:0] hi_out, lo_out
);

always @ (posedge clk) begin
    if (rst) begin
        hi_out <= 32'h00000000;
        lo_out <= 32'h00000000;
    end else if (hilo_op.hilo_write_en) begin
        hi_out <= hilo_op.hilo_wval[63:32];
        lo_out <= hilo_op.hilo_wval[31:0];
    end else begin
        hi_out <= hi_out;
        lo_out <= lo_out;
    end
end

endmodule