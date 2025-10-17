module Overflow_return (
    clk,rst,en,
    Five_in,Ten_in,Twenty_in,
    Five_out,Ten_out,Twenty_out
);
    
    input en,clk rst;
    input Five_in,Ten_in,Twenty_in;
    output reg Five_out,Ten_out,Twenty_out;

    always @(posedge clk)
        
        if(rst) begin
            Five_out <= 0;
            Ten_out <= 0;
            Twenty_out <= 0;
        end

        else if (en) begin
            Five_out <= Five_in;
            Ten_out <= Ten_in;
            Twenty_out <= Twenty_in;
        end
endmodule