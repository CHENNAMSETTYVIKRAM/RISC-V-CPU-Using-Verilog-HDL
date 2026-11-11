`timescale 1ns/1ps

// ============================================================================
// Activity 3.3 & Activity 3.6 Deliverable: cpu_tb.v
// Self-Checking Single-Cycle RISC-V CPU Testbench
// Runs Program 1 (Sum), Program 2 (Fibonacci), Program 3 (Array Max),
// Program 4 (Bubble Sort), Program 5 (GCD), and Program 6 (Shift-Add Mul).
// Prints [PASS] or [FAIL] for each program.
// ============================================================================

module cpu_tb;
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
    integer total_tests = 0;
    integer prog_errors = 0;
    integer i;

    always #5 clk = ~clk;

    riscv_single_cycle #(.IMEM_DEPTH(256), .DMEM_DEPTH(256)) uut (
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

    task clear_cpu;
        begin
            reset = 1;
            for (i = 0; i < 256; i = i + 1) begin
                uut.instruction_mem[i] = 32'h00000013; // NOP
                uut.data_mem[i]        = 32'h00000000;
            end
            for (i = 0; i < 32; i = i + 1) begin
                uut.u_regfile.registers[i] = 32'h00000000;
            end
            #20;
            reset = 0;
        end
    endtask

    initial begin
        $display("=================================================================");
        $display("  ACTIVITY 3.3 / 3.6: SELF-CHECKING SINGLE-CYCLE CPU TESTBENCH  ");
        $display("=================================================================");

        // ---------------------------------------------------------------------
        // Program 1: Sum of 1 to 10
        // Expected: x3 = 55 (0x37)
        // ---------------------------------------------------------------------
        clear_cpu();
        $readmemh("day3/src/program1.hex", uut.instruction_mem);
        #400; // Allow single-cycle execution of ~35 instructions
        total_tests = total_tests + 1;
        if (uut.u_regfile.registers[3] === 32'd55) begin
            $display("[PASS] Program 1 (Sum 1..10): Final x3 = %0d (Expected: 55)", uut.u_regfile.registers[3]);
        end else begin
            $display("[FAIL] Program 1 (Sum 1..10): Final x3 = %0d (Expected: 55)", uut.u_regfile.registers[3]);
            errors = errors + 1;
        end

        // ---------------------------------------------------------------------
        // Program 2: Fibonacci 10 Words in Memory
        // Expected: dmem[0..9] = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
        // ---------------------------------------------------------------------
        clear_cpu();
        $readmemh("day3/src/program2.hex", uut.instruction_mem);
        #700;
        total_tests = total_tests + 1;
        prog_errors = 0;
        if (uut.data_mem[0] !== 32'd0)  prog_errors = prog_errors + 1;
        if (uut.data_mem[1] !== 32'd1)  prog_errors = prog_errors + 1;
        if (uut.data_mem[2] !== 32'd1)  prog_errors = prog_errors + 1;
        if (uut.data_mem[3] !== 32'd2)  prog_errors = prog_errors + 1;
        if (uut.data_mem[4] !== 32'd3)  prog_errors = prog_errors + 1;
        if (uut.data_mem[5] !== 32'd5)  prog_errors = prog_errors + 1;
        if (uut.data_mem[6] !== 32'd8)  prog_errors = prog_errors + 1;
        if (uut.data_mem[7] !== 32'd13) prog_errors = prog_errors + 1;
        if (uut.data_mem[8] !== 32'd21) prog_errors = prog_errors + 1;
        if (uut.data_mem[9] !== 32'd34) prog_errors = prog_errors + 1;

        if (prog_errors == 0) begin
            $display("[PASS] Program 2 (Fibonacci): mem[0..9] = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]");
        end else begin
            $display("[FAIL] Program 2 (Fibonacci): Memory mismatch! Errors = %0d", prog_errors);
            errors = errors + 1;
        end

        // ---------------------------------------------------------------------
        // Program 3: Array Maximum (8 Words)
        // Inputs: mem[0..7] = [12, 45, 7, 89, 23, 56, 3, 34]
        // Expected: x3 = 89
        // ---------------------------------------------------------------------
        clear_cpu();
        uut.data_mem[0] = 32'd12;
        uut.data_mem[1] = 32'd45;
        uut.data_mem[2] = 32'd7;
        uut.data_mem[3] = 32'd89;
        uut.data_mem[4] = 32'd23;
        uut.data_mem[5] = 32'd56;
        uut.data_mem[6] = 32'd3;
        uut.data_mem[7] = 32'd34;
        $readmemh("day3/src/program3.hex", uut.instruction_mem);
        #300;
        total_tests = total_tests + 1;
        if (uut.u_regfile.registers[3] === 32'd89) begin
            $display("[PASS] Program 3 (Array Max): Final x3 = %0d (Expected: 89)", uut.u_regfile.registers[3]);
        end else begin
            $display("[FAIL] Program 3 (Array Max): Final x3 = %0d (Expected: 89)", uut.u_regfile.registers[3]);
            errors = errors + 1;
        end

        // ---------------------------------------------------------------------
        // Program 4: In-Place Bubble Sort (8 Words)
        // Inputs: mem[0..7] = [64, 34, 25, 12, 22, 11, 90, 4]
        // Expected: mem[0..7] = [4, 11, 12, 22, 25, 34, 64, 90]
        // ---------------------------------------------------------------------
        clear_cpu();
        uut.data_mem[0] = 32'd64;
        uut.data_mem[1] = 32'd34;
        uut.data_mem[2] = 32'd25;
        uut.data_mem[3] = 32'd12;
        uut.data_mem[4] = 32'd22;
        uut.data_mem[5] = 32'd11;
        uut.data_mem[6] = 32'd90;
        uut.data_mem[7] = 32'd4;
        $readmemh("day3/src/program4.hex", uut.instruction_mem);
        #1500;
        total_tests = total_tests + 1;
        prog_errors = 0;
        if (uut.data_mem[0] !== 32'd4)  prog_errors = prog_errors + 1;
        if (uut.data_mem[1] !== 32'd11) prog_errors = prog_errors + 1;
        if (uut.data_mem[2] !== 32'd12) prog_errors = prog_errors + 1;
        if (uut.data_mem[3] !== 32'd22) prog_errors = prog_errors + 1;
        if (uut.data_mem[4] !== 32'd25) prog_errors = prog_errors + 1;
        if (uut.data_mem[5] !== 32'd34) prog_errors = prog_errors + 1;
        if (uut.data_mem[6] !== 32'd64) prog_errors = prog_errors + 1;
        if (uut.data_mem[7] !== 32'd90) prog_errors = prog_errors + 1;

        if (prog_errors == 0) begin
            $display("[PASS] Program 4 (Bubble Sort): mem[0..7] = [4, 11, 12, 22, 25, 34, 64, 90]");
        end else begin
            $display("[FAIL] Program 4 (Bubble Sort): Memory sort mismatch! Errors = %0d", prog_errors);
            errors = errors + 1;
        end

        // ---------------------------------------------------------------------
        // Program 5: Euclid GCD (48, 18)
        // Expected: x3 = 6
        // ---------------------------------------------------------------------
        clear_cpu();
        $readmemh("day3/src/program5.hex", uut.instruction_mem);
        #400;
        total_tests = total_tests + 1;
        if (uut.u_regfile.registers[3] === 32'd6) begin
            $display("[PASS] Program 5 (Euclid GCD): Final x3 = %0d (Expected: 6)", uut.u_regfile.registers[3]);
        end else begin
            $display("[FAIL] Program 5 (Euclid GCD): Final x3 = %0d (Expected: 6)", uut.u_regfile.registers[3]);
            errors = errors + 1;
        end

        // ---------------------------------------------------------------------
        // Program 6: Software Shift-and-Add Multiply (13 * 11)
        // Expected: x3 = 143 (0x8F)
        // ---------------------------------------------------------------------
        clear_cpu();
        $readmemh("day3/src/program6.hex", uut.instruction_mem);
        #500;
        total_tests = total_tests + 1;
        if (uut.u_regfile.registers[3] === 32'd143) begin
            $display("[PASS] Program 6 (Shift-Add Mul): Final x3 = %0d (Expected: 143)", uut.u_regfile.registers[3]);
        end else begin
            $display("[FAIL] Program 6 (Shift-Add Mul): Final x3 = %0d (Expected: 143)", uut.u_regfile.registers[3]);
            errors = errors + 1;
        end

        $display("=================================================================");
        if (errors == 0)
            $display("  ALL %0d PROGRAMS PASSED SINGLE-CYCLE CPU VERIFICATION!  ", total_tests);
        else
            $display("  VERIFICATION FAILED: %0d / %0d PROGRAMS FAILED!  ", errors, total_tests);
        $display("=================================================================");
        $finish;
    end
endmodule
