`include "common_defs.svh"

module branch_res (                                             //就相当于一个小的ALU。。。比较器
    input   branch_op_t                 branch_op,              //需要判断的分支类型
    input   logic[`DATA_WIDTH-1:0]      operand1, operand2,     //分支判断的两个操作数

    output  logic                       branch_result           //分支的结果（跳转与否），是一个bool
);

logic[`DATA_WIDTH-1:0] res_add, res_sub;
assign res_add = operand1 + operand2;
assign res_sub = operand1 - operand2;

always @(*) begin
    case(branch_op)
        BRA_BEQ:    branch_result <= (res_sub == 0);
        BRA_BGEZ:   branch_result <= operand1[`DATA_WIDTH-1] ? 0 : 1;
        BRA_BGTZ:   branch_result <= (~operand1[`DATA_WIDTH-1] && res_sub != 0);
        BRA_BLEZ:   branch_result <= (operand1[`DATA_WIDTH-1] || res_sub == 0);
        BRA_BLTZ:   branch_result <= operand1[`DATA_WIDTH-1];
        BRA_BNE:    branch_result <= ~(res_sub == 0);
        default: begin

        end
    endcase
end

endmodule   //branch_res