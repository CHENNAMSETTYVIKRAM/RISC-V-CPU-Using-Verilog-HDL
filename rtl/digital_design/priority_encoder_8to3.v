`timescale 1ns/1ps

// ============================================================================
// Module: priority_encoder_8to3
// Description: 8-to-3 Priority Encoder where bit 7 has highest priority.
//              Outputs binary encoded index of highest active input and 'valid'.
// ============================================================================

module priority_encoder_8to3 (
    input  wire [7:0] in,
    output reg  [2:0] code,
    output reg        valid
);

    always @(*) begin
        valid = 1'b1;
        casez (in)
            8'b1???????: code = 3'd7;
            8'b01??????: code = 3'd6;
            8'b001?????: code = 3'd5;
            8'b0001????: code = 3'd4;
            8'b00001???: code = 3'd3;
            8'b000001??: code = 3'd2;
            8'b0000001?: code = 3'd1;
            8'b00000001: code = 3'd0;
            default: begin
                code  = 3'd0;
                valid = 1'b0;
            end
        endcase
    end

endmodule
