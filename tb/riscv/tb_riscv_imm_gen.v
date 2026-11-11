`timescale 1ns/1ps

module tb_riscv_imm_gen;
    reg  [31:0] instr;
    wire [31:0] imm_out;

    integer errors = 0;
    integer tests  = 0;

    riscv_imm_gen uut (
        .instr(instr), .imm_out(imm_out)
    );

    initial begin
        // I-type: ADDI x1, x0, -1 -> imm = 0xFFFFFFFF (32'hFFF00093)
        instr = 32'hFFF00093; #10;
        tests = tests + 1;
        if (imm_out !== 32'hFFFFFFFF) begin
            $display("[FAIL] I-type negative immediate: got %h", imm_out);
            errors = errors + 1;
        end

        // S-type: SW x2, 4(x1) -> imm = 4 (32'h0020a223)
        instr = 32'h0020a223; #10;
        tests = tests + 1;
        if (imm_out !== 32'd4) begin
            $display("[FAIL] S-type immediate: got %d (expected 4)", imm_out);
            errors = errors + 1;
        end

        // U-type: LUI x1, 0x12345 (32'h123450B7)
        instr = 32'h123450B7; #10;
        tests = tests + 1;
        if (imm_out !== 32'h12345000) begin
            $display("[FAIL] U-type immediate: got %h", imm_out);
            errors = errors + 1;
        end

        // J-type: JAL x1, -4 (32'hFFDFF0EF)
        instr = 32'hFFDFF0EF; #10;
        tests = tests + 1;
        if (imm_out !== -32'sd4) begin
            $display("[FAIL] J-type immediate: got %d (expected -4)", $signed(imm_out));
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] riscv_imm_gen: All %0d tests passed.", tests);
        else
            $display("[FAIL] riscv_imm_gen: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
