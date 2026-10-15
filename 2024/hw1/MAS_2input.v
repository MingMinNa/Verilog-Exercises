module MAS_2input (
    input  signed [4:0] Din1,
    input  signed [4:0] Din2,
    input         [1:0] Sel,
    input  signed [4:0]  Q,

    output        [1:0] Tcmp,
    output signed [4:0] TDout,
    output signed [3:0] Dout
);

wire signed [4:0] TDout_2;

ALU ALU_0 (
    .Din1(Din1),
    .Din2(Din2),
    .Sel(Sel),
    .TDout(TDout)
);

ALU ALU_1 (
    .Din1(TDout),
    .Din2(Q),
    .Sel(Tcmp),
    .TDout(TDout_2)
);

assign Tcmp = {TDout >= Q, TDout >= 0};
assign Dout = TDout_2[3:0];

endmodule


module ALU (
    input  signed [4:0] Din1,
    input  signed [4:0] Din2,
    input         [1:0] Sel,

    output reg signed [4:0] TDout
);

always @(Din1 or Din2 or Sel) begin

    case (Sel)
        2'b00:   TDout = Din1 + Din2;
        2'b11:   TDout = Din1 - Din2;
        default: TDout = Din1;
    endcase
end

endmodule