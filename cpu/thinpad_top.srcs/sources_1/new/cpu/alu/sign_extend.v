module sign_extend #(
    parameter DATA_IN_WIDTH = 16,
    parameter DATA_OUT_WIDTH = 32
)(
    input       wire[DATA_IN_WIDTH-1:0]      data_in,
    output      wire[31:0]      data_out
);

assign data_out = {{(DATA_OUT_WIDTH-DATA_IN_WIDTH){data_in[DATA_IN_WIDTH-1]}}, data_in};

endmodule