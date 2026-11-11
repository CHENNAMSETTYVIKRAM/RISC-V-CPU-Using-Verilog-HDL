`timescale 1ns/1ps

module tb_configurable_counter_8bit;
    reg        clk = 0;
    reg        reset;
    reg        enable;
    reg        up_down;
    reg        load;
    reg  [7:0] load_data;
    wire [7:0] count;
    wire       max_tick;
    wire       min_tick;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    configurable_counter_8bit uut (
        .clk(clk), .reset(reset), .enable(enable), .up_down(up_down),
        .load(load), .load_data(load_data), .count(count),
        .max_tick(max_tick), .min_tick(min_tick)
    );

    initial begin
        // 1. Reset
        reset = 1; enable = 0; up_down = 1; load = 0; load_data = 8'd0;
        @(posedge clk); #1;
        reset = 0;
        tests = tests + 1;
        if (count !== 8'd0 || min_tick !== 1) begin
            $display("[FAIL] Counter Reset failed: count=%d min=%b", count, min_tick);
            errors = errors + 1;
        end

        // 2. Count up
        enable = 1; up_down = 1;
        repeat (5) @(posedge clk); #1;
        tests = tests + 1;
        if (count !== 8'd5) begin
            $display("[FAIL] Count up 5 cycles: count=%d (expected 5)", count);
            errors = errors + 1;
        end

        // 3. Count down
        up_down = 0;
        repeat (2) @(posedge clk); #1;
        tests = tests + 1;
        if (count !== 8'd3) begin
            $display("[FAIL] Count down 2 cycles: count=%d (expected 3)", count);
            errors = errors + 1;
        end

        // 4. Parallel Load
        load = 1; load_data = 8'hFE;
        @(posedge clk); #1;
        load = 0; up_down = 1;
        tests = tests + 1;
        if (count !== 8'hFE) begin
            $display("[FAIL] Parallel Load failed: count=%h (expected FE)", count);
            errors = errors + 1;
        end

        // 5. Max tick
        @(posedge clk); #1; // count becomes 8'hFF
        tests = tests + 1;
        if (count !== 8'hFF || max_tick !== 1) begin
            $display("[FAIL] Max tick check: count=%h max=%b", count, max_tick);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] configurable_counter_8bit: All %0d tests passed.", tests);
        else
            $display("[FAIL] configurable_counter_8bit: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
