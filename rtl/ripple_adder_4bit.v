module full_adder_1bit (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

module ripple_adder_4bit (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       cin,
    output wire [3:0] sum,
    output wire       cout
);
    wire [4:0] carry;
    assign carry[0] = cin;

    genvar bit_index;
    generate
        for (bit_index = 0; bit_index < 4; bit_index = bit_index + 1) begin : g_full_adder
            full_adder_1bit bit_adder (
                .a(a[bit_index]), .b(b[bit_index]), .cin(carry[bit_index]),
                .sum(sum[bit_index]), .cout(carry[bit_index + 1])
            );
        end
    endgenerate
    assign cout = carry[4];
endmodule
