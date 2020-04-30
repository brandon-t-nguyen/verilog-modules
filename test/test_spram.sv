`include "test_defs.vh"

module test_spram_rw;

localparam DATA_WIDTH=8;
localparam DATA_DEPTH=256;

logic clk; always #5 clk = !clk;
logic rst;

// Read/write port
logic                          en;
logic                          wr_en;
logic [$clog2(DATA_DEPTH)-1:0] addr;
wire  [DATA_WIDTH-1:0]         rd_data;
logic [DATA_WIDTH-1:0]         wr_data;

spram #(.DATA_WIDTH(DATA_WIDTH), .DATA_DEPTH(DATA_DEPTH)) ram
(
    .clk,
    .rst,
    .en,
    .wr_en,
    .addr,
    .rd_data,
    .wr_data
);

logic [DATA_DEPTH-1:0][DATA_WIDTH-1:0] expect_data;

task write;
input [$clog2(DATA_DEPTH)-1:0] arg_addr;
input [DATA_WIDTH-1:0] data;
begin
    en    = 1;
    wr_en = 1;
    addr = arg_addr;
    wr_data = data;
    @(negedge clk);
    wr_en = 0;
    expect_data[arg_addr] = data;
end
endtask

task read;
input [$clog2(DATA_DEPTH)-1:0] arg_addr;
begin
    en = 1;
    addr = arg_addr;
    @(negedge clk);
    en = 0;
end
endtask

task reset;
begin
    expect_data = 'x;
    clk = 0;
    rst = 1;
    en = 0;
    wr_en = 0;
    addr = '0;
    wr_data = '0;
    @(negedge clk);
    @(negedge clk);
    rst = 0;
end
endtask

int i;
`T_VARS
initial begin
    $dumpfile("wave_spram.vcd");
    $dumpvars(0, test_spram);

    reset();

    `T_TEST("write-read")
    write(0, 8'hde);
    write(1, 8'had);
    write(2, 8'hbe);
    write(3, 8'hef);
    read(0); `T_EXPECT_EQ(rd_data, expect_data[0], "0x%1h")
    read(1); `T_EXPECT_EQ(rd_data, expect_data[1], "0x%1h")
    read(2); `T_EXPECT_EQ(rd_data, expect_data[2], "0x%1h")
    read(3); `T_EXPECT_EQ(rd_data, expect_data[3], "0x%1h")

    `T_TEST("striping")
    for (i = 0; i < DATA_DEPTH; i = i + 1) begin
        write(i, i % 2 ? 8'ha5 : 8'h5a);
    end
    for (i = 0; i < DATA_DEPTH; i = i + 1) begin
        read(i); `T_EXPECT_EQ(rd_data, expect_data[i], "0x%1h")
    end

    `T_TEST("random-data")
    for (i = 0; i < DATA_DEPTH; i = i + 1) begin
        write(i, $random() % 256);
    end
    for (i = 0; i < DATA_DEPTH; i = i + 1) begin
        read(i); `T_EXPECT_EQ(rd_data, expect_data[i], "0x%1h")
    end

    `T_TEST("read-disable")
    read(0);
    for (i = 0; i < DATA_DEPTH; i = i + 1) begin
        addr = i;
        @(negedge clk);
        `T_EXPECT_EQ(rd_data, expect_data[0], "0x%1h")
    end

    `T_FINISH
end

endmodule
