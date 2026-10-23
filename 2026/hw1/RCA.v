module RCA(
	input  [3:0]  x,
	input  [3:0]  y,
	input 		  c_in,
	
	output [3:0]  s,
	output        c_out
);

wire [4:0] carry;
genvar i;

generate
	for (i = 0; i < 4; i = i + 1) begin : FA_GEN

		FA FA_inst (
			.x    (x[i]),
			.y    (y[i]),
			.c_in (carry[i]),
			.s    (s[i]),
			.c_out(carry[i+1])
		);
	end
endgenerate

assign carry[0] = c_in;
assign c_out = carry[4];

endmodule
