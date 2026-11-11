`timescale 1ns/1ps

// ============================================================================
// Module: riscv_m_extension
// Description: RV32M Standard Extension for Integer Multiplication and Division.
//              Supports:
//                - MUL:    Lower 32-bits of (rs1 * rs2)
//                - MULH:   Upper 32-bits of signed(rs1) * signed(rs2)
//                - MULHSU: Upper 32-bits of signed(rs1) * unsigned(rs2)
//                - MULHU:  Upper 32-bits of unsigned(rs1) * unsigned(rs2)
//                - DIV:    Signed division rs1 / rs2 (with div-by-zero & overflow handling)
//                - DIVU:   Unsigned division rs1 / rs2 (with div-by-zero handling)
//                - REM:    Signed remainder rs1 % rs2 (with div-by-zero & overflow handling)
//                - REMU:   Unsigned remainder rs1 % rs2 (with div-by-zero handling)
//
// Corner Case Specifications per RISC-V Unprivileged ISA v20191213:
//   - Division by zero:
//       DIV(x, 0)  = -1 (32'hFFFFFFFF)
//       DIVU(x, 0) = 2^32 - 1 (32'hFFFFFFFF)
//       REM(x, 0)  = x (dividend)
//       REMU(x, 0) = x (dividend)
//   - Signed overflow (-2^31 / -1 = 32'h80000000 / 32'hFFFFFFFF):
//       DIV(-2^31, -1) = -2^31 (32'h80000000)
//       REM(-2^31, -1) = 0
// ============================================================================

module riscv_m_extension (
    input  wire [31:0] a,          // rs1 operand
    input  wire [31:0] b,          // rs2 operand
    input  wire [2:0]  funct3,     // M-extension function selector
    output reg  [31:0] result
);

    localparam M_MUL    = 3'b000,
               M_MULH   = 3'b001,
               M_MULHSU = 3'b010,
               M_MULHU  = 3'b011,
               M_DIV    = 3'b100,
               M_DIVU   = 3'b101,
               M_REM    = 3'b110,
               M_REMU   = 3'b111;

    // 64-bit multiplication products
    wire signed [63:0] prod_ss  = $signed(a) * $signed(b);
    wire signed [63:0] prod_su  = $signed(a) * $signed({1'b0, b});
    wire        [63:0] prod_uu  = a * b;

    // Corner case identification
    wire is_div_by_zero = (b == 32'd0);
    wire is_signed_overflow = (a == 32'h80000000) && (b == 32'hFFFFFFFF);

    always @(*) begin
        case (funct3)
            M_MUL:    result = prod_uu[31:0];
            M_MULH:   result = prod_ss[63:32];
            M_MULHSU: result = prod_su[63:32];
            M_MULHU:  result = prod_uu[63:32];

            M_DIV: begin
                if (is_div_by_zero)
                    result = 32'hFFFFFFFF;
                else if (is_signed_overflow)
                    result = 32'h80000000;
                else
                    result = $signed(a) / $signed(b);
            end

            M_DIVU: begin
                if (is_div_by_zero)
                    result = 32'hFFFFFFFF;
                else
                    result = a / b;
            end

            M_REM: begin
                if (is_div_by_zero)
                    result = a;
                else if (is_signed_overflow)
                    result = 32'd0;
                else
                    result = $signed(a) % $signed(b);
            end

            M_REMU: begin
                if (is_div_by_zero)
                    result = a;
                else
                    result = a % b;
            end

            default: result = 32'd0;
        endcase
    end

endmodule
