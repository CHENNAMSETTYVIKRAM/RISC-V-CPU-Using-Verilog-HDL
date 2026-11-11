`timescale 1ns/1ps

module tb_decoder_3to8;
    reg  [2:0] in;
    reg        enable;
    wire [7:0] out;

    integer errors = 0;
    integer tests  = 0;
    integer i;

    decoder_3to8 uut (
        .in(in), .enable(enable), .out(out)
    );

    initial begin
        // When enable = 0, output is all 0s
        enable = 0; in = 3'd3; #10;
        tests = tests + 1;
        if (out !== 8'b0000_0000) begin
            $display("[FAIL] Enable=0 failed: out=%b", out);
            errors = errors + 1;
        end

        // Iterate through all 8 inputs with enable=1
        enable = 1;
        for (i = 0; i < 8; i = i + 1) begin
            in = i; #10;
            tests = tests + 1;
            if (out !== (8'b0000_0001 << i)) begin
                $display("[FAIL] Decoder input %0d failed: out=%b (expected %b)", i, out, (8'b0000_0001 << i));
                errors = errors + 1;
            end
        end

        if (errors == 0)
            $display("[PASS] decoder_3to8: All %0d tests passed.", tests);
        else
            $display("[FAIL] decoder_3to8: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
