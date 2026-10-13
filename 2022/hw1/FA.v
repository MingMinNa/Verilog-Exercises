module FA (
    input  x, 
    input  y, 
    input  carry_in,
    
    output s,
    output carry_out
);

wire s1, c1, c2;

HA HA_1 (
    .x(x),
    .y(y),
    .s(s1),
    .c(c1)
);

HA HA_2 (
    .x(carry_in),
    .y(s1),
    .s(s),
    .c(c2)
);

assign carry_out = c1 | c2;

endmodule