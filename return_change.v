module Change_remaining (
    clk,en,rst,
    req_amt,
    Five_in,Ten_in,Twenty_in,
    Five_avl,Ten_avl,Twenty_avl,
    Five_out,Ten_out,Twenty_out,
    enable_dispense
);
    //This is the money the user gives to the vending machien
    input [7:0] Five_in,Ten_in,Twenty_in;

    //These are the denominations available in the machien
    input [7:0] Five_avl,Ten_avl,Twenty_avl;

    //These are the denominations to be given back to user
    output reg [7:0] Five_out,Ten_out,Twenty_out;

    //This is to enable the ITem modules to say weater to dispense or not
    output reg enable_dispense; 

    //This is the requested value to be given
    input [7:0] req_amt;

    input clk,en,rst;

    //These are secondary memory needed for logic
    reg [7:0 ]amt;
    reg[7:0] temp_five,temp_ten,temp_twenty;

    //always block
     always @(posedge clk or posedge rst) begin

        if(rst) begin
            Five_out <= 0;
            Ten_out <= 0;
            Twenty_out <= 0;
            enable_dispense <= 0;
        end

        else if(en) begin
            amt = req_amt;

            //Calculating the denominations to give out and the number
            //Giving higher denominations first
            if(amt >= 20 && Twenty_avl>0)begin
                temp_twenty = ((amt/20)<Twenty_avl) ? amt/20 : Twenty_avl;
                amt = amt - temp_twenty*20;
            end

            else begin
                temp_twenty = 0;
            end

            if(amt >= 10 && Ten_avl > 0)begin 
                temp_ten = ((amt/10)<Ten_avl) ? amt/10 : Ten_avl;
                amt = amt - temp_ten*10;
            end

            else begin
                temp_ten = 0;
            end

            if(amt >= 5 && Five_avl > 0)begin 
                temp_five = ((amt/5)<Five_avl) ? amt/5 : Five_avl;
                amt = amt - temp_five*5;
            end

            else begin
                temp_five = 0;
            end

        //If available denominations satisfy the needed amt then we give out elsegive user teir money back and no product
            if(amt == 0) begin
                Five_out <= temp_five;
                Ten_out <= temp_ten;
                Twenty_out <= temp_twenty;
                enable_dispense <= 1'b1;
            end

            else begin
                Five_out <= Five_in;
                Ten_out <= Ten_in;
                Twenty_out <= Twenty_in;
                enable_dispense <= 1'b0;
            end
            
        end

     end
endmodule