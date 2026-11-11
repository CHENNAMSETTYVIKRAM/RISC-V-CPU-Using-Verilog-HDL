`timescale 1ns/1ps

// ============================================================================
// Module: riscv_alu
// Description: Complete 32-bit RV32I Arithmetic Logic Unit (ALU).
//              Implements all arithmetic, logic, comparison, and shift operations
//              defined in the RISC-V Unprivileged ISA Specification.
// ============================================================================

module riscv_alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero,
    output wire        negative,
    output reg         carry,
    output reg         overflow
);

    // ALU Control Operations:
    localparam ALU_ADD  = 4'b0000,
               ALU_SUB  = 4'b1000,
               ALU_SLL  = 4'b0001,
               ALU_SLT  = 4'b0010,
               ALU_SLTU = 4'b0011,
               ALU_XOR  = 4'b0100,
               ALU_SRL  = 4'b0101,
               ALU_SRA  = 4'b1101,
               ALU_OR   = 4'b0110,
               ALU_AND  = 4'b0111,
               ALU_LUI  = 4'b1111;

    wire [4:0]  shamt = b[4:0];
    reg  [32:0] ext_result;

    always @(*) begin
        result     = 32'd0;
        carry      = 1'b0;
        overflow   = 1'b0;
        ext_result = 33'd0;

        case (alu_ctrl)
            ALU_ADD: begin
                ext_result = {1'b0, a} + {1'b0, b};
                result     = ext_result[31:0];
                carry      = ext_result[32];
                // Signed overflow: positive + positive = negative OR negative + negative = positive
                overflow   = (~a[31] & ~b[31] & result[31]) | (a[31] & b[31] & ~result[31]);
            end

            ALU_SUB: begin
                ext_result = {1'b0, a} - {1'b0, b};
                result     = ext_result[31:0];
                carry      = ext_result[32];
                // Signed overflow: positive - negative = negative OR negative - positive = positive
                overflow   = (~a[31] & b[31] & result[31]) | (a[31] & ~b[31] & ~result[31]);
            end

            ALU_SLL:  result = a << shamt;
            ALU_SLT:  result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            ALU_SLTU: result = (a < b) ? 32'd1 : 32'd0;
            ALU_XOR:  result = a ^ b;
            ALU_SRL:  result = a >> shamt;
            ALU_SRA:  result = $signed(a) >>> shamt;
            ALU_OR:   result = a | b;
            ALU_AND:  result = a & b;
            ALU_LUI:  result = b; // Pass B directly (used for LUI)

            default:  result = 32'd0;
        endcase
    end

    assign zero     = (result == 32'd0);
    assign negative = result[31];

endmodule
