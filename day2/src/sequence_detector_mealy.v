`timescale 1ns/1ps

// ============================================================================
// Module: sequence_detector_mealy
// Description: Mealy Sequence Detector for binary pattern "1011" with overlapping
//              detection capability. Asserted on the clock cycle the 4th bit arrives.
// ============================================================================

module sequence_detector_mealy (
    input  wire clk,
    input  wire reset,
    input  wire din,
    output wire detected
);

    localparam [1:0] S0 = 2'b00,  // None matched
                     S1 = 2'b01,  // Matched "1"
                     S2 = 2'b10,  // Matched "10"
                     S3 = 2'b11;  // Matched "101"

    reg [1:0] state;

    always @(posedge clk) begin
        if (reset) begin
            state <= S0;
        end else begin
            case (state)
                S0: state <= din ? S1 : S0;
                S1: state <= din ? S1 : S2;
                S2: state <= din ? S3 : S0;
                S3: state <= din ? S1 : S2; // If din=1, "1011" matched! Next bit '1' is potential prefix of next "1011"
                default: state <= S0;
            endcase
        end
    end

    // Mealy output depends on current state and current input
    assign detected = (state == S3) && (din == 1'b1);

endmodule
