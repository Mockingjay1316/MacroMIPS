`include "common_defs.svh"

module memory_unit (
    input   logic[`DATA_WIDTH-1:0]      mem_addr, mem_wdata,
    input   logic                       load_from_mem, mem_data_write_en,
    input   logic                       is_mem_data_read, mem_byte_en,
    input   logic                       mem_sign_ext,

    output  logic[`DATA_WIDTH-1:0]      mem_rdata
);



endmodule