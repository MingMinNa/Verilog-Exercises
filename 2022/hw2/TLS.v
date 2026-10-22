module TLS (
    input          clk,
    input          reset,
    input          Set,
    input          Stop,
    input          Jump,
    input   [3:0]  Gin,
    input   [3:0]  Yin,
    input   [3:0]  Rin,

    output         Gout,
    output         Yout,
    output         Rout
);

parameter IDLE   = 2'd0;
parameter GREEN  = 2'd1;
parameter YELLOW = 2'd2;
parameter RED    = 2'd3;

reg [1:0] state;
reg [3:0] count;

// Store the duration of each light
reg [3:0] G_time;
reg [3:0] Y_time;
reg [3:0] R_time;

assign Gout = (state == GREEN);
assign Yout = (state == YELLOW);
assign Rout = (state == RED);

always @(posedge clk or posedge reset) begin

    if (reset) begin

        state  <= IDLE;
        count  <= 4'd0;
        G_time <= 4'd0;
        Y_time <= 4'd0;
        R_time <= 4'd0;
    end
    else if (Set) begin

        G_time <= Gin;
        Y_time <= Yin;
        R_time <= Rin;

        state <= GREEN;
        count <= 4'd1;
    end
    else if (Jump) begin

        state <= RED;
        count <= 4'd1;
    end
    else if (Stop) begin

        state <= state;
        count <= count;
    end
    else begin
        case (state)
            GREEN: begin
                if (count >= G_time) begin
                    state <= YELLOW;
                    count <= 4'd1;
                end
                else begin
                    count <= count + 4'd1;
                end
            end

            YELLOW: begin
                if (count >= Y_time) begin
                    state <= RED;
                    count <= 4'd1;
                end
                else begin
                    count <= count + 4'd1;
                end
            end

            RED: begin
                if (count >= R_time) begin
                    state <= GREEN;
                    count <= 4'd1;
                end
                else begin
                    count <= count + 4'd1;
                end
            end

            default: begin
                state <= IDLE;
                count <= 4'd0;
            end
        endcase
    end
end

endmodule