`timescale 1ns/1ps

// ============================================================================
// Module: lfsr_8bit
// Description: 8-bit Linear Feedback Shift Register (LFSR) with maximal-length
//              Fibonacci feedback polynomial (x^8 + x^6 + x^5 + x^4 + 1).
//              Period = 2^8 - 1 = 255 non-zero pseudo-random states.
// ============================================================================

module lfsr_8bit (
    input  wire       clk,
    input  wire       reset,        // Synchronous active-high reset
    input  wire       seed_load,    // Synchronous parallel seed load
    input  wire       enable,       // Shift enable
    input  wire [7:0] seed,         // Parallel seed input
    output reg  [7:0] lfsr_out      // LFSR pseudo-random state output
);

    wire feedback;
    // Feedback taps: bits [7], [5], [4], [3] (corresponding to x^8, x^6, x^5, x^4)
    assign feedback = lfsr_out[7] ^ lfsr_out[5] ^ lfsr_out[4] ^ lfsr_out[3];

    always @(posedge clk) begin
        if (reset) begin
            lfsr_out <= 8'h01; // Avoid all-zero lockup state
        end else if (seed_load) begin
            // If user attempts to load 0, fall back to 8'h01 to preserve oscillation
            lfsr_out <= (seed != 8'h00) ? seed : 8'h01;
        end else if (enable) begin
            lfsr_out <= {lfsr_out[6:0], feedback};
        end
    end

endmodule
