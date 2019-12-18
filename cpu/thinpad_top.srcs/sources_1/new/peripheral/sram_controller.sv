`include "common_defs.svh"

module sram_controller (
    input   logic       main_clk, rst,
    input   logic       peri_clk, main_shift_clk,
    input   logic       sram_en,
    input   logic       load_from_mem,
    input   logic       is_data_read,       //1表示读数据，0表示写数据
    input   logic       data_write_en,
    input   logic       mem_byte_en,
    input   logic       mem_sign_ext,
    input   logic[31:0] pc, data_addr,
    input   logic[31:0] data_write,
    output  logic[31:0] data_read, instr_read,
    output  logic       mem_stall,

    //BaseRAM信号
    inout   wire[31:0] base_ram_data,      //BaseRAM数据，低8位与CPLD串口控制器共享
    output  logic[19:0] base_ram_addr,      //BaseRAM地址
    output  logic[3:0]  base_ram_be_n,      //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output  logic       base_ram_ce_n,      //BaseRAM片选，低有效
    output  logic       base_ram_oe_n,      //BaseRAM读使能，低有效
    output  logic       base_ram_we_n,      //BaseRAM写使能，低有效

    //ExtRAM信号
    inout   wire[31:0] ext_ram_data,       //ExtRAM数据
    output  logic[19:0] ext_ram_addr,       //ExtRAM地址
    output  logic[3:0]  ext_ram_be_n,       //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output  logic       ext_ram_ce_n,       //ExtRAM片选，低有效
    output  logic       ext_ram_oe_n,       //ExtRAM读使能，低有效
    output  logic       ext_ram_we_n        //ExtRAM写使能，低有效
);
/*
logic[31:0] base_wdata, ext_wdata, rdata;
assign ext_ram_data = (data_addr[22] && ~is_data_read && data_write_en) ? ext_wdata : 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
assign base_ram_data = (~data_addr[22] && ~is_data_read && data_write_en) ? base_wdata : 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
assign rdata = is_data_read ? (data_addr[22] ? ext_ram_data : base_ram_data) : 32'h00000000;
*/

logic[31:0] base_wdata, ext_wdata, rdata;
logic[19:0] pc_20, data_20;
assign pc_20 = pc[21:2];
assign data_20 = data_addr[21:2];
logic pc_ext, data_ext;
assign pc_ext = pc[22];
assign data_ext = data_addr[22];

assign mem_stall = (~(pc_ext ^ data_ext)) & (load_from_mem | data_write_en);

logic[3:0] pc_be_n, data_be_n;
logic pc_ce_n, pc_oe_n, pc_we_n;
logic data_ce_n, data_oe_n, data_we_n;

always_comb begin
    pc_be_n <= 4'b0000;
    data_be_n <= 4'b0000;
    if (mem_byte_en & data_write_en) begin
        case(data_addr[1:0])
            2'b00: data_be_n <= 4'b1110;
            2'b01: data_be_n <= 4'b1101;
            2'b10: data_be_n <= 4'b1011;
            2'b11: data_be_n <= 4'b0111;
        endcase
    end

    pc_ce_n <= 1'b0;
    pc_oe_n <= 1'b0;
    pc_we_n <= 1'b1;

    if (~(is_data_read ^ data_write_en)) begin
        data_ce_n <= 1'b1;
        data_we_n <= 1'b1;
        data_oe_n <= 1'b1;
    end else if (is_data_read && ~data_write_en) begin
        data_ce_n <= 1'b0;
        data_we_n <= 1'b1;
        data_oe_n <= 1'b0;
    end else if (~is_data_read && data_write_en) begin
        data_ce_n <= 1'b0;
        data_we_n <= 1'b0;
        data_oe_n <= 1'b1;
    end

    // TODO: fix it to enable version, or judge this in bus.
    // instruction can always read, bus will know use
    // it or not. we only need to disable data write.
    if (~sram_en) begin
        data_ce_n <= 1'b1;
        data_we_n <= 1'b1;
        data_oe_n <= 1'b1;
    end
end

logic ext_wr_en, base_wr_en;
assign ext_ram_data = ext_wr_en ? ext_wdata : 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
assign base_ram_data = base_wr_en ? base_wdata : 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;

always_comb begin
    ext_wr_en <= 1'b0;
    base_wr_en <= 1'b0;
    if (mem_stall) begin
        if (data_ext) begin
            ext_ram_addr <= data_20;
            ext_ram_be_n <= data_be_n;
            ext_ram_ce_n <= data_ce_n;
            ext_ram_oe_n <= data_oe_n;
            ext_ram_we_n <= data_we_n | main_shift_clk;
            ext_wr_en    <= ~data_we_n;
            if (mem_byte_en) begin
                ext_wdata <= {data_write[7:0], data_write[7:0], data_write[7:0], data_write[7:0]};
            end else begin
                ext_wdata <= data_write;
            end
        end else begin
            base_ram_addr <= data_20;
            base_ram_be_n <= data_be_n;
            base_ram_ce_n <= data_ce_n;
            base_ram_oe_n <= data_oe_n;
            base_ram_we_n <= data_we_n | main_shift_clk;
            base_wr_en    <= ~data_we_n;
            if (mem_byte_en) begin
                base_wdata <= {data_write[7:0], data_write[7:0], data_write[7:0], data_write[7:0]};
            end else begin
                base_wdata <= data_write;
            end
        end
    end else begin
        if (pc_ext) begin
            ext_ram_addr <= pc_20;
            ext_ram_be_n <= pc_be_n;
            ext_ram_ce_n <= pc_ce_n;
            ext_ram_oe_n <= pc_oe_n;
            ext_ram_we_n <= pc_we_n;
            ext_wr_en    <= ~pc_we_n;

            base_ram_addr <= data_20;
            base_ram_be_n <= data_be_n;
            base_ram_ce_n <= data_ce_n;
            base_ram_oe_n <= data_oe_n;
            base_ram_we_n <= data_we_n | main_shift_clk;
            base_wr_en    <= ~data_we_n;
            if (mem_byte_en) begin
                base_wdata <= {data_write[7:0], data_write[7:0], data_write[7:0], data_write[7:0]};
            end else begin
                base_wdata <= data_write;
            end
        end else begin
            base_ram_addr <= pc_20;
            base_ram_be_n <= pc_be_n;
            base_ram_ce_n <= pc_ce_n;
            base_ram_oe_n <= pc_oe_n;
            base_ram_we_n <= pc_we_n;
            base_wr_en    <= ~pc_we_n;

            ext_ram_addr <= data_20;
            ext_ram_be_n <= data_be_n;
            ext_ram_ce_n <= data_ce_n;
            ext_ram_oe_n <= data_oe_n;
            ext_ram_we_n <= data_we_n | main_shift_clk;
            ext_wr_en    <= ~data_we_n;
            if (mem_byte_en) begin
                ext_wdata <= {data_write[7:0], data_write[7:0], data_write[7:0], data_write[7:0]};
            end else begin
                ext_wdata <= data_write;
            end
        end
    end

    if (rst) begin
        base_ram_ce_n <= 1'b1;
        base_ram_oe_n <= 1'b1;
        base_ram_we_n <= 1'b1;
        base_wr_en    <= 1'b0;
        ext_ram_ce_n  <= 1'b1;
        ext_ram_oe_n  <= 1'b1;
        ext_ram_we_n  <= 1'b1;
        ext_wr_en     <= 1'b0;
    end
end

always @(posedge main_shift_clk) begin
    if (mem_stall) begin
        if (data_ext) begin
            rdata      <= ext_ram_data;
            instr_read <= 32'h00000000;
        end else begin
            rdata      <= base_ram_data;
            instr_read <= 32'h00000000;
        end
    end else begin
        if (pc_ext) begin
            instr_read <= ext_ram_data;
            rdata      <= base_ram_data;
        end else begin
            instr_read <= base_ram_data;
            rdata      <= ext_ram_data;
        end
    end
end

always_comb begin
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
    end
end

/*
always_comb begin
    if (data_addr >= 32'h80000000 && data_addr < 32'h80800000) begin
        mem_stall <= ~data_addr[22] & (load_from_mem | data_write_en);
    end else if (data_addr >= 32'h00000000 && data_addr < 32'h00800000) begin
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
    if (data_addr >= 32'hbfd003f8) begin
        ext_ram_be_n <= 4'b0000;
        base_ram_be_n <= 4'b0000;
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
*/
endmodule