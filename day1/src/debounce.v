`timescale 1ns/1ps

// ============================================================================
// Module: button_debouncer
// Description: Parameterizable digital button debouncer with 2-stage
//              synchronization and stable-state integration filter.
// ============================================================================

module button_debouncer #(
    parameter DEBOUNCE_CYCLES = 16   // Number of consecutive stable cycles required
)(
    input  wire clk,
    input  wire reset,
    input  wire noisy_button,
    output reg  clean_out
);

    localparam CNT_WIDTH = (DEBOUNCE_CYCLES <= 1) ? 1 : $clog2(DEBOUNCE_CYCLES);

    reg sync_0;
    reg sync_1;
    reg [CNT_WIDTH-1:0] timer;

    // 2-stage synchronizer to prevent metastability
    always @(posedge clk) begin
        if (reset) begin
            sync_0 <= 1'b0;
            sync_1 <= 1'b0;
        end else begin
            sync_0 <= noisy_button;
            sync_1 <= sync_0;
        end
    end

    // Counter filter
    always @(posedge clk) begin
        if (reset) begin
            timer     <= {CNT_WIDTH{1'b0}};
            clean_out <= 1'b0;
        end else begin
            if (sync_1 == clean_out) begin
                timer <= {CNT_WIDTH{1'b0}};
            end else begin
                if (timer == DEBOUNCE_CYCLES - 1) begin
                    clean_out <= sync_1;
                    timer     <= {CNT_WIDTH{1'b0}};
                end else begin
                    timer <= timer + 1'b1;
                end
            end
        end
    end

endmodule
