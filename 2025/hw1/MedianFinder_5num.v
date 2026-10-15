module MedianFinder_5num(
    input  [3:0] 	num1, 
	input  [3:0] 	num2, 
	input  [3:0] 	num3, 
	input  [3:0] 	num4, 
	input  [3:0] 	num5,  
	
    output [3:0] 	median  
);

wire [3:0] res_out [5:0];

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
    .A(res_out[0]),
    .B(res_out[2]),
    .min(),
    .max(res_out[4])
);

Comparator2 CMP_3 (
    .A(res_out[1]),
    .B(res_out[3]),
    .min(res_out[5]),
    .max()
);

MedianFinder_3num MF3_0 (
    .num1(res_out[4]),
    .num2(res_out[5]),
    .num3(num5),
    .median(median)
);

endmodule
