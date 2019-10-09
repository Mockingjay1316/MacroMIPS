`ifndef COMMON_DEFS_VH
`define COMMON_DEFS_VH

`define ADDR_WIDTH 32
`define DATA_WIDTH 32
`define INST_WIDTH 32

`define REGISTER_NUM 32
`define REGID_WIDTH 5

typedef enum logic[3:0] { 
    ALU_ADD, ALU_SUB, ALU_MULT,
    ALU_AND, ALU_NOR, ALU_OR, ALU_XOR,
    ALU_SLL, ALU_SRL, ALU_SRA, ALU_SLT, ALU_SLTU,
    ALU_NOP
} alu_op_t;             //alu的各个操作，相当于指令的简化版

typedef enum logic[3:0] {
    BRA_BEQ, BRA_BGEZ, BRA_BGTZ, BRA_BLEZ, BRA_BLTZ,
    BRA_BNE,
    BRA_NOP
} branch_op_t;

//NOTE: 已修复OP和FUNCT反了的问题

`define OP_SPECIAL   6'b000000
`define OP_REGIMM    6'b000001
`define OP_J         6'b000010
`define OP_JAL       6'b000011
`define OP_BEQ       6'b000100
`define OP_BNE       6'b000101
`define OP_BLEZ      6'b000110
`define OP_BGTZ      6'b000111
`define OP_ADDIU     6'b001001
`define OP_SLTI      6'b001010
`define OP_SLTIU     6'b001011
`define OP_ANDI      6'b001100
`define OP_ORI       6'b001101
`define OP_XORI      6'b001110
`define OP_LUI       6'b001111

`define FUNCT_SLL          6'b000000
`define FUNCT_SLLV         6'b000100
`define FUNCT_SRL          6'b000010
`define FUNCT_SRLV         6'b000110
`define FUNCT_SRA          6'b000011
`define FUNCT_SRAV         6'b000111
`define FUNCT_JR           6'b001000
`define FUNCT_ADDU         6'b100001
`define FUNCT_SLT          6'b101010
`define FUNCT_SLTU         6'b101011
`define FUNCT_SUBU         6'b100011
`define FUNCT_MULTU        6'b011001
`define FUNCT_AND          6'b100100
`define FUNCT_NOR          6'b100111
`define FUNCT_OR           6'b100101
`define FUNCT_XOR          6'b100110

`define BRANCH_BLTZ     5'b00000
`define BRANCH_BGEZ     5'b00001

`endif