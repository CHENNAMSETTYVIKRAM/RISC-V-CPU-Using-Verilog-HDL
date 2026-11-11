`timescale 1ns/1ps

module tb_vending_machine;
    reg       clk = 0;
    reg       reset;
    reg       coin5;
    reg       coin10;
    reg       cancel;
    wire      dispense;
    wire [4:0] change;
    wire [4:0] refund;
    wire [4:0] credit;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    vending_machine #(.ITEM_PRICE(15)) uut (
        .clk(clk), .reset(reset), .coin5(coin5), .coin10(coin10), .cancel(cancel),
        .dispense(dispense), .change(change), .refund(refund), .credit(credit)
    );

    initial begin
        // Reset
        reset = 1; coin5 = 0; coin10 = 0; cancel = 0;
        @(posedge clk); #1;
        reset = 0;

        // Scenario 1: Exact payment (5 + 10 = 15)
        coin5 = 1;
        @(posedge clk); #1;
        coin5 = 0;
        tests = tests + 1;
        if (credit !== 5'd5) begin
            $display("[FAIL] Credit not updated to 5: credit=%d", credit);
            errors = errors + 1;
        end

        coin10 = 1;
        @(posedge clk); #1;
        coin10 = 0;
        tests = tests + 1;
        if (!dispense || change !== 0) begin
            $display("[FAIL] Dispense failed on 5+10: disp=%b change=%d", dispense, change);
            errors = errors + 1;
        end

        // Scenario 2: Overpayment with change (10 + 10 = 20 -> dispense + 5 change)
        @(posedge clk); #1;
        coin10 = 1;
        @(posedge clk); #1;
        coin10 = 0;
        @(posedge clk); #1;
        coin10 = 1;
        @(posedge clk); #1;
        coin10 = 0;
        tests = tests + 1;
        if (!dispense || change !== 5'd5) begin
            $display("[FAIL] Dispense with change failed: disp=%b change=%d", dispense, change);
            errors = errors + 1;
        end

        // Scenario 3: Cancel and refund
        @(posedge clk); #1;
        coin5 = 1;
        @(posedge clk); #1;
        coin5 = 0;
        cancel = 1;
        @(posedge clk); #1;
        cancel = 0;
        tests = tests + 1;
        if (refund !== 5'd5 || credit !== 0) begin
            $display("[FAIL] Cancel refund failed: ref=%d cred=%d", refund, credit);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] vending_machine: All %0d tests passed.", tests);
        else
            $display("[FAIL] vending_machine: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
