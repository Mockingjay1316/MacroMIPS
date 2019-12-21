`include "common_defs.svh"

module cmd_buff (
    input   logic           clk, rst, wr_clk,
    input   logic[31:0]     wdata,
    input   logic           wr_en,
    output  logic[11:0]     cli_hdata, cli_vdata,
    output  logic[7:0]      data_out
);

logic[10:0] hptr, vptr;
logic[10:0] out_hptr, out_vptr;
logic not_full_yet;
logic[10:0] start_line;
logic[15:0] wloc, rloc;
assign wloc = hptr + 100 * vptr;
assign rloc = out_hptr + 100 * out_vptr;

logic[7:0] wchar, wcolor, rchar, rcolor;
logic[5:0] hbit, vbit;

always @(posedge clk) begin
    if (rst) begin
        out_hptr <= 0;
        out_vptr <= 0;
        hbit <= 0;
        vbit <= 0;
    end else begin
        if (hbit != 7) begin
            hbit <= hbit + 1;
        end else begin
            hbit <= 0;
            if (vbit != 11) begin
                vbit <= vbit + 1;
            end else begin
                vbit <= 0;
                if (out_hptr != 99) begin
                    out_hptr <= out_hptr + 1;
                end else begin
                    out_hptr <= 0;
                    if (out_vptr != 49) begin
                        out_vptr <= out_vptr + 1;
                    end else begin
                        out_vptr <= 0;
                    end
                end
            end
        end
    end
end

always_comb begin
    cli_hdata <= out_hptr * 8 + hbit;
    if (not_full_yet) begin
        cli_vdata <= out_vptr * 12 + vbit;
    end else begin
        if (start_line > out_vptr && not_full_yet == 1'b0) begin
            cli_vdata <= (out_vptr - start_line + 50) * 12 + vbit;
        end else begin
            cli_vdata <= (out_vptr - start_line) * 12 + vbit;
        end
    end
end

logic wr_char, is_slash_n;

always @(posedge wr_clk) begin
    if (rst) begin
        not_full_yet <= 1'b1;
        start_line <= 0;
        is_slash_n <= 1'b0;
        hptr <= 0;
        vptr <= 0;
    end else begin
        if (wr_en) begin
            if (wdata[7:0] == 8'd10) begin              // \n需要清空下一行，然后放在行首
                vptr <= vptr + 1;
                hptr <= 0;
                if (vptr == 49) begin
                    vptr <= 0;
                    if (not_full_yet) begin
                        not_full_yet <= 1'b0;
                        start_line <= 1;
                    end
                end
                if (not_full_yet == 0) begin
                    if (start_line < 49) begin
                        start_line <= start_line + 1;
                    end else begin
                        start_line <= 0;
                    end
                end
                is_slash_n <= 1'b1;
            end else if (wdata[7:0] == 8'd13) begin     // \r只是简单回到行首
                hptr <= 0;
            end else begin
                hptr <= hptr + 1;
                if (hptr == 99) begin
                    hptr <= 0;
                    vptr <= vptr + 1;
                    if (vptr == 49 && not_full_yet) begin
                        vptr <= 0;
                        not_full_yet <= 1'b0;
                        start_line <= 1;
                    end
                    if (not_full_yet == 0) begin
                        start_line <= start_line + 1;
                    end
                end
            end
        end

        if (is_slash_n) begin
            hptr <= hptr + 1;
            if (hptr == 99) begin
                hptr <= 0;
                is_slash_n <= 1'b0;
            end
        end
    end
end

always_comb begin
    wr_char <= 1'b0;
    if (wr_en) begin
        if (wdata[7:0] != 8'd10 && wdata[7:0] != 8'd13)  begin
            wchar <= wdata[7:0] - 32;
            wcolor <= 8'hff;
            if (wdata[16]) begin
                wcolor <= wdata[15:7];
            end
            wr_char <= 1'b1;
            if (wdata[7:0] < 32 || wdata[7:0] > 127) begin
                wchar <= 0;
                wcolor <= 0;
                wr_char <= 1'b0;
            end
        end
    end else if (is_slash_n) begin
        wchar   <= 0;
        wcolor  <= 0;
        wr_char <= 1'b1;
    end
end

cli_buff char_buff (
    .a(wloc),
    .d(wchar),
    .dpra(rloc),
    .clk(wr_clk),
    .we(wr_char),
    .dpo(rchar)
);
cli_buff color_buff (
    .a(wloc),
    .d(wcolor),
    .dpra(rloc),
    .clk(wr_clk),
    .we(wr_char),
    .dpo(rcolor)
);

logic bit_res;
logic[13:0] bitmap_loc;
assign bitmap_loc = rchar * 96 + hbit + 8 * vbit;

char_bitmap c_bitmap (
    .a(bitmap_loc),
    .spo(bit_res)
);

always_comb begin
    if (bit_res) begin
        data_out <= rcolor;
    end else begin
        data_out <= 8'h00;
    end
end

endmodule