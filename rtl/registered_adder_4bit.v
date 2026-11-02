module registered_adder_4bit (
    input  wire       clk,
    input  wire       reset,
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       cin,
    output reg  [3:0] sum,
    output reg        cout
);
    wire [3:0] next_sum;
    wire       next_cout;

    ripple_adder_4bit adder (
        .a(a), .b(b), .cin(cin), .sum(next_sum), .cout(next_cout)
    );

    // Synchronous active-high reset; output captures the current sum on each rising edge.
    always @(posedge clk) begin
        if (reset) begin
            sum  <= 4'b0000;
            cout <= 1'b0;
        end else begin
            sum  <= next_sum;
            cout <= next_cout;
        end
    end
endmodule
