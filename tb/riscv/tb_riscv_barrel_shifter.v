`timescale 1ns/1ps

module tb_riscv_barrel_shifter;
    reg  [31:0] data_in;
    reg  [4:0]  shamt;
    reg  [1:0]  shift_type;
    wire [31:0] data_out;

    integer errors = 0;
    integer tests  = 0;

    riscv_barrel_shifter uut (
        .data_in(data_in), .shamt(shamt), .shift_type(shift_type), .data_out(data_out)
    );

    initial begin
        // SLL: 0x00000003 << 3 = 0x00000018
        shift_type = 2'b00; data_in = 32'h00000003; shamt = 5'd3; #10;
        tests = tests + 1;
        if (data_out !== 32'h00000018) begin
            $display("[FAIL] SLL failed: got %h", data_out);
            errors = errors + 1;
        end

        // SRL: 0x80000000 >> 4 = 0x08000000
        shift_type = 2'b01; data_in = 32'h80000000; shamt = 5'd4; #10;
        tests = tests + 1;
        if (data_out !== 32'h08000000) begin
            $display("[FAIL] SRL failed: got %h", data_out);
            errors = errors + 1;
        end

        // SRA: 0x80000000 >>> 4 = 0xF8000000
        shift_type = 2'b10; data_in = 32'h80000000; shamt = 5'd4; #10;
        tests = tests + 1;
        if (data_out !== 32'hF8000000) begin
            $display("[FAIL] SRA failed: got %h (expected F8000000)", data_out);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] riscv_barrel_shifter: All %0d tests passed.", tests);
        else
            $display("[FAIL] riscv_barrel_shifter: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
