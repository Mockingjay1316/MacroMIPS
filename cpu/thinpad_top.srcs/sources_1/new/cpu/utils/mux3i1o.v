module mux3i1o #(
    parameter DATA_WIDTH = 32
)(
    input   wire[DATA_WIDTH-1:0]    d0, d1, d2,     //数据输入
    input   wire[1:0]               sel,            //选择信号
    output  reg[DATA_WIDTH-1:0]     out             //数据输出
);

always @(sel) begin
    case(sel)                       //选择输出信号
        2'b00: out = d0;
        2'b01: out = d1;
        2'b10: out = d2;
        default: out = 32'b0;
    endcase
end

endmodule