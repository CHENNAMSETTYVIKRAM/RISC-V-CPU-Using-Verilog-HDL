`timescale 1ns/1ps
module tb_wash_controller;
    reg clk, reset, start, water_full, wash_done, drain_done, rinse_done, spin_done;
    wire water_valve, wash_motor, drain_pump, spin_motor, cycle_done;
    wash_controller dut (.*);
    always #5 clk = ~clk;

    task tick;
        begin @(posedge clk); #1; end
    endtask

    initial begin
        clk=0; reset=1; start=0; water_full=0; wash_done=0;
        drain_done=0; rinse_done=0; spin_done=0;
        tick(); reset=0;
        @(negedge clk); start=1; tick();
        if (!water_valve) $fatal(1, "FILL output missing");
        @(negedge clk); start=0; water_full=1; tick();
        if (!wash_motor) $fatal(1, "WASH output missing");
        @(negedge clk); water_full=0; wash_done=1; tick();
        if (!drain_pump) $fatal(1, "DRAIN output missing");
        @(negedge clk); wash_done=0; drain_done=1; tick();
        if (!water_valve) $fatal(1, "RINSE output missing");
        @(negedge clk); drain_done=0; rinse_done=1; tick();
        if (!spin_motor) $fatal(1, "SPIN output missing");
        @(negedge clk); rinse_done=0; spin_done=1; tick();
        if (!cycle_done) $fatal(1, "DONE output missing");
        $display("PASS: wash-cycle transitions");
        $finish;
    end
endmodule
