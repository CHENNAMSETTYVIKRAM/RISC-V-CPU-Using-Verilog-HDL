`timescale 1ns/1ps

// ============================================================================
// Activity 4.1, 4.2, 4.6 Deliverable: cpu_pipe_tb.v
// Self-Checking 5-Stage Pipelined RISC-V CPU Testbench
// Evaluates Hazard Test, Branch Flush Test, and all 6 Assembly Programs.
// Samples and prints hardware performance telemetry counters:
//   - perf_total_cycles
//   - perf_instructions_retired
//   - perf_stall_cycles
//   - perf_flush_cycles
// ============================================================================

module cpu_pipe_tb;
    reg clk = 0;
    reg reset;

    wire [31:0] debug_pc;
    wire [31:0] debug_wb_data;
    wire [4:0]  debug_wb_rd;
    wire        debug_wb_reg_write;
    wire [31:0] debug_reg1;
    wire [31:0] debug_reg2;
    wire [31:0] debug_reg3;
    wire [31:0] debug_reg4;
    wire [31:0] debug_reg5;
    wire [31:0] debug_dmem0;
    wire [31:0] debug_dmem1;
    wire [31:0] debug_dmem9;

    wire [31:0] perf_total_cycles;
    wire [31:0] perf_instructions_retired;
    wire [31:0] perf_stall_cycles;
    wire [31:0] perf_flush_cycles;

    integer errors = 0;
    integer total_suites = 0;
    integer prog_errors = 0;
    integer i;

    always #5 clk = ~clk;

    riscv_core_5stage #(.IMEM_DEPTH(256), .DMEM_DEPTH(256)) uut (
        .clk                       (clk),
        .reset                     (reset),
        .debug_pc                  (debug_pc),
        .debug_wb_data             (debug_wb_data),
        .debug_wb_rd               (debug_wb_rd),
        .debug_wb_reg_write        (debug_wb_reg_write),
        .debug_reg1                (debug_reg1),
        .debug_reg2                (debug_reg2),
        .debug_reg3                (debug_reg3),
        .debug_reg4                (debug_reg4),
        .debug_reg5                (debug_reg5),
        .debug_dmem0               (debug_dmem0),
        .debug_dmem1               (debug_dmem1),
        .debug_dmem9               (debug_dmem9),
        .perf_total_cycles         (perf_total_cycles),
        .perf_instructions_retired (perf_instructions_retired),
        .perf_stall_cycles        (perf_stall_cycles),
        .perf_flush_cycles        (perf_flush_cycles)
    );

    task clear_pipeline;
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
        $display("=========================================================================================");
        $display("  ACTIVITY 4.1 / 4.2 / 4.6: 5-STAGE PIPELINED CPU TESTBENCH & PERFORMANCE TELEMETRY    ");
        $display("=========================================================================================");

        // ---------------------------------------------------------------------
        // Test 1: Activity 4.1 Data Hazard Test (Forwarding & Load-Use Stall)
        // ---------------------------------------------------------------------
        clear_pipeline();
        $readmemh("day4/src/hazard_test.hex", uut.instruction_mem);
        #150;
        total_suites = total_suites + 1;
        if (uut.u_regfile.registers[1] === 32'd10 &&
            uut.u_regfile.registers[2] === 32'd15 &&
            uut.u_regfile.registers[3] === 32'd25 &&
            uut.u_regfile.registers[4] === 32'd25 &&
            uut.u_regfile.registers[5] === 32'd35) begin
            $display("[PASS] Activity 4.1 Data Hazards: x1=10, x2=15, x3=25, x4=25, x5=35 verified");
            $display("       Telemetry: Cycles=%0d, Retired=%0d, Stalls=%0d, Flushes=%0d",
                     perf_total_cycles, perf_instructions_retired, perf_stall_cycles, perf_flush_cycles);
        end else begin
            $display("[FAIL] Activity 4.1 Data Hazards: Register value mismatch!");
            errors = errors + 1;
        end

        // ---------------------------------------------------------------------
        // Test 2: Activity 4.2 Control Hazard Test (Taken/Not-Taken Branch & Flush)
        // ---------------------------------------------------------------------
        clear_pipeline();
        $readmemh("day4/src/branch_flush_test.hex", uut.instruction_mem);
        #200;
        total_suites = total_suites + 1;
        if (uut.u_regfile.registers[1] === 32'd1 &&
            uut.u_regfile.registers[2] === 32'd2 &&
            uut.u_regfile.registers[3] === 32'd100 &&
            uut.u_regfile.registers[5] === 32'd200) begin
            $display("[PASS] Activity 4.2 Control Hazards: Branch/Jump flushes verified (x3=100, x5=200)");
            $display("       Telemetry: Cycles=%0d, Retired=%0d, Stalls=%0d, Flushes=%0d",
                     perf_total_cycles, perf_instructions_retired, perf_stall_cycles, perf_flush_cycles);
        end else begin
            $display("[FAIL] Activity 4.2 Control Hazards: Speculative instruction leaked into x3 (%0d)!",
                     uut.u_regfile.registers[3]);
            errors = errors + 1;
        end

        // ---------------------------------------------------------------------
        // Test 3: Program 1 (Sum 1..10)
        // ---------------------------------------------------------------------
        clear_pipeline();
        $readmemh("day4/src/program1.hex", uut.instruction_mem);
        #600;
        total_suites = total_suites + 1;
        if (uut.u_regfile.registers[3] === 32'd55) begin
            $display("[PASS] Program 1 (Sum 1..10): Final x3 = %0d (Expected: 55)", uut.u_regfile.registers[3]);
            $display("       Telemetry: Cycles=%0d, Retired=%0d, Stalls=%0d, Flushes=%0d",
                     perf_total_cycles, perf_instructions_retired, perf_stall_cycles, perf_flush_cycles);
        end else begin
            $display("[FAIL] Program 1 (Sum 1..10): Final x3 = %0d", uut.u_regfile.registers[3]);
            errors = errors + 1;
        end

        // ---------------------------------------------------------------------
        // Test 4: Program 2 (Fibonacci 10 Words)
        // ---------------------------------------------------------------------
        clear_pipeline();
        $readmemh("day4/src/program2.hex", uut.instruction_mem);
        #1000;
        total_suites = total_suites + 1;
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
            $display("       Telemetry: Cycles=%0d, Retired=%0d, Stalls=%0d, Flushes=%0d",
                     perf_total_cycles, perf_instructions_retired, perf_stall_cycles, perf_flush_cycles);
        end else begin
            $display("[FAIL] Program 2 (Fibonacci): Mismatch errors = %0d", prog_errors);
            errors = errors + 1;
        end

        // ---------------------------------------------------------------------
        // Test 5: Program 3 (Array Max 8 Words)
        // ---------------------------------------------------------------------
        clear_pipeline();
        uut.data_mem[0] = 32'd12;
        uut.data_mem[1] = 32'd45;
        uut.data_mem[2] = 32'd7;
        uut.data_mem[3] = 32'd89;
        uut.data_mem[4] = 32'd23;
        uut.data_mem[5] = 32'd56;
        uut.data_mem[6] = 32'd3;
        uut.data_mem[7] = 32'd34;
        $readmemh("day4/src/program3.hex", uut.instruction_mem);
        #400;
        total_suites = total_suites + 1;
        if (uut.u_regfile.registers[3] === 32'd89) begin
            $display("[PASS] Program 3 (Array Max): Final x3 = %0d (Expected: 89)", uut.u_regfile.registers[3]);
            $display("       Telemetry: Cycles=%0d, Retired=%0d, Stalls=%0d, Flushes=%0d",
                     perf_total_cycles, perf_instructions_retired, perf_stall_cycles, perf_flush_cycles);
        end else begin
            $display("[FAIL] Program 3 (Array Max): Final x3 = %0d", uut.u_regfile.registers[3]);
            errors = errors + 1;
        end

        // ---------------------------------------------------------------------
        // Test 6: Program 4 (Bubble Sort 8 Words)
        // ---------------------------------------------------------------------
        clear_pipeline();
        uut.data_mem[0] = 32'd64;
        uut.data_mem[1] = 32'd34;
        uut.data_mem[2] = 32'd25;
        uut.data_mem[3] = 32'd12;
        uut.data_mem[4] = 32'd22;
        uut.data_mem[5] = 32'd11;
        uut.data_mem[6] = 32'd90;
        uut.data_mem[7] = 32'd4;
        $readmemh("day4/src/program4.hex", uut.instruction_mem);
        #2000;
        total_suites = total_suites + 1;
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
            $display("       Telemetry: Cycles=%0d, Retired=%0d, Stalls=%0d, Flushes=%0d",
                     perf_total_cycles, perf_instructions_retired, perf_stall_cycles, perf_flush_cycles);
        end else begin
            $display("[FAIL] Program 4 (Bubble Sort): Errors = %0d", prog_errors);
            errors = errors + 1;
        end

        // ---------------------------------------------------------------------
        // Test 7: Program 5 (Euclid GCD)
        // ---------------------------------------------------------------------
        clear_pipeline();
        $readmemh("day4/src/program5.hex", uut.instruction_mem);
        #500;
        total_suites = total_suites + 1;
        if (uut.u_regfile.registers[3] === 32'd6) begin
            $display("[PASS] Program 5 (Euclid GCD): Final x3 = %0d (Expected: 6)", uut.u_regfile.registers[3]);
            $display("       Telemetry: Cycles=%0d, Retired=%0d, Stalls=%0d, Flushes=%0d",
                     perf_total_cycles, perf_instructions_retired, perf_stall_cycles, perf_flush_cycles);
        end else begin
            $display("[FAIL] Program 5 (Euclid GCD): Final x3 = %0d", uut.u_regfile.registers[3]);
            errors = errors + 1;
        end

        // ---------------------------------------------------------------------
        // Test 8: Program 6 (Shift-Add Multiply)
        // ---------------------------------------------------------------------
        clear_pipeline();
        $readmemh("day4/src/program6.hex", uut.instruction_mem);
        #600;
        total_suites = total_suites + 1;
        if (uut.u_regfile.registers[3] === 32'd143) begin
            $display("[PASS] Program 6 (Shift-Add Mul): Final x3 = %0d (Expected: 143)", uut.u_regfile.registers[3]);
            $display("       Telemetry: Cycles=%0d, Retired=%0d, Stalls=%0d, Flushes=%0d",
                     perf_total_cycles, perf_instructions_retired, perf_stall_cycles, perf_flush_cycles);
        end else begin
            $display("[FAIL] Program 6 (Shift-Add Mul): Final x3 = %0d", uut.u_regfile.registers[3]);
            errors = errors + 1;
        end

        $display("=========================================================================================");
        if (errors == 0)
            $display("  ALL %0d 5-STAGE PIPELINED TEST SUITES PASSED VERIFICATION!  ", total_suites);
        else
            $display("  VERIFICATION FAILED: %0d / %0d TEST SUITES FAILED!  ", errors, total_suites);
        $display("=========================================================================================");
        $finish;
    end
endmodule
