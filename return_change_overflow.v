module Overflow_return (
    clk,rst,en,
    Five_in,Ten_in,Twenty_in,
    Five_out,Ten_out,Twenty_out
);
    
    input en,clk rst;
    input Five_in,Ten_in,Twenty_in;
    output reg Five_out,Ten_out,Twenty_out;

    always @(posedge clk)
endmodule