//This module is used to return any money given by the user when they input money after the max limit is reached
//Here its 40 cuz our last state is S40 

module Overflow_return (
    clk,rst,en,
    Five_in,Ten_in,Twenty_in,
    Five_out,Ten_out,Twenty_out
);

    //All input and output ports needed
    input en,clk rst;
    //Inputs the current input value by user 
    input Five_in,Ten_in,Twenty_in;
    //To output the value back
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