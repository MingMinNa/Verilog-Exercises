module CIPU (
    input        clk, 
    input        rst,
    input  [7:0] people_thing_in,
    input        ready_fifo,
    input        ready_lifo,
    input  [7:0] thing_in,
    input  [3:0] thing_num,

    output reg       valid_fifo,
    output reg       valid_lifo,
    output reg       valid_fifo2,
    output reg [7:0] people_thing_out,
    output reg [7:0] thing_out,
    output reg       done_thing,
    output reg       done_fifo,
    output reg       done_lifo,
    output reg       done_fifo2
);

// '$', ';', '0'
localparam [7:0] END_MARK = 8'h24, SEP = 8'h3b, ZERO = 8'h30;
localparam [2:0] P_WAIT = 0, P_READ  = 1, P_OUT  = 2, P_DONE = 3;
localparam [2:0] L_WAIT = 0, L_READ  = 1, L_POP  = 2, L_ACK  = 3, 
                 L_HOLD = 4, L_DRAIN = 5, L_DONE = 6;

reg [2:0] p_state, l_state;
reg [7:0] passengers [0:15];
reg [7:0] baggage [0:15];
reg [4:0] p_count, p_rd;
reg [4:0] bag_count, drain_rd;
reg [3:0] pop_left;
reg zero_case;

integer j;

always @(posedge clk or posedge rst) begin

    if (rst) begin
        p_state   <= P_WAIT;
        l_state   <= L_WAIT;
        p_count   <= 0;
        p_rd      <= 0;
        bag_count <= 0;
        drain_rd  <= 0;
        pop_left  <= 0;
        zero_case <= 0;
        valid_fifo  <= 0;
        valid_lifo  <= 0;
        valid_fifo2 <= 0;
        people_thing_out <= 0;
        thing_out  <= 0;
        done_thing <= 0;
        done_fifo  <= 0;
        done_lifo  <= 0;
        done_fifo2 <= 0;

        for (j = 0; j < 16; j = j + 1) begin
            passengers[j] <= 0;
            baggage[j]    <= 0;
        end
    end else begin

        valid_fifo  <= 0;
        valid_lifo  <= 0;
        valid_fifo2 <= 0;
        done_thing  <= 0;

        // Passenger FIFO, independent of baggage processing.
        case (p_state)
            P_WAIT: if (ready_fifo) begin
                p_state <= P_READ;
            end
            P_READ: begin
                if (people_thing_in == END_MARK) begin
                    p_rd <= 0;
                    p_state <= P_OUT;
                end else if (
                    // 'A' <= people_thing_in <= 'Z'
                    people_thing_in >= 8'h41 &&
                    people_thing_in <= 8'h5a
                ) begin
                    if (p_count < 16) begin
                        passengers[p_count[3:0]] <= people_thing_in;
                        p_count <= p_count + 1'b1;
                    end
                end
            end
            P_OUT: begin
                if (p_rd < p_count) begin
                    people_thing_out <= passengers[p_rd[3:0]];
                    valid_fifo <= 1;
                    p_rd <= p_rd + 1'b1;
                end else begin
                    done_fifo <= 1;
                    p_state <= P_DONE;
                end
            end
            P_DONE: ;
            default: p_state <= P_WAIT;
        endcase

        // Baggage stack and final bottom-to-top drain.
        case (l_state)
            L_WAIT: if (ready_lifo) begin
                l_state <= L_READ;
            end
            L_READ: begin
                if (thing_in == END_MARK) begin
                    drain_rd  <= 0;
                    done_lifo <= 1;
                    l_state   <= L_DRAIN;
                end else if (thing_in == SEP) begin
                    pop_left  <= thing_num;
                    zero_case <= (thing_num == 0);
                    l_state   <= L_POP;
                end else if (
                    // '1' <= people_thing_in <= '9'
                    thing_in >= 8'h31 && 
                    thing_in <= 8'h39
                ) begin
                    if (bag_count < 16) begin
                        baggage[bag_count[3:0]] <= thing_in;
                        bag_count <= bag_count + 1'b1;
                    end
                end
            end
            L_POP: begin
                if (zero_case) begin
                    thing_out  <= ZERO;
                    valid_lifo <= 1;
                    zero_case  <= 0;
                    l_state    <= L_ACK;
                end else if (
                    pop_left  != 0 && 
                    bag_count != 0
                ) begin
                    thing_out  <= baggage[bag_count - 1'b1];
                    valid_lifo <= 1;
                    bag_count  <= bag_count - 1'b1;
                    pop_left   <= pop_left - 1'b1;
                    if (pop_left == 1)
                        l_state <= L_ACK;
                end else begin
                    l_state <= L_ACK;
                end
            end
            L_ACK: begin
                done_thing <= 1;
                l_state <= L_HOLD;
            end
            L_HOLD: l_state <= L_READ;
            L_DRAIN: begin
                if (drain_rd < bag_count) begin
                    thing_out <= baggage[drain_rd[3:0]];
                    valid_fifo2 <= 1;
                    drain_rd <= drain_rd + 1'b1;
                end else begin
                    done_fifo2 <= 1;
                    l_state <= L_DONE;
                end
            end
            L_DONE: ;
            default: l_state <= L_WAIT;
        endcase
    end
end

endmodule