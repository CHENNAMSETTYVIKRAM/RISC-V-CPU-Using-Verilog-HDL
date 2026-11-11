`timescale 1ns/1ps

module tb_lfsr_8bit;
    reg clk = 0;
    reg reset;
    reg seed_load;
    reg enable;
    reg [7:0] seed;
    wire [7:0] lfsr_out;

    integer errors = 0;
    integer tests  = 0;
    integer step;
    reg [7:0] initial_val;

    always #5 clk = ~clk;

    lfsr_8bit uut (
        .clk(clk), .reset(reset), .seed_load(seed_load),
        .enable(enable), .seed(seed), .lfsr_out(lfsr_out)
    );

    initial begin
        reset = 1; seed_load = 0; enable = 0; seed = 8'h00;
        @(posedge clk); #1;
        reset = 0;
        tests = tests + 1;
        if (lfsr_out !== 8'h01) begin
            $display("[FAIL] LFSR reset state should be 8'h01, got %h", lfsr_out);
            errors = errors + 1;
        end

        // Parallel seed load
        seed = 8'h5A; seed_load = 1;
        @(posedge clk); #1;
        seed_load = 0;
        tests = tests + 1;
        if (lfsr_out !== 8'h5A) begin
            $display("[FAIL] LFSR seed load failed: got %h (expected 5A)", lfsr_out);
            errors = errors + 1;
        end

        // Enable shift and check that state advances
        enable = 1;
        initial_val = lfsr_out;
        @(posedge clk); #1;
        tests = tests + 1;
        if (lfsr_out === initial_val || lfsr_out === 8'h00) begin
            $display("[FAIL] LFSR did not advance properly: got %h", lfsr_out);
            errors = errors + 1;
        end

        // Verify that LFSR never enters lockup state 0x00 over 100 cycles
        for (step = 0; step < 100; step = step + 1) begin
            @(posedge clk); #1;
            if (lfsr_out === 8'h00) begin
                $display("[FAIL] LFSR entered forbidden zero state at cycle %0d", step);
                errors = errors + 1;
            end
        end
        tests = tests + 1;

        if (errors == 0)
            $display("[PASS] lfsr_8bit: All %0d tests passed.", tests);
        else
            $display("[FAIL] lfsr_8bit: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
