`include "cpu_defs.vh"

module alu_core #(
    parameter DATA_WIDTH = 32
)(
    input   wire[4:0]               op_code,
    input   wire[DATA_WIDTH-1:0]    operand1, operand2,
    output  wire[DATA_WIDTH-1:0]    result,
    output  reg                     flag_zero, flag_sign
);

wire[DATA_WIDTH-1:0] add_res, sub_res;
assign add_res = operand1 + operand2;
assign sub_res = operand1 - operand2;

reg[DATA_WIDTH-1:0] t_result;
assign result = t_result;

always @(op_code or operand1 or operand2) begin
    case (op_code)
        `OP_ADD : t_result = add_res;
        `OP_SUB : t_result = sub_res;
        `OP_AND : t_result = operand1 & operand2;
        `OP_OR  : t_result = operand1 | operand2;
        `OP_XOR : t_result = operand1 ^ operand2;
        `OP_SLL : t_result = operand1 << operand2[4:0];
        `OP_SRL : t_result = operand1 >> operand2[4:0];
        `OP_SRA : t_result = $signed(operand1) >>> operand2[4:0];
    endcase
end

always @(t_result) begin
    if (t_result === 0) begin
        flag_zero = 1;
    end else begin
        flag_zero = 0;
    end

    if (t_result[DATA_WIDTH-1]) begin
        flag_sign = 1;
    end else begin
        flag_sign = 0;
    end
end

endmodule
