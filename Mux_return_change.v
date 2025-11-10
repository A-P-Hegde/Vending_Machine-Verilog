module Mux_return_change (
    rst,en1,en2,
    Overflow,Change,Out
);

//This is a module to multiplex the outputs of two modules both of which return money to user
//Overflow represents money out from overflow module 
//Simillarly change
//Out is the multiplexed output

    input [23:0] Overflow,Change;
    output reg [23:0] Out;

    always @(*)
        if(rst) begin
            Out <= 0;
        end
        else begin
            if(en1)
                Out <= Change;
            else if(en2)
                Out <= Overflow;
        end
endmodule