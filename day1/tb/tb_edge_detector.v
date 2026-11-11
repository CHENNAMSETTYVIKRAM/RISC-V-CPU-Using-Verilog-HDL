`timescale 1ns/1ps

module tb_edge_detector;
    reg clk = 0;
    reg reset;
    reg async_in;
    wire sync_out;
    wire posedge_pulse;
    wire negedge_pulse;
    wire anyedge_pulse;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    edge_detector uut (
        .clk(clk), .reset(reset), .async_in(async_in),
        .sync_out(sync_out),
        .posedge_pulse(posedge_pulse),
        .negedge_pulse(negedge_pulse),
        .anyedge_pulse(anyedge_pulse)
    );

    initial begin
        reset = 1; async_in = 0;
        repeat (2) @(posedge clk); #1;
        reset = 0;

        // Apply positive edge
        @(posedge clk); #2; async_in = 1;

        // Wait through 2-stage synchronizer to detect posedge pulse
        @(posedge clk);
        @(posedge clk); #1;
        tests = tests + 1;
        if (posedge_pulse !== 1 || anyedge_pulse !== 1 || negedge_pulse !== 0) begin
            $display("[FAIL] posedge pulse not generated: pos=%b any=%b neg=%b",
                     posedge_pulse, anyedge_pulse, negedge_pulse);
            errors = errors + 1;
        end

        // Ensure pulse lasts exactly 1 cycle
        @(posedge clk); #1;
        tests = tests + 1;
        if (posedge_pulse !== 0 || anyedge_pulse !== 0) begin
            $display("[FAIL] posedge pulse lasted longer than 1 cycle");
            errors = errors + 1;
        end

        // Apply negative edge
        @(posedge clk); #2; async_in = 0;
        @(posedge clk);
        @(posedge clk); #1;
        tests = tests + 1;
        if (negedge_pulse !== 1 || anyedge_pulse !== 1 || posedge_pulse !== 0) begin
            $display("[FAIL] negedge pulse not generated: neg=%b any=%b pos=%b",
                     negedge_pulse, anyedge_pulse, posedge_pulse);
            errors = errors + 1;
        end

        @(posedge clk); #1;
        tests = tests + 1;
        if (negedge_pulse !== 0 || anyedge_pulse !== 0) begin
            $display("[FAIL] negedge pulse lasted longer than 1 cycle");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] edge_detector: All %0d tests passed.", tests);
        else
            $display("[FAIL] edge_detector: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
