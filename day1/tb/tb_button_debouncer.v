`timescale 1ns/1ps

module tb_button_debouncer;
    reg clk = 0;
    reg reset;
    reg noisy_button;
    wire clean_out;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    button_debouncer #(.DEBOUNCE_CYCLES(4)) uut (
        .clk(clk), .reset(reset), .noisy_button(noisy_button), .clean_out(clean_out)
    );

    initial begin
        reset = 1; noisy_button = 0;
        repeat (2) @(posedge clk); #1;
        reset = 0;

        // Apply rapid glitches (bounces) < 4 cycles
        noisy_button = 1; #7;
        noisy_button = 0; #6;
        noisy_button = 1; #8;
        noisy_button = 0; #10;
        tests = tests + 1;
        if (clean_out !== 0) begin
            $display("[FAIL] Debouncer let glitch through: clean_out=%b", clean_out);
            errors = errors + 1;
        end

        // Apply stable high for > 4 cycles + 2 sync stages
        noisy_button = 1;
        repeat (8) @(posedge clk); #1;
        tests = tests + 1;
        if (clean_out !== 1) begin
            $display("[FAIL] Debouncer did not transition to high after stable input: clean_out=%b", clean_out);
            errors = errors + 1;
        end

        // Apply stable low for > 4 cycles
        noisy_button = 0;
        repeat (8) @(posedge clk); #1;
        tests = tests + 1;
        if (clean_out !== 0) begin
            $display("[FAIL] Debouncer did not transition to low after stable input: clean_out=%b", clean_out);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] button_debouncer: All %0d tests passed.", tests);
        else
            $display("[FAIL] button_debouncer: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
