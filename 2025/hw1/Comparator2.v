module Comparator2 (
    input   [3:0]   A,  
    input   [3:0]   B,  

    output  reg [3:0] min,  
    output  reg [3:0] max  
);

always @(*) begin

    if (A < B) begin
        min = A;
        max = B;
    end
    else begin
        min = B;
        max = A;
    end    
end

endmodule
