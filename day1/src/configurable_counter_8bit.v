`timescale 1ns/1ps

// ============================================================================
// Module: configurable_counter_8bit
// Description: Synchronous 8-bit up/down counter with synchronous reset,
//              synchronous load, count enable, and terminal count flags.
// ============================================================================

module configurable_counter_8bit #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             reset,       // Synchronous active-high reset
    input  wire             enable,      // Count enable
    input  wire             up_down,     // 1 = Count up, 0 = Count down
    input  wire             load,        // Synchronous load enable
    input  wire [WIDTH-1:0] load_data,   // Parallel data to load
    output reg  [WIDTH-1:0] count,       // Counter output
    output wire             max_tick,    // Asserted when count == all 1s
    output wire             min_tick     // Asserted when count == 0
);

    always @(posedge clk) begin
        if (reset) begin
            count <= {WIDTH{1'b0}};
        end else if (load) begin
            count <= load_data;
        end else if (enable) begin
            if (up_down)
                count <= count + 1'b1;
            else
                count <= count - 1'b1;
        end
    end

    assign max_tick = (count == {WIDTH{1'b1}});
    assign min_tick = (count == {WIDTH{1'b0}});

endmodule
