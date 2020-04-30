/*
 * Positive edge clocked Dual port RAM with a synchronous read port and a synchronous write port
 */
module dpram_rw #(parameter DATA_WIDTH=8, parameter DATA_DEPTH=256)
(
    input clk,
    input rst,

    // Read port
    input                          rd_en,
    input [$clog2(DATA_DEPTH)-1:0] rd_addr,
    output [DATA_WIDTH-1:0]        rd_data,

    // Write port
    input                          wr_en,
    input [$clog2(DATA_DEPTH)-1:0] wr_addr,
    input [DATA_WIDTH-1:0]         wr_data
);

logic [DATA_DEPTH-1:0][DATA_WIDTH-1:0] data;

task automatic reset_data;
int i;
begin
    for (i = 0; i < DATA_DEPTH; i = i + 1) data[i] <= '0;
end
endtask

initial begin
    reset_data();
end

logic [DATA_WIDTH-1:0] rd_buffer; assign rd_data = rd_buffer;

always_ff @(posedge clk) begin
    if (rst) begin
        reset_data();
        rd_buffer <= '0;
    end else begin
        if (rd_en) rd_buffer     <= data[rd_addr];
        if (wr_en) data[wr_addr] <= wr_data;
    end
end

endmodule
