`timescale 1ns/1ps

module tb_watchdog_timer;
    reg clk = 0;
    reg reset;
    reg kick;
    wire reset_pulse;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    watchdog_timer #(.TIMEOUT_CYCLES(6)) uut (
        .clk(clk), .reset(reset), .kick(kick), .reset_pulse(reset_pulse)
    );

    initial begin
        reset = 1; kick = 0;
        @(posedge clk); #1;
        reset = 0;
        tests = tests + 1;
        if (reset_pulse !== 0) begin
            $display("[FAIL] Reset pulse asserted during reset");
            errors = errors + 1;
        end

        // Keep watchdog alive by kicking every 3 cycles
        repeat (3) begin
            repeat (3) @(posedge clk); #1;
            kick = 1;
            @(posedge clk); #1;
            kick = 0;
            if (reset_pulse !== 0) begin
                $display("[FAIL] Watchdog timed out despite kick!");
                errors = errors + 1;
            end
        end
        tests = tests + 1;

        // Allow watchdog to expire (no kick for 7 cycles)
        repeat (6) @(posedge clk); #1;
        tests = tests + 1;
        if (reset_pulse !== 1) begin
            $display("[FAIL] Watchdog did not assert reset_pulse on timeout");
            errors = errors + 1;
        end

        // Ensure pulse is only 1 cycle
        @(posedge clk); #1;
        tests = tests + 1;
        if (reset_pulse !== 0) begin
            $display("[FAIL] Watchdog reset pulse lasted > 1 cycle");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] watchdog_timer: All %0d tests passed.", tests);
        else
            $display("[FAIL] watchdog_timer: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
