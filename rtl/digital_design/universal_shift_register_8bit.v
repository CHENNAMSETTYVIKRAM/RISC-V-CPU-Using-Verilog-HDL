`timescale 1ns/1ps

// ============================================================================
// Module: universal_shift_register_8bit
// Description: 8-bit Universal Shift Register supporting 4 operations:
//              00: Hold
//              01: Shift Left  (data shifts towards MSB, inserts serial_left at LSB)
//              10: Shift Right (data shifts towards LSB, inserts serial_right at MSB)
//              11: Parallel Load
// ============================================================================

module universal_shift_register_8bit #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             reset,        // Synchronous active-high reset
    input  wire [1:0]       mode,         // Operation select
    input  wire [WIDTH-1:0] parallel_in,  // Parallel data input
    input  wire             serial_left,  // Serial bit in for shift-left
    input  wire             serial_right, // Serial bit in for shift-right
    output reg  [WIDTH-1:0] data_out      // Parallel register output
);

    always @(posedge clk) begin
        if (reset) begin
            data_out <= {WIDTH{1'b0}};
        end else begin
            case (mode)
                2'b00: data_out <= data_out;                                // Hold
                2'b01: data_out <= {data_out[WIDTH-2:0], serial_left};      // Shift left
                2'b10: data_out <= {serial_right, data_out[WIDTH-1:1]};      // Shift right
                2'b11: data_out <= parallel_in;                             // Parallel load
                default: data_out <= data_out;
            endcase
        end
    end

endmodule
