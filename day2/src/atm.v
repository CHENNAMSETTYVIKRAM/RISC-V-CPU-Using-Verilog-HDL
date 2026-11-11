`timescale 1ns/1ps

// ============================================================================
// Module: atm_controller
// Description: Automated Teller Machine (ATM) Controller FSM.
//              Supports PIN verification (max 3 attempts), balance inquiry,
//              cash withdrawal, cash deposit, card ejection, and account lockout.
// ============================================================================

module atm_controller #(
    parameter [15:0] CORRECT_PIN    = 16'd1234,
    parameter [15:0] INITIAL_BALANCE = 16'd5000
)(
    input  wire        clk,
    input  wire        reset,

    input  wire        card_insert,
    input  wire [15:0] pin_entered,
    input  wire        pin_submit,

    input  wire [1:0]  txn_select,      // 0: Withdraw, 1: Deposit, 2: Balance check
    input  wire [15:0] amount,
    input  wire        txn_start,

    output reg  [3:0]  state,
    output reg  [15:0] balance,
    output reg  [15:0] balance_display,

    output reg         cash_dispense,
    output reg         card_eject,
    output reg         pin_error,
    output reg         insufficient_funds,
    output reg         transaction_success
);

    localparam [3:0] IDLE      = 4'd0,
                     PIN_ENTRY = 4'd1,
                     VERIFY    = 4'd2,
                     MENU      = 4'd3,
                     WITHDRAW  = 4'd4,
                     DEPOSIT   = 4'd5,
                     BALANCE   = 4'd6,
                     EJECT     = 4'd7,
                     LOCKED    = 4'd8;

    reg [1:0] attempts;

    always @(posedge clk) begin
        if (reset) begin
            state               <= IDLE;
            balance             <= INITIAL_BALANCE;
            balance_display     <= 16'd0;
            attempts            <= 2'd0;
            cash_dispense       <= 1'b0;
            card_eject          <= 1'b0;
            pin_error           <= 1'b0;
            insufficient_funds  <= 1'b0;
            transaction_success <= 1'b0;
        end else begin
            // Default pulse signals
            cash_dispense       <= 1'b0;
            card_eject          <= 1'b0;
            pin_error           <= 1'b0;
            insufficient_funds  <= 1'b0;
            transaction_success <= 1'b0;

            case (state)
                IDLE: begin
                    attempts        <= 2'd0;
                    balance_display <= 16'd0;
                    if (card_insert)
                        state <= PIN_ENTRY;
                end

                PIN_ENTRY: begin
                    if (pin_submit)
                        state <= VERIFY;
                end

                VERIFY: begin
                    if (pin_entered == CORRECT_PIN) begin
                        attempts <= 2'd0;
                        state    <= MENU;
                    end else begin
                        pin_error <= 1'b1;
                        if (attempts >= 2'd2) begin
                            state <= LOCKED;
                        end else begin
                            attempts <= attempts + 1'b1;
                            state    <= PIN_ENTRY;
                        end
                    end
                end

                MENU: begin
                    if (txn_start) begin
                        case (txn_select)
                            2'b00: state <= WITHDRAW;
                            2'b01: state <= DEPOSIT;
                            2'b10: state <= BALANCE;
                            default: state <= EJECT;
                        endcase
                    end
                end

                WITHDRAW: begin
                    if (amount <= balance) begin
                        balance             <= balance - amount;
                        cash_dispense       <= 1'b1;
                        transaction_success <= 1'b1;
                        state               <= EJECT;
                    end else begin
                        insufficient_funds  <= 1'b1;
                        state               <= MENU;
                    end
                end

                DEPOSIT: begin
                    balance             <= balance + amount;
                    transaction_success <= 1'b1;
                    state               <= EJECT;
                end

                BALANCE: begin
                    balance_display     <= balance;
                    transaction_success <= 1'b1;
                    state               <= EJECT;
                end

                EJECT: begin
                    card_eject <= 1'b1;
                    state      <= IDLE;
                end

                LOCKED: begin
                    // Remains locked until system reset
                    state <= LOCKED;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
