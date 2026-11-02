`timescale 1ns/1ps

module half_adder4 (
    input  [3:0] A,
    input  [3:0] B,
    output [3:0] Sum,
    output [3:0] Carry
);

assign Sum = A ^ B;
assign Carry = A & B;

endmodule