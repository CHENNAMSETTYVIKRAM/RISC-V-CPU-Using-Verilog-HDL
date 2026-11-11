`timescale 1ns/1ps

// ============================================================================
// Module: carry_adder_subtractor_8bit
// Description: Synthesizable 8-bit ripple-carry adder / subtractor with signed
//              overflow detection and carry-out.
// Modes:
//   mode = 0: Addition       (Result = A + B, Carry = unsigned carry-out)
//   mode = 1: Subtraction    (Result = A - B, Carry = unsigned borrow / inverted carry)
// ============================================================================

module full_adder_1b (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

module carry_adder_subtractor_8bit #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             mode,       // 0 = Add, 1 = Subtract
    output wire [WIDTH-1:0] result,
    output wire             carry_out,
    output wire             overflow
);
    wire [WIDTH-1:0] b_eff;
    wire [WIDTH:0]   carry;

    assign b_eff    = b ^ {WIDTH{mode}};
    assign carry[0] = mode;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : g_adder_slice
            full_adder_1b fa (
                .a   (a[i]),
                .b   (b_eff[i]),
                .cin (carry[i]),
                .sum (result[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

    assign carry_out = carry[WIDTH];
    // Signed overflow occurs when two numbers of the same sign produce a result of opposite sign.
    assign overflow  = carry[WIDTH] ^ carry[WIDTH-1];

endmodule
