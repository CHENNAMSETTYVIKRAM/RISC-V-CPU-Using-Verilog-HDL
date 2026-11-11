`timescale 1ns/1ps

module tb_atm_controller;
    reg        clk = 0;
    reg        reset;
    reg        card_insert;
    reg [15:0] pin_entered;
    reg        pin_submit;
    reg [1:0]  txn_select;
    reg [15:0] amount;
    reg        txn_start;

    wire [3:0]  state;
    wire [15:0] balance;
    wire [15:0] balance_display;
    wire        cash_dispense;
    wire        card_eject;
    wire        pin_error;
    wire        insufficient_funds;
    wire        transaction_success;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    atm_controller #(
        .CORRECT_PIN(16'd1234),
        .INITIAL_BALANCE(16'd5000)
    ) uut (
        .clk(clk), .reset(reset),
        .card_insert(card_insert),
        .pin_entered(pin_entered), .pin_submit(pin_submit),
        .txn_select(txn_select), .amount(amount), .txn_start(txn_start),
        .state(state), .balance(balance), .balance_display(balance_display),
        .cash_dispense(cash_dispense), .card_eject(card_eject),
        .pin_error(pin_error), .insufficient_funds(insufficient_funds),
        .transaction_success(transaction_success)
    );

    initial begin
        // Reset
        reset = 1; card_insert = 0; pin_entered = 0; pin_submit = 0;
        txn_select = 0; amount = 0; txn_start = 0;
        @(posedge clk); #1;
        reset = 0;
        tests = tests + 1;
        if (state !== 4'd0 || balance !== 16'd5000) begin
            $display("[FAIL] ATM Reset failed: state=%d bal=%d", state, balance);
            errors = errors + 1;
        end

        // Insert card
        card_insert = 1;
        @(posedge clk); #1;
        card_insert = 0;

        // Enter correct PIN (1234)
        pin_entered = 16'd1234; pin_submit = 1;
        @(posedge clk); #1;
        pin_submit = 0;

        @(posedge clk); #1; // State reaches MENU (3)
        tests = tests + 1;
        if (state !== 4'd3) begin
            $display("[FAIL] ATM did not reach MENU state: state=%d", state);
            errors = errors + 1;
        end

        // Withdraw 1000 rupees
        txn_select = 2'b00; amount = 16'd1000; txn_start = 1;
        @(posedge clk); #1;
        txn_start = 0;

        @(posedge clk); #1;
        tests = tests + 1;
        if (!cash_dispense || !transaction_success || balance !== 16'd4000) begin
            $display("[FAIL] Withdrawal failed: dispense=%b success=%b bal=%d",
                     cash_dispense, transaction_success, balance);
            errors = errors + 1;
        end

        // Card eject
        @(posedge clk); #1;
        tests = tests + 1;
        if (!card_eject) begin
            $display("[FAIL] Card eject pulse not generated");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] atm_controller: All %0d tests passed.", tests);
        else
            $display("[FAIL] atm_controller: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
