`include "common_defs.svh"

module flash_controller (
    input wire clk,
    input logic[7:0] flash_data,
    output wire[22:0] flash_addr,
    output wire[18:0] video_addr,
    output logic[7:0] video_data,
    output logic video_write_enable
);

reg[22:0] addr;
assign video_addr = addr[18:0];
assign flash_addr = addr;

enum {ADDR, LOAD, STORE, END} state;

parameter max = 479999;

always @(posedge clk) begin
    case(state)
        ADDR:begin
            addr <= addr + 1
            video_write_enable <= 1;
            video_data <= video_data;
            state <= LOAD;
        end
        LOAD: begin
            addr <= addr;
            vedio_write_enable <= 1;
            v_data <= flash_data[7:0];
            state <= STORE;
        end
        STORE: begin
            addr <= addr;
            video_write_enable <= 0;
            video_data <= video_data;
            if (addr == max)
                state <= END;
            else 
                state <= ADDR;
        end
        default: begin
            addr <= addr;
            video_write_enable <= 1;
            video_data <= video_data;
            state <= END;
        end
    endcase
end

endmodule