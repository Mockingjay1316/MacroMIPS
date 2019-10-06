`include "common_defs.svh"

module control_unit (
    input   logic[`INST_WIDTH-1:0]      instr,
    input   logic[`DATA_WIDTH-1:0]      reg_rdata1, reg_rdata2,     //为了进行分支判断

    output  logic[`DATA_WIDTH-1:0]      operand1, operand2,
    output  logic[`REGID_WIDTH-1:0]     reg_raddr1, reg_raddr2, reg_waddr,
    output  logic                       reg_write_en,
    output  alu_op_t                    alu_op                      //解析出来的alu指令
);

logic[5:0]  funct, op;
logic[15:0] imm_unext;
assign reg_raddr1 = instr[25:21];
assign reg_raddr2 = instr[20:16];
assign imm_unext = instr[15:0];
assign funct = instr[31:26];
assign op = instr[5:0];

always @(*) begin
    case(funct)
        `FUNCT_ORI: begin
            alu_op <= ALU_OR;                               //alu进行OR的操作
            operand1 <= reg_rdata1;                         //第一个操作数是寄存器
            operand2 <= {16'h0, imm_unext[15:0]};           //ORI对立即数进行的是0拓展
            reg_waddr <= reg_raddr2;
            reg_write_en <= 1'b1;                           //这个指令需要写寄存器
        end
        default: begin
            
        end
    endcase
end

endmodule