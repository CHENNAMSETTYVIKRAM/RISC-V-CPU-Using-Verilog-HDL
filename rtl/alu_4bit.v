module alu_4bit (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [2:0] opcode,
    output reg  [3:0] result,
    output reg        carry_borrow,
    output wire       zero
);
    reg [4:0] arithmetic;

    always @* begin
        result       = 4'b0000;
        carry_borrow = 1'b0;
        arithmetic   = 5'b00000;

        case (opcode)
            3'b000: begin
                arithmetic   = {1'b0, a} + {1'b0, b};
                result       = arithmetic[3:0];
                carry_borrow = arithmetic[4];
            end
            3'b001: begin
                result       = a - b;
                carry_borrow = (a < b);
            end
            3'b010: result = a & b;
            3'b011: result = a | b;
            3'b100: result = a ^ b;
            default: begin
                result       = 4'b0000;
                carry_borrow = 1'b0;
            end
        endcase
    end

    assign zero = (result == 4'b0000);
endmodule
