`timescale 1ns/1ps

// ============================================================================
// Module: sync_fifo_16x8
// Description: Synchronous FIFO memory with circular write/read pointers,
//              word count tracker, full/empty flags, and overflow/underflow
//              guard logic. Supports simultaneous read and write.
// ============================================================================

module sync_fifo_16x8 #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4   // Depth = 2^4 = 16
)(
    input  wire                  clk,
    input  wire                  reset,      // Synchronous active-high reset
    input  wire                  wr_en,      // Write request
    input  wire                  rd_en,      // Read request
    input  wire [DATA_WIDTH-1:0] data_in,    // Input data
    output reg  [DATA_WIDTH-1:0] data_out,   // Output data
    output wire                  full,       // FIFO is full
    output wire                  empty,      // FIFO is empty
    output reg  [ADDR_WIDTH:0]   count       // Occupancy count (0 to 16)
);

    localparam DEPTH = 1 << ADDR_WIDTH;

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH-1:0] wr_ptr;
    reg [ADDR_WIDTH-1:0] rd_ptr;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    wire do_write = wr_en && !full;
    wire do_read  = rd_en && !empty;

    always @(posedge clk) begin
        if (reset) begin
            wr_ptr   <= {ADDR_WIDTH{1'b0}};
            rd_ptr   <= {ADDR_WIDTH{1'b0}};
            count    <= {(ADDR_WIDTH+1){1'b0}};
            data_out <= {DATA_WIDTH{1'b0}};
        end else begin
            case ({do_write, do_read})
                2'b10: begin // Write only
                    mem[wr_ptr] <= data_in;
                    wr_ptr      <= wr_ptr + 1'b1;
                    count       <= count + 1'b1;
                end
                2'b01: begin // Read only
                    data_out <= mem[rd_ptr];
                    rd_ptr   <= rd_ptr + 1'b1;
                    count    <= count - 1'b1;
                end
                2'b11: begin // Simultaneous read and write
                    mem[wr_ptr] <= data_in;
                    wr_ptr      <= wr_ptr + 1'b1;
                    data_out    <= mem[rd_ptr];
                    rd_ptr      <= rd_ptr + 1'b1;
                    count       <= count; // Unchanged
                end
                default: ; // Idle
            endcase
        end
    end

endmodule
