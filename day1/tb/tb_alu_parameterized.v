`timescale 1ns/1ps

// ============================================================================
// Testbench: tb_alu_parameterized
// Description: Exhaustive self-checking testbench for parameterized 32-bit ALU.
//              Contains 30 directed test vectors covering normal operations,
//              signed overflow, carry-out, borrow, boundary zero, and shift edges.
// ============================================================================

module tb_alu_parameterized;
    parameter WIDTH = 32;

    reg  [WIDTH-1:0] a;
    reg  [WIDTH-1:0] b;
    reg  [3:0]       alu_ctrl;
    wire [WIDTH-1:0] result;
    wire             zero;
    wire             negative;
    wire             carry;
    wire             overflow;

    integer errors = 0;
    integer tests  = 0;

    alu_parameterized #(.WIDTH(WIDTH)) uut (
        .a        (a),
        .b        (b),
        .alu_ctrl (alu_ctrl),
        .result   (result),
        .zero     (zero),
        .negative (negative),
        .carry    (carry),
        .overflow (overflow)
    );

    task check_vector;
        input [WIDTH-1:0] in_a;
        input [WIDTH-1:0] in_b;
        input [3:0]       ctrl;
        input [WIDTH-1:0] exp_res;
        input             exp_zero;
        input             exp_neg;
        input             exp_carry;
        input             exp_ovf;
        input [255:0]     desc;
    begin
        a = in_a; b = in_b; alu_ctrl = ctrl; #10;
        tests = tests + 1;
        if (result !== exp_res || zero !== exp_zero || negative !== exp_neg ||
            carry !== exp_carry || overflow !== exp_ovf) begin
            $display("[FAIL] Vector %0d (%s): a=%h b=%h ctrl=%b | Res=%h (exp %h) Z=%b N=%b C=%b V=%b",
                     tests, desc, in_a, in_b, ctrl, result, exp_res, zero, negative, carry, overflow);
            errors = errors + 1;
        end
    end
    endtask

    initial begin
        // --- 1. ADD Normal & Flags ---
        check_vector(32'd10, 32'd25, 4'b0000, 32'd35, 1'b0, 1'b0, 1'b0, 1'b0, "ADD normal");
        check_vector(32'h00000000, 32'h00000000, 4'b0000, 32'h0, 1'b1, 1'b0, 1'b0, 1'b0, "ADD zero flag");
        check_vector(32'hFFFFFFFF, 32'd1, 4'b0000, 32'h0, 1'b1, 1'b0, 1'b1, 1'b0, "ADD carry-out");
        check_vector(32'h7FFFFFFF, 32'd1, 4'b0000, 32'h80000000, 1'b0, 1'b1, 1'b0, 1'b1, "ADD signed pos overflow");
        check_vector(32'h80000000, 32'h80000000, 4'b0000, 32'h0, 1'b1, 1'b0, 1'b1, 1'b1, "ADD signed neg overflow");

        // --- 2. SUB Normal & Flags ---
        check_vector(32'd50, 32'd20, 4'b1000, 32'd30, 1'b0, 1'b0, 1'b0, 1'b0, "SUB normal positive");
        check_vector(32'd20, 32'd50, 4'b1000, 32'hFFFFFFE2, 1'b0, 1'b1, 1'b1, 1'b0, "SUB borrow/negative");
        check_vector(32'd42, 32'd42, 4'b1000, 32'h0, 1'b1, 1'b0, 1'b0, 1'b0, "SUB zero flag");
        check_vector(32'h80000000, 32'd1, 4'b1000, 32'h7FFFFFFF, 1'b0, 1'b0, 1'b0, 1'b1, "SUB underflow to pos");
        check_vector(32'h7FFFFFFF, 32'hFFFFFFFF, 4'b1000, 32'h80000000, 1'b0, 1'b1, 1'b1, 1'b1, "SUB signed pos overflow");

        // --- 3. Bitwise Logic: AND, OR, XOR ---
        check_vector(32'hF0F0F0F0, 32'h0F0F0F0F, 4'b0111, 32'h0, 1'b1, 1'b0, 1'b0, 1'b0, "AND disjoint");
        check_vector(32'hAAAAAAAA, 32'h55555555, 4'b0110, 32'hFFFFFFFF, 1'b0, 1'b1, 1'b0, 1'b0, "OR complement");
        check_vector(32'hFFFFFFFF, 32'hFFFFFFFF, 4'b0100, 32'h0, 1'b1, 1'b0, 1'b0, 1'b0, "XOR identical");
        check_vector(32'h12345678, 32'hFFFFFFFF, 4'b0100, 32'hEDCBA987, 1'b0, 1'b1, 1'b0, 1'b0, "XOR invert");

        // --- 4. Shift Operations: SLL, SRL, SRA ---
        check_vector(32'd1, 32'd0, 4'b0001, 32'd1, 1'b0, 1'b0, 1'b0, 1'b0, "SLL shamt 0");
        check_vector(32'd1, 32'd31, 4'b0001, 32'h80000000, 1'b0, 1'b1, 1'b0, 1'b0, "SLL shamt 31");
        check_vector(32'h80000000, 32'd1, 4'b0101, 32'h40000000, 1'b0, 1'b0, 1'b0, 1'b0, "SRL shamt 1");
        check_vector(32'h80000000, 32'd31, 4'b0101, 32'd1, 1'b0, 1'b0, 1'b0, 1'b0, "SRL shamt 31");
        check_vector(32'h80000000, 32'd4, 4'b1101, 32'hF8000000, 1'b0, 1'b1, 1'b0, 1'b0, "SRA sign extend");
        check_vector(32'h70000000, 32'd4, 4'b1101, 32'h07000000, 1'b0, 1'b0, 1'b0, 1'b0, "SRA positive");

        // --- 5. Comparisons: SLT, SLTU ---
        check_vector(32'hFFFFFFF6, 32'd0, 4'b0010, 32'd1, 1'b0, 1'b0, 1'b0, 1'b0, "SLT -10 < 0");
        check_vector(32'd0, 32'hFFFFFFF6, 4'b0010, 32'd0, 1'b1, 1'b0, 1'b0, 1'b0, "SLT 0 < -10");
        check_vector(32'hFFFFFFF6, 32'd0, 4'b0011, 32'd0, 1'b1, 1'b0, 1'b0, 1'b0, "SLTU large unsign < 0");
        check_vector(32'd10, 32'd20, 4'b0011, 32'd1, 1'b0, 1'b0, 1'b0, 1'b0, "SLTU 10 < 20");

        // --- 6. Upper Immediate Pass-through (LUI) ---
        check_vector(32'h0, 32'hDEADBEEF, 4'b1111, 32'hDEADBEEF, 1'b0, 1'b1, 1'b0, 1'b0, "LUI pass-through");

        // Additional Corner Vectors to reach 30
        check_vector(32'h7FFFFFFF, 32'h7FFFFFFF, 4'b0000, 32'hFFFFFFFE, 1'b0, 1'b1, 1'b0, 1'b1, "ADD max positive");
        check_vector(32'h80000000, 32'h7FFFFFFF, 4'b1000, 32'd1, 1'b0, 1'b0, 1'b0, 1'b1, "SUB min_neg - max_pos");
        check_vector(32'hFFFFFFFF, 32'h00000000, 4'b0111, 32'h0, 1'b1, 1'b0, 1'b0, 1'b0, "AND all ones with zero");
        check_vector(32'h00000000, 32'h00000000, 4'b0110, 32'h0, 1'b1, 1'b0, 1'b0, 1'b0, "OR zeros");
        check_vector(32'hFFFFFFFF, 32'd31, 4'b0001, 32'h80000000, 1'b0, 1'b1, 1'b0, 1'b0, "SLL all ones shift 31");

        if (errors == 0)
            $display("[PASS] tb_alu_parameterized: All %0d test vectors passed.", tests);
        else
            $display("[FAIL] tb_alu_parameterized: %0d / %0d vectors failed.", errors, tests);
        $finish;
    end

endmodule
