`include "common_defs.svh"

module cp0_reg (
    input   logic                       clk,                        //cp0寄存器的时钟信号
    input   logic                       rst,                        //寄存器复位信号
    input   logic                       write_en,                   //写使能
    input   logic                       EPC_write_en,               //EPC写使能，同时也指示是否发生中断
    input   logic[`REGID_WIDTH-1:0]     raddr, waddr,               //读和写的地址
    input   logic[2:0]                  wsel, rsel,                 //select字段
    input   logic[5:0]                  hardware_int,               //硬件中断
    input   logic[`DATA_WIDTH-1:0]      wdata, EPC_in,
    input   logic                       is_eret,                    //收到eret时需要进行一系列原子操作
    output  logic[`DATA_WIDTH-1:0]      EPC_out,

    input   logic[7:0]                  excep_code,                 //exception handler告知异常码
    output  logic                       hw_int_o,                   //发给control是否发生硬件中断

    output  logic[`DATA_WIDTH-1:0]      reg_out,
    output  logic[`DATA_WIDTH-1:0]      rdata                       //读出来的数据
);

logic[`DATA_WIDTH-1:0] Status, EBase, Cause, EPC;
integer iter;
cp0_name_t wname, rname;

assign EPC_out = EPC;                                              //这里单纯读出EPC，是否EPC旁通在control处理

//assign reg_out = regs[16];

always_comb begin                                                   //parsing input addr & sel
    case(waddr)
        5'd12:      wname <= CP0_STATUS;
        5'd13:      wname <= CP0_CAUSE;
        5'd14:      wname <= CP0_EPC;
        5'd15: begin
            case(wsel)
                3'd1:       wname <= CP0_EBASE;
                default:    wname <= CP0_UNKNOW;
            endcase
            end
        default: begin
            wname <= CP0_UNKNOW;
        end
    endcase
    case(raddr)
        5'd12:      rname <= CP0_STATUS;
        5'd13:      rname <= CP0_CAUSE;
        5'd14:      rname <= CP0_EPC;
        5'd15: begin
            case(rsel)
                3'd1:       rname <= CP0_EBASE;
                default:    rname <= CP0_UNKNOW;
            endcase
            end
        default: begin
            rname <= CP0_UNKNOW;
        end
    endcase
end

always @(posedge clk) begin
    Cause[15:10] <= hardware_int;
    if (EPC_write_en) begin
        Cause[7:0] <= excep_code;               //保存中断号,中断号统一由handler管理
    end
    if ((Cause[15:10] & Status[15:10]) != 6'b000000) begin
        hw_int_o <= 1'b1;
        //Cause[7:0] <= 8'd0;                     //硬件中断号
    end
    if (write_en) begin
        case(wname)
            CP0_STATUS:     Status  <= wdata;   //写Status寄存器
            CP0_CAUSE: begin                    //写Cause寄存器
                Cause[9:8]  <= wdata[9:8];
                Cause[22]   <= wdata[22];
                Cause[23]   <= wdata[23];
                end
            CP0_EPC:        EPC     <= wdata;   //写EPC
            CP0_EBASE:      EBase   <= wdata;   //写EBse
            default: begin
                
            end
        endcase
    end
    if (EPC_write_en) begin                     //在发生异常的时候写EPC
        EPC <= EPC_in;
    end
    if (is_eret) begin
        // TODO: eret logic
    end
    if (rst) begin                                                  //cp0寄存器同步清零
        Status <= 32'h00000000;
        Cause <= 32'h00000000;
        EPC <= 32'h00000000;
        EBase <= 32'h00000000;
    end
end

always_comb begin
    case(rname)
        CP0_STATUS:     rdata   <= Status;  //Status寄存器
        CP0_CAUSE:      rdata   <= Cause;   //Cause
        CP0_EPC:        rdata   <= EPC;     //EPC
        CP0_EBASE:      rdata   <= EBase;   //EBse
        default: begin
            rdata   <= 32'h00000000;
        end
    endcase
    if (rname == wname) begin
        case (rname)
            CP0_STATUS:     rdata   <= wdata;   //Status寄存器
            CP0_CAUSE:      rdata   <= {Cause[31:24], wdata[23:22], Cause[21:10], wdata[9:8], Cause[7:0]};   //Cause
            CP0_EPC:        rdata   <= wdata;   //EPC
            CP0_EBASE:      rdata   <= wdata;   //EBse
            default: begin
                rdata   <= 32'h00000000;
            end
        endcase
    end
end

endmodule