`include "common_defs.svh"

module sram_controller (
    input   logic       main_clk, rst,
    input   logic       peri_clk,
    input   logic       is_data_read,       //1表示读数据，0表示写数据
    input   logic       data_write_en,
    input   logic       mem_byte_en,
    input   logic       mem_sign_ext,
    input   logic[31:0] pc, data_addr,
    input   logic[31:0] data_write,
    output  logic[31:0] data_read, instr_read,

    //BaseRAM信号
    inout   logic[31:0] base_ram_data,      //BaseRAM数据，低8位与CPLD串口控制器共享
    output  logic[19:0] base_ram_addr,      //BaseRAM地址
    output  logic[3:0]  base_ram_be_n,      //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output  logic       base_ram_ce_n,      //BaseRAM片选，低有效
    output  logic       base_ram_oe_n,      //BaseRAM读使能，低有效
    output  logic       base_ram_we_n,      //BaseRAM写使能，低有效

    //ExtRAM信号
    inout   logic[31:0] ext_ram_data,       //ExtRAM数据
    output  logic[19:0] ext_ram_addr,       //ExtRAM地址
    output  logic[3:0]  ext_ram_be_n,       //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output  logic       ext_ram_ce_n,       //ExtRAM片选，低有效
    output  logic       ext_ram_oe_n,       //ExtRAM读使能，低有效
    output  logic       ext_ram_we_n        //ExtRAM写使能，低有效
);

logic[31:0] base_wdata, ext_wdata;
assign ext_ram_data = (~is_data_read && data_write_en) ? ext_wdata : 32'hzzzzzzzz;

always @(*) begin
    if (~mem_byte_en) begin
        ext_ram_be_n <= 4'b0000;
    end else begin
        case(data_addr[1:0])
            2'b00: ext_ram_be_n <= 4'b1110;
            2'b01: ext_ram_be_n <= 4'b1101;
            2'b10: ext_ram_be_n <= 4'b1011;
            2'b11: ext_ram_be_n <= 4'b0111;
            default: begin
                
            end
        endcase
    end
end

always @(posedge peri_clk) begin
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
        base_ram_addr <= pc[21:2];
        if (is_data_read) begin
            ext_ram_ce_n <= 1'b0;
            ext_ram_oe_n <= 1'b0;
            ext_ram_we_n <= 1'b1;
            ext_ram_addr <= data_addr[21:2];
        end else begin
            ext_ram_ce_n <= 1'b0;
            ext_ram_oe_n <= 1'b0;
            ext_ram_we_n <= ~data_write_en;
            ext_ram_addr <= data_addr[21:2];
            if (mem_byte_en) begin
                ext_wdata <= {data_write[7:0], data_write[7:0], data_write[7:0], data_write[7:0]};
            end else begin
                ext_wdata <= data_write;
            end
        end
    end else if (main_clk == 1'b0) begin
        instr_read <= base_ram_data;
        if (is_data_read) begin
            if (mem_byte_en) begin
                if (mem_sign_ext) begin
                    case(data_addr[1:0])
                        2'b00: data_read <= {{24{ext_ram_data[7]}}, ext_ram_data[7:0]};
                        2'b01: data_read <= {{24{ext_ram_data[15]}}, ext_ram_data[15:8]};
                        2'b10: data_read <= {{24{ext_ram_data[23]}}, ext_ram_data[23:16]};
                        2'b11: data_read <= {{24{ext_ram_data[31]}}, ext_ram_data[31:24]};
                        default: begin
                            
                        end
                    endcase
                end else begin
                    case(data_addr[1:0])
                        2'b00: data_read <= {24'h000000, ext_ram_data[7:0]};
                        2'b01: data_read <= {24'h000000, ext_ram_data[15:8]};
                        2'b10: data_read <= {24'h000000, ext_ram_data[23:16]};
                        2'b11: data_read <= {24'h000000, ext_ram_data[31:24]};
                        default: begin
                            
                        end
                    endcase
                end
            end else begin
                data_read <= ext_ram_data;
            end
        end else begin
            data_read <= 32'hzzzzzzzz;
        end
    end
end

endmodule