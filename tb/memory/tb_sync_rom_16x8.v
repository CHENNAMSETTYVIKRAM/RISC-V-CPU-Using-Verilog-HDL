`timescale 1ns/1ps

module tb_sync_rom_16x8;
    reg        clk = 0;
    reg  [3:0] addr;
    wire [7:0] data_out;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    sync_rom_16x8 uut (
        .clk(clk), .addr(addr), .data_out(data_out)
    );

    initial begin
        // Read address 0 (expected default 8'hA0)
        addr = 4'd0;
        @(posedge clk); #1;
        tests = tests + 1;
        if (data_out !== 8'hA0) begin
            $display("[FAIL] ROM addr 0: got %h (expected A0)", data_out);
            errors = errors + 1;
        end

        // Read address 5 (expected default 8'hB1)
        addr = 4'd5;
        @(posedge clk); #1;
        tests = tests + 1;
        if (data_out !== 8'hB1) begin
            $display("[FAIL] ROM addr 5: got %h (expected B1)", data_out);
            errors = errors + 1;
        end

        // Read address 15 (expected default 8'hD3)
        addr = 4'd15;
        @(posedge clk); #1;
        tests = tests + 1;
        if (data_out !== 8'hD3) begin
            $display("[FAIL] ROM addr 15: got %h (expected D3)", data_out);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] sync_rom_16x8: All %0d tests passed.", tests);
        else
            $display("[FAIL] sync_rom_16x8: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
