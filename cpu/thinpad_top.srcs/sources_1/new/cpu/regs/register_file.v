module register_file (
    input   wire            clk,                        //时钟信号
    input   wire            write_en,                   //写使能
    input   wire[4:0]       raddr1, raddr2, waddr1,     //读和写的地址
    output  wire[31:0]      rdata1, rdata2,             //读的数据
    input   wire[31:0]      wdata                       //写的数据
);

reg [31:0] regs [31:0];

always @(posedge clk) begin
    if (write_en) begin
        regs[waddr1] <= wdata;
    end
end

assign rdata1 = (raddr1 == 0) ? 0 : regs[raddr1];
assign rdata2 = (raddr2 == 0) ? 0 : regs[raddr2];

endmodule