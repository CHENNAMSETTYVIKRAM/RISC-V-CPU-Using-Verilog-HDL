module wash_controller (
    input  wire clk,
    input  wire reset,
    input  wire start,
    input  wire water_full,
    input  wire wash_done,
    input  wire drain_done,
    input  wire rinse_done,
    input  wire spin_done,
    output reg  water_valve,
    output reg  wash_motor,
    output reg  drain_pump,
    output reg  spin_motor,
    output reg  cycle_done
);
    localparam [2:0] IDLE  = 3'd0,
                     FILL  = 3'd1,
                     WASH  = 3'd2,
                     DRAIN = 3'd3,
                     RINSE = 3'd4,
                     SPIN  = 3'd5,
                     DONE  = 3'd6;

    reg [2:0] state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @* begin
        next_state = state;
        case (state)
            IDLE:  if (start)      next_state = FILL;
            FILL:  if (water_full) next_state = WASH;
            WASH:  if (wash_done)  next_state = DRAIN;
            DRAIN: if (drain_done) next_state = RINSE;
            RINSE: if (rinse_done) next_state = SPIN;
            SPIN:  if (spin_done)  next_state = DONE;
            DONE:  if (start)      next_state = FILL;
            default:              next_state = IDLE;
        endcase
    end

    always @* begin
        water_valve = 1'b0;
        wash_motor  = 1'b0;
        drain_pump  = 1'b0;
        spin_motor  = 1'b0;
        cycle_done  = 1'b0;
        case (state)
            FILL:  water_valve = 1'b1;
            RINSE: water_valve = 1'b1;
            WASH:  wash_motor  = 1'b1;
            DRAIN: drain_pump  = 1'b1;
            SPIN:  spin_motor  = 1'b1;
            DONE:  cycle_done  = 1'b1;
            default: ;
        endcase
    end
endmodule
