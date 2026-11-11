`timescale 1ns/1ps

// ============================================================================
// Module: edge_detector
// Description: Multi-mode edge detector with integrated 2-stage input synchronizer.
//              Generates clean single-cycle pulses for rising, falling, and both edges.
// ============================================================================

module edge_detector (
    input  wire clk,
    input  wire reset,
    input  wire async_in,        // Asynchronous or raw input signal
    output wire sync_out,        // Synchronized level
    output wire posedge_pulse,   // 1-cycle pulse on 0 -> 1 transition
    output wire negedge_pulse,   // 1-cycle pulse on 1 -> 0 transition
    output wire anyedge_pulse    // 1-cycle pulse on any transition
);

    reg meta_flop;
    reg sync_flop;
    reg delay_flop;

    always @(posedge clk) begin
        if (reset) begin
            meta_flop  <= 1'b0;
            sync_flop  <= 1'b0;
            delay_flop <= 1'b0;
        end else begin
            meta_flop  <= async_in;
            sync_flop  <= meta_flop;
            delay_flop <= sync_flop;
        end
    end

    assign sync_out      = sync_flop;
    assign posedge_pulse = sync_flop & ~delay_flop;
    assign negedge_pulse = ~sync_flop & delay_flop;
    assign anyedge_pulse = sync_flop ^ delay_flop;

endmodule
