`include "common_defs.svh"

module alu_core (
    input   alu_op_t                    alu_op,                 //输入alu的指令
    input   logic[`DATA_WIDTH-1:0]      operand1, operand2,
    input   hilo_op_t                   idex_hilo_op,

    output  hilo_op_t                   ex_hilo_op,
    output  logic[`DATA_WIDTH-1:0]      alu_result
);

logic[`DATA_WIDTH-1:0] res_add, res_sub;
logic[2*`DATA_WIDTH-1:0] res_multu;
assign res_add = operand1 + operand2;
assign res_sub = operand1 - operand2;
assign res_multu = operand1 * operand2;

always @(*) begin
    ex_hilo_op <= idex_hilo_op;
    case(alu_op)
        ALU_ADD:    alu_result <= res_add;
        ALU_SUB:    alu_result <= res_sub;
        ALU_AND:    alu_result <= operand1 & operand2;
        ALU_NOR:    alu_result <= ~(operand1 | operand2);
        ALU_OR:     alu_result <= operand1 | operand2;
        ALU_XOR:    alu_result <= operand1 ^ operand2;
        ALU_SLL:    alu_result <= operand2 << operand1[4:0];                //逻辑左移
        ALU_SRL:    alu_result <= operand2 >> operand1[4:0];                //逻辑右移
        ALU_SRA:    alu_result <= $signed(operand2) >>> operand1[4:0];      //算术右移
        ALU_SLT:    alu_result <= (operand1[`DATA_WIDTH-1] != operand2[`DATA_WIDTH-1]) ?
                                    operand1[`DATA_WIDTH-1] : res_sub[`DATA_WIDTH-1];
        ALU_SLTU:   alu_result <= (operand1 < operand2) ? 1 : 0;
        ALU_NOP:    alu_result <= operand1;
        ALU_MULTU:  begin
            ex_hilo_op.hilo_wval <= res_multu;
            ex_hilo_op.hilo_write_en <= 1'b1;
            end
        ALU_MULT:  begin
            if (operand1[31] ^ operand2[31] == 1'b1) begin
                ex_hilo_op.hilo_wval <= ~res_multu + 1;
            end else begin
                ex_hilo_op.hilo_wval <= res_multu;
            end
            ex_hilo_op.hilo_write_en <= 1'b1;
            end
        default: begin
            
        end
    endcase
end
    
endmodule