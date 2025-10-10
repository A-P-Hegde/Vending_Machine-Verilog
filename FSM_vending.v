module Vending_Machine (
    clk,rst,en,
    select_item,
    Five_in,Ten_in,Twenty_in,
    Five_out,Ten_out,Twenty_out,
    item_out,
);
    //-----------------------------------------------------------------------------------//

    //Defining of the ports wires
    input clk,rst,en;
    input [3:0] select_item;
    input [7:0] Five_in,Ten_in,Twenty_in;
    output [7:0] Five_out,Ten_out,Twenty_out;
    output item_out;

    //Wires needed for other modules
    wire [7:0] req_amt;
    wire [7:0] amount_in;
    wire enable_dispense;
    wire en_for_change;
    wire en_for_items;
    wire [3:0] rst_counter;
    wire internal_reset;   //To reset machine after a few cycles after item given 
                                   //To use as reset for instantiated blocks
    
    //State wire
    wire [8:0]current_state,next_state;

    //Item Cost Wire
    parameter cost_It_1 = 25

    //-----------------------------------------------------------------------------------//
    
    //Instantiating the modules

    Change_remaining ch(.clk(clk),.rst(internal_reset),.en(en_for_change),
    .req_amt(req_amt),                                             //NOT COMPLETED INSTANTIATION (missing ports)!!!!
    .Five_in(Five_in),.Ten_in(Ten_in),.Twenty_in(Twenty_in),
    .Five_out(Five_out),.Ten_out(Ten_out),.Twenty_out(Twenty_out)
    .enable_dispense(enable_dispense));

    Item it1(.clk(clk),.rst(internal_reset,),.en1(en_for_items),.en2(enable_dispense),
    .cost(cost_It_1),
    .amount_in(amount_in),.item_out(item_out));     //THIS IS COMPLETE 

    //-----------------------------------------------------------------------------------//

    //Define States Here

    //State 0 rupees - 40 rupees 
    parameter S0 = 9'd0,
                    S5 = 9'd2,
                    S10 = 9'd4,
                    S15 = 9'd8,
                    S20 = 9'd16,
                    S25 = 9'd32,
                    S30 = 9'd64,
                    S35 = 9'd128,
                    S40 = 9'd256;

    //-----------------------------------------------------------------------------------//

    //always sequential
    always @ (posedge clk or posedge rst) begin
        
        if(rst) begin
            Five_out <= 0;
            Ten_out <= 0;
            Twenty_out <= 0;
            item_out <= 0;
            req_amt <= 0;
            en_for_change <= 0;
            rst_counter <= 0;
        end

        //Here all main things happen (Remember no putting multiple denominations at once)
        else if(en) begin

            internal_reset <= rst;
            current_state <= next_state;

        end

        //Resetting after item out
        else if(item_out) begin
            if(rst_counter == 6) begin    
                Five_out <= 0;
                Ten_out <= 0;
                Twenty_out <= 0;
                item_out <= 0;
                req_amt <= 0;
                rst_counter <= 0;
                internal_reset <= 1
            end

            else
                rst_counter = rst_counter + 1;
        end

        // Dont know if this is needed (not sure)
        else begin
            rst_counter <= 0;
            internal_reset <= 0;
        end

    end

    //-----------------------------------------------------------------------------------//

    //Combinational Logic always block
    always @(*) begin
    
        case(state) 
                S0:
                    if(Five_in) begin
                        next_state = S5;
                    end
                    else if(Ten_in) begin
                        next_state = S10;
                    end
                    else if(Twenty_in) begin
                        next_state = S20;
                    end
                    else
                        next_state = S0;

                S5:
                    if(Five_in) begin
                        next_state = S10;
                    end
                    else if(Ten_in) begin
                        next_state = S15;
                    end
                    else if(Twenty_in) begin
                        next_state = S25;
                    end
                    else
                        next_state = S5;
                
                S10:
                    if(Five_in) begin
                        next_state = S15;
                    end
                    else if(Ten_in) begin
                        next_state = S20;
                    end
                    else if(Twenty_in) begin
                        next_state = S30;
                    end
                    else
                        next_state = S10;

                S15:
                    if(Five_in) begin
                        next_state = S20;
                    end
                    else if(Ten_in) begin
                        next_state = S25;
                    end
                    else if(Twenty_in) begin
                        next_state = S35;
                    end
                    else
                        next_state = S15;
                
                S20:
                    if(Five_in) begin
                        next_state = S25;
                    end
                    else if(Ten_in) begin
                        next_state = S30;
                    end
                    else if(Twenty_in) begin
                        next_state = S40;
                    end
                    else
                        next_state = S20;

                S25:
                    if(Five_in) begin
                        next_state = S30;
                    end
                    else if(Ten_in) begin
                        next_state = S35;
                    end
                    else if(Twenty_in) begin
                        next_state = S45;
                    end
                    else
                        next_state = S25;

                S30:
                    if(Five_in) begin
                        next_state = S35;
                    end
                    else if(Ten_in) begin
                        next_state = S40;
                    end
                    else if(Twenty_in) begin
                        next_state = S50;
                    end
                    else
                        next_state = S30;

                S35:
                    if(Five_in) begin
                        next_state = S40;
                    end
                    else if(Ten_in) begin
                        next_state = S45;
                    end
                    else if(Twenty_in) begin
                        next_state = S55;
                    end
                    else
                        next_state = S35;

                S40: //This shoud be the limit User should not put more money than this (NOT COMPLETED)
                
        endcase

    end
    
endmodule