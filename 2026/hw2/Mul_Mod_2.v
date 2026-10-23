module Mul_Mod_2 (
    input  [22:0] A,
    input  [22:0] B,

    output reg [23:0] Z
);

localparam signed [46:0] Q = 48'sd8380417;

reg [45:0] U_out;

reg signed [46:0] T1;
reg signed [46:0] T2;
reg signed [46:0] T3;
reg signed [46:0] M_out;

// Modular reduction using:
// Q = 2^23 - 2^13 + 1  => 2^23 = 2^13 - 1 (mod Q)

function signed [46:0] reduce_step;

input signed [46:0] value;

reg signed [46:0] high_part;
reg signed [46:0] low_part;

begin
    high_part = value >>> 23;
    low_part  = value - (high_part <<< 23);

    reduce_step = low_part 
                - high_part
                + (high_part <<< 13);
end
endfunction

always @(*) begin

    // 23-bit x 23-bit = 46-bit
    U_out = A * B;

    // Reduction
    T1 = reduce_step($signed({1'b0, U_out})); // 46-bit -> 36-bit 
    T2 = reduce_step(T1);                     // 36-bit -> 27-bit
    T3 = reduce_step(T2);                     // 27-bit -> 24-bit

    if (T3 < 48'sd0)
        M_out = T3 + Q;
    else if (T3 >= Q)
        M_out = T3 - Q;
    else
        M_out = T3;

    Z = M_out[23:0];
end
    
endmodule
