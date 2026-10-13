module ALU_1bit (
    input           a, 
    input           b, 
    input           less, 
    input           Ainvert, 
    input           Binvert, 
    input           c_in, 
    input  [1:0]    op,

    output reg      result, 
    output reg      c_out, 
    output reg      set, 
    output reg      overflow 
);

reg a_out, b_out;
wire FA_s, FA_c;

FA FA_1 (
    .x(a_out),
    .y(b_out),
    .carry_in(c_in),
    .s(FA_s),
    .carry_out(FA_c)
);

always @(*) begin
    
    if (Ainvert) a_out = ~a;
    else         a_out = a;
    
    if (Binvert) b_out = ~b;
    else         b_out = b;

    case (op)
        2'b00:   result = a_out & b_out;
        2'b01:   result = a_out | b_out;
        2'b10:   result = FA_s;
        default: result = less;
    endcase

    set = FA_s;
    c_out = FA_c;
    overflow = c_in ^ c_out;
end

endmodule