`timescale 1ns/1ps

module tb_priority_encoder_8to3;
    reg  [7:0] in;
    wire [2:0] code;
    wire       valid;

    integer errors = 0;
    integer tests  = 0;

    priority_encoder_8to3 uut (
        .in(in), .code(code), .valid(valid)
    );

    initial begin
        // None active
        in = 8'b0000_0000; #10;
        tests = tests + 1;
        if (valid !== 0) begin
            $display("[FAIL] In=0 should have valid=0");
            errors = errors + 1;
        end

        // Bit 0 only
        in = 8'b0000_0001; #10;
        tests = tests + 1;
        if (code !== 3'd0 || valid !== 1) begin
            $display("[FAIL] Bit 0 active failed: code=%d valid=%b", code, valid);
            errors = errors + 1;
        end

        // Bit 4 active with lower bits active (priority check)
        in = 8'b0001_0101; #10;
        tests = tests + 1;
        if (code !== 3'd4 || valid !== 1) begin
            $display("[FAIL] Priority check bit 4 failed: code=%d (expected 4)", code);
            errors = errors + 1;
        end

        // Highest bit 7 active
        in = 8'b1011_1111; #10;
        tests = tests + 1;
        if (code !== 3'd7 || valid !== 1) begin
            $display("[FAIL] Priority check bit 7 failed: code=%d (expected 7)", code);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] priority_encoder_8to3: All %0d tests passed.", tests);
        else
            $display("[FAIL] priority_encoder_8to3: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
