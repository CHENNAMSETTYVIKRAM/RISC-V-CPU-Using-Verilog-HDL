`timescale 1ns/1ps

// ============================================================================
// Module: elevator_controller
// Description: 4-Floor Automatic Elevator FSM.
//              Handles floor requests (floors 1-4), direction determination,
//              travel between floors, door dwell countdown, and emergency halt.
// ============================================================================

module elevator_controller #(
    parameter DOOR_TIME_CYCLES = 4
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       emergency,
    input  wire [2:0] floor_request,    // Valid values: 1, 2, 3, 4

    output reg  [2:0] current_floor,
    output reg        motor_up,
    output reg        motor_down,
    output reg        door_open
);

    localparam [1:0] IDLE = 2'b00,
                     UP   = 2'b01,
                     DOWN = 2'b10,
                     DOOR = 2'b11;

    reg [1:0] state;
    reg [2:0] target_floor;
    reg [31:0] door_timer;

    always @(posedge clk) begin
        if (reset) begin
            current_floor <= 3'd1;
            target_floor  <= 3'd1;
            state         <= IDLE;
            door_timer    <= 32'd0;
            motor_up      <= 1'b0;
            motor_down    <= 1'b0;
            door_open     <= 1'b0;
        end else if (emergency) begin
            state         <= IDLE;
            door_timer    <= 32'd0;
            motor_up      <= 1'b0;
            motor_down    <= 1'b0;
            door_open     <= 1'b0;
        end else begin
            // Default actuator outputs
            motor_up   <= 1'b0;
            motor_down <= 1'b0;
            door_open  <= 1'b0;

            case (state)
                IDLE: begin
                    if (floor_request >= 3'd1 && floor_request <= 3'd4) begin
                        target_floor <= floor_request;
                        if (floor_request > current_floor) begin
                            state    <= UP;
                            motor_up <= 1'b1;
                        end else if (floor_request < current_floor) begin
                            state      <= DOWN;
                            motor_down <= 1'b1;
                        end else begin
                            state      <= DOOR;
                            door_timer <= DOOR_TIME_CYCLES;
                            door_open  <= 1'b1;
                        end
                    end
                end

                UP: begin
                    motor_up <= 1'b1;
                    if (current_floor < target_floor) begin
                        current_floor <= current_floor + 1'b1;
                        if (current_floor + 1'b1 == target_floor) begin
                            motor_up   <= 1'b0;
                            state      <= DOOR;
                            door_timer <= DOOR_TIME_CYCLES;
                            door_open  <= 1'b1;
                        end
                    end else begin
                        state <= IDLE;
                    end
                end

                DOWN: begin
                    motor_down <= 1'b1;
                    if (current_floor > target_floor) begin
                        current_floor <= current_floor - 1'b1;
                        if (current_floor - 1'b1 == target_floor) begin
                            motor_down <= 1'b0;
                            state      <= DOOR;
                            door_timer <= DOOR_TIME_CYCLES;
                            door_open  <= 1'b1;
                        end
                    end else begin
                        state <= IDLE;
                    end
                end

                DOOR: begin
                    door_open <= 1'b1;
                    if (door_timer <= 1) begin
                        state      <= IDLE;
                        door_open  <= 1'b0;
                        door_timer <= 32'd0;
                    end else begin
                        door_timer <= door_timer - 1'b1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
