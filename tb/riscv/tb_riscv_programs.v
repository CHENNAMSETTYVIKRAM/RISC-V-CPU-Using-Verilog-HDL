`timescale 1ns/1ps

module tb_riscv_programs;
    reg clk = 0;
    reg reset;
    wire [31:0] debug_pc;
    wire [31:0] debug_reg1, debug_reg2, debug_reg3, debug_reg4, debug_reg5;
    wire [31:0] debug_dmem0, debug_dmem1, debug_dmem9;

    integer errors = 0;
    integer tests  = 0;
    integer i;

    always #5 clk = ~clk;

    riscv_core_5stage #(.IMEM_DEPTH(256), .DMEM_DEPTH(256)) cpu (
        .clk(clk), .reset(reset),
        .debug_pc(debug_pc),
        .debug_reg1(debug_reg1), .debug_reg2(debug_reg2),
        .debug_reg3(debug_reg3), .debug_reg4(debug_reg4),
        .debug_reg5(debug_reg5),
        .debug_dmem0(debug_dmem0), .debug_dmem1(debug_dmem1),
        .debug_dmem9(debug_dmem9)
    );

    initial begin
        // ====================================================================
        // TEST 1: Program 1 - Sum of 1 to N (N = 10)
        // ====================================================================
        $display("[INFO] Running Program 1: Sum 1..10...");
        $readmemh("programs/program1_sum.hex", cpu.instruction_mem);

        reset = 1;
        repeat (3) @(posedge clk); #1;
        reset = 0;

        repeat (70) @(posedge clk); #1;

        tests = tests + 1;
        if (cpu.registers[3] === 32'd55) begin
            $display("[PASS] Program 1 (Sum): x3 = %0d (expected 55)", cpu.registers[3]);
        end else begin
            $display("[FAIL] Program 1 (Sum): x3 = %0d (expected 55)", cpu.registers[3]);
            errors = errors + 1;
        end

        // ====================================================================
        // TEST 2: Program 2 - First 10 Fibonacci Numbers
        // ====================================================================
        $display("[INFO] Running Program 2: Fibonacci (10 numbers)...");
        for (i = 0; i < 256; i = i + 1) cpu.instruction_mem[i] = 32'd0;
        $readmemh("programs/program2_fibonacci.hex", cpu.instruction_mem);

        reset = 1;
        repeat (3) @(posedge clk); #1;
        reset = 0;

        repeat (140) @(posedge clk); #1;

        // Check data_mem[0..9] == [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
        tests = tests + 1;
        if (cpu.data_mem[0] === 32'd0  && cpu.data_mem[1] === 32'd1  &&
            cpu.data_mem[2] === 32'd1  && cpu.data_mem[3] === 32'd2  &&
            cpu.data_mem[4] === 32'd3  && cpu.data_mem[5] === 32'd5  &&
            cpu.data_mem[6] === 32'd8  && cpu.data_mem[7] === 32'd13 &&
            cpu.data_mem[8] === 32'd21 && cpu.data_mem[9] === 32'd34) begin
            $display("[PASS] Program 2 (Fibonacci): mem[0..9] correctly computed [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]");
        end else begin
            $display("[FAIL] Program 2 (Fibonacci): mem[0..9] mismatch: %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d",
                     cpu.data_mem[0], cpu.data_mem[1], cpu.data_mem[2], cpu.data_mem[3], cpu.data_mem[4],
                     cpu.data_mem[5], cpu.data_mem[6], cpu.data_mem[7], cpu.data_mem[8], cpu.data_mem[9]);
            errors = errors + 1;
        end

        // ====================================================================
        // TEST 3: Program 3 - Maximum Element in Array of 8 Words
        // ====================================================================
        $display("[INFO] Running Program 3: Array Maximum (8 elements)...");
        for (i = 0; i < 256; i = i + 1) cpu.instruction_mem[i] = 32'd0;
        $readmemh("programs/program3_max.hex", cpu.instruction_mem);

        reset = 1;
        // Pre-initialize data memory with array: [12, 45, 7, 89, 23, 56, 3, 34]
        cpu.data_mem[0] = 32'd12; cpu.data_mem[1] = 32'd45;
        cpu.data_mem[2] = 32'd7;  cpu.data_mem[3] = 32'd89;
        cpu.data_mem[4] = 32'd23; cpu.data_mem[5] = 32'd56;
        cpu.data_mem[6] = 32'd3;  cpu.data_mem[7] = 32'd34;

        repeat (3) @(posedge clk); #1;
        reset = 0;

        repeat (90) @(posedge clk); #1;

        tests = tests + 1;
        if (cpu.registers[3] === 32'd89) begin
            $display("[PASS] Program 3 (Max Array): x3 = %0d (expected 89)", cpu.registers[3]);
        end else begin
            $display("[FAIL] Program 3 (Max Array): x3 = %0d (expected 89)", cpu.registers[3]);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] ALL 3 RISC-V ASSEMBLY BENCHMARK PROGRAMS PASSED VERIFICATION!");
        else
            $display("[FAIL] RISC-V Benchmark Programs: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
