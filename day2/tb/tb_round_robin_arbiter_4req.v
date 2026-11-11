`timescale 1ns/1ps

module tb_round_robin_arbiter_4req;
    reg        clk = 0;
    reg        reset;
    reg  [3:0] req;
    wire [3:0] grant;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    round_robin_arbiter_4req uut (
        .clk(clk), .reset(reset), .req(req), .grant(grant)
    );

    initial begin
        // Reset
        reset = 1; req = 4'b0000;
        @(posedge clk); #1;
        reset = 0;
        tests = tests + 1;
        if (grant !== 4'b0000) begin
            $display("[FAIL] Arbiter reset failed: grant=%b", grant);
            errors = errors + 1;
        end

        // Single requester (Master 2)
        req = 4'b0100;
        @(posedge clk); #1;
        tests = tests + 1;
        if (grant !== 4'b0100) begin
            $display("[FAIL] Grant to single req 2 failed: grant=%b", grant);
            errors = errors + 1;
        end

        // Release request 2 and assert simultaneous requests 0 and 1
        req = 4'b0011;
        @(posedge clk); #1; // Master 2 released, arbitrate
        @(posedge clk); #1;
        tests = tests + 1;
        if (grant === 4'b0000) begin
            $display("[FAIL] Arbiter failed to grant active requests: grant=%b", grant);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] round_robin_arbiter_4req: All %0d tests passed.", tests);
        else
            $display("[FAIL] round_robin_arbiter_4req: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
