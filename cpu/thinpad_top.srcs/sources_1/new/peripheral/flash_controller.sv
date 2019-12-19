`include "common_defs.svh"

module flash_controller (
    input   logic       main_clk, rst,
    input   logic       peri_clk, main_shift_clk,
    input   logic       flash_en,
    input   logic       load_from_mem,
    input   logic       is_data_read,       //1表示读数据，0表示写数据
    input   logic       data_write_en,
    input   logic       mem_byte_en,
    input   logic       mem_sign_ext,
    input   logic[31:0] data_addr,
    input   logic[31:0] data_write,
    output  logic[31:0] data_read,
    output  logic       mem_stall, data_not_ready,

    //Flash存储器信号，参考 JS28F640 芯片手册
    output  logic[22:0] flash_a,            //Flash地址，a0仅在8bit模式有效，16bit模式无意义
    inout   wire[15:0]  flash_d,            //Flash数据
    output  logic       flash_rp_n,         //Flash复位信号，低有效
    output  logic       flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧写
    output  logic       flash_ce_n,         //Flash片选信号，低有效
    output  logic       flash_oe_n,         //Flash读使能信号，低有效
    output  logic       flash_we_n,         //Flash写使能信号，低有效
    output  logic       flash_byte_n        //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1
);

assign flash_vpen = 1'b0;
assign flash_byte_n = 1'b1;
assign flash_rp_n = 1'b1;

`define WAIT_CYCLES 4

typedef enum { 
    STATE_INIT, STATE_RESET,
    STATE_WRITE_BYTE_[`WAIT_CYCLES],
    STATE_READ_BYTE_0_[`WAIT_CYCLES],
    STATE_READ_BYTE_1_[`WAIT_CYCLES]
} flash_state_t;

`undef WAIT_CYCLES

flash_state_t flash_state;
logic[31:0] rdata;
logic[22:0] base_addr;
assign base_addr = {data_addr[22:2], 2'b00};
logic[15:0] wdata;
logic wr_en;
assign flash_d = wr_en ? wdata : 16'hzzzz;
assign data_read = rdata;

`define GEN_WAIT_STATE(NAME, A, B) NAME``_``A: begin \
    flash_state <= NAME``_``B; \
end \

`define GEN_WAIT_STATES(NAME) `GEN_WAIT_STATE(NAME, 0, 1)\
`GEN_WAIT_STATE(NAME, 1, 2) \
`GEN_WAIT_STATE(NAME, 2, 3) \

always @(posedge main_shift_clk) begin
    if (rst) begin
        flash_state <= STATE_RESET;
        wr_en <= 1'b0;
        rdata <= 32'h00000000;
        flash_ce_n <= 1'b1;
        flash_we_n <= 1'b1;
        flash_oe_n <= 1'b1;
        data_not_ready <= 1'b0;
    end else begin
        unique case(flash_state)
            STATE_RESET: begin
                flash_ce_n <= 1'b0;
                flash_we_n <= 1'b0;
                flash_oe_n <= 1'b1;
                wr_en <= 1'b1;
                wdata <= 16'h00ff;
                flash_a <= 0;
                flash_state <= STATE_WRITE_BYTE_0;
                end
            STATE_INIT: begin
                flash_ce_n <= 1'b1;
                flash_we_n <= 1'b1;
                flash_oe_n <= 1'b1;
                wr_en <= 1'b0;
                if (is_data_read) begin
                    data_not_ready <= 1'b1;
                    flash_ce_n <= 1'b0;
                    flash_oe_n <= 1'b0;
                    flash_a <= base_addr;
                    flash_state <= STATE_READ_BYTE_0_0;
                end else if (data_write_en) begin
                    data_not_ready <= 1'b1;
                    flash_ce_n <= 1'b0;
                    flash_we_n <= 1'b0;
                    flash_a <= base_addr;
                    flash_state <= STATE_WRITE_BYTE_0;
                    wr_en <= 1'b1;
                    wdata <= data_write[15:0];
                end
                end
            
            `GEN_WAIT_STATES(STATE_WRITE_BYTE)

            STATE_WRITE_BYTE_3: begin
                data_not_ready <= 1'b0;
                flash_ce_n <= 1'b1;
                flash_we_n <= 1'b1;
                flash_oe_n <= 1'b1;
                flash_state <= STATE_INIT;
                end
            
            `GEN_WAIT_STATES(STATE_READ_BYTE_0)

            STATE_READ_BYTE_0_3: begin
                rdata[15:0] <= flash_d;
                flash_a <= base_addr + 2'h2;
                flash_state <= STATE_READ_BYTE_1_0;
                end
            
            `GEN_WAIT_STATES(STATE_READ_BYTE_1)

            STATE_READ_BYTE_1_3: begin
                data_not_ready <= 1'b0;
                rdata[31:16] <= flash_d;
                flash_ce_n <= 1'b1;
                flash_we_n <= 1'b1;
                flash_oe_n <= 1'b1;
                flash_state <= STATE_INIT;
                end
            
            default: flash_state <= STATE_INIT;
        endcase
    end
end

endmodule