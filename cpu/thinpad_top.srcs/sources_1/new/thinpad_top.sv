`include "common_defs.svh"

module thinpad_top(
    input   wire       clk_50M,            
    input   wire       clk_11M0592,        

    input   wire       clock_btn,          
    input   wire       reset_btn,          

    input   wire[3:0]  touch_btn,          
    input   wire[31:0] dip_sw,             
    output  wire[15:0] leds,               
    output  wire[7:0]  dpy0,               
    output  wire[7:0]  dpy1,               

    output  wire       uart_rdn, // read
    output  wire       uart_wrn, // write
    input   wire       uart_dataready,
    input   wire       uart_tbre, // busy sending
    input   wire       uart_tsre,  // send done

    inout   wire[31:0] base_ram_data,      
    output  wire[19:0] base_ram_addr,      
    output  wire[3:0]  base_ram_be_n,      
    output  wire       base_ram_ce_n,      
    output  wire       base_ram_oe_n,      
    output  wire       base_ram_we_n,      

    
    inout   wire[31:0] ext_ram_data,       
    output  wire[19:0] ext_ram_addr,      
    output  wire[3:0]  ext_ram_be_n,       
    output  wire       ext_ram_ce_n,       
    output  wire       ext_ram_oe_n,       
    output  wire       ext_ram_we_n,       

    
    output  wire       txd,                
    input   wire       rxd,                

    
    output  wire[22:0] flash_a,            
    inout   wire[15:0] flash_d,            
    output  wire       flash_rp_n,         
    output  wire       flash_vpen,         
    output  wire       flash_ce_n,         
    output  wire       flash_oe_n,         
    output  wire       flash_we_n,         
    output  wire       flash_byte_n,       

    
    output  wire       sl811_a0,
    //inout  logic[7:0] sl811_d,            
    output  wire       sl811_wr_n,
    output  wire       sl811_rd_n,
    output  wire       sl811_cs_n,
    output  wire       sl811_rst_n,
    output  wire       sl811_dack_n,
    input   wire       sl811_intrq,
    input   wire       sl811_drq_n,

    
    output  wire       dm9k_cmd,
    inout   wire[15:0] dm9k_sd,
    output  wire       dm9k_iow_n,
    output  wire       dm9k_ior_n,
    output  wire       dm9k_cs_n,
    output  wire       dm9k_pwrst_n,
    input   wire       dm9k_int,

    
    output  wire[2:0]  video_red,          
    output  wire[2:0]  video_green,        
    output  wire[1:0]  video_blue,         
    output  wire       video_hsync,        
    output  wire       video_vsync,        
    output  wire       video_clk,          
    output  wire       video_de            
);

assign leds = 16'b0101010101010101;

assign uart_rdn = 1'b1;
assign uart_wrn = 1'b1;
logic rst, peri_clk, bus_clk, main_clk;

logic[`INST_WIDTH-1:0] instr;
logic[`ADDR_WIDTH-1:0] pc, mem_addr;
logic[`DATA_WIDTH-1:0] mem_wdata, reg_out, mem_rdata;
logic[4:0] mem_ctrl_signal;
logic mem_stall;
logic[5:0] hardware_int, uart_request;


assign uart_rdn = 1'b1;
assign uart_wrn = 1'b1;

logic[4:0] sram_ctrl_signal, uart_ctrl_signal;
logic[`DATA_WIDTH-1:0] sram_wdata, sram_rdata, uart_rdata, uart_wdata;
logic[`INST_WIDTH-1:0] sram_inst;
logic[`ADDR_WIDTH-1:0] sram_data_addr, sram_inst_addr, uart_addr;

logic sram_enable, uart_enable;
logic sram_stall;
main_pll pll (
    .clk_in1(clk_50M),
    .clk_out1(bus_clk),
    .clk_out2(peri_clk),
    .clk_out3(main_clk),
    .locked(rst)
);

bus_controller bus_ctrl(
    .mem_addr(mem_addr),  
    .pc(pc),
    .mem_wdata(mem_wdata),
    .mem_ctrl_signal(mem_ctrl_signal),
    .hardware_request(hardware_int),               
    .mem_rdata(mem_rdata),
    .instruction(instr),
    .mem_stall(mem_stall),

    //for sram_controller
    .sram_ctrl_signal(sram_ctrl_signal), 
    .sram_data_addr(sram_data_addr), 
    .sram_inst_addr(sram_inst_addr),
    .sram_rdata(sram_rdata), 
    .sram_inst(sram_inst),
    .sram_wdata(sram_wdata),
    .sram_enable(sram_enable),
    .sram_stall(sram_stall),

    //for uart_controller
    .uart_addr(uart_addr),
    .uart_rdata(uart_rdata),
    .uart_wdata(uart_wdata),
    .uart_enable(uart_enable),
    .uart_request(uart_request),
    .uart_ctrl_signal(uart_ctrl_signal)
);
cpu_core cpu (
    .clk_50M(main_clk),
    .clk_11M0592(clk_11M0592),

    .clock_btn(clock_btn),
    .reset_btn(reset_btn | ~rst),
    .mem_stall(mem_stall),
    
    .hardware_int,
    .pc_out(pc),
    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .reg_out(reg_out),
    .mem_rdata(mem_rdata),
    .mem_ctrl_signal(mem_ctrl_signal),
    .instruction(instr)
);

sram_controller sram_ctrl (
    .main_clk(main_clk),
    .peri_clk(peri_clk),
    .rst(~rst),
    .pc(sram_inst_addr),
    .instr_read(sram_inst),
    .data_write_en(sram_ctrl_signal[3]),
    .load_from_mem(sram_ctrl_signal[4]),
    .is_data_read(sram_ctrl_signal[2]),
    .mem_byte_en(sram_ctrl_signal[1]),
    .mem_sign_ext(sram_ctrl_signal[0]),
    .data_addr(sram_data_addr),
    .data_write(sram_wdata),
    .data_read(sram_rdata),
    .mem_stall(sram_stall),

    .base_ram_data(base_ram_data),
    .base_ram_addr(base_ram_addr),
    .base_ram_be_n(base_ram_be_n),
    .base_ram_ce_n(base_ram_ce_n),
    .base_ram_oe_n(base_ram_oe_n),
    .base_ram_we_n(base_ram_we_n),

    .ext_ram_data(ext_ram_data),
    .ext_ram_addr(ext_ram_addr),
    .ext_ram_be_n(ext_ram_be_n),
    .ext_ram_ce_n(ext_ram_ce_n),
    .ext_ram_oe_n(ext_ram_oe_n),
    .ext_ram_we_n(ext_ram_we_n)
);

uart_controller uart_ctrl(
    .peri_clk(peri_clk),
    .main_clk(main_clk),
    .reset_btn(reset_btn),
    .rst(rst),

    .mem_addr(uart_addr),
    .uart_wdata(uart_wdata),
    .uart_rdata(uart_rdata),
    .mem_ctrl_signal(uart_ctrl_signal),
    .rxd(rxd),
    .txd(txd),
    .hardware_int(uart_request)
);



endmodule
