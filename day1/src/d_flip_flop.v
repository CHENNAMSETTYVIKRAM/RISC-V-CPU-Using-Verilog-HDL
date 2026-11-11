`timescale 1ns/1ps

// ============================================================================
// Module: d_flip_flop
// Description: D Flip-Flop with synchronous reset, asynchronous reset, and
//              clock enable. Demonstrates robust sequential logic standards.
// ============================================================================

module d_flip_flop #(
    parameter WIDTH = 1,
    parameter ASYNC_RESET = 0   // 0: Synchronous reset, 1: Asynchronous reset
)(
    input  wire             clk,
    input  wire             reset,   // Active-high reset
    input  wire             en,      // Clock enable
    input  wire [WIDTH-1:0] d,       // Data input
    output reg  [WIDTH-1:0] q        // Registered output
);

    generate
        if (ASYNC_RESET) begin : g_async_rst
            always @(posedge clk or posedge reset) begin
                if (reset)
                    q <= {WIDTH{1'b0}};
                else if (en)
                    q <= d;
            end
        end else begin : g_sync_rst
            always @(posedge clk) begin
                if (reset)
                    q <= {WIDTH{1'b0}};
                else if (en)
                    q <= d;
            end
        end
    endgenerate

endmodule
