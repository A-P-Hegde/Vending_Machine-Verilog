module Item1 (
    clk,rst,en1,en2,
    amount_in,item_out
);
    //Basic inputs
    input clk,rst,en1,en2; 

    //-------------------------------------------------------------------------------------------//
     //Enable 1 is from main module (Vending machien) which selects item
     //Enable 2 is from Change_remaining module which tells if change is availabe to give back and if should be dispensed
    //-------------------------------------------------------------------------------------------//

    //total amount input
    input [7:0] amount_in;

    //to send out signal or no
    output reg item_out;

    //to check if already dispensed or no
    reg dispensed;

    //Cost of item
    parameter cost = 25;

    //always block 
    always @(posedge clk or posedge rst) begin
        
        //Reseting
        if(rst) begin
            item_out <= 0;
            dispense <= 0;
        end

        //To send output signal only for one cycle
        else if(en1 && en2 && (amount_in > cost) && !(dispensed)) begin
            item_out <= 1'b1;
        end

        //To make output signal zero once dispensed reset dispensed once enable from main module becomes low
        else begin
            item_out <= 0;
            if (!en1) begin
                dispense <= 0;
            end
        end
            
    end

endmodule