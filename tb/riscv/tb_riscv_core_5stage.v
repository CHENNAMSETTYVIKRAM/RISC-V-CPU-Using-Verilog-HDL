`timescale 1ns/1ps

// ============================================================================
// Testbench: tb_riscv_core_5stage
// Description: Self-checking testbench for 5-stage pipelined RV32I+M core.
//              Verifies:
//              - EX-to-EX forwarding
//              - MEM-to-EX forwarding
//              - Load-Use hazard stalling
//              - RV32M hardware multiplication & division (MUL, DIV)
//              - Byte-level memory operations (SB, LB)
// ============================================================================

module tb_riscv_core_5stage;
    reg clk = 0;
    reg reset;
    wire [31:0] debug_pc;
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

    riscv_core_5stage #(.IMEM_DEPTH(128), .DMEM_DEPTH(128)) uut (
        .clk(clk), .reset(reset),
        .debug_pc(debug_pc),
        .debug_reg1(debug_reg1), .debug_reg2(debug_reg2),
        .debug_reg3(debug_reg3), .debug_reg4(debug_reg4),
        .debug_reg5(debug_reg5),
        .debug_dmem0(debug_dmem0), .debug_dmem1(debug_dmem1),
        .debug_dmem9(debug_dmem9)
    );

    initial begin
        // Program testing Forwarding, Hazards, RV32M, and Sub-word Memory:
        // 0x00: ADDI x1, x0, 10    (x1 = 10)
        // 0x04: ADDI x2, x1, 5     (x2 = 15)  [EX-to-EX Forwarding of x1]
        // 0x08: ADD  x3, x2, x1    (x3 = 25)  [EX-to-EX of x2, MEM-to-EX of x1]
        // 0x0C: SW   x3, 0(x0)     (mem[0] = 25)
        // 0x10: LW   x4, 0(x0)     (x4 = 25)
        // 0x14: ADDI x5, x4, 7     (x5 = 32)  [Load-Use Stall + Forwarding]
        // 0x18: MUL  x1, x2, x3    (x1 = 15 * 25 = 375) [RV32M MUL]
        // 0x1C: DIV  x2, x1, x4    (x2 = 375 / 25 = 15)  [RV32M DIV]
        // 0x20: SB   x2, 4(x0)     (store byte 15 at byte offset 4)
        // 0x24: LB   x3, 4(x0)     (load byte 15 from byte offset 4)
        // 0x28: JAL  x0, 0         (inf loop)
        uut.instruction_mem[0]  = 32'h00A00093; // ADDI x1, x0, 10
        uut.instruction_mem[1]  = 32'h00508113; // ADDI x2, x1, 5
        uut.instruction_mem[2]  = 32'h001101B3; // ADD  x3, x2, x1
        uut.instruction_mem[3]  = 32'h00302023; // SW   x3, 0(x0)
        uut.instruction_mem[4]  = 32'h00002203; // LW   x4, 0(x0)
        uut.instruction_mem[5]  = 32'h00720293; // ADDI x5, x4, 7
        uut.instruction_mem[6]  = 32'h023100B3; // MUL  x1, x2, x3
        uut.instruction_mem[7]  = 32'h0240C133; // DIV  x2, x1, x4
        uut.instruction_mem[8]  = 32'h00200223; // SB   x2, 4(x0)
        uut.instruction_mem[9]  = 32'h00400183; // LB   x3, 4(x0)
        uut.instruction_mem[10] = 32'h0000006F; // JAL  x0, 0

        reset = 1;
        repeat (2) @(posedge clk); #1;
        reset = 0;

        // Run 40 cycles for all stages, stalls, and operations to complete
        repeat (40) @(posedge clk); #1;

        tests = tests + 1;
        if (uut.registers[4] !== 32'd25) begin
            $display("[FAIL] x4 (LW) = %d (expected 25)", uut.registers[4]);
            errors = errors + 1;
        end

        tests = tests + 1;
        if (uut.registers[5] !== 32'd32) begin
            $display("[FAIL] x5 (Load-Use Stall) = %d (expected 32)", uut.registers[5]);
            errors = errors + 1;
        end

        tests = tests + 1;
        if (uut.registers[1] !== 32'd375) begin
            $display("[FAIL] x1 (RV32M MUL) = %d (expected 375)", uut.registers[1]);
            errors = errors + 1;
        end

        tests = tests + 1;
        if (uut.registers[2] !== 32'd15) begin
            $display("[FAIL] x2 (RV32M DIV) = %d (expected 15)", uut.registers[2]);
            errors = errors + 1;
        end

        tests = tests + 1;
        if (uut.registers[3] !== 32'd15) begin
            $display("[FAIL] x3 (LB Sub-word Load) = %d (expected 15)", uut.registers[3]);
            errors = errors + 1;
        end

        tests = tests + 1;
        if (debug_dmem0 !== 32'd25) begin
            $display("[FAIL] data_mem[0] = %d (expected 25)", debug_dmem0);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] tb_riscv_core_5stage: All %0d pipeline hazard, RV32M, and memory tests passed.", tests);
        else
            $display("[FAIL] tb_riscv_core_5stage: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
