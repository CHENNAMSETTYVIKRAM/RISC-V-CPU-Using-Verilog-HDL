`timescale 1ns/1ps

module tb_elevator_controller;
    reg        clk = 0;
    reg        reset;
    reg        emergency;
    reg  [2:0] floor_request;
    wire [2:0] current_floor;
    wire       motor_up;
    wire       motor_down;
    wire       door_open;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    elevator_controller #(.DOOR_TIME_CYCLES(3)) uut (
        .clk(clk), .reset(reset), .emergency(emergency),
        .floor_request(floor_request),
        .current_floor(current_floor),
        .motor_up(motor_up), .motor_down(motor_down),
        .door_open(door_open)
    );

    initial begin
        // Reset
        reset = 1; emergency = 0; floor_request = 3'd0;
        @(posedge clk); #1;
        reset = 0;
        tests = tests + 1;
        if (current_floor !== 3'd1 || door_open !== 0) begin
            $display("[FAIL] Elevator reset failed: floor=%d door=%b", current_floor, door_open);
            errors = errors + 1;
        end

        // Request Floor 3
        floor_request = 3'd3;
        @(posedge clk); #1;
        floor_request = 3'd0;

        // Expect elevator to move up
        tests = tests + 1;
        if (!motor_up) begin
            $display("[FAIL] Motor up not engaged for floor 3 request");
            errors = errors + 1;
        end

        // Wait until floor 3 reached
        repeat (6) @(posedge clk); #1;
        tests = tests + 1;
        if (current_floor !== 3'd3 || !door_open) begin
            $display("[FAIL] Elevator did not reach floor 3: floor=%d door=%b", current_floor, door_open);
            errors = errors + 1;
        end

        // Wait for door countdown to close
        repeat (4) @(posedge clk); #1;
        tests = tests + 1;
        if (door_open !== 0) begin
            $display("[FAIL] Door did not close after timeout");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("[PASS] elevator_controller: All %0d tests passed.", tests);
        else
            $display("[FAIL] elevator_controller: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
