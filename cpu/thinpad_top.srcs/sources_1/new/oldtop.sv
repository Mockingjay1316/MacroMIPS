`include "common_defs.svh"

module thinpad_top(
    input   wire       clk_50M,            //50MHz 鏃堕挓杈撳叆
    input   wire       clk_11M0592,        //11.0592MHz 鏃堕挓杈撳叆

    input   wire       clock_btn,          //BTN5鎵嬪姩鏃堕挓鎸夐挳锟??鍏筹紝甯︽秷鎶栫數璺紝鎸変笅鏃朵负1
    input   wire       reset_btn,          //BTN6鎵嬪姩澶嶄綅鎸夐挳锟??鍏筹紝甯︽秷鎶栫數璺紝鎸変笅鏃朵负1

    input   wire[3:0]  touch_btn,          //BTN1~BTN4锛屾寜閽紑鍏筹紝鎸変笅鏃朵负1
    input   wire[31:0] dip_sw,             //32浣嶆嫧鐮佸紑鍏筹紝鎷ㄥ埌鈥淥N鈥濇椂锟??1
    output  wire[15:0] leds,               //16浣峀ED锛岃緭鍑烘椂1鐐逛寒
    output  wire[7:0]  dpy0,               //鏁扮爜绠′綆浣嶄俊鍙凤紝鍖呮嫭灏忔暟鐐癸紝杈撳嚭1鐐逛寒
    output  wire[7:0]  dpy1,               //鏁扮爜绠￠珮浣嶄俊鍙凤紝鍖呮嫭灏忔暟鐐癸紝杈撳嚭1鐐逛寒

    //CPLD涓插彛鎺у埗鍣ㄤ俊锟??
    output  logic       uart_rdn,           //璇讳覆鍙ｄ俊鍙凤紝浣庢湁锟??
    output  logic       uart_wrn,           //鍐欎覆鍙ｄ俊鍙凤紝浣庢湁锟??
    input   wire       uart_dataready,     //涓插彛鏁版嵁鍑嗗锟??
    input   wire       uart_tbre,          //鍙戯拷?锟芥暟鎹爣锟??
    input   wire       uart_tsre,          //鏁版嵁鍙戯拷?锟藉畬姣曟爣锟??

    //BaseRAM淇″彿
    inout   wire[31:0] base_ram_data,      //BaseRAM鏁版嵁锛屼綆8浣嶄笌CPLD涓插彛鎺у埗鍣ㄥ叡锟??
    output  wire[19:0] base_ram_addr,      //BaseRAM鍦板潃
    output  wire[3:0]  base_ram_be_n,      //BaseRAM瀛楄妭浣胯兘锛屼綆鏈夋晥銆傚鏋滀笉浣跨敤瀛楄妭浣胯兘锛岃淇濇寔锟??0
    output  wire       base_ram_ce_n,      //BaseRAM鐗囷拷?锟斤紝浣庢湁锟??
    output  wire       base_ram_oe_n,      //BaseRAM璇讳娇鑳斤紝浣庢湁锟??
    output  wire       base_ram_we_n,      //BaseRAM鍐欎娇鑳斤紝浣庢湁锟??

    //ExtRAM淇″彿
    inout   wire[31:0] ext_ram_data,       //ExtRAM鏁版嵁
    output  wire[19:0] ext_ram_addr,       //ExtRAM鍦板潃
    output  wire[3:0]  ext_ram_be_n,       //ExtRAM瀛楄妭浣胯兘锛屼綆鏈夋晥銆傚鏋滀笉浣跨敤瀛楄妭浣胯兘锛岃淇濇寔锟??0
    output  wire       ext_ram_ce_n,       //ExtRAM鐗囷拷?锟斤紝浣庢湁锟??
    output  wire       ext_ram_oe_n,       //ExtRAM璇讳娇鑳斤紝浣庢湁锟??
    output  wire       ext_ram_we_n,       //ExtRAM鍐欎娇鑳斤紝浣庢湁锟??

    //鐩磋繛涓插彛淇″彿
    output  wire       txd,                //鐩磋繛涓插彛鍙戯拷?锟界
    input   wire       rxd,                //鐩磋繛涓插彛鎺ユ敹锟??

    //Flash瀛樺偍鍣ㄤ俊鍙凤紝鍙傦拷?? JS28F640 鑺墖鎵嬪唽
    output  wire[22:0] flash_a,            //Flash鍦板潃锛宎0浠呭湪8bit妯″紡鏈夋晥锟??16bit妯″紡鏃犳剰锟??
    inout   wire[15:0] flash_d,            //Flash鏁版嵁
    output  wire       flash_rp_n,         //Flash澶嶄綅淇″彿锛屼綆鏈夋晥
    output  wire       flash_vpen,         //Flash鍐欎繚鎶や俊鍙凤紝浣庣數骞虫椂涓嶈兘鎿﹂櫎銆佺儳锟??
    output  wire       flash_ce_n,         //Flash鐗囷拷?锟戒俊鍙凤紝浣庢湁锟??
    output  wire       flash_oe_n,         //Flash璇讳娇鑳戒俊鍙凤紝浣庢湁锟??
    output  wire       flash_we_n,         //Flash鍐欎娇鑳戒俊鍙凤紝浣庢湁锟??
    output  wire       flash_byte_n,       //Flash 8bit妯″紡閫夋嫨锛屼綆鏈夋晥銆傚湪浣跨敤flash锟??16浣嶆ā寮忔椂璇疯锟??1

    //USB 鎺у埗鍣ㄤ俊鍙凤紝鍙傦拷?? SL811 鑺墖鎵嬪唽
    output  wire       sl811_a0,
    //inout  logic[7:0] sl811_d,            //USB鏁版嵁绾夸笌缃戠粶鎺у埗鍣ㄧ殑dm9k_sd[7:0]鍏变韩
    output  wire       sl811_wr_n,
    output  wire       sl811_rd_n,
    output  wire       sl811_cs_n,
    output  wire       sl811_rst_n,
    output  wire       sl811_dack_n,
    input   wire       sl811_intrq,
    input   wire       sl811_drq_n,

    //缃戠粶鎺у埗鍣ㄤ俊鍙凤紝鍙傦拷?? DM9000A 鑺墖鎵嬪唽
    output  wire       dm9k_cmd,
    inout   wire[15:0] dm9k_sd,
    output  wire       dm9k_iow_n,
    output  wire       dm9k_ior_n,
    output  wire       dm9k_cs_n,
    output  wire       dm9k_pwrst_n,
    input   wire       dm9k_int,

    //鍥惧儚杈撳嚭淇″彿
    output  wire[2:0]  video_red,          //绾㈣壊鍍忕礌锟??3锟??
    output  wire[2:0]  video_green,        //缁胯壊鍍忕礌锟??3锟??
    output  wire[1:0]  video_blue,         //钃濊壊鍍忕礌锟??2锟??
    output  wire       video_hsync,        //琛屽悓姝ワ紙姘村钩鍚屾锛変俊锟??
    output  wire       video_vsync,        //鍦哄悓姝ワ紙鍨傜洿鍚屾锛変俊锟??
    output  wire       video_clk,          //鍍忕礌鏃堕挓杈撳嚭
    output  wire       video_de            //琛屾暟鎹湁鏁堜俊鍙凤紝鐢ㄤ簬鍖哄垎娑堥殣锟??
);

logic rst, peri_clk, bus_clk, main_clk;
logic[`INST_WIDTH-1:0] instr;
logic[`ADDR_WIDTH-1:0] pc, mem_addr;
logic[`DATA_WIDTH-1:0] mem_wdata, sram_rdata, uart_rdata, reg_out, mem_rdata;
logic[4:0] mem_ctrl_signal;
logic is_uart, mem_stall;
logic[5:0] hardware_int;

assign hardware_int = {3'b000, ext_uart_already_read_status^ext_uart_read_status, 2'b00};        //鎵撳紑浜嗙‖浠朵腑锟??


main_pll pll (
    .clk_in1(clk_50M),
    .clk_out1(bus_clk),
    .clk_out2(peri_clk),
    .clk_out3(main_clk),
    .locked(rst)
);

cpu_core cpu (
    .clk_50M(main_clk),
    .clk_11M0592(clk_11M0592),

    .clock_btn(clock_btn),
    .reset_btn(reset_btn | ~rst),
    .mem_stall(mem_stall),

    .leds(leds),
    .dpy0(dpy0),
    .dpy1(dpy1),

    .hardware_int,
    .pc_out(pc),
    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .reg_out(reg_out),
    .mem_rdata(mem_rdata),
    .mem_ctrl_signal(mem_ctrl_signal),
    .is_uart(is_uart),
    .instruction(instr)
);

sram_controller sram_ctrl (
    .main_clk(main_clk),
    .peri_clk(peri_clk),
    .rst(~rst),
    .pc(pc),
    .instr_read(instr),
    .data_write_en(mem_ctrl_signal[3]),
    .load_from_mem(mem_ctrl_signal[4]),
    .is_data_read(mem_ctrl_signal[2]),
    .mem_byte_en(mem_ctrl_signal[1]),
    .mem_sign_ext(mem_ctrl_signal[0]),
    .data_addr(mem_addr),
    .data_write(mem_wdata),
    .data_read(sram_rdata),
    .mem_stall(mem_stall),

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
/*
ila_0 ila (
    .clk(main_clk),
    .probe0(is_uart),
    .probe1(ext_uart_busy),
    .probe2(mem_rdata),
    .probe3(uart_rdata),
    .probe4(ext_uart_wavai),
    .probe5(ext_uart_start),
    .probe6(ext_uart_tx),
    .probe7(mem_stall),
    .probe8(mem_ctrl_signal),
    .probe9(pc),
    .probe10(mem_addr),
    .probe11(reg_out),
    .probe12(instr)
);
*/
assign mem_rdata = is_uart ? uart_rdata : sram_rdata;

//鐩磋繛涓插彛鎺ユ敹鍙戯拷?锟芥紨绀猴紝浠庣洿杩炰覆鍙ｆ敹鍒扮殑鏁版嵁鍐嶅彂閫佸嚭锟??
logic[7:0] ext_uart_rx;
logic[7:0] ext_uart_buffer, ext_uart_tx;
logic ext_uart_ready, ext_uart_busy, ext_uart_clear;
logic ext_uart_start, ext_uart_wavai, ext_uart_ravai, ext_uart_read_status, ext_uart_already_read_status;
uart_rstate_t uart_rstate;

logic[`DATA_WIDTH-1:0] uart_data_buff;
logic[`DATA_WIDTH-1:0] uart_data;
assign uart_data = uart_wrn ? 32'bz : uart_data_buff;

async_receiver #(.ClkFrequency(60000000),.Baud(9600))   //鎺ユ敹妯″潡锟??9600鏃犳楠屼綅
    ext_uart_r(
        .clk(peri_clk),                                 //澶栭儴鏃堕挓淇″彿
        .RxD(rxd),                                      //澶栭儴涓茶淇″彿杈撳叆
        .RxD_data_ready(ext_uart_ready),                //鏁版嵁鎺ユ敹鍒版爣锟??
        .RxD_clear(ext_uart_clear),                     //娓呴櫎鎺ユ敹鏍囧織
        .RxD_data(ext_uart_rx)                          //鎺ユ敹鍒扮殑锟??瀛楄妭鏁版嵁
    );

assign ext_uart_wavai = mem_ctrl_signal[3] & is_uart;
logic[1:0] counter;

always @(posedge peri_clk) begin
    if (reset_btn | ~rst) begin
        uart_rstate <= UART_RWAIT;
        ext_uart_read_status <= ext_uart_already_read_status;
    end else begin
        case(uart_rstate)
            UART_RWAIT: begin
                ext_uart_clear <= 1'b0;
                if (ext_uart_ready & ~ext_uart_clear) begin
                    uart_rstate <= UART_RREAD;
                end
                end
            UART_RREAD: begin
                uart_rstate <= UART_RACK;
                ext_uart_buffer <= ext_uart_rx;         //璇诲叆鏁版嵁
                ext_uart_read_status <= ~ext_uart_read_status;
                end
            UART_RACK: begin
                uart_rstate <= UART_RWAIT;
                ext_uart_clear <= 1'b1;
                end
            default: begin
                
                end
        endcase
    end
end

always @(posedge peri_clk) begin                         //灏嗙紦鍐插尯ext_uart_buffer鍙戯拷?锟藉嚭锟??
    if (!ext_uart_busy && ext_uart_wavai) begin
        if (mem_addr[3:0] == 4'h8) begin
            ext_uart_start <= 1'b1;
        end
    end else begin
        ext_uart_start <= 1'b0;
    end
end

always @(*) begin
    if (mem_addr[3:0] == 4'hc) begin
        uart_rdata <= {30'b0, ext_uart_already_read_status^ext_uart_read_status, ~ext_uart_busy};
    end else if (mem_addr[3:0] == 4'h8) begin
        if (mem_ctrl_signal[3] & is_uart) begin
            ext_uart_tx <= mem_wdata[7:0];
        end else if (is_uart) begin
            uart_rdata <= {24'b0, ext_uart_buffer};
        end
    end else if (mem_addr == 32'hbfd003f8) begin
        if (mem_ctrl_signal[3]) begin//3 -> mem_data_write_en 
            uart_wrn <= 1'b0;
            uart_rdn <= 1'b1;
            uart_data_buff <= mem_wdata;
        end else begin
            uart_rdn <= 1'b0;
            uart_wrn <= 1'b1;
            uart_rdata <= {24'b0, uart_data[7:0]};
        end
    end else if (mem_addr == 32'hbfd003fc) begin
        uart_rdata <= {30'b0, uart_dataready, uart_tsre & uart_tbre};
    end
end

always @(posedge main_clk) begin                         //灏嗙紦鍐插尯ext_uart_buffer鍙戯拷?锟藉嚭锟??
    if (reset_btn | ~rst) begin
        ext_uart_already_read_status <= 1'b0;
    end else if (is_uart & mem_ctrl_signal[2] && mem_addr[3:0] == 4'h8) begin
        ext_uart_already_read_status <= ext_uart_read_status;
    end
end

async_transmitter #(.ClkFrequency(60000000),.Baud(9600)) //鍙戯拷?锟芥ā鍧楋紝9600鏃犳楠屼綅
    ext_uart_t(
        .clk(peri_clk),                                 //澶栭儴鏃堕挓淇″彿
        .TxD(txd),                                      //涓茶淇″彿杈撳嚭
        .TxD_busy(ext_uart_busy),                       //鍙戯拷?锟藉櫒蹇欑姸鎬佹寚锟??
        .TxD_start(ext_uart_start),                     //锟??濮嬪彂閫佷俊锟??
        .TxD_data(ext_uart_tx)                          //寰呭彂閫佺殑鏁版嵁
    );

endmodule
