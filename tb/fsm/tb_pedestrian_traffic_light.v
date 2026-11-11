`timescale 1ns/1ps

module tb_pedestrian_traffic_light;
    reg clk = 0;
    reg reset;
    reg ped_req;
    wire car_red;
    wire car_yellow;
    wire car_green;
    wire walk;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    pedestrian_traffic_light #(
        .GREEN_TIME(3), .YELLOW_TIME(2), .RED_TIME(2), .WALK_TIME(2)
    ) uut (
        .clk(clk), .reset(reset), .ped_req(ped_req),
        .car_red(car_red), .car_yellow(car_yellow), .car_green(car_green),
        .walk(walk)
    );

    initial begin
        reset = 1; ped_req = 0;
        @(posedge clk); #1;
        reset = 0;

        // Vehicle Green
        tests = tests + 1;
        if (!car_green || car_red || walk) begin
            $display("[FAIL] Initial state not GREEN: grn=%b red=%b walk=%b", car_green, car_red, walk);
            errors = errors + 1;
        end

        // Assert pedestrian request
        ped_req = 1;
        @(posedge clk); #1;
        ped_req = 0;

        // Wait for GREEN -> YELLOW -> RED_WALK
        repeat (5) @(posedge clk); #1;
        tests = tests + 1;
        if (!walk || !car_red) begin
            $display("[FAIL] Pedestrian walk phase not entered: walk=%b red=%b", walk, car_red);
            errors = errors + 1;
        end

        // Safety interlock check: car_green and walk must never be asserted together
        repeat (10) begin
            @(posedge clk); #1;
            if (car_green && walk) begin
                $display("[FAIL] CRITICAL SAFETY VIOLATION: Green light and Walk asserted simultaneously!");
                errors = errors + 1;
            end
        end
        tests = tests + 1;

        if (errors == 0)
            $display("[PASS] pedestrian_traffic_light: All %0d tests passed.", tests);
        else
            $display("[FAIL] pedestrian_traffic_light: %0d / %0d tests failed.", errors, tests);
        $finish;
    end
endmodule
