`timescale 1ns/1ps

module tb_riscv_core_2stage;
    reg clk = 0;
    reg reset;
    wire [31:0] debug_pc;
    wire [31:0] debug_reg3;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    riscv_core_2stage #(.IMEM_DEPTH(64), .DMEM_DEPTH(64)) uut (
        .clk(clk), .reset(reset),
        .debug_pc(debug_pc), .debug_reg3(debug_reg3)
    );

    initial begin
        // Load test instructions into instruction_mem:
        // 0x00: ADDI x1, x0, 15  (32'h00F00093)
        // 0x04: ADDI x2, x0, 25  (32'h01900113)
        // 0x08: ADD  x3, x1, x2  (32'h002081B3) -> x3 should be 40
        // 0x0C: SW   x3, 0(x0)   (32'h00302023)
        // 0x10: LW   x4, 0(x0)   (32'h00002203)
        // 0x14: JAL  x0, 0       (32'h0000006F)
        uut.instruction_mem[0] = 32'h00F00093;
        uut.instruction_mem[1] = 32'h01900113;
        uut.instruction_mem[2] = 32'h002081B3;
        uut.instruction_mem[3] = 32'h00302023;
        uut.instruction_mem[4] = 32'h00002203;
        uut.instruction_mem[5] = 32'h0000006F;

        reset = 1;
        repeat (2) @(posedge clk); #1;
        reset = 0;

        // Run for 15 cycles to execute the program
        repeat (15) @(posedge clk); #1;

        tests = tests + 1;
        if (uut.registers[3] !== 32'd40) begin
            $display("[FAIL] 2-Stage Core x3 value: got %d (expected 40)", uut.registers[3]);
            errors = errors + 1;
        end

        tests = tests + 1;
        if (uut.registers[4] !== 32'd40) begin
            $display("[FAIL] 2-Stage Core x4 LW value: got %d (expected 40)", uut.registers[4]);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] riscv_core_2stage: All %0d tests passed.", tests);
        else
            $display("[FAIL] riscv_core_2stage: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
