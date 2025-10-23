//This module is to give the number of money left in the machine to return to the user
module Currencies_in_machine (
    enable,
    Five_out,Ten_out,Twenty_out
    Five_after_return,Ten_after_return,Twenty_after_return
);

    input []

    always @(*) begin
        if(enable) begin
            Five_after_return <= Five_out;
            Ten_after_return <= Ten_out;
            Twenty_after_return <= Twenty_out;
        end
        //Else latch
    end
    
endmodule