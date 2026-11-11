`timescale 1ns/1ps

// ============================================================================
// Module: riscv_barrel_shifter
// Description: Standalone 32-bit barrel shifter supporting logical left,
//              logical right, and arithmetic right shifts.
// Shift Types:
//   2'b00: SLL (Shift Left Logical)
//   2'b01: SRL (Shift Right Logical)
//   2'b10: SRA (Shift Right Arithmetic)
// ============================================================================

module riscv_barrel_shifter (
    input  wire [31:0] data_in,
    input  wire [4:0]  shamt,
    input  wire [1:0]  shift_type,
    output reg  [31:0] data_out
);

    always @(*) begin
        case (shift_type)
            2'b00:   data_out = data_in << shamt;
            2'b01:   data_out = data_in >> shamt;
            2'b10:   data_out = $signed(data_in) >>> shamt;
            default: data_out = 32'd0;
        endcase
    end

endmodule
