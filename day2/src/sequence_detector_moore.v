`timescale 1ns/1ps

// ============================================================================
// Module: sequence_detector_moore
// Description: Moore Sequence Detector for binary pattern "1011" with overlapping
//              detection capability. Output asserted in dedicated detection state S4.
// ============================================================================

module sequence_detector_moore (
    input  wire clk,
    input  wire reset,
    input  wire din,
    output wire detected
);

    localparam [2:0] S0 = 3'b000,  // None
                     S1 = 3'b001,  // "1"
                     S2 = 3'b010,  // "10"
                     S3 = 3'b011,  // "101"
                     S4 = 3'b100;  // "1011" (Detected)

    reg [2:0] state;

    always @(posedge clk) begin
        if (reset) begin
            state <= S0;
        end else begin
            case (state)
                S0: state <= din ? S1 : S0;
                S1: state <= din ? S1 : S2;
                S2: state <= din ? S3 : S0;
                S3: state <= din ? S4 : S2;
                S4: state <= din ? S1 : S2; // Overlapping: "1011" ends with '1', so if next is '0', goes to S2 ("10")
                default: state <= S0;
            endcase
        end
    end

    // Moore output depends strictly on current state
    assign detected = (state == S4);

endmodule
