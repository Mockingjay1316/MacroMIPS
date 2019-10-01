module mux2i1o #(
    parameter DATA_WIDTH = 32
)(
    input   wire[DATA_WIDTH-1:0]    d0, d1,         //数据输入
    input   wire                    sel,            //选择信号
    output  wire[DATA_WIDTH-1:0]    out             //数据输出
);

assign out = sel ? d1: d0;

endmodule