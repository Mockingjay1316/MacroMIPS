`include "common_defs.svh"

module alu_core (
    input   alu_op_t                    alu_op,                 //输入alu的指令
    input   logic[`DATA_WIDTH-1:0]      operand1, operand2,

    output  logic[`DATA_WIDTH-1:0]      alu_result
);

logic[`DATA_WIDTH-1:0] res_add, res_sub;
assign res_add = operand1 + operand2;
assign res_sub = operand1 - operand2;

always @(*) begin
    case(alu_op)
        ALU_OR: alu_result <= operand1 | operand2;
        default: begin
            
        end
    endcase
end
    
endmodule