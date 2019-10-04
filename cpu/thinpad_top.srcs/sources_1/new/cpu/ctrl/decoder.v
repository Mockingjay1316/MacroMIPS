module decoder (
    input   wire[5:0]   op,
    input   wire[5:0]   funct,
    output  wire[4:0]   dec_instr
);

reg[4:0] dec_result;
assign dec_instr = dec_result;

always @(op or funct) begin
    case (op)
        6'b001001: dec_result = `INST_ADDIU;
        6'b001100: dec_result = `INST_ANDI;
        6'b000100: dec_result = `INST_BEQ;
        6'b000111: dec_result = `INST_BGTZ;
        6'b000101: dec_result = `INST_BNE;
        6'b000010: dec_result = `INST_J;
        6'b000011: dec_result = `INST_JAL;
        6'b100000: dec_result = `INST_LB;
        6'b001111: dec_result = `INST_LUI;
        6'b100011: dec_result = `INST_LW;
        6'b001101: dec_result = `INST_ORI;
        6'b101000: dec_result = `INST_SB;
        6'b101011: dec_result = `INST_SW;
        6'b001110: dec_result = `INST_XORI;
        6'b000000:begin
            case (funct)
                6'b100001: dec_result = `INST_ADDU;
                6'b100100: dec_result = `INST_AND;
                6'b001000: dec_result = `INST_JR;
                6'b100101: dec_result = `INST_OR;
                6'b000000: dec_result = `INST_SLL;
                6'b000010: dec_result = `INST_SRL;
                6'b100110: dec_result = `INST_XOR;
                default: dec_result = 5'bx;
            endcase
        end
        default: dec_result = 5'bx;
    endcase
end

endmodule // decoder
