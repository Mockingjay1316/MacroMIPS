`ifndef COMMON_DEFS_VH
`define COMMON_DEFS_VH

`timescale 1ns / 1ps

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

`define OP_SPECIAL      6'b000000
`define OP_REGIMM       6'b000001
`define OP_J            6'b000010
`define OP_JAL          6'b000011
`define OP_BEQ          6'b000100
`define OP_BNE          6'b000101
`define OP_BLEZ         6'b000110
`define OP_BGTZ         6'b000111
`define OP_ADDIU        6'b001001
`define OP_SLTI         6'b001010
`define OP_SLTIU        6'b001011
`define OP_ANDI         6'b001100
`define OP_ORI          6'b001101
`define OP_XORI         6'b001110
`define OP_LUI          6'b001111
`define OP_COP0         6'b010000
`define OP_LB           6'b100000
`define OP_LW           6'b100011
`define OP_LBU          6'b100100
`define OP_SB           6'b101000
`define OP_SW           6'b101011

`define FUNCT_SLL       6'b000000
`define FUNCT_SLLV      6'b000100
`define FUNCT_SRL       6'b000010
`define FUNCT_SRLV      6'b000110
`define FUNCT_SRA       6'b000011
`define FUNCT_SRAV      6'b000111
`define FUNCT_JR        6'b001000
`define FUNCT_JALR      6'b001001
`define FUNCT_SYSCALL   6'b001100
`define FUNCT_ERET      6'b011000
`define FUNCT_ADDU      6'b100001
`define FUNCT_SLT       6'b101010
`define FUNCT_SLTU      6'b101011
`define FUNCT_SUBU      6'b100011
`define FUNCT_MULTU     6'b011001
`define FUNCT_AND       6'b100100
`define FUNCT_NOR       6'b100111
`define FUNCT_OR        6'b100101
`define FUNCT_XOR       6'b100110

`define BRANCH_BLTZ     5'b00000
`define BRANCH_BGEZ     5'b00001

`define STALL_BEF_IF    5'b10000
`define STALL_BEF_ID    5'b11000
`define STALL_BEF_EX    5'b11100
`define STALL_BEF_MEM   5'b11110
`define STALL_BEF_WB    5'b11111

typedef struct packed {
    logic[4:0]      reg_waddr;
    logic[31:0]     reg_wval;
    logic           reg_write_en;
} reg_op_t;

typedef struct packed {
    logic[4:0]      cp0_waddr;
    logic[2:0]      cp0_sel;
    logic           cp0_write_en;
    logic[31:0]     cp0_wval;
} cp0_op_t;

typedef enum logic[6:0] {
    CP0_STATUS, CP0_EBASE, CP0_CAUSE, CP0_EPC,
    CP0_UNKNOW
} cp0_name_t;

typedef struct packed {
    logic[31:0]     EPC;
    logic           is_excep;
    logic[7:0]      excep_code;
} excep_info_t;

typedef enum logic[2:0] {
    UART_RWAIT, UART_RREAD, UART_RACK
} uart_rstate_t;


interface Bus(
    input logic clk
);
    logic[`ADDR_WIDTH-1:0]      pc_out, mem_addr;
    logic[`DATA_WIDTH-1:0]      mem_wdata, reg_out;
    logic[4:0]                  mem_ctrl_signal;
    logic[`DATA_WIDTH-1:0]      mem_rdata;

    modport master(
        output  mem_addr, mem_wdata, reg_out, mem_ctrl_signal,
        input   mem_rada, hardware_int, mem_stall,
        input   clk
    );

    modport slave(
        input   mem_addr, mem_wdata, reg_out, mem_ctrl_signal,
        output  mem_rdata, hardware_int, mem_stall,
        input   clk
    );
}
endinterface

interface Sram();
    wire[31:0] ram_data;      //BaseRAM数据，低8位与CPLD串口控制器共享
    wire[19:0] ram_addr;      //BaseRAM地址
    wire[3:0]  ram_be_n;      //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    wire       ram_ce_n;      //BaseRAM片选，低有效
    wire       ram_oe_n;      //BaseRAM读使能，低有效
    wire       ram_we_n;      //BaseRAM写使能，低有效

    modport master(
        input ram_data;
        output ram_addr, ram_be_n, ram_ce_n, ram_oe_n, ram_we_n,
    );
endinterface

interface URAT();
    logic rxd, txd;

    modport master(
        input   rxd,
        output  txd
    );
endinterface

`endif