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

`define FUNCT_SPECIAL   6'b000000
`define FUNCT_ADDIU     6'b001001
`define FUNCT_SLTI      6'b001010
`define FUNCT_SLTIU     6'b001011
`define FUNCT_ANDI      6'b001100
`define FUNCT_ORI       6'b001101
`define FUNCT_XORI      6'b001110
`define FUNCT_LUI       6'b001111

`define OP_SLL          6'b000000
`define OP_SLLV         6'b000100
`define OP_SRL          6'b000010
`define OP_SRLV         6'b000110
`define OP_SRA          6'b000011
`define OP_SRAV         6'b000111
`define OP_ADDU         6'b100001
`define OP_SLT          6'b101010
`define OP_SUBU         6'b100011
`define OP_MULTU        6'b011001
`define OP_AND          6'b100100
`define OP_NOR          6'b100111
`define OP_OR           6'b100101
`define OP_XOR          6'b100110

`endif