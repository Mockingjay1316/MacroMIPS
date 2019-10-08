`include "common_defs.svh"

module control_unit (
    input   logic[`INST_WIDTH-1:0]      instr,
    input   logic[`DATA_WIDTH-1:0]      reg_rdata1, reg_rdata2,     //从寄存器堆的输入，并非真的操作数（可能数据旁通）

    input   logic[`REGID_WIDTH-1:0]     ex_reg_waddr,               //数据旁通返回的结果，ex段
    input   logic[`DATA_WIDTH-1:0]      ex_alu_result,
    input   logic                       ex_reg_write_en,
    input   logic[`REGID_WIDTH-1:0]     mem_reg_waddr,              //数据旁通返回的结果，mem段
    input   logic[`DATA_WIDTH-1:0]      mem_reg_wdata,
    input   logic                       mem_reg_write_en,

    output  logic[`DATA_WIDTH-1:0]      operand1, operand2,         //送往ALU的操作数
    output  logic[`REGID_WIDTH-1:0]     reg_raddr1, reg_raddr2, reg_waddr,
    output  logic                       reg_write_en,
    output  alu_op_t                    alu_op,                     //解析出来的alu指令

    input   logic[`ADDR_WIDTH-1:0]      old_pc,
    output  logic                       is_branch,                  //是否执行分支转移
    output  logic[`ADDR_WIDTH-1:0]      new_pc                      //转移到的新的PC
);

logic[5:0]  funct, op;
logic[15:0] imm_unext;
logic[4:0]  sa;
assign reg_raddr1 = instr[25:21];
assign reg_raddr2 = instr[20:16];
assign imm_unext = instr[15:0];
assign funct = instr[31:26];
assign op = instr[5:0];
assign sa = instr[10:6];

logic[`ADDR_WIDTH-1:0] branch_new_pc;
logic[`DATA_WIDTH-1:0] rdata1, rdata2;

assign branch_new_pc = {{14{imm_unext[15]}}, imm_unext[15:0], 2'b00} + old_pc + 3'b100;

always @(*) begin
    if ((reg_raddr1 === ex_reg_waddr)
        && (ex_reg_write_en === 1'b1)) begin
        rdata1 <= ex_alu_result;
    end else if ((reg_raddr1 === mem_reg_waddr)
        && (mem_reg_write_en === 1'b1)) begin
        rdata1 <= mem_reg_wdata;
    end else begin
        rdata1 <= reg_rdata1;
    end

    if ((reg_raddr2 === ex_reg_waddr)
        && (ex_reg_write_en === 1'b1)) begin
        rdata2 <= ex_alu_result;
    end else if ((reg_raddr2 === mem_reg_waddr)
        && (mem_reg_write_en === 1'b1)) begin
        rdata2 <= mem_reg_wdata;
    end else begin
        rdata2 <= reg_rdata2;
    end
end

logic branch_result;
branch_op_t branch_op;
branch_res branch_res_r (
    .branch_op(branch_op),
    .operand1(rdata1),
    .operand2(rdata2),
    .branch_result(branch_result)
);

always @(*) begin
    reg_write_en <= 1'b0;
    is_branch <= 1'b0;
    case(funct)
        /****************   Immediate   ********************/
        `FUNCT_ADDIU: begin                                 //ADDIU
            alu_op <= ALU_ADD;
            operand1 <= rdata1;
            operand2 <= {{16{imm_unext[15]}}, imm_unext[15:0]};
            reg_waddr <= reg_raddr2;
            reg_write_en <= 1'b1;
            end
        `FUNCT_SLTI: begin                                  //SLTI
            alu_op <= ALU_SLT;
            operand1 <= rdata1;
            operand2 <= {{16{imm_unext[15]}}, imm_unext[15:0]};
            reg_waddr <= reg_raddr2;
            reg_write_en <= 1'b1;
            end
        `FUNCT_SLTIU: begin                                 //SLTIU
            alu_op <= ALU_SLTU;
            operand1 <= rdata1;
            operand2 <= {{16{imm_unext[15]}}, imm_unext[15:0]};
            reg_waddr <= reg_raddr2;
            reg_write_en <= 1'b1;
            end
        `FUNCT_ANDI: begin                                  //ANDI
            alu_op <= ALU_AND;
            operand1 <= rdata1;
            operand2 <= {16'h0, imm_unext[15:0]};           //ANDI是0扩展
            reg_waddr <= reg_raddr2;
            reg_write_en <= 1'b1;
            end
        `FUNCT_ORI: begin                                   //ORI
            alu_op <= ALU_OR;                               //alu进行OR的操作
            operand1 <= rdata1;                             //第一个操作数是寄存器
            operand2 <= {16'h0, imm_unext[15:0]};           //ORI对立即数进行的是0拓展
            reg_waddr <= reg_raddr2;
            reg_write_en <= 1'b1;                           //这个指令需要写寄存器
            end
        `FUNCT_XORI: begin                                  //XORI
            alu_op <= ALU_XOR;
            operand1 <= rdata1;
            operand2 <= {16'h0, imm_unext[15:0]};           //XORI是0扩展
            reg_waddr <= reg_raddr2;
            reg_write_en <= 1'b1;
            end
        `FUNCT_LUI: begin                                   //LUI
            alu_op <= ALU_OR;                               //等价操作
            operand1 <= 32'h00000000;                       //LUI的rs字段为00000，所以rdata1为32'b0
            operand2 <= {imm_unext[15:0], 16'h0};           //LUI操作低位补0
            reg_waddr <= reg_raddr2;
            reg_write_en <= 1'b1;
            end
        /****************   Register   ********************/
        `FUNCT_SPECIAL: begin
            operand1 <= rdata1;
            operand2 <= rdata2;
            reg_waddr <= instr[15:11];
            reg_write_en <= 1'b0;
            case (op)
                `OP_SLL: begin                              //SLL
                    alu_op <= ALU_SLL;
                    operand1 <= {27'b0, sa};
                    reg_write_en <= 1'b1;
                    end
                `OP_SLLV: begin                             //SLLV
                    alu_op <= ALU_SLL;
                    reg_write_en <= 1'b1;
                    end
                `OP_SRL: begin                              //SRL
                    alu_op <= ALU_SRL;
                    operand1 <= {27'b0, sa};
                    reg_write_en <= 1'b1;
                    end
                `OP_SRLV: begin                             //SRLV
                    alu_op <= ALU_SRL;
                    reg_write_en <= 1'b1;
                    end
                `OP_SRA: begin                              //SRA
                    alu_op <= ALU_SRA;
                    operand1 <= {27'b0, sa};
                    reg_write_en <= 1'b1;
                    end
                `OP_SRAV: begin                             //SRAV
                    alu_op <= ALU_SRA;
                    reg_write_en <= 1'b1;
                    end
                `OP_ADDU: begin                             //ADDU
                    alu_op <= ALU_ADD;
                    reg_write_en <= 1'b1;
                    end
                `OP_SLT: begin                              //SLT
                    alu_op <= ALU_SLT;
                    reg_write_en <= 1'b1;
                    end
                `OP_SLTU: begin                             //SLTU
                    alu_op <= ALU_SLTU;
                    reg_write_en <= 1'b1;
                    end
                `OP_SUBU: begin                             //SUBU
                    alu_op <= ALU_SUB;
                    reg_write_en <= 1'b1;
                    end
                `OP_AND: begin                              //AND
                    alu_op <= ALU_AND;
                    reg_write_en <= 1'b1;
                    end
                `OP_NOR: begin                              //NOR
                    alu_op <= ALU_NOR;
                    reg_write_en <= 1'b1;
                    end
                `OP_OR: begin                               //OR
                    alu_op <= ALU_OR;
                    reg_write_en <= 1'b1;
                    end
                `OP_XOR: begin                              //XOR
                    alu_op <= ALU_XOR;
                    reg_write_en <= 1'b1;
                    end
                default: begin
                    
                    end
            endcase
            end
        /************   Register & Immediate   ************/
        `FUNCT_REGIMM: begin
            reg_write_en <= 1'b0;
            case(reg_raddr2)
                `BRANCH_BLTZ: begin                         //BLTZ
                    branch_op <= BRA_BLTZ;
                    is_branch <= branch_result;
                    new_pc <= branch_new_pc;
                    end
                `BRANCH_BGEZ: begin                         //BGEZ
                    branch_op <= BRA_BGEZ;
                    is_branch <= branch_result;
                    new_pc <= branch_new_pc;
                    end
                default: begin
                    
                    end
            endcase
            end
        /******************   Branch   ********************/
        `FUNCT_BEQ: begin                                   //BEQ
            reg_write_en <= 1'b0;
            branch_op <= BRA_BEQ;
            is_branch <= branch_result;
            new_pc <= branch_new_pc;
            end
        `FUNCT_BNE: begin                                   //BNE
            reg_write_en <= 1'b0;
            branch_op <= BRA_BNE;
            is_branch <= branch_result;
            new_pc <= branch_new_pc;
            end
        `FUNCT_BLEZ: begin                                  //BLEZ
            reg_write_en <= 1'b0;
            branch_op <= BRA_BLEZ;
            is_branch <= branch_result;
            new_pc <= branch_new_pc;
            end
        `FUNCT_BGTZ: begin                                  //BGTZ
            reg_write_en <= 1'b0;
            branch_op <= BRA_BLEZ;
            is_branch <= branch_result;
            new_pc <= branch_new_pc;
            end
        default: begin
            
            end
    endcase
end

endmodule