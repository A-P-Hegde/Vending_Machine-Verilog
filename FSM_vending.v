module ItemA (
    clk,rst,en,
    Five_in,Ten_in,Twenty_in,
    Five_out,Ten_out,ItemA_out
);
    // Declaration of Ports
    input Five_in,Ten_in,Twenty_in,fifty_in;
    input clk,rst,en;
    output Five_out,Ten_out,Five_out,ItemA_out;
    
    //Declaration of needed registers
    reg [8:0] current_st,next_st;
    reg current_balance;

    //Declaration of all possible states
    localparam   St_default = 9'b00000001,
                       St_five = 9'b00000010,
                       St_ten = 9'b000000100,
                       St_fifteen = 9'b000001000,
                       St_twenty = 9'b000010000,
                       St_twentyfive = 9'b000100000,
                       St_thirty = 9'b001000000,
                       St_thirtyfive = 9'b010000000
                       St_forty=9'b100000000;
    
    //Declaration of item price
    localparam price = 25;

    //Start of FSM
    always @(rst)
    begin
        current_st <= St_default;
    end
    
    //Conditions for FSM state change
    always @(posedge clk)
    begin
        case (current_st)
            St_default:
                
                if(Five_in) begin
                    next_st = St_five;
                    {Five_out,Ten_out} = 2'b00;
                    ItemA_out=1'b0;
                end 

                if(Ten_in)begin
                    next_st=St_ten;
                    {Five_out,Ten_out}=2'b00;
                    ItemA_out=1'b0;
                end

                if(Twenty_in)
                ...
            default: 
        endcase
    end



endmodule