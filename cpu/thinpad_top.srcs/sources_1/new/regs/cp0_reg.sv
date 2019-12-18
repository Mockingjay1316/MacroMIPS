`include "common_defs.svh"

module cp0_reg (
    input   logic                       clk,                        //cp0寄存器的时钟信号
    input   logic                       rst,                        //寄存器复位信号
    input   logic                       write_en,                   //写使能
    input   logic                       EPC_write_en,               //EPC写使能，同时也指示是否发生中断
    input   logic[`REGID_WIDTH-1:0]     raddr, waddr,               //读和写的地址
    input   logic[2:0]                  wsel, rsel,                 //select字段
    input   logic[5:0]                  hardware_int,               //硬件中断
    input   logic[`DATA_WIDTH-1:0]      wdata, EPC_in, BadVAddr_in,
    input   logic                       is_mem_eret,                    //收到eret时需要进行一系列原子操作
    output  logic[`DATA_WIDTH-1:0]      EPC_out,
    input   logic                       tlbp, tlbr,
    input   tlb_entry_t                 tlb_rdata,
    input   logic[31:0]                 tlbp_index,

    input   logic[7:0]                  excep_code,                 //exception handler告知异常码
    output  logic                       hw_int_o,                   //发给control是否发生硬件中断

    output  logic[`DATA_WIDTH-1:0]      reg_out,
    output  logic[`DATA_WIDTH-1:0]      rdata                       //读出来的数据
);

logic[`DATA_WIDTH-1:0] Status, EBase, Cause, EPC;
logic[`DATA_WIDTH-1:0] Index, Random, Context, PageMask;
logic[`DATA_WIDTH-1:0] EntryHi, EntryLo0, EntryLo1, Config1, Wired;
logic[`DATA_WIDTH-1:0] Count, Compare, BadVAddr;
logic[5:0] hw_int;
logic timer_int;
integer iter;
cp0_name_t wname, rname;

//assign EPC_out = EPC;                                              //这里单纯读出EPC，是否EPC旁通在control处理

//assign reg_out = regs[16];

always_comb begin                                                   //parsing input addr & sel
    case(waddr)
        5'd0:       wname <= CP0_INDEX;
        5'd1:       wname <= CP0_RANDOM;
        5'd2:       wname <= CP0_ENTRYLO0;
        5'd3:       wname <= CP0_ENTRYLO1;
        5'd4:       wname <= CP0_CONTEXT;
        5'd5:       wname <= CP0_PAGEMASK;
        5'd6:       wname <= CP0_WIRED;
        5'd8:       wname <= CP0_BADVADDR;
        5'd9:       wname <= CP0_COUNT;
        5'd10:      wname <= CP0_ENTRYHI;
        5'd11:      wname <= CP0_COMPARE;
        5'd12:      wname <= CP0_STATUS;
        5'd13:      wname <= CP0_CAUSE;
        5'd14:      wname <= CP0_EPC;
        5'd15: begin
            case(wsel)
                3'd1:       wname <= CP0_EBASE;
                default:    wname <= CP0_UNKNOW;
            endcase
            end
        5'd16: begin
            case(wsel)
                3'd1:       wname <= CP0_CONFIG1;
                default:    wname <= CP0_UNKNOW;
            endcase
            end
        default: begin
            wname <= CP0_UNKNOW;
        end
    endcase
    case(raddr)
        5'd0:       rname <= CP0_INDEX;
        5'd1:       rname <= CP0_RANDOM;
        5'd2:       rname <= CP0_ENTRYLO0;
        5'd3:       rname <= CP0_ENTRYLO1;
        5'd4:       rname <= CP0_CONTEXT;
        5'd5:       rname <= CP0_PAGEMASK;
        5'd6:       rname <= CP0_WIRED;
        5'd8:       rname <= CP0_BADVADDR;
        5'd9:       rname <= CP0_COUNT;
        5'd10:      rname <= CP0_ENTRYHI;
        5'd11:      rname <= CP0_COMPARE;
        5'd12:      rname <= CP0_STATUS;
        5'd13:      rname <= CP0_CAUSE;
        5'd14:      rname <= CP0_EPC;
        5'd15: begin
            case(rsel)
                3'd1:       rname <= CP0_EBASE;
                default:    rname <= CP0_UNKNOW;
            endcase
            end
        5'd16: begin
            case(rsel)
                3'd1:       rname <= CP0_CONFIG1;
                default:    rname <= CP0_UNKNOW;
            endcase
            end
        default: begin
            rname <= CP0_UNKNOW;
        end
    endcase
end

always_comb begin
    hw_int <= {timer_int, hardware_int[4:0]};
    hw_int_o <= 1'b0;
    if ((hw_int & Status[15:10]) != 6'b000000) begin            //把Cause[15:10](也就是h_int)和中断屏蔽与一下
        hw_int_o <= 1'b1;                                       //硬件中断号统一由handler管理
    end
    if (rst) begin
        hw_int_o <= 1'b0;
    end
end

always @(posedge clk) begin
    Cause[15:10] <= hw_int;
    Count <= Count + 1;
    if (Compare != 32'h00000000 && Count == Compare) begin
        timer_int <= 1'b1;
    end
    if (Random > Wired) begin
        Random <= Random - 1;
    end else begin
        Random <= `MMU_SIZE;
    end
    if (write_en) begin
        case(wname)
            CP0_INDEX:      Index    <= wdata;
            CP0_ENTRYLO0:   EntryLo0 <= wdata;
            CP0_ENTRYLO1:   EntryLo1 <= wdata;
            CP0_CONTEXT: begin
                Context[31:23] <= wdata[31:23];
                end
            CP0_PAGEMASK:   PageMask <= wdata;
            CP0_WIRED: begin
                Wired <= wdata;
                Random <= `MMU_SIZE;     //写Wired寄存器同时会置Random为最大值
                end
            CP0_COUNT:      Count <= wdata;
            CP0_BADVADDR:   BadVAddr <= wdata;
            CP0_ENTRYHI:    EntryHi  <= wdata;
            CP0_COMPARE: begin
                Compare <= wdata;
                timer_int <= 1'b0;
                end
            CP0_STATUS:     Status   <= wdata;  //写Status寄存器
            CP0_CAUSE: begin                    //写Cause寄存器
                Cause[9:8]  <= wdata[9:8];
                Cause[22]   <= wdata[22];
                Cause[23]   <= wdata[23];
                end
            CP0_EPC:        EPC     <= wdata;   //写EPC
            CP0_EBASE:      EBase[29:12]   <= wdata[29:12];   //写EBse
            default: begin
                
            end
        endcase
    end
    if (EPC_write_en) begin                     //在发生异常的时候写EPC
        EPC         <= EPC_in;
        Status[1]   <= 1'b1;                    //EXL置位表示发生异常，这样也会禁用硬件中断
        Cause[6:2]  <= excep_code[6:2];         //保存中断号,中断号统一由handler管理
        if (excep_code[6:2] == 5'd3) begin      //为了TLB快速重填，需要设置Context和EntryHi寄存器
            Context[22:4]  <= BadVAddr_in[31:13];
            EntryHi[31:13] <= BadVAddr_in[31:13];
            BadVAddr       <= BadVAddr_in;
        end
    end
    if (is_mem_eret) begin
        Status[1]   <= 1'b0;                    //清除EXL位
    end
    if (tlbp) begin
        Index <= tlbp_index;
    end
    if (tlbr) begin
        EntryHi <= {tlb_rdata.VPN2, 5'b00000, tlb_rdata.ASID};
        EntryLo0 <= {tlb_rdata.PFN0, tlb_rdata.PFN0_fl, tlb_rdata.G};
        EntryLo1 <= {tlb_rdata.PFN1, tlb_rdata.PFN1_fl, tlb_rdata.G};
    end
    if (rst) begin                                                  //cp0寄存器同步清零
        Status <= 32'h10000000;
        Cause <= 32'h00000000;
        EPC <= 32'h00000000;
        EBase <= 32'h80000000;
        Random <= `MMU_SIZE;
        Index <= 32'h00000000;
        PageMask <= 32'h00000000;
        EntryHi <= 32'h00000000;
        EntryLo0 <= 32'h00000000;
        EntryLo1 <= 32'h00000000;
        Wired <= 32'h00000000;
        Context <= 32'h00000000;
        Config1 <= {1'b0, 6'd16, 25'd0};
        BadVAddr <= 32'h00000000;
        Count <= 32'h00000000;
        Compare <= 32'h00000000;
        timer_int <= 1'b0;
    end
end

always_comb begin
    case(rname)
        CP0_INDEX:      rdata   <= Index;
        CP0_ENTRYLO0:   rdata   <= EntryLo0;
        CP0_ENTRYLO1:   rdata   <= EntryLo1;
        CP0_CONTEXT:    rdata   <= Context;
        CP0_PAGEMASK:   rdata   <= PageMask;
        CP0_WIRED:      rdata   <= Wired;
        CP0_COUNT:      rdata   <= Count;
        CP0_BADVADDR:   rdata   <= BadVAddr;
        CP0_COMPARE:    rdata   <= Compare;
        CP0_ENTRYHI:    rdata   <= EntryHi;
        CP0_CONFIG1:    rdata   <= {1'b0, `MMU_SIZE, 25'd0};
        CP0_STATUS:     rdata   <= Status;  //Status寄存器
        CP0_CAUSE:      rdata   <= {Cause[31:16], hw_int, Cause[9:0]};   //Cause
        CP0_EPC:        rdata   <= EPC;     //EPC
        CP0_EBASE:      rdata   <= EBase;   //EBse
        default: begin
            rdata   <= 32'h00000000;
        end
    endcase
    if (rname == wname && write_en) begin
        case (rname)
            CP0_INDEX:      rdata   <= wdata;
            CP0_ENTRYLO0:   rdata   <= wdata;
            CP0_ENTRYLO1:   rdata   <= wdata;
            CP0_CONTEXT:    rdata   <= wdata;
            CP0_PAGEMASK:   rdata   <= wdata;
            CP0_WIRED:      rdata   <= wdata;
            CP0_COUNT:      rdata   <= wdata;
            CP0_BADVADDR:   rdata   <= wdata;
            CP0_COMPARE:    rdata   <= wdata;
            CP0_ENTRYHI:    rdata   <= wdata;
            CP0_STATUS:     rdata   <= wdata;   //Status寄存器
            CP0_CAUSE:      rdata   <= {Cause[31:24], wdata[23:22], Cause[21:16], hw_int, wdata[9:8], Cause[7:0]};   //Cause
            CP0_EPC:        rdata   <= wdata;   //EPC
            CP0_EBASE:      rdata   <= {EBase[31:30], wdata[29:12], EBase[11:0]};   //EBase
            default: begin
                rdata   <= 32'h00000000;
            end
        endcase
    end
    if (rname == CP0_INDEX && tlbp) begin
        rdata <= tlbp_index;
    end
    if (rname == CP0_ENTRYHI && tlbr) begin
        rdata <= {tlb_rdata.VPN2, 5'b00000, tlb_rdata.ASID};
    end
    if (rname == CP0_ENTRYLO0 && tlbr) begin
        rdata <= {tlb_rdata.PFN0, tlb_rdata.PFN0_fl, tlb_rdata.G};
    end
    if (rname == CP0_ENTRYLO1 && tlbr) begin
        rdata <= {tlb_rdata.PFN1, tlb_rdata.PFN1_fl, tlb_rdata.G};
    end
    EPC_out <= EPC;
    if (wname == CP0_EPC && write_en) begin
        EPC_out <= wdata;
    end
end

endmodule