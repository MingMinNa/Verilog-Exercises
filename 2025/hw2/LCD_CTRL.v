module LCD_CTRL(
	input 	   	  clk	   ,
	input 		  rst	   ,
	input 	[3:0] cmd      , 
	input 		  cmd_valid,
	input 	[7:0] IROM_Q   ,
	input 	[7:0] IRAM_Q   ,

	output 		  IROM_rd  , 
	output  [5:0] IROM_A   ,
	output 		  IRAM_ceb ,
	output 		  IRAM_web ,
	output  [7:0] IRAM_D   ,
	output  [5:0] IRAM_A   ,
	output 		  busy	   ,
	output reg	  done
);

localparam [2:0] S_PRIME = 3'd0,
				 S_LOAD  = 3'd1,
				 S_IDLE  = 3'd2,
				 S_EXEC  = 3'd3,
				 S_WRITE = 3'd4;

reg [2:0] state;
reg [7:0] pixels [0:63];
reg [5:0] rd_addr, wr_addr;
reg [2:0] op_x, op_y;
reg [3:0] operation;

// Operation point (x,y) denotes the bottom-right center of a 4x4 region.
// columns x-2 through x+1, rows y-2 through y+1.
// x and y are clamped to [2,6].
reg [7:0] region_min, region_max;
reg [11:0] region_sum;

integer row, col;
integer addr;

always @(*) begin

	region_min = 8'hff;
	region_max = 8'h00;
	region_sum = 12'd0;
	
	for (row = 0; row < 4; row = row + 1) begin
		for (col = 0; col < 4; col = col + 1) begin

			addr = ((op_y - 3'd2 + row) << 3) + op_x - 3'd2 + col;
			
			if (pixels[addr] < region_min)
				region_min = pixels[addr];
			if (pixels[addr] > region_max)
				region_max = pixels[addr];
			
			region_sum = region_sum + {4'b0000, pixels[addr]};
		end
	end
end

assign IROM_rd = (state == S_PRIME || state == S_LOAD);
assign IROM_A  = rd_addr;
assign IRAM_ceb = (state == S_WRITE);
assign IRAM_web = 1'b0; // This design writes IRAM but never reads it.
assign IRAM_A = wr_addr;
assign IRAM_D = pixels[wr_addr];
assign busy = (state != S_IDLE);

integer i, j;
integer index_4x4;

always @(posedge clk or posedge rst) begin
	
	if (rst) begin
		state   <= S_PRIME;
		rd_addr <= 6'd0;
		wr_addr <= 6'd0;
		op_x <= 3'd4;
		op_y <= 3'd4;
		operation <= 4'd0;
		done <= 1'b0;

	end else begin
		case (state)
			S_PRIME: begin
				// Give the falling-edge IROM a full half cycle
				// at address zero before capturing its first value.
				state <= S_LOAD;
			end
			S_LOAD: begin
				pixels[rd_addr] <= IROM_Q;
				if (rd_addr == 6'd63)
					state <= S_IDLE;
				else
					rd_addr <= rd_addr + 6'd1;
			end
			S_IDLE: begin
				if (cmd_valid) begin
					operation <= cmd;
					if (cmd == 4'd0) begin
						wr_addr <= 6'd0;
						done    <= 1'b0;
						state   <= S_WRITE;
					end else if (cmd >= 4'd1 && cmd <= 4'd7) begin
						state <= S_EXEC;
					end
				end
			end
			S_EXEC: begin
				case (operation)
					4'd1: if (op_y > 3'd2) op_y <= op_y - 3'd1;
					4'd2: if (op_y < 3'd6) op_y <= op_y + 3'd1;
					4'd3: if (op_x > 3'd2) op_x <= op_x - 3'd1;
					4'd4: if (op_x < 3'd6) op_x <= op_x + 3'd1;
					default: begin
						for (i = 0; i < 4; i = i + 1) begin
							for (j = 0; j < 4; j = j + 1) begin
								index_4x4 = ((op_y - 3'd2 + i) << 3)
											+ op_x - 3'd2 + j;
								if (operation == 4'd5)
									pixels[index_4x4] <= region_max;
								else if (operation == 4'd6)
									pixels[index_4x4] <= region_min;
								else
									pixels[index_4x4] <= region_sum[11:4];
							end
						end
					end
				endcase
				state <= S_IDLE;
			end
			S_WRITE: begin
				// Each byte is committed on the preceding negedge.
				if (wr_addr == 6'd63) begin
					state <= S_IDLE;
					done  <= 1'b1;
				end else begin
					wr_addr <= wr_addr + 6'd1;
				end
			end
			default: state <= S_PRIME;
		endcase
	end
end

endmodule