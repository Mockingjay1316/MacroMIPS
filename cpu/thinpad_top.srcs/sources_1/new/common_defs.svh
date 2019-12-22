`ifndef COMMON_DEFS_VH
`define COMMON_DEFS_VH

`timescale 1ns / 1ps

`define ADDR_WIDTH 32
`define DATA_WIDTH 32
`define INST_WIDTH 32

`define REGISTER_NUM 32
`define REGID_WIDTH 5

typedef enum logic[3:0] { 
    ALU_ADD, ALU_SUB, ALU_MULTU, ALU_MULT,
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
`define FUNCT_TLBR      6'b000001
`define FUNCT_TLBWI     6'b000010
`define FUNCT_TLBWR     6'b000110
`define FUNCT_SLLV      6'b000100
`define FUNCT_SRL       6'b000010
`define FUNCT_SRLV      6'b000110
`define FUNCT_SRA       6'b000011
`define FUNCT_SRAV      6'b000111
`define FUNCT_JR        6'b001000
`define FUNCT_TLBP      6'b001000
`define FUNCT_JALR      6'b001001
`define FUNCT_SYSCALL   6'b001100
`define FUNCT_MFHI      6'b010000
`define FUNCT_MTHI      6'b010001
`define FUNCT_MFLO      6'b010010
`define FUNCT_MTLO      6'b010011
`define FUNCT_ERET      6'b011000
`define FUNCT_ADDU      6'b100001
`define FUNCT_SLT       6'b101010
`define FUNCT_SLTU      6'b101011
`define FUNCT_SUBU      6'b100011
`define FUNCT_MULT      6'b011000
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

`define MMU_SIZE        6'd15           //实际的TLB大小为16(15+1)
`define MMU_SIZE_NUM    16
`define MMU_SIZE_NUM_LOG2   4

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

typedef struct packed {
    logic           hilo_write_en;
    logic[63:0]     hilo_wval;
} hilo_op_t;

typedef enum logic[6:0] {
    CP0_STATUS, CP0_EBASE, CP0_CAUSE, CP0_EPC,
    CP0_ENTRYHI, CP0_ENTRYLO0, CP0_ENTRYLO1,
    CP0_PAGEMASK, CP0_INDEX, CP0_RANDOM, CP0_CONTEXT,
    CP0_CONFIG1, CP0_WIRED,
    CP0_COUNT, CP0_COMPARE, CP0_BADVADDR,
    CP0_UNKNOW
} cp0_name_t;

typedef struct packed {
    logic[31:0]     EPC;
    logic           is_excep;
    logic           is_syscall;
    logic           is_eret;
    logic           instr_valid;
    logic           tlb_pc_miss;
    logic[7:0]      excep_code;
} excep_info_t;

typedef enum logic[2:0] {
    UART_RWAIT, UART_RREAD, UART_RACK
} uart_rstate_t;

typedef enum {
    VGA_CLI, VGA_TOWER, VGA_PCLOGO,
    VGA_SNAKE, VGA_V4030, VGA_V10075
} vga_mode_t;

typedef struct packed {
    logic[31:0]     addr;
    logic[4:0]      ctrl_signal;
    logic[31:0]     wdata;
    logic           enable;
} mem_control_info;

typedef struct packed {
    logic           data_not_ready;
    logic[31:0]     rdata;
} mem_data;

typedef struct packed {
    logic[18:0]     VPN2;
    logic[7:0]      ASID;
    logic[31:0]     PageMask;
    logic           G;
    logic[25:0]     PFN0, PFN1;
    logic[4:0]      PFN0_fl, PFN1_fl;           //flag: [4:2]-C [1]-D [0]-V
    logic           inited;
} tlb_entry_t;

typedef struct packed {
    logic[31:0]     paddr;
    logic[3:0]      index;
    logic           miss, dirty, valid;
    logic[2:0]      cache_fl;
} tlb_res_t;

typedef struct packed {
    logic[31:0]     paddr, vaddr;
    logic           miss, dirty, valid, illegal;
} mmu_res_t;

typedef struct packed {
    logic           tlb_write_en, tlb_write_random, tlbp, tlbr;
    logic           instr_valid;
    tlb_entry_t     tlb_rdata;
    logic[31:0]     tlbp_index;
} pipeline_data_t;

typedef logic [`MMU_SIZE_NUM * $bits(tlb_entry_t) - 1:0] tlb_flat_entry_t;

`endif