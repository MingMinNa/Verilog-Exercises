module FA(
	input 	x,
	input 	y,
	input 	c_in,

	output  s, 
	output  c_out
);

wire [2:0] res_out;

HA HA_0 (
	.x(x),
	.y(y),
	.s(res_out[0]),
	.c(res_out[1])
);

HA HA_1 (
	.x(c_in),
	.y(res_out[0]),
	.s(s),
	.c(res_out[2])
);

assign c_out = res_out[1] | res_out[2];

endmodule
