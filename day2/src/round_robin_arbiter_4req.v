`timescale 1ns/1ps

// ============================================================================
// Module: round_robin_arbiter_4req
// Description: Fair 4-requester round-robin arbiter with rotating priority pointer.
//              Holds an active grant until the master releases its request line.
// ============================================================================

module round_robin_arbiter_4req (
    input  wire       clk,
    input  wire       reset,      // Active-high synchronous reset
    input  wire [3:0] req,        // 4 requester lines
    output reg  [3:0] grant       // One-hot grant lines
);

    reg [1:0] priority_ptr;
    reg [3:0] candidate;
    reg       found;
    integer   k;
    integer   idx;

    // Combinational search starting at priority_ptr
    always @(*) begin
        candidate = 4'b0000;
        found     = 1'b0;
        idx       = 0;
        for (k = 0; k < 4; k = k + 1) begin
            idx = priority_ptr + k;
            if (idx >= 4)
                idx = idx - 4;
            if (!found && req[idx]) begin
                candidate = 4'b0001 << idx;
                found     = 1'b1;
            end
        end
    end

    // Sequential arbitration state
    always @(posedge clk) begin
        if (reset) begin
            grant        <= 4'b0000;
            priority_ptr <= 2'd0;
        end else if (grant != 4'b0000) begin
            // If currently granted master has released its request, advance pointer and arbitrate
            if ((grant & req) == 4'b0000) begin
                case (grant)
                    4'b0001: priority_ptr <= 2'd1;
                    4'b0010: priority_ptr <= 2'd2;
                    4'b0100: priority_ptr <= 2'd3;
                    4'b1000: priority_ptr <= 2'd0;
                    default: priority_ptr <= priority_ptr;
                endcase
                grant <= candidate;
            end
            // Otherwise, hold the current grant
        end else begin
            grant <= candidate;
        end
    end

endmodule
