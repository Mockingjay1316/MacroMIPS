`include "common_defs.svh"

module alu_core (
    input   alu_op_t                    alu_op,                 //输入alu的指�?
    input   logic[`DATA_WIDTH-1:0]      operand1, operand2,

    output  logic[`DATA_WIDTH-1:0]      alu_result
);

logic[`DATA_WIDTH-1:0] res_add, res_sub;
assign res_add = operand1 + operand2;
assign res_sub = operand1 - operand2;

always @(*) begin
    case(alu_op)
        ALU_ADD:    alu_result <= res_add;
        ALU_SUB:    alu_result <= res_sub;
        ALU_AND:    alu_result <= operand1 & operand2;
        ALU_NOR:    alu_result <= ~(operand1 | operand2);
        ALU_OR:     alu_result <= operand1 | operand2;
        ALU_XOR:    alu_result <= operand1 ^ operand2;
        ALU_SLL:    alu_result <= operand2 << operand1[4:0];                
        ALU_SRL:    alu_result <= operand2 >> operand1[4:0];                
        ALU_SRA:    alu_result <= $signed(operand2) >>> operand1[4:0];      
        ALU_SLT:    alu_result <= (operand1[`DATA_WIDTH-1] != operand2[`DATA_WIDTH-1]) ?
                                    operand1[`DATA_WIDTH-1] : res_sub[`DATA_WIDTH-1];
        ALU_SLTU:   alu_result <= (operand1 < operand2) ? 1 : 0;
        ALU_NOP:    alu_result <= operand1;
        default: begin
            
        end
    endcase
end
    
endmodule