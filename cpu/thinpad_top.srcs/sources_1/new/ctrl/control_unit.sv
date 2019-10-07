`include "common_defs.svh"

module control_unit (
    input   logic[`INST_WIDTH-1:0]      instr,
    input   logic[`DATA_WIDTH-1:0]      reg_rdata1, reg_rdata2,     //为了进行分支判断

    input   logic[`REGID_WIDTH-1:0]     ex_reg_waddr,
    input   logic[`DATA_WIDTH-1:0]      ex_alu_result,
    input   logic                       ex_reg_write_en,
    input   logic[`REGID_WIDTH-1:0]     mem_reg_waddr,
    input   logic[`DATA_WIDTH-1:0]      mem_reg_wdata,
    input   logic                       mem_reg_write_en,

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

logic[`DATA_WIDTH-1:0] rdata1, rdata2;

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

always @(*) begin
    case(funct)
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
        `FUNCT_ORI: begin
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
        default: begin
            
        end
    endcase
end

endmodule