module MedianFinder_7num(
    input  	[3:0]  	num1, 
	input  	[3:0]  	num2, 
	input  	[3:0]  	num3, 
	input  	[3:0]  	num4, 
	input  	[3:0]  	num5, 
	input  	[3:0]  	num6, 
	input  	[3:0]  	num7,  
	
    output 	[3:0] 	median  
);

wire [3:0] res_out [17:0];

Comparator2 CMP_0 (
	.A(num1),
	.B(num2),
	.min(res_out[0]),
	.max(res_out[1])
);

Comparator2 CMP_1 (
	.A(num3),
	.B(num4),
	.min(res_out[2]),
	.max(res_out[3])
);

Comparator2 CMP_2 (
	.A(num5),
	.B(num6),
	.min(res_out[4]),
	.max(res_out[5])
);

/* Find the Minimum */ 

Comparator2 CMP_3 (
	.A(res_out[0]),
	.B(res_out[2]),
	.min(res_out[6]),
	.max(res_out[12])
);

Comparator2 CMP_4 (
	.A(res_out[4]),
	.B(res_out[6]),
	.min(res_out[7]),
	.max(res_out[13])
);

Comparator2 CMP_5 (
	.A(res_out[7]),
	.B(num7),
	.min(res_out[8]), // Minimum
	.max(res_out[14]) 
);


/* Find the Maximum */ 

Comparator2 CMP_6 (
	.A(res_out[1]),
	.B(res_out[3]),
	.min(res_out[15]),
	.max(res_out[9])
);

Comparator2 CMP_7 (
	.A(res_out[5]),
	.B(res_out[9]),
	.min(res_out[16]),
	.max(res_out[10])
);

Comparator2 CMP_8 (
	.A(res_out[10]),
	.B(num7),
	.min(res_out[17]),
	.max(res_out[11]) // Maximum
);

/*  Assume the numbers is 1, 2, 3, 4, 5, 6, 7 */
// res_out[ 0] = 1
// res_out[ 1] = 2
// res_out[ 2] = 3
// res_out[ 3] = 4
// res_out[ 4] = 5
// res_out[ 5] = 6

// res_out[ 6] = 1
// res_out[ 7] = 1
// res_out[ 8] = 1
// res_out[ 9] = 4
// res_out[10] = 6
// res_out[11] = 7

// res_out[12] = 3
// res_out[13] = 5
// res_out[14] = 7 (X)
// res_out[15] = 2
// res_out[16] = 4
// res_out[17] = 6

MedianFinder_5num MF5_0 (
	.num1(res_out[12]),
	.num2(res_out[13]),
	.num3(res_out[15]),
	.num4(res_out[16]),
	.num5(res_out[17]),
	.median(median)
);

endmodule
