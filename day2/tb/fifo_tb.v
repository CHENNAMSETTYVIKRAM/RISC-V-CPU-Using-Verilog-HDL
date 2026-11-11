`timescale 1ns/1ps

module tb_sync_fifo_16x8;
    reg        clk = 0;
    reg        reset;
    reg        wr_en;
    reg        rd_en;
    reg  [7:0] data_in;
    wire [7:0] data_out;
    wire       full;
    wire       empty;
    wire [4:0] count;

    integer errors = 0;
    integer tests  = 0;
    integer i;

    always #5 clk = ~clk;

    sync_fifo_16x8 #(.DATA_WIDTH(8), .ADDR_WIDTH(4)) uut (
        .clk(clk), .reset(reset), .wr_en(wr_en), .rd_en(rd_en),
        .data_in(data_in), .data_out(data_out),
        .full(full), .empty(empty), .count(count)
    );

    initial begin
        // Reset check
        reset = 1; wr_en = 0; rd_en = 0; data_in = 8'h00;
        @(posedge clk); #1;
        reset = 0;
        tests = tests + 1;
        if (!empty || full || count !== 0) begin
            $display("[FAIL] FIFO Reset failed: empty=%b full=%b count=%d", empty, full, count);
            errors = errors + 1;
        end

        // Write 4 elements: 10, 20, 30, 40
        wr_en = 1;
        for (i = 1; i <= 4; i = i + 1) begin
            data_in = i * 10;
            @(posedge clk); #1;
        end
        wr_en = 0;
        tests = tests + 1;
        if (count !== 4 || empty || full) begin
            $display("[FAIL] Write 4 elements: count=%d (expected 4)", count);
            errors = errors + 1;
        end

        // Read 2 elements (should get 10, then 20)
        rd_en = 1;
        @(posedge clk); #1;
        tests = tests + 1;
        if (data_out !== 10) begin
            $display("[FAIL] Read 1: got %d (expected 10)", data_out);
            errors = errors + 1;
        end

        @(posedge clk); #1;
        tests = tests + 1;
        if (data_out !== 20) begin
            $display("[FAIL] Read 2: got %d (expected 20)", data_out);
            errors = errors + 1;
        end
        rd_en = 0;

        // Fill remaining 14 words to reach capacity of 16
        wr_en = 1;
        for (i = 0; i < 14; i = i + 1) begin
            data_in = 8'h80 + i;
            @(posedge clk); #1;
        end
        wr_en = 0;
        tests = tests + 1;
        if (!full || count !== 16) begin
            $display("[FAIL] FIFO full check failed: full=%b count=%d (expected 16)", full, count);
            errors = errors + 1;
        end

        // Overflow guard check: writing when full must not corrupt count
        wr_en = 1; data_in = 8'hFF;
        @(posedge clk); #1;
        wr_en = 0;
        tests = tests + 1;
        if (count !== 16) begin
            $display("[FAIL] FIFO overflow guard failed: count=%d", count);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] sync_fifo_16x8: All %0d tests passed.", tests);
        else
            $display("[FAIL] sync_fifo_16x8: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
