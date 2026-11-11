`timescale 1ns/1ps

// ============================================================================
// Module: sync_ram_16x8
// Description: Synchronous single-port RAM (16 words x 8 bits).
//              Synthesizable to FPGA block RAM or distributed LUT RAM.
// ============================================================================

module sync_ram_16x8 #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  we,        // Write enable
    input  wire [ADDR_WIDTH-1:0] addr,      // 4-bit word address
    input  wire [DATA_WIDTH-1:0] data_in,   // Data to write
    output reg  [DATA_WIDTH-1:0] data_out   // Registered data output
);

    localparam DEPTH = 1 << ADDR_WIDTH;
    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];

    always @(posedge clk) begin
        if (we) begin
            memory[addr] <= data_in;
        end
        data_out <= memory[addr];
    end

endmodule
