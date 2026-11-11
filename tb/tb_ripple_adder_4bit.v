`timescale 1ns/1ps
module tb_ripple_adder_4bit;
    reg [3:0] a, b;
    reg cin;
    wire [3:0] sum;
    wire cout;
    reg [4:0] expected;
    integer i, j, k;

    ripple_adder_4bit dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));
    initial begin
        for (i = 0; i < 16; i = i + 1)
            for (j = 0; j < 16; j = j + 1)
                for (k = 0; k < 2; k = k + 1) begin
                    a = i; b = j; cin = k;
                    #1;
                    expected = i + j + k;
                    if ({cout, sum} !== expected)
                        $fatal(1, "adder mismatch: a=%0d b=%0d cin=%0d", i, j, k);
                end
        $display("PASS: 512 adder vectors");
        $finish;
    end
endmodule
