`timescale 1ns/1ps
module tb_registered_adder_4bit;
    reg clk, reset;
    reg [3:0] a, b;
    reg cin;
    wire [3:0] sum;
    wire cout;
    registered_adder_4bit dut (.clk(clk), .reset(reset), .a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));
    always #5 clk = ~clk;

    initial begin
        clk=0; reset=1; a=0; b=0; cin=0;
        @(posedge clk); #1;
        if ({cout,sum} !== 5'b0) $fatal(1, "synchronous reset failed");
        @(negedge clk); reset=0; a=4'd15; b=4'd1;
        @(posedge clk); #1;
        if ({cout,sum} !== 5'b10000) $fatal(1, "registered addition failed");
        $display("PASS: registered adder reset and capture");
        $finish;
    end
endmodule
