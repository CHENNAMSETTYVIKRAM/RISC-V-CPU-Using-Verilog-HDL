`timescale 1ns/1ps

// ============================================================================
// Module: alu_parameterized
// Description: Parameterized Arithmetic Logic Unit (default WIDTH = 32).
//              Supports: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND, LUI.
//              Outputs: result, zero, negative, carry, overflow.
// ============================================================================

module alu_parameterized #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire [3:0]       alu_ctrl,
    output reg  [WIDTH-1:0] result,
    output wire             zero,
    output wire             negative,
    output reg              carry,
    output reg              overflow
);

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

    wire [4:0]      shamt = b[4:0];
    reg  [WIDTH:0]  ext_result;

    always @(*) begin
        result     = {WIDTH{1'b0}};
        carry      = 1'b0;
        overflow   = 1'b0;
        ext_result = {(WIDTH+1){1'b0}};

        case (alu_ctrl)
            ALU_ADD: begin
                ext_result = {1'b0, a} + {1'b0, b};
                result     = ext_result[WIDTH-1:0];
                carry      = ext_result[WIDTH];
                overflow   = (~a[WIDTH-1] & ~b[WIDTH-1] & result[WIDTH-1]) |
                             (a[WIDTH-1] & b[WIDTH-1] & ~result[WIDTH-1]);
            end

            ALU_SUB: begin
                ext_result = {1'b0, a} - {1'b0, b};
                result     = ext_result[WIDTH-1:0];
                carry      = ext_result[WIDTH];
                overflow   = (~a[WIDTH-1] & b[WIDTH-1] & result[WIDTH-1]) |
                             (a[WIDTH-1] & ~b[WIDTH-1] & ~result[WIDTH-1]);
            end

            ALU_SLL:  result = a << shamt;
            ALU_SLT:  result = ($signed(a) < $signed(b)) ? {{(WIDTH-1){1'b0}}, 1'b1} : {WIDTH{1'b0}};
            ALU_SLTU: result = (a < b) ? {{(WIDTH-1){1'b0}}, 1'b1} : {WIDTH{1'b0}};
            ALU_XOR:  result = a ^ b;
            ALU_SRL:  result = a >> shamt;
            ALU_SRA:  result = $signed(a) >>> shamt;
            ALU_OR:   result = a | b;
            ALU_AND:  result = a & b;
            ALU_LUI:  result = b;

            default:  result = {WIDTH{1'b0}};
        endcase
    end

    assign zero     = (result == {WIDTH{1'b0}});
    assign negative = result[WIDTH-1];

endmodule
