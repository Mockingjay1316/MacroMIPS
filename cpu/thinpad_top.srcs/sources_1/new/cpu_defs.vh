`ifndef CPU_DEFS_SV
`define CPU_DEFS_SV

`define OP_ADD  5'b00000
`define OP_SUB  5'b00001
`define OP_AND  5'b00010
`define OP_OR   5'b00011
`define OP_XOR  5'b00100
`define OP_NOR  5'b00101
`define OP_SLL  5'b00110
`define OP_SRL  5'b00111
`define OP_SRA  5'b01000
`define OP_MULT 5'b01001

`define INST_ADDIU      5'b00000
`define INST_ADDI       5'b00001
`define INST_AND        5'b00010
`define INST_ANDI       5'b00011
`define INST_BEQ        5'b00100
`define INST_BGTZ       5'b00101
`define INST_BNE        5'b00110
`define INST_J          5'b00111
`define INST_JAL        5'b01000
`define INST_JR         5'b01001
`define INST_LB         5'b01010
`define INST_LUI        5'b01011
`define INST_LW         5'b01100
`define INST_OR         5'b01101
`define INST_ORI        5'b01110
`define INST_SB         5'b01111
`define INST_SLL        5'b10000
`define INST_SRL        5'b10001
`define INST_SW         5'b10010
`define INST_XOR        5'b10011
`define INST_XORI       5'b10100

`endif