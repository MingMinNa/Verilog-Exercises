module Mul_Mod (
    input  [22:0] A,
    input  [22:0] B,

    output [23:0] Z
);

localparam [23:0] Q = 24'd8380417;

// Stage 1: Partial Multiplication

wire [28:0] mul_high;
wire [39:0] mul_low;
wire [46:0] U;

assign mul_high = A * B[22:17];
assign mul_low  = A * B[16:0];

RCA #(.WIDTH(47)) RCA_U (
    .a    ({1'b0, mul_high, 17'b0}),
    .b    ({7'b0, mul_low}),
    .c_in (1'b0),
    .sum  (U),
    .c_out()
);

// Stage 2: Quotient Approximation

wire [23:0] V;
wire [23:0] Y;

assign V = U[45:22];
assign Y = U[23:0];

// Upper path: V + V[23:10]
wire [24:0] V_add1;

RCA #(.WIDTH(25)) RCA_V1 (
    .a    ({1'b0, V}),
    .b    ({11'b0, V[23:10]}),
    .c_in (1'b0),
    .sum  (V_add1),
    .c_out()
);

// Concatenate the lower 10 bits
wire [34:0] V_concat;

assign V_concat = {V_add1, V[9:0]};

// Lower path: (V << 1) + V + V[23:1]
wire [25:0] V_add2;
wire [25:0] V_add3;

RCA #(.WIDTH(26)) RCA_V2 (
    .a    ({1'b0, V, 1'b0}),
    .b    ({2'b00, V}),
    .c_in (1'b0),
    .sum  (V_add2),
    .c_out()
);

RCA #(.WIDTH(26)) RCA_V3 (
    .a    (V_add2),
    .b    ({3'b000, V[23:1]}),
    .c_in (1'b0),
    .sum  (V_add3),
    .c_out()
);

// Add selected lower-path bits
wire [34:0] V_sum;
wire [23:0] W;

RCA #(.WIDTH(35)) RCA_V4 (
    .a    (V_concat),
    .b    ({21'b0, V_add3[25:12]}),
    .c_in (1'b0),
    .sum  (V_sum),
    .c_out()
);

assign W = V_sum[34:11];

// Stage 3: Constant Multiplication
// X = W * Q (lower 24 bits)

wire [10:0] W_sub;
wire [23:0] X;

// W[23:13] - W[10:0] 
// = W[23:13] + two's complement of W[10:0] 
// = W[23:13] + ~W[10:0] + 1

RCA #(.WIDTH(11)) RCA_X (
    .a    (W[23:13]),
    .b    (~W[10:0]),
    .c_in (1'b1),
    .sum  (W_sub),
    .c_out()
);

assign X[12:0]  = W[12:0];
assign X[22:13] = W_sub[9:0];
assign X[23]    = W_sub[10] ^ W[0];

// Stage 4: Remainder Calculation
// D = Y - X

wire [23:0] D;

RCA #(.WIDTH(24)) RCA_D (
    .a    (Y),
    .b    (~X),
    .c_in (1'b1),
    .sum  (D),
    .c_out()
);

// Stage 5: Final Correction
// M = D - Q

wire [23:0] M;
wire no_borrow;

RCA #(.WIDTH(24)) RCA_M (
    .a    (D),
    .b    (~Q),
    .c_in (1'b1),
    .sum  (M),
    .c_out(no_borrow)
);

assign Z = no_borrow ? M : D;

endmodule


module RCA #(
    parameter WIDTH = 24
)(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input              c_in,

    output [WIDTH-1:0] sum,
    output             c_out
);

wire [WIDTH:0] carry;
genvar i;

generate
    for (i = 0; i < WIDTH; i = i + 1) begin : FA

        assign sum[i] = a[i] ^ b[i] ^ carry[i];

        assign carry[i+1] = 
            (a[i] & b[i]) |
            ((a[i] ^ b[i]) & carry[i]);
    end
endgenerate

assign carry[0] = c_in;
assign c_out = carry[WIDTH];

endmodule
