`include "common_defs.svh"

module cp0_reg (
    input   logic                       clk,                        //cp0寄存器的时钟信号
    input   logic                       rst,                        //寄存器复位信号
    input   logic                       write_en,                   //写使能
    input   logic[`REGID_WIDTH-1:0]     raddr, waddr,               //读和写的地址
    input   logic[2:0]                  wsel, rsel,                 //select字段
    input   logic[5:0]                  hardware_int,               //硬件中断
    input   logic[`DATA_WIDTH-1:0]      wdata,

    output  logic[`DATA_WIDTH-1:0]      reg_out,
    output  logic[`DATA_WIDTH-1:0]      rdata                       //读出来的数据
);

logic[`DATA_WIDTH-1:0] Status, EBase, Cause, EPC;
integer iter;
cp0_name_t wname, rname;

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
end

endmodule