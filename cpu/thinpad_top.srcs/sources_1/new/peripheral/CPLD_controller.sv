module cpld_controller(
    Bus.master data_bus,
    CPLD.master cpld  
);

logic[`ADDR_WIDTH-1:0] mem_addr;
logic[`DATA_WIDTH-1:0] uart_rdata, mem_wdata, uart_data;

logic uart_rdn, uart_wdn, uart_dataready, uart_tbre, uart_tsre;
logic mem_iswrite;

assign mem_addr = data_bus.address;
assign mem_iswrite = data_bus.write;
assign mem_wdata = data_bus.mem_wdata;
assign data_bus.mem_rdata = uart_rdata;

assign cpld.uart_rdn = uart_rdn;
assign cpld.uart_wrn = uart_wrn;
assign uart_dataready = cpld.uart_dataready;
assign uart_tbre = cpld.uart_tbre;
assign uart_tsre = cpld.uart_tsre;                                                                

assign uart_data = uart_wrn ? 32'bz : uart_data_buff;

always @(*) begin
    uart_rdn <= 1;
    uart_wrn <= 1;
    if(mem_addr == 32'hbfd003f8) begin
        if(mem_iswrite) begin    //write si 
            uart_wrn <= 1'b0;
            uart_rdn <= 1'b1;
            uart_data_buff <= mem_wdata;
        end else begin  //read si
            uart_rdn <= 1'b0;
            uart_wrn <= 1'b1;
            uart_rdata <= {24'b0, uart_data[7:0]};  
        end
    end else if (mem_addr == 32'hbfd003fc) begin
        uart_rdata <= {30'b0, uart_dataready, uart_tsre & uart_tbre};
    end
end

endmodule