`timescale 1ns/1ps

module tb_carry_adder_subtractor_8bit;
    reg  [7:0] a, b;
    reg        mode;
    wire [7:0] result;
    wire       carry_out;
    wire       overflow;

    integer errors = 0;
    integer tests  = 0;

    carry_adder_subtractor_8bit uut (
        .a(a), .b(b), .mode(mode),
        .result(result), .carry_out(carry_out), .overflow(overflow)
    );

    initial begin
        // Test 1: Addition without carry
        mode = 0; a = 8'd25; b = 8'd30; #10;
        tests = tests + 1;
        if (result !== 8'd55 || carry_out !== 0 || overflow !== 0) begin
            $display("[FAIL] Add 25 + 30: res=%d cout=%b ovf=%b", result, carry_out, overflow);
            errors = errors + 1;
        end

        // Test 2: Addition with unsigned carry
        mode = 0; a = 8'd200; b = 8'd100; #10;
        tests = tests + 1;
        if (result !== 8'd44 || carry_out !== 1 || overflow !== 0) begin
            $display("[FAIL] Add 200 + 100: res=%d cout=%b ovf=%b", result, carry_out, overflow);
            errors = errors + 1;
        end

        // Test 3: Addition with signed overflow (positive + positive = negative)
        mode = 0; a = 8'sd100; b = 8'sd50; #10; // 100 + 50 = 150 -> exceeds +127
        tests = tests + 1;
        if (overflow !== 1) begin
            $display("[FAIL] Signed overflow pos+pos: res=%d ovf=%b", result, overflow);
            errors = errors + 1;
        end

        // Test 4: Subtraction without borrow
        mode = 1; a = 8'd50; b = 8'd20; #10;
        tests = tests + 1;
        if (result !== 8'd30 || carry_out !== 1 || overflow !== 0) begin
            $display("[FAIL] Sub 50 - 20: res=%d cout=%b ovf=%b", result, carry_out, overflow);
            errors = errors + 1;
        end

        // Test 5: Subtraction with borrow (A < B)
        mode = 1; a = 8'd10; b = 8'd25; #10;
        tests = tests + 1;
        if (carry_out !== 0) begin
            $display("[FAIL] Sub borrow 10 - 25: res=%d cout=%b", result, carry_out);
            errors = errors + 1;
        end

        // Test 6: Subtraction with signed overflow (negative - positive = positive)
        mode = 1; a = -8'sd100; b = 8'sd50; #10; // -100 - 50 = -150 -> below -128
        tests = tests + 1;
        if (overflow !== 1) begin
            $display("[FAIL] Signed overflow neg-pos: res=%d ovf=%b", result, overflow);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] carry_adder_subtractor_8bit: All %0d tests passed.", tests);
        else
            $display("[FAIL] carry_adder_subtractor_8bit: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
