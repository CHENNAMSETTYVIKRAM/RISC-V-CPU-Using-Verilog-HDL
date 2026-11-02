`timescale 1ns/1ps
module tb_alu_4bit;
    reg [3:0] a, b;
    reg [2:0] opcode;
    wire [3:0] result;
    wire carry_borrow, zero;
    alu_4bit dut (.a(a), .b(b), .opcode(opcode), .result(result), .carry_borrow(carry_borrow), .zero(zero));

    task check;
        input [3:0] want_result;
        input want_flag;
        input want_zero;
        begin
            #1;
            if ({result, carry_borrow, zero} !== {want_result, want_flag, want_zero})
                $fatal(1, "ALU mismatch opcode=%b got %b%b%b", opcode, result, carry_borrow, zero);
        end
    endtask

    initial begin
        a=4'd15; b=4'd1; opcode=3'b000; check(4'd0,1'b1,1'b1);
        a=4'd3; b=4'd5; opcode=3'b001; check(4'd14,1'b1,1'b0);
        a=4'b0101; b=4'b0011; opcode=3'b010; check(4'b0001,1'b0,1'b0);
        opcode=3'b011; check(4'b0111,1'b0,1'b0);
        opcode=3'b100; check(4'b0110,1'b0,1'b0);
        opcode=3'b111; check(4'b0000,1'b0,1'b1);
        $display("PASS: ALU operation and flag examples");
        $finish;
    end
endmodule
