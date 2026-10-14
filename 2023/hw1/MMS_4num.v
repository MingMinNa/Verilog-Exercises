module MMS_4num (
    input       [7:0] number0,
    input       [7:0] number1,
    input       [7:0] number2,
    input       [7:0] number3,
    input             select,
    
    output reg  [7:0] result
);

reg [7:0] res_out [1:0];
    
always @(*) begin

    case ({select, number0 > number1}) 
        2'b00:     res_out[0] = number1;
        2'b11:     res_out[0] = number1;
        // Otherwise, 2'b01 / 2'b10
        default:  res_out[0] = number0;
    endcase 
    
    case ({select, number2 > number3}) 
        2'b00:     res_out[1] = number3;
        2'b11:     res_out[1] = number3;
        // Otherwise, 2'b01 / 2'b10
        default:  res_out[1] = number2;
    endcase 

    case ({select, res_out[0] > res_out[1]}) 
        2'b00:     result = res_out[1];
        2'b11:     result = res_out[1];
        // Otherwise, 2'b01 / 2'b10
        default:  result = res_out[0];
    endcase 

    /*
    res_out[0] = ((number0 > number1) ^ select)
                 ? number0 : number1;

    res_out[1] = ((number2 > number3) ^ select)
                 ? number2 : number3;

    result = ((res_out[0] > res_out[1]) ^ select)
             ? res_out[0] : res_out[1];
    */
end

endmodule