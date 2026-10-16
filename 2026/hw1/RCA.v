module RCA(
	input  [3:0]  x,
	input  [3:0]  y,
	input 		  c_in,
	
	output [3:0]  s,
	output        c_out
);

wire [3:0] Tc_out;

FA FA_0 (
	.x(x[0]),
	.y(y[0]),
	.c_in(c_in),
	.s(s[0]),
	.c_out(Tc_out[0])
);

FA FA_1 (
	.x(x[1]),
	.y(y[1]),
	.c_in(Tc_out[0]),
	.s(s[1]),
	.c_out(Tc_out[1])
);

FA FA_2 (
	.x(x[2]),
	.y(y[2]),
	.c_in(Tc_out[1]),
	.s(s[2]),
	.c_out(Tc_out[2])
);

FA FA_3 (
	.x(x[3]),
	.y(y[3]),
	.c_in(Tc_out[2]),
	.s(s[3]),
	.c_out(c_out)
);

endmodule
