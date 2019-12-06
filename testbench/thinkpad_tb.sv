`include "common_defs.svh"

module thinpad_tb;

Clock clk;
clock clock_instance(.clk);

Sram     base_ram();
Sram     ext_ram(); 
UART     uart();

reg[3:0]  touch_btn;
reg[31:0] dip_sw;   

reg clock_btn = 0;
wire[15:0] leds;    
wire[7:0]  dpy0;    
wire[7:0]  dpy1;
wire [22:0]flash_a;      
wire [15:0]flash_d;      
wire flash_rp_n;         
wire flash_vpen;         
wire flash_ce_n;         
wire flash_oe_n;         
wire flash_we_n;         
wire flash_byte_n;

wire uart_rdn;           //读串口信号，低有效
wire uart_wrn;           //写串口信号，低有效
wire uart_dataready;     //串口数据准备好
wire uart_tbre;          //发送数据标志
wire uart_tsre;          //数据发送完毕标志

thinpad_top thinpad_instance(
    .clk_50M(clk.clk_50M),
    .clk_11M0592(clk.clk_11M0592),
    .clock_btn(clock_btn),
    .reset_btn(clk.reset_btn),
    .touch_btn(touch_btn),
    .uart_rdn(uart_rdn),
    .uart_wrn(uart_wrn),
    .uart_dataready(uart_dataready),
    .uart_tbre(uart_tbre),
    .uart_tsre(uart_tsre),
    .base_ram,
    .ext_ram, 
    .uart,
    .dip_sw(dip_sw),
    .leds(leds),
    .dpy1(dpy1),
    .dpy0(dpy0),
    .flash_d(flash_d),
    .flash_a(flash_a),
    .flash_rp_n(flash_rp_n),
    .flash_vpen(flash_vpen),
    .flash_oe_n(flash_oe_n),
    .flash_ce_n(flash_ce_n),
    .flash_byte_n(flash_byte_n),
    .flash_we_n(flash_we_n)
);


cpld_model cpld(
    .clk_uart(clk_11M0592),
    .uart_rdn(uart_rdn),
    .uart_wrn(uart_wrn),
    .uart_dataready(uart_dataready),
    .uart_tbre(uart_tbre),
    .uart_tsre(uart_tsre),
    .data(base_ram.ram_data[7:0])
);

initial begin 
    //在这里可以自定义测试输入序列，例如：
    dip_sw = 32'h2;
    touch_btn = 0;
    for (integer i = 0; i < 20; i = i+1) begin
        #100; //等待100ns
        clock_btn = 1; //按下手工时钟按钮
        #100; //等待100ns
        clock_btn = 0; //松开手工时钟按钮
    end
    // 模拟PC通过串口发�?�字�??
    cpld.pc_send_byte(8'h32);
    #10000;
    cpld.pc_send_byte(8'h33);
end

    parameter BASE_RAM_INIT_FILE = "../../../../../testbench/thinpad/mem_init/base.bin";
    parameter EXT_RAM_INIT_FILE = "../../../../../testbench/thinpad/mem_init/ext.bin";
    parameter FLASH_INIT_FILE = "../../../../../testbench/thinpad/mem_init/flash.bin";

    sram_model base1(
        .DataIO(base_ram.ram_data[15:0]),
        .Address(base_ram.ram_addr[19:0]),
        .OE_n(base_ram.ram_oe_n),
        .CE_n(base_ram.ram_ce_n),
        .WE_n(base_ram.ram_we_n),
        .LB_n(base_ram.ram_be_n[0]),
        .UB_n(base_ram.ram_be_n[1]));

    sram_model base2(
        .DataIO(base_ram.ram_data[31:16]),
        .Address(base_ram.ram_addr[19:0]),
        .OE_n(base_ram.ram_oe_n),
        .CE_n(base_ram.ram_ce_n),
        .WE_n(base_ram.ram_we_n),
        .LB_n(base_ram.ram_be_n[2]),
        .UB_n(base_ram.ram_be_n[3]));

    sram_model ext1(
        .DataIO(ext_ram.ram_data[15:0]),
        .Address(ext_ram.ram_addr[19:0]),
        .OE_n(ext_ram.ram_oe_n),
        .CE_n(ext_ram.ram_ce_n),
        .WE_n(ext_ram.ram_we_n),
        .LB_n(ext_ram.ram_be_n[0]),
        .UB_n(ext_ram.ram_be_n[1]));

    sram_model ext2(
        .DataIO(ext_ram.ram_data[31:16]),
        .Address(ext_ram.ram_addr[19:0]),
        .OE_n(ext_ram.ram_oe_n),
        .CE_n(ext_ram.ram_ce_n),
        .WE_n(ext_ram.ram_we_n),
        .LB_n(ext_ram.ram_be_n[2]),
        .UB_n(ext_ram.ram_be_n[3]));

    // Flash 仿真模型
    x28fxxxp30 #(.FILENAME_MEM(FLASH_INIT_FILE)) flash(
        .A(flash_a[1+:22]), 
        .DQ(flash_d), 
        .W_N(flash_we_n),    // Write Enable 
        .G_N(flash_oe_n),    // Output Enable
        .E_N(flash_ce_n),    // Chip Enable
        .L_N(1'b0),    // Latch Enable
        .K(1'b0),      // Clock
        .WP_N(flash_vpen),   // Write Protect
        .RP_N(flash_rp_n),   // Reset/Power-Down
        .VDD('d3300), 
        .VDDQ('d3300), 
        .VPP('d1800), 
        .Info(1'b1));

    initial begin 
        wait(flash_byte_n == 1'b0);
        $display("8-bit Flash interface is not supported in simulation!");
        $display("Please tie flash_byte_n to high");
        $stop;
    end

    initial begin 
        reg [31:0] tmp_array[0:1048575];
        integer n_File_ID, n_Init_Size;
        n_File_ID = $fopen(BASE_RAM_INIT_FILE, "rb");
        if(!n_File_ID)begin 
            n_Init_Size = 0;
            $display("Failed to open BaseRAM init file");
        end else begin
            n_Init_Size = $fread(tmp_array, n_File_ID);
            n_Init_Size /= 4;
            $fclose(n_File_ID);
        end
        $display("BaseRAM Init Size(words): %d",n_Init_Size);
        for (integer i = 0; i < n_Init_Size; i++) begin
            base1.mem_array0[i] = tmp_array[i][24+:8];
            base1.mem_array1[i] = tmp_array[i][16+:8];
            base2.mem_array0[i] = tmp_array[i][8+:8];
            base2.mem_array1[i] = tmp_array[i][0+:8];
        end
    end
    
    initial begin 
        reg [31:0] tmp_array[0:1048575];
        integer n_File_ID, n_Init_Size;
        n_File_ID = $fopen(EXT_RAM_INIT_FILE, "rb");
        if(!n_File_ID)begin 
            n_Init_Size = 0;
            $display("Failed to open ExtRAM init file");
        end else begin
            n_Init_Size = $fread(tmp_array, n_File_ID);
            n_Init_Size /= 4;
            $fclose(n_File_ID);
        end
        $display("ExtRAM Init Size(words): %d",n_Init_Size);
        for (integer i = 0; i < n_Init_Size; i++) begin
            ext1.mem_array0[i] = tmp_array[i][24+:8];
            ext1.mem_array1[i] = tmp_array[i][16+:8];
            ext2.mem_array0[i] = tmp_array[i][8+:8];
            ext2.mem_array1[i] = tmp_array[i][0+:8];
        end
    end

    /*wire uart_clk;
    assign uart_clk = clk.base_2x;

    integer count;

    task uart_send_char(
        input Byte_t char
    );
        count = 0;
        @(negedge uart_clk);
        uart.rxd = 0;
        while (count < 8) begin
            @(negedge uart_clk);
            uart.rxd = char[count];
            count = count + 1;
        end
        @(negedge uart_clk);
        uart.rxd = 1;
        @(negedge uart_clk);
        uart.rxd = 1;

    endtask

    integer wait_clock;

    initial begin
        wait(thinpad_instance.clk.rst == 0);
        uart.rxd = 1;

        $stop;

        wait_clock = 0;
        while (wait_clock < 20) begin
            @(posedge clk.base);
            wait_clock = wait_clock + 1;
        end
    end*/
endmodule