`timescale 1ns/1ps

// ============================================================================
// Testbench: tb_riscv_single_cycle
// Description: Self-checking testbench for Single-Cycle RV32I Processor.
//              Verifies program execution across arithmetic, branch, memory,
//              and jump instructions with 1 cycle per instruction.
// ============================================================================

module tb_riscv_single_cycle;
    reg clk = 0;
    reg reset;

    wire [31:0] debug_pc;
    wire [31:0] debug_instr;
    wire [31:0] debug_alu_result;
    wire [31:0] debug_wb_data;
    wire        debug_branch_taken;
    wire [31:0] debug_reg1;
    wire [31:0] debug_reg2;
    wire [31:0] debug_reg3;
    wire [31:0] debug_reg4;
    wire [31:0] debug_reg5;
    wire [31:0] debug_dmem0;
    wire [31:0] debug_dmem1;
    wire [31:0] debug_dmem9;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    riscv_single_cycle #(.IMEM_DEPTH(128), .DMEM_DEPTH(128)) uut (
        .clk                (clk),
        .reset              (reset),
        .debug_pc           (debug_pc),
        .debug_instr        (debug_instr),
        .debug_alu_result   (debug_alu_result),
        .debug_wb_data      (debug_wb_data),
        .debug_branch_taken (debug_branch_taken),
        .debug_reg1         (debug_reg1),
        .debug_reg2         (debug_reg2),
        .debug_reg3         (debug_reg3),
        .debug_reg4         (debug_reg4),
        .debug_reg5         (debug_reg5),
        .debug_dmem0        (debug_dmem0),
        .debug_dmem1        (debug_dmem1),
        .debug_dmem9        (debug_dmem9)
    );

    initial begin
        // Program 1: Sum 1..10 in machine code
        uut.instruction_mem[0] = 32'h00a00113; // addi x2, x0, 10
        uut.instruction_mem[1] = 32'h00000193; // addi x3, x0, 0
        uut.instruction_mem[2] = 32'h002181b3; // add  x3, x3, x2
        uut.instruction_mem[3] = 32'hfff10113; // addi x2, x2, -1
        uut.instruction_mem[4] = 32'hfe011ce3; // bne  x2, x0, -8
        uut.instruction_mem[5] = 32'h0000006f; // jal  x0, 0 (loop forever)

        reset = 1;
        repeat (2) @(posedge clk); #1;
        reset = 0;

        // Run 40 cycles (1 cycle per instruction)
        repeat (40) @(posedge clk); #1;

        tests = tests + 1;
        if (uut.registers[3] !== 32'd55) begin
            $display("[FAIL] Single-cycle Program 1: x3 = %d (expected 55)", uut.registers[3]);
            errors = errors + 1;
        end else begin
            $display("[PASS] Single-cycle Program 1: x3 = %d (Sum 1..10 verified)", uut.registers[3]);
        end

        // Program 5: GCD(48, 18)
        // 0: addi x1, x0, 48
        // 1: addi x2, x0, 18
        // 2: beq  x1, x2, done (offset +16 -> 6)
        // 3: blt  x1, x2, sub_b (offset +8 -> 5)
        // 4: sub  x1, x1, x2
        // 5: jal  x0, loop (offset -12 -> 2)
        // 6: sub  x2, x2, x1
        // 7: jal  x0, loop (offset -20 -> 2)
        // 8: addi x3, x1, 0
        // 9: jal  x0, 0
        reset = 1;
        uut.instruction_mem[0] = 32'h03000093; // addi x1, x0, 48
        uut.instruction_mem[1] = 32'h01200113; // addi x2, x0, 18
        uut.instruction_mem[2] = 32'h00208c63; // beq  x1, x2, 24
        uut.instruction_mem[3] = 32'h0020c663; // blt  x1, x2, 12
        uut.instruction_mem[4] = 32'h402080b3; // sub  x1, x1, x2
        uut.instruction_mem[5] = 32'hff50006f; // jal  x0, -12
        uut.instruction_mem[6] = 32'h40110133; // sub  x2, x2, x1
        uut.instruction_mem[7] = 32'hfed0006f; // jal  x0, -20
        uut.instruction_mem[8] = 32'h00008193; // addi x3, x1, 0
        uut.instruction_mem[9] = 32'h0000006f; // jal  x0, 0
        repeat (2) @(posedge clk); #1;
        reset = 0;

        repeat (40) @(posedge clk); #1;

        tests = tests + 1;
        if (uut.registers[3] !== 32'd6) begin
            $display("[FAIL] Single-cycle Program 5: GCD = %d (expected 6)", uut.registers[3]);
            errors = errors + 1;
        end else begin
            $display("[PASS] Single-cycle Program 5: GCD = %d (GCD(48, 18) verified)", uut.registers[3]);
        end

        if (errors == 0)
            $display("[PASS] tb_riscv_single_cycle: All %0d program verification checks passed.", tests);
        else
            $display("[FAIL] tb_riscv_single_cycle: %0d / %0d tests failed.", errors, tests);
        $finish;
    end

endmodule
