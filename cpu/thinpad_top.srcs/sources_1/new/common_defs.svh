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
    ALU_SLL, ALU_SRL, ALU_SRA,
    ALU_NOP
} alu_op_t;             //alu的各个操作，相当于指令的简化版

`define FUNCT_ORI 6'b001101
`define FUNCT_SPECIAL 6'b000000

`endif