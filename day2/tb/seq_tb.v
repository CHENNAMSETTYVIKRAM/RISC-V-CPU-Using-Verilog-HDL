`timescale 1ns/1ps

module tb_sequence_detectors;
    reg  clk = 0;
    reg  reset;
    reg  din;
    wire mealy_detected;
    wire moore_detected;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    sequence_detector_mealy uut_mealy (
        .clk(clk), .reset(reset), .din(din), .detected(mealy_detected)
    );

    sequence_detector_moore uut_moore (
        .clk(clk), .reset(reset), .din(din), .detected(moore_detected)
    );

    // Helper task to send a bit
    task send_bit(input b);
    begin
        din = b;
        @(posedge clk); #1;
    end
    endtask

    initial begin
        reset = 1; din = 0;
        repeat (2) @(posedge clk); #1;
        reset = 0;

        // Sequence: 1, 0, 1, 1 (Detect 1011)
        send_bit(1);
        send_bit(0);
        send_bit(1);

        // 4th bit is 1 -> Mealy detects immediately
        din = 1; #1;
        tests = tests + 1;
        if (!mealy_detected) begin
            $display("[FAIL] Mealy did not assert detected on 4th bit arrival");
            errors = errors + 1;
        end

        // Clock the 4th bit in -> Moore reaches S4 (detected state)
        @(posedge clk); #1;
        tests = tests + 1;
        if (!moore_detected) begin
            $display("[FAIL] Moore did not assert detected in state S4");
            errors = errors + 1;
        end

        // Overlapping test: next bits 0, 1, 1 -> "1011011" has 2 matches!
        send_bit(0);
        send_bit(1);
        din = 1; #1;
        tests = tests + 1;
        if (!mealy_detected) begin
            $display("[FAIL] Mealy failed overlapping sequence detection");
            errors = errors + 1;
        end

        @(posedge clk); #1;
        tests = tests + 1;
        if (!moore_detected) begin
            $display("[FAIL] Moore failed overlapping sequence detection");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] sequence_detectors (Mealy & Moore): All %0d tests passed.", tests);
        else
            $display("[FAIL] sequence_detectors: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
