`timescale 1ns/1ps

module tb_d_flip_flop;
    reg clk = 0;
    reg reset;
    reg en;
    reg d;
    wire q_sync, q_async;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    d_flip_flop #(.WIDTH(1), .ASYNC_RESET(0)) dff_sync (
        .clk(clk), .reset(reset), .en(en), .d(d), .q(q_sync)
    );

    d_flip_flop #(.WIDTH(1), .ASYNC_RESET(1)) dff_async (
        .clk(clk), .reset(reset), .en(en), .d(d), .q(q_async)
    );

    initial begin
        // Reset check
        reset = 1; en = 0; d = 1;
        #2;
        tests = tests + 1;
        if (q_async !== 0) begin
            $display("[FAIL] Async reset did not take effect immediately");
            errors = errors + 1;
        end

        @(posedge clk); #1;
        reset = 0;
        tests = tests + 1;
        if (q_sync !== 0 || q_async !== 0) begin
            $display("[FAIL] Synchronous reset check failed");
            errors = errors + 1;
        end

        // Clock enable disabled check
        en = 0; d = 1;
        @(posedge clk); #1;
        tests = tests + 1;
        if (q_sync !== 0) begin
            $display("[FAIL] Enable=0 failed: Q changed unexpectedly");
            errors = errors + 1;
        end

        // Clock enable active check
        en = 1; d = 1;
        @(posedge clk); #1;
        tests = tests + 1;
        if (q_sync !== 1 || q_async !== 1) begin
            $display("[FAIL] Enable=1 failed: Q did not capture D=1");
            errors = errors + 1;
        end

        d = 0;
        @(posedge clk); #1;
        tests = tests + 1;
        if (q_sync !== 0 || q_async !== 0) begin
            $display("[FAIL] Enable=1 failed: Q did not capture D=0");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] d_flip_flop: All %0d tests passed.", tests);
        else
            $display("[FAIL] d_flip_flop: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
