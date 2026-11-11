`timescale 1ns/1ps

// ============================================================================
// Module: watchdog_timer
// Description: Parameterizable hardware watchdog timer. Decrements each clock cycle.
//              A 'kick' pulse reloads the counter. If the timer expires, a
//              single-cycle 'reset_pulse' is generated to reset the system.
// ============================================================================

module watchdog_timer #(
    parameter TIMEOUT_CYCLES = 16
)(
    input  wire clk,
    input  wire reset,       // Active-high reset
    input  wire kick,        // Reloads the countdown timer
    output reg  reset_pulse  // 1-cycle timeout recovery pulse
);

    localparam CNT_WIDTH = (TIMEOUT_CYCLES < 2) ? 1 : $clog2(TIMEOUT_CYCLES + 1);

    reg [CNT_WIDTH-1:0] count;

    always @(posedge clk) begin
        if (reset) begin
            count       <= TIMEOUT_CYCLES;
            reset_pulse <= 1'b0;
        end else if (kick) begin
            count       <= TIMEOUT_CYCLES;
            reset_pulse <= 1'b0;
        end else if (count <= 1) begin
            count       <= TIMEOUT_CYCLES; // Auto-reload after timeout
            reset_pulse <= 1'b1;           // Assert system reset pulse
        end else begin
            count       <= count - 1'b1;
            reset_pulse <= 1'b0;
        end
    end

endmodule
