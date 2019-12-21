`include "common_defs.svh"

module data_bus (
    input   logic[31:0]         data_addr, wdata,
    input   logic[4:0]          ctrl_signal,
    output  logic[31:0]         rdata,
    output  logic               data_not_ready,
    output  mem_control_info    sram_ctrl, uart_ctrl, flash_ctrl, vga_ctrl,
    input   mem_data            sram_data, uart_data, flash_data, vga_data
);

assign sram_ctrl.addr  = data_addr;
assign uart_ctrl.addr  = data_addr;
assign flash_ctrl.addr = data_addr;
assign vga_ctrl.addr   = data_addr;
assign sram_ctrl.wdata  = wdata;
assign uart_ctrl.wdata  = wdata;
assign flash_ctrl.wdata = wdata;
assign vga_ctrl.wdata   = wdata;

always_comb begin
    sram_ctrl.enable        <= 1'b0;
    sram_ctrl.ctrl_signal   <= 5'b00000;
    uart_ctrl.enable        <= 1'b0;
    uart_ctrl.ctrl_signal   <= 5'b00000;
    flash_ctrl.enable       <= 1'b0;
    flash_ctrl.ctrl_signal  <= 5'b00000;
    vga_ctrl.enable         <= 1'b0;
    vga_ctrl.ctrl_signal    <= 5'b00000;
    data_not_ready          <= 1'b0;

    if (ctrl_signal[3] | ctrl_signal[2]) begin
        if (data_addr[27:24] == 4'h0) begin
            sram_ctrl.ctrl_signal   <= ctrl_signal;
            sram_ctrl.enable        <= 1'b1;
            data_not_ready          <= 1'b0;
            rdata                   <= sram_data.rdata;
        end else if (data_addr[27:24] == 4'he) begin
            flash_ctrl.ctrl_signal  <= ctrl_signal;
            flash_ctrl.enable       <= 1'b1;
            data_not_ready          <= flash_data.data_not_ready;
            rdata                   <= flash_data.rdata;
        end else if (data_addr[31:20] == 12'hbfd) begin
            uart_ctrl.ctrl_signal   <= ctrl_signal;
            uart_ctrl.enable        <= 1'b1;
            data_not_ready          <= 1'b0;
            rdata                   <= uart_data.rdata;
            if (data_addr[3:0] == 4'h8) begin
                vga_ctrl.ctrl_signal   <= ctrl_signal;
                vga_ctrl.enable        <= 1'b1;
            end
        end else if (data_addr[27:24] == 4'h2) begin
            vga_ctrl.ctrl_signal    <= ctrl_signal;
            vga_ctrl.enable         <= 1'b1;
        end
    end
    
end

endmodule