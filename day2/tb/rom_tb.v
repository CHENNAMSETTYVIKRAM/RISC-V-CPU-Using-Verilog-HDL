`timescale 1ns/1ps

// ============================================================================
// Activity 2.8 Deliverable: rom_tb.v
// Self-Checking ROM Testbench loading rom.hex via $readmemh
// ============================================================================

module tb_sync_rom_16x8;
    reg        clk = 0;
    reg  [3:0] addr;
    wire [7:0] data_out;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    sync_rom_16x8 #(.INIT_FILE("day2/src/rom.hex")) uut (
        .clk(clk), .addr(addr), .data_out(data_out)
    );

    initial begin
        // Read address 0 (expected 8'h10 from rom.hex)
        addr = 4'd0;
        @(posedge clk); #1;
        tests = tests + 1;
        if (data_out !== 8'h10) begin
            $display("[FAIL] ROM addr 0: got %h (expected 10)", data_out);
            errors = errors + 1;
        end

        // Read address 5 (expected 8'h65 from rom.hex)
        addr = 4'd5;
        @(posedge clk); #1;
        tests = tests + 1;
        if (data_out !== 8'h65) begin
            $display("[FAIL] ROM addr 5: got %h (expected 65)", data_out);
            errors = errors + 1;
        end

        // Read address 15 (expected 8'h0F from rom.hex)
        addr = 4'd15;
        @(posedge clk); #1;
        tests = tests + 1;
        if (data_out !== 8'h0F) begin
            $display("[FAIL] ROM addr 15: got %h (expected 0F)", data_out);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] sync_rom_16x8 ($readmemh rom.hex): All %0d tests passed.", tests);
        else
            $display("[FAIL] sync_rom_16x8 ($readmemh rom.hex): %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
