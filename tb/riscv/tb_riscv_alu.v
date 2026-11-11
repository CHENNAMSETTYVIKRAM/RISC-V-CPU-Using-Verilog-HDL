`timescale 1ns/1ps

module tb_riscv_alu;
    reg  [31:0] a, b;
    reg  [3:0]  alu_ctrl;
    wire [31:0] result;
    wire        zero, negative, carry, overflow;

    integer errors = 0;
    integer tests  = 0;

    riscv_alu uut (
        .a(a), .b(b), .alu_ctrl(alu_ctrl),
        .result(result), .zero(zero), .negative(negative),
        .carry(carry), .overflow(overflow)
    );

    initial begin
        // 1. ADD: 15 + 27 = 42
        alu_ctrl = 4'b0000; a = 32'd15; b = 32'd27; #10;
        tests = tests + 1;
        if (result !== 32'd42 || zero !== 0 || negative !== 0) begin
            $display("[FAIL] ADD 15+27 failed: res=%d", result);
            errors = errors + 1;
        end

        // 2. SUB: 50 - 50 = 0 (Zero flag check)
        alu_ctrl = 4'b1000; a = 32'd50; b = 32'd50; #10;
        tests = tests + 1;
        if (result !== 32'd0 || zero !== 1) begin
            $display("[FAIL] SUB zero flag check failed: res=%d zero=%b", result, zero);
            errors = errors + 1;
        end

        // 3. SLL: 32'h00000001 << 4 = 32'h00000010
        alu_ctrl = 4'b0001; a = 32'h00000001; b = 32'd4; #10;
        tests = tests + 1;
        if (result !== 32'h00000010) begin
            $display("[FAIL] SLL failed: res=%h", result);
            errors = errors + 1;
        end

        // 4. SLT (Signed Less Than): -5 < 3 -> 1
        alu_ctrl = 4'b0010; a = -32'sd5; b = 32'sd3; #10;
        tests = tests + 1;
        if (result !== 32'd1) begin
            $display("[FAIL] SLT -5 < 3 failed: res=%d", result);
            errors = errors + 1;
        end

        // 5. SLTU (Unsigned Less Than): -5 (0xFFFFFFFB) < 3 -> 0
        alu_ctrl = 4'b0011; a = 32'hFFFFFFFB; b = 32'd3; #10;
        tests = tests + 1;
        if (result !== 32'd0) begin
            $display("[FAIL] SLTU unsigned comparison failed: res=%d", result);
            errors = errors + 1;
        end

        // 6. XOR: 32'hF0F0F0F0 ^ 32'hFFFF0000 = 32'h0F0FF0F0
        alu_ctrl = 4'b0100; a = 32'hF0F0F0F0; b = 32'hFFFF0000; #10;
        tests = tests + 1;
        if (result !== 32'h0F0FF0F0) begin
            $display("[FAIL] XOR failed: res=%h", result);
            errors = errors + 1;
        end

        // 7. SRL: 32'h80000000 >> 1 = 32'h40000000
        alu_ctrl = 4'b0101; a = 32'h80000000; b = 32'd1; #10;
        tests = tests + 1;
        if (result !== 32'h40000000) begin
            $display("[FAIL] SRL failed: res=%h", result);
            errors = errors + 1;
        end

        // 8. SRA: 32'h80000000 >>> 1 = 32'hC0000000 (sign bit preserved)
        alu_ctrl = 4'b1101; a = 32'h80000000; b = 32'd1; #10;
        tests = tests + 1;
        if (result !== 32'hC0000000) begin
            $display("[FAIL] SRA failed: res=%h", result);
            errors = errors + 1;
        end

        // 9. OR & AND
        alu_ctrl = 4'b0110; a = 32'h0000FFFF; b = 32'hFF00FF00; #10; // OR
        tests = tests + 1;
        if (result !== 32'hFF00FFFF) begin
            $display("[FAIL] OR failed: res=%h", result);
            errors = errors + 1;
        end

        alu_ctrl = 4'b0111; a = 32'h0000FFFF; b = 32'hFF00FF00; #10; // AND
        tests = tests + 1;
        if (result !== 32'h0000FF00) begin
            $display("[FAIL] AND failed: res=%h", result);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] riscv_alu: All %0d tests passed.", tests);
        else
            $display("[FAIL] riscv_alu: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
