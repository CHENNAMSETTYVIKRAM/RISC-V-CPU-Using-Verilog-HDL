`timescale 1ns/1ps

module tb_sync_ram_16x8;
    reg        clk = 0;
    reg        we;
    reg  [3:0] addr;
    reg  [7:0] data_in;
    wire [7:0] data_out;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    sync_ram_16x8 uut (
        .clk(clk), .we(we), .addr(addr),
        .data_in(data_in), .data_out(data_out)
    );

    initial begin
        // Write byte 8'h55 to address 4
        we = 1; addr = 4'd4; data_in = 8'h55;
        @(posedge clk); #1;

        // Write byte 8'hAA to address 7
        addr = 4'd7; data_in = 8'hAA;
        @(posedge clk); #1;

        // Read back from address 4
        we = 0; addr = 4'd4;
        @(posedge clk); #1;
        tests = tests + 1;
        if (data_out !== 8'h55) begin
            $display("[FAIL] Read addr 4 failed: got %h (expected 55)", data_out);
            errors = errors + 1;
        end

        // Read back from address 7
        addr = 4'd7;
        @(posedge clk); #1;
        tests = tests + 1;
        if (data_out !== 8'hAA) begin
            $display("[FAIL] Read addr 7 failed: got %h (expected AA)", data_out);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] sync_ram_16x8: All %0d tests passed.", tests);
        else
            $display("[FAIL] sync_ram_16x8: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
