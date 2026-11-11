`timescale 1ns/1ps

// ============================================================================
// Module: vending_machine
// Description: Multi-coin vending machine FSM (Item cost = 15).
//              Accepts 5 and 10 rupee coins. Provides single-cycle pulses for
//              dispense, change return, and cancellation refunds.
// ============================================================================

module vending_machine #(
    parameter ITEM_PRICE = 15
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       coin5,
    input  wire       coin10,
    input  wire       cancel,

    output reg        dispense,
    output reg  [4:0] change,
    output reg  [4:0] refund,
    output reg  [4:0] credit
);

    localparam [1:0] S0  = 2'b00,
                     S5  = 2'b01,
                     S10 = 2'b10;

    reg [1:0] state;

    always @(posedge clk) begin
        if (reset) begin
            state    <= S0;
            credit   <= 5'd0;
            dispense <= 1'b0;
            change   <= 5'd0;
            refund   <= 5'd0;
        end else begin
            // Single-cycle default pulses
            dispense <= 1'b0;
            change   <= 5'd0;
            refund   <= 5'd0;

            if (cancel) begin
                refund <= credit;
                credit <= 5'd0;
                state  <= S0;
            end else begin
                case (state)
                    S0: begin
                        credit <= 5'd0;
                        if (coin5) begin
                            credit <= 5'd5;
                            state  <= S5;
                        end else if (coin10) begin
                            credit <= 5'd10;
                            state  <= S10;
                        end
                    end

                    S5: begin
                        if (coin5) begin
                            credit <= 5'd10;
                            state  <= S10;
                        end else if (coin10) begin
                            // 5 + 10 = 15 -> Vend
                            dispense <= 1'b1;
                            change   <= 5'd0;
                            credit   <= 5'd0;
                            state    <= S0;
                        end
                    end

                    S10: begin
                        if (coin5) begin
                            // 10 + 5 = 15 -> Vend
                            dispense <= 1'b1;
                            change   <= 5'd0;
                            credit   <= 5'd0;
                            state    <= S0;
                        end else if (coin10) begin
                            // 10 + 10 = 20 -> Vend with 5 change
                            dispense <= 1'b1;
                            change   <= 5'd5;
                            credit   <= 5'd0;
                            state    <= S0;
                        end
                    end

                    default: state <= S0;
                endcase
            end
        end
    end

endmodule
