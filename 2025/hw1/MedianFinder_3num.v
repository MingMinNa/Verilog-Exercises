module MedianFinder_3num(
    input  [3:0]    num1, 
    input  [3:0]    num2, 
    input  [3:0]    num3,  
    
    output [3:0]    median  
);

wire [3:0] res_out [2:0];

Comparator2 CMP_0 (
    .A(num1),
    .B(num2),
    .min(res_out[0]),
    .max(res_out[1])
);

Comparator2 CMP_1 (
    .A(res_out[1]),
    .B(num3),
    .min(res_out[2]),
    .max()
);

Comparator2 CMP_2 (
    .A(res_out[0]),
    .B(res_out[2]),
    .min(),
    .max(median)
);

endmodule
