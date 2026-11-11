`timescale 1ns/1ps

// ============================================================================
// Module: priority_encoder_8to3_ifelse
// Description: 8-to-3 Priority Encoder implemented using an if-else priority tree.
//              Bit 7 has highest priority, bit 0 lowest.
//              Outputs binary index and valid flag.
// ============================================================================

module priority_encoder_8to3_ifelse (
    input  wire [7:0] in,
    output reg  [2:0] code,
    output reg        valid
);

    always @(*) begin
        valid = 1'b1;
        if (in[7])      code = 3'd7;
        else if (in[6]) code = 3'd6;
        else if (in[5]) code = 3'd5;
        else if (in[4]) code = 3'd4;
        else if (in[3]) code = 3'd3;
        else if (in[2]) code = 3'd2;
        else if (in[1]) code = 3'd1;
        else if (in[0]) code = 3'd0;
        else begin
            code  = 3'd0;
            valid = 1'b0;
        end
    end

endmodule
