`timescale 1ns/1ps

module tb_riscv_regfile;
    reg        clk = 0;
    reg        reset;
    reg  [4:0]  rs1_addr, rs2_addr, rd_addr;
    reg  [31:0] wr_data;
    reg        wr_en;
    wire [31:0] rs1_data, rs2_data;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    riscv_regfile uut (
        .clk(clk), .reset(reset),
        .rs1_addr(rs1_addr), .rs2_addr(rs2_addr),
        .rd_addr(rd_addr), .wr_data(wr_data), .wr_en(wr_en),
        .rs1_data(rs1_data), .rs2_data(rs2_data)
    );

    initial begin
        // Reset check
        reset = 1; rs1_addr = 0; rs2_addr = 0; rd_addr = 0; wr_data = 0; wr_en = 0;
        @(posedge clk); #1;
        reset = 0;

        // Write to x5
        rd_addr = 5'd5; wr_data = 32'hDEADBEEF; wr_en = 1;
        @(posedge clk); #1;
        wr_en = 0;

        // Read from x5
        rs1_addr = 5'd5; #1;
        tests = tests + 1;
        if (rs1_data !== 32'hDEADBEEF) begin
            $display("[FAIL] Regfile read x5: got %h", rs1_data);
            errors = errors + 1;
        end

        // Attempt write to x0 (must remain zero!)
        rd_addr = 5'd0; wr_data = 32'hFFFFFFFF; wr_en = 1;
        @(posedge clk); #1;
        wr_en = 0; rs1_addr = 5'd0; #1;
        tests = tests + 1;
        if (rs1_data !== 32'd0) begin
            $display("[FAIL] x0 written to non-zero: got %h", rs1_data);
            errors = errors + 1;
        end

        // Internal bypass check: write and read same register in same cycle
        rd_addr = 5'd10; wr_data = 32'h12345678; wr_en = 1;
        rs2_addr = 5'd10; #1; // Combinational read before clock edge
        tests = tests + 1;
        if (rs2_data !== 32'h12345678) begin
            $display("[FAIL] Internal bypass failed: got %h", rs2_data);
            errors = errors + 1;
        end
        @(posedge clk); #1;

        if (errors == 0)
            $display("[PASS] riscv_regfile: All %0d tests passed.", tests);
        else
            $display("[FAIL] riscv_regfile: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
