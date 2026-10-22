
module rails (
    input        clk,
    input        reset,
    input  [3:0] data,

    output reg   valid,
    output reg   result
);

parameter INIT  = 2'd0;
parameter READ  = 2'd1;
parameter CALC  = 2'd2;
parameter CLEAR = 2'd3;

reg [1:0] state;
reg [3:0] remaining;
reg [3:0] next_train;
reg [15:0] stack_mask;
reg is_possible;

wire [15:0] push_mask;

// Mark trains from next_train to data-1
assign push_mask =
    (16'hFFFF >> (16 - (data - next_train)))
    << (next_train - 1'b1);

always @(posedge clk or posedge reset) begin

    if (reset) begin

        state       <= INIT;
        remaining   <= 4'd0;
        next_train  <= 4'd1;
        stack_mask  <= 16'd0;
        is_possible <= 1'b1;
        valid       <= 1'b0;
        result      <= 1'b0;
    end
    else begin
        case (state)
            INIT: begin
                valid       <= 1'b0;
                remaining   <= data;
                next_train  <= 4'd1;
                stack_mask  <= 16'd0;
                is_possible <= 1'b1;
                state       <= READ;
            end

            READ: begin
                valid <= 1'b0;

                if (data >= next_train) begin

                    // Push trains before data
                    stack_mask <= stack_mask | push_mask;

                    // The target train departs directly
                    next_train <= data + 4'd1;

                end
                else begin
                    
                    // Check whether data is stack top
                    if (stack_mask[data - 1'b1] &&
                        ((stack_mask >> data) == 16'd0)) begin

                        // Pop the target train
                        stack_mask[data - 1'b1] <= 1'b0;
                    end
                    else begin
                        is_possible <= 1'b0;
                    end
                end

                if (remaining == 4'd1) 
                    state <= CALC;
                else
                    remaining <= remaining - 4'd1;
            end

            CALC: begin
                result <= is_possible;
                valid  <= 1'b1;
                state  <= CLEAR;
            end

            CLEAR: begin
                valid <= 1'b0;
                state <= INIT;
            end

            default: begin
                state <= INIT;
            end
        endcase
    end
end

endmodule
