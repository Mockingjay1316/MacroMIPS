`include "common_defs.svh"

module sram_controller (
    Bus.slave           data_bus,
    Bus.slave           inst_bus,
    Sram.master         base_ram,
    Sram.master         ext_ram,
    CPLD.master         cpld
);

logic[31:0] base_wdata, ext_wdata, rdata, data_write, data_addr, pc, data_read;
logic[`ADDR_WIDTH-1:0] data_addr;
logic is_data_read, data_write_en, mem_byte_en, mem_sign_ext;
logic mem_stall;

logic uart_rdn, uart_wdn, uart_dataready, uart_tbre, uart_tsre;
assign cpld.uart_rdn = uart_rdn;
assign cpld.uart_wrn = uart_wrn;
assign uart_dataready = cpld.uart_dataready;
assign uart_tbre = cpld.uart_tbre;
assign uart_tsre = cpld.uart_tsre; 

logic peri_clk, main_clk;
assign peri_clk = inst_bus.clk.peri_clk;
assign main_clk = inst_bus.clk.main_clk;

assign data_bus.mem_rdata = data_read;
assign load_from_mem = inst_bus.mem_ctrl_signal[4];
assign data_write_en = inst_bus.mem_ctrl_signal[3];
assign is_data_read = inst_bus.mem_ctrl_signal[2];
assign mem_byte_en = inst_bus.mem_ctrl_signal[1];
assign mem_sign_ext = inst_bus.mem_ctrl_signal[0];

assign data_addr = data_bus.mem_addr;
assign pc = inst_bus.mem_addr;
assign inst_bus.mem_stall = mem_stall;

assign data_write = data_bus.mem_wdata;
assign ext_ram.ram_data = (data_addr[22] && ~is_data_read && data_write_en) ? ext_wdata : 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
assign base_ram.ram_data = (~data_addr[22] && ~is_data_read && data_write_en) ? base_wdata : 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
assign rdata = is_data_read ? (data_addr[22] ? ext_ram_data : base_ram_data) : 32'h00000000;

always_comb begin
    if (data_addr >= 32'h80000000 && data_addr <= 32'h80800000) begin
        mem_stall <= ~data_addr[22] & (load_from_mem | data_write_en);
    end else begin
        mem_stall <= 1'b0;
    end
end

always @(*) begin
    if (~mem_byte_en | ~data_write_en) begin
        ext_ram_be_n <= 4'b0000;
        base_ram_be_n <= 4'b0000;
    end else begin
        case(data_addr[1:0])
            2'b00: ext_ram_be_n <= 4'b1110;
            2'b01: ext_ram_be_n <= 4'b1101;
            2'b10: ext_ram_be_n <= 4'b1011;
            2'b11: ext_ram_be_n <= 4'b0111;
        endcase
        if (~data_addr[22]) begin
            case(data_addr[1:0])
                2'b00: base_ram_be_n <= 4'b1110;
                2'b01: base_ram_be_n <= 4'b1101;
                2'b10: base_ram_be_n <= 4'b1011;
                2'b11: base_ram_be_n <= 4'b0111;
            endcase
        end
    end
end

always @(posedge peri_clk) begin
    uart_rdn <= 1;
    uart_wrn <= 1;
    if (rst) begin
        base_ram_ce_n <= 1'b1;
        base_ram_oe_n <= 1'b1;
        base_ram_we_n <= 1'b1;
        ext_ram_ce_n  <= 1'b1;
        ext_ram_oe_n  <= 1'b1;
        ext_ram_we_n  <= 1'b1;
    end else if (main_clk == 1'b1) begin
        base_ram_ce_n <= 1'b0;
        base_ram_oe_n <= 1'b0;
        base_ram_we_n <= 1'b1;
        if (~mem_stall) begin
            base_ram_addr <= pc[21:2];
        end else begin
            base_ram_addr <= data_addr[21:2];
            if (~is_data_read) begin
                base_ram_we_n <= ~data_write_en;
                base_ram_oe_n <= 1'b1;
                if (mem_byte_en) begin
                    base_wdata <= {data_write[7:0], data_write[7:0], data_write[7:0], data_write[7:0]};
                end else begin
                    base_wdata <= data_write;
                end
            end
        end
        if(mem_addr == 32'hbfd003f8) begin
            if(data_write_en) begin    //write si 
                uart_wrn <= 1'b0;
                uart_rdn <= 1'b1;
                base_ram_data <= mem_wdata;
                base_ram_ce_n <= 1'b1;
            end else begin  //read si
                uart_rdn <= 1'b0;
                uart_wrn <= 1'b1;
                data_read <= {24'b0, uart_data[7:0]};  
            end
        end else if (mem_addr == 32'hbfd003fc) begin
            data_read <= {30'b0, uart_dataready, uart_tsre & uart_tbre};
        end
        if (is_data_read) begin
            ext_ram_ce_n <= 1'b0;
            ext_ram_oe_n <= 1'b0;
            ext_ram_we_n <= 1'b1;
            ext_ram_addr <= data_addr[21:2];
        end else begin
            ext_ram_ce_n <= 1'b0;
            ext_ram_oe_n <= 1'b1;
            ext_ram_we_n <= ~data_write_en;
            ext_ram_addr <= data_addr[21:2];
            if (mem_byte_en) begin
                ext_wdata <= {data_write[7:0], data_write[7:0], data_write[7:0], data_write[7:0]};
            end else begin
                ext_wdata <= data_write;
            end
        end
    end else if (main_clk == 1'b0) begin
        base_ram_we_n <= 1'b1;
        ext_ram_we_n  <= 1'b1;
        if (~mem_stall) begin
            instr_read <= base_ram_data;
        end else begin
            instr_read <= 32'h00000000;
        end
        if (is_data_read) begin
            if (mem_byte_en) begin
                if (mem_sign_ext) begin
                    case(data_addr[1:0])
                        2'b00: data_read <= {{24{rdata[7]}}, rdata[7:0]};
                        2'b01: data_read <= {{24{rdata[15]}}, rdata[15:8]};
                        2'b10: data_read <= {{24{rdata[23]}}, rdata[23:16]};
                        2'b11: data_read <= {{24{rdata[31]}}, rdata[31:24]};
                    endcase
                end else begin
                    case(data_addr[1:0])
                        2'b00: data_read <= {24'h000000, rdata[7:0]};
                        2'b01: data_read <= {24'h000000, rdata[15:8]};
                        2'b10: data_read <= {24'h000000, rdata[23:16]};
                        2'b11: data_read <= {24'h000000, rdata[31:24]};
                    endcase
                end
            end else begin
                data_read <= rdata;
            end
        end else begin
            data_read <= 32'hzzzzzzzz;
        end
    end

    if (data_addr >= 32'hbfd003f8 && data_write_en) begin
        ext_ram_ce_n  <= 1'b1;
        ext_ram_oe_n  <= 1'b1;
        ext_ram_we_n  <= 1'b1;
    end
end

endmodule