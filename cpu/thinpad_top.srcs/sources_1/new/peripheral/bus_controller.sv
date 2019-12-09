module bus_controller(
    //for cpu
    input    logic[`ADDR_WIDTH-1:0]     mem_addr,  pc,
    input    logic[`DATA_WIDTH-1:0]     mem_wdata,
    input    logic[4:0]                 mem_ctrl_signal,
    output   logic[5:0]                 hardware_request,               
    output   logic[`DATA_WIDTH-1:0]     mem_rdata,
    output   logic[`INST_WIDTH-1:0]     instruction,
    output   logic                      mem_stall, 

    //for sram_controller
    output  logic[4:0]                  sram_ctrl_signal, 
    output  logic[`ADDR_WIDTH-1:0]      sram_data_addr, sram_inst_addr,
    input   logic[`DATA_WIDTH-1:0]      sram_rdata, sram_inst,
    output  logic[`DATA_WIDTH-1:0]      sram_wdata,
    output  logic                       sram_enable,
    input   logic                       sram_stall,

    //for uart_controller
    output  logic[`ADDR_WIDTH-1:0]      uart_addr,
    input   logic[`DATA_WIDTH-1:0]      uart_rdata,
    output  logic[`DATA_WIDTH-1:0]      uart_wdata,
    output  logic                       uart_enable,
    input logic[5:0]                    uart_request,
    output  logic[4:0]                  uart_ctrl_signal  

);
    always @ (*) begin 
        sram_enable <= 1'b0;
        uart_enable <= 1'b0;
        instruction <= sram_inst;
        sram_inst_addr <= pc;

        if( mem_addr >= 32'hbfd003f8) begin
            uart_enable <= 1'b1;
            uart_wdata <= mem_wdata;
            mem_rdata <= uart_rdata;
            uart_addr <= mem_addr;
            hardware_request <= uart_request;
            uart_ctrl_signal <= mem_ctrl_signal;
        end
        else begin
            sram_enable <= 1'b1;
            sram_wdata <= mem_wdata;
            sram_data_addr <= mem_addr;
            mem_rdata <= sram_rdata;
            
            sram_ctrl_signal <= mem_ctrl_signal;
            mem_stall <= sram_stall;
        end
    end
endmodule