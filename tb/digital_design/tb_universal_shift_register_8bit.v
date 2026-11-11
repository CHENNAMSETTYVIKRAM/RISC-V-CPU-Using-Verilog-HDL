`timescale 1ns/1ps

module tb_universal_shift_register_8bit;
    reg        clk = 0;
    reg        reset;
    reg  [1:0] mode;
    reg  [7:0] parallel_in;
    reg        serial_left;
    reg        serial_right;
    wire [7:0] data_out;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    universal_shift_register_8bit #(.WIDTH(8)) uut (
        .clk(clk), .reset(reset), .mode(mode),
        .parallel_in(parallel_in),
        .serial_left(serial_left), .serial_right(serial_right),
        .data_out(data_out)
    );

    initial begin
        // Reset
        reset = 1; mode = 2'b00; parallel_in = 8'h00; serial_left = 0; serial_right = 0;
        @(posedge clk); #1;
        reset = 0;
        tests = tests + 1;
        if (data_out !== 8'h00) begin
            $display("[FAIL] Reset failed: got %h", data_out);
            errors = errors + 1;
        end

        // Parallel load: 8'hA5
        mode = 2'b11; parallel_in = 8'hA5;
        @(posedge clk); #1;
        tests = tests + 1;
        if (data_out !== 8'hA5) begin
            $display("[FAIL] Parallel Load failed: got %h (expected A5)", data_out);
            errors = errors + 1;
        end

        // Hold mode
        mode = 2'b00; parallel_in = 8'hFF;
        @(posedge clk); #1;
        tests = tests + 1;
        if (data_out !== 8'hA5) begin
            $display("[FAIL] Hold mode failed: got %h (expected A5)", data_out);
            errors = errors + 1;
        end

        // Shift Left: insert 1 at LSB -> 8'hA5 (10100101) << 1 | 1 = 01001011 (8'h4B)
        mode = 2'b01; serial_left = 1;
        @(posedge clk); #1;
        tests = tests + 1;
        if (data_out !== 8'h4B) begin
            $display("[FAIL] Shift Left failed: got %h (expected 4B)", data_out);
            errors = errors + 1;
        end

        // Shift Right: insert 1 at MSB -> 8'h4B (01001011) >> 1 with MSB=1 = 10100101 (8'hA5)
        mode = 2'b10; serial_right = 1;
        @(posedge clk); #1;
        tests = tests + 1;
        if (data_out !== 8'hA5) begin
            $display("[FAIL] Shift Right failed: got %h (expected A5)", data_out);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] universal_shift_register_8bit: All %0d tests passed.", tests);
        else
            $display("[FAIL] universal_shift_register_8bit: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
