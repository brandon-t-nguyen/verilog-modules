`include "test_defs.vh"

module test_dpram_rw;

localparam DATA_WIDTH=8;
localparam DATA_DEPTH=256;

logic clk; always #5 clk = !clk;
logic rst;

// Read port
logic                          rd_en;
logic [$clog2(DATA_DEPTH)-1:0] rd_addr;
wire  [DATA_WIDTH-1:0]         rd_data;

// Write port
logic                          wr_en;
logic [$clog2(DATA_DEPTH)-1:0] wr_addr;
logic [DATA_WIDTH-1:0]         wr_data;

dpram_rw #(.DATA_WIDTH(DATA_WIDTH), .DATA_DEPTH(DATA_DEPTH)) ram
(
    .clk,
    .rst,
    .rd_en,
    .rd_addr,
    .rd_data,
    .wr_en,
    .wr_addr,
    .wr_data
);

logic [DATA_DEPTH-1:0][DATA_WIDTH-1:0] expect_data;

task write;
input [$clog2(DATA_DEPTH)-1:0] addr;
input [DATA_WIDTH-1:0] data;
begin
    wr_en = 1;
    wr_addr = addr;
    wr_data = data;
    @(negedge clk);
    wr_en = 0;
    expect_data[addr] = data;
end
endtask

task read;
input [$clog2(DATA_DEPTH)-1:0] addr;
begin
    rd_en = 1;
    rd_addr = addr;
    @(negedge clk);
    rd_en = 0;
end
endtask

task reset;
begin
    expect_data = 'x;
    clk = 0;
    rst = 1;
    rd_en = 0;
    wr_en = 0;
    rd_addr = '0;
    wr_addr = '0;
    wr_data = '0;
    @(negedge clk);
    @(negedge clk);
    rst = 0;
end
endtask

int i;
`T_VARS
initial begin
    $dumpfile("wave_dpram_rw.vcd");
    $dumpvars(0, test_dpram_rw);

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
        rd_addr = i;
        @(negedge clk);
        `T_EXPECT_EQ(rd_data, expect_data[0], "0x%1h")
    end

    `T_FINISH
end

endmodule
