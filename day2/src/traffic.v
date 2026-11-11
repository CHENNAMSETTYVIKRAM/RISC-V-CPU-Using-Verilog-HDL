`timescale 1ns/1ps

// ============================================================================
// Module: pedestrian_traffic_light
// Description: Traffic Light Controller with Pedestrian Crossing Request.
//              Cycles through VEHICLE GREEN, VEHICLE YELLOW, PEDESTRIAN WALK,
//              and VEHICLE RED safety intervals.
// ============================================================================

module pedestrian_traffic_light #(
    parameter GREEN_TIME  = 10,
    parameter YELLOW_TIME = 3,
    parameter RED_TIME    = 5,
    parameter WALK_TIME   = 4
)(
    input  wire clk,
    input  wire reset,
    input  wire ped_req,     // Pedestrian pushbutton request

    output reg  car_red,
    output reg  car_yellow,
    output reg  car_green,
    output reg  walk
);

    localparam [1:0] S_GREEN     = 2'b00,
                     S_YELLOW    = 2'b01,
                     S_RED_WALK  = 2'b10,
                     S_RED       = 2'b11;

    reg [1:0]  state, next_state;
    reg [31:0] timer;
    reg        ped_pending;

    // Latch pedestrian request until served in S_RED_WALK
    always @(posedge clk) begin
        if (reset)
            ped_pending <= 1'b0;
        else if (state == S_RED_WALK)
            ped_pending <= 1'b0;
        else if (ped_req)
            ped_pending <= 1'b1;
    end

    // Sequential timer and state register
    always @(posedge clk) begin
        if (reset) begin
            state <= S_GREEN;
            timer <= GREEN_TIME - 1;
        end else begin
            if (timer == 0) begin
                state <= next_state;
                case (next_state)
                    S_GREEN:    timer <= GREEN_TIME - 1;
                    S_YELLOW:   timer <= YELLOW_TIME - 1;
                    S_RED_WALK: timer <= WALK_TIME - 1;
                    S_RED:      timer <= RED_TIME - 1;
                    default:    timer <= GREEN_TIME - 1;
                endcase
            end else begin
                timer <= timer - 1'b1;
            end
        end
    end

    // Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            S_GREEN: begin
                // Transition to yellow if pedestrian waiting or cycle completed
                next_state = S_YELLOW;
            end
            S_YELLOW: begin
                next_state = ped_pending ? S_RED_WALK : S_RED;
            end
            S_RED_WALK: begin
                next_state = S_RED;
            end
            S_RED: begin
                next_state = S_GREEN;
            end
            default: next_state = S_GREEN;
        endcase
    end

    // Output decoder (Moore style)
    always @(*) begin
        car_green  = (state == S_GREEN);
        car_yellow = (state == S_YELLOW);
        car_red    = (state == S_RED_WALK) || (state == S_RED);
        walk       = (state == S_RED_WALK);
    end

endmodule
