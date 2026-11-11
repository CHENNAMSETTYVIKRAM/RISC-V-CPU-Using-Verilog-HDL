`timescale 1ns/1ps

// ============================================================================
// Testbench: tb_regfile_random
// Description: Rigorous register file verification running 200 pseudo-random
//              write and dual-read operations, validating x0 hardwire invariant
//              and same-cycle write-to-read internal bypass logic against a
//              golden behavioral reference model.
// ============================================================================

module tb_regfile_random;
    reg         clk = 0;
    reg         reset;
    reg         we;
    reg  [4:0]  waddr;
    reg  [31:0] wdata;
    reg  [4:0]  raddr1;
    reg  [4:0]  raddr2;
    wire [31:0] rdata1;
    wire [31:0] rdata2;

    integer errors = 0;
    integer i;

    // Golden reference model
    reg [31:0] ref_regs [0:31];
    reg [31:0] exp_rdata1;
    reg [31:0] exp_rdata2;

    always #5 clk = ~clk;

    riscv_regfile uut (
        .clk    (clk),
        .reset  (reset),
        .we     (we),
        .waddr  (waddr),
        .wdata  (wdata),
        .raddr1 (raddr1),
        .raddr2 (raddr2),
        .rdata1 (rdata1),
        .rdata2 (rdata2)
    );

    initial begin
        // Reset sequence
        reset = 1; we = 0; waddr = 0; wdata = 0; raddr1 = 0; raddr2 = 0;
        for (i = 0; i < 32; i = i + 1) ref_regs[i] = 32'd0;
        repeat (3) @(posedge clk); #1;
        reset = 0;

        // Run 200 pseudo-random operations
        for (i = 0; i < 200; i = i + 1) begin
            @(posedge clk); #1;
            we     = $random % 2;
            waddr  = $random % 32;
            wdata  = {$random, $random};
            raddr1 = $random % 32;
            raddr2 = $random % 32;

            // Compute expected bypass data
            exp_rdata1 = (raddr1 == 5'd0) ? 32'd0 :
                         ((we && (waddr == raddr1)) ? wdata : ref_regs[raddr1]);
            exp_rdata2 = (raddr2 == 5'd0) ? 32'd0 :
                         ((we && (waddr == raddr2)) ? wdata : ref_regs[raddr2]);

            // Update golden model on positive edge write
            if (we && (waddr != 5'd0)) begin
                ref_regs[waddr] = wdata;
            end
            ref_regs[0] = 32'd0;

            #1; // Sample asynchronous read outputs
            if (rdata1 !== exp_rdata1) begin
                $display("[FAIL] Op %0d: Port1 mismatch: got %h, expected %h (raddr1=%0d, waddr=%0d, we=%b)",
                         i, rdata1, exp_rdata1, raddr1, waddr, we);
                errors = errors + 1;
            end
            if (rdata2 !== exp_rdata2) begin
                $display("[FAIL] Op %0d: Port2 mismatch: got %h, expected %h (raddr2=%0d, waddr=%0d, we=%b)",
                         i, rdata2, exp_rdata2, raddr2, waddr, we);
                errors = errors + 1;
            end
        end

        // Final verification that x0 remained permanently zero
        raddr1 = 0; raddr2 = 0; #1;
        if (rdata1 !== 32'd0 || rdata2 !== 32'd0) begin
            $display("[FAIL] Permanent x0=0 invariant violated!");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] tb_regfile_random: 200 random operations passed with 0 errors.");
        else
            $display("[FAIL] tb_regfile_random: %0d errors detected.", errors);
        $finish;
    end

endmodule
