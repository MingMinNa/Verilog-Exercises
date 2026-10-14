module MMS_8num (
    input   [7:0] number0,
    input   [7:0] number1,
    input   [7:0] number2,
    input   [7:0] number3,
    input   [7:0] number4,
    input   [7:0] number5,
    input   [7:0] number6,
    input   [7:0] number7,
    input         select,

    output  [7:0] result
);

wire [7:0] res_out [1:0];

MMS_4num MMS4_1 (
    .number0(number0),
    .number1(number1),
    .number2(number2),
    .number3(number3),
    .select(select),
    .result(res_out[0])
);

MMS_4num MMS4_2 (
    .number0(number4),
    .number1(number5),
    .number2(number6),
    .number3(number7),
    .select(select),
    .result(res_out[1])
);

assign result = 
    ((res_out[0] > res_out[1]) ^ select)
    ? res_out[0] : res_out[1];

endmodule