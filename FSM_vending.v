module Vending_Machine (
    clk,rst,en,
    select_item,
    Five_in,Ten_in,Twenty_in,
    Five_out,Ten_out,Twenty_out,
    item_out
);
    //-----------------------------------------------------------------------------------//

    //Defining of the ports wires
    input clk,rst,en;
    input [1:0] select_item;
    input Five_in,Ten_in,Twenty_in;
    output reg [7:0] Five_out,Ten_out,Twenty_out;
    output reg item_out;

    //Regs needed for other modules
    reg [7:0] req_amt;
    reg [7:0] amount_in;
    reg [7:0] Five_out_change;
    reg [7:0] Five_out_overflow;
    reg [7:0] Ten_out_change;
    reg [7:0] Ten_out_overflow;
    reg [7:0] Twenty_out_change;
    reg [7:0] Twenty_out_overflow;
    reg enable_dispense;
    reg en_for_change;
    reg en_for_overflow;
    reg en_for_item1,en_for_item2,en_for_item3;
    reg [3:0] rst_counter;
    reg internal_reset;   //To reset machine after a few cycles after item given 
                                   //To use as reset for instantiated blocks
    
    //-----------------------------------------------------------------------------------//
    
    //To keep track of how many Five,Ten,Twenty are in the system

    reg [7:0] Five_in_total,Ten_in_total,Twenty_in_total;

    //-----------------------------------------------------------------------------------//

    //State reg
    reg [8:0]current_state,next_state;

    //Item Cost Wire
    parameter cost_It_1 = 20,
                    cost_It_2 = 15,
                    cost_It_3 = 10;    //Code is made for max cost of item being 20
                                              //Just add more states to make max cost more
                                              //max cost should be <= largest money state - 20 
    //-----------------------------------------------------------------------------------//
    

    //Instantiating the modules

    Change_remaining ch(.clk(clk),.rst(internal_reset),.en(en_for_change),
    .req_amt(req_amt),                                             //NOT COMPLETED INSTANTIATION (missing ports)!!!!
    .Five_in(Five_in_total),.Ten_in(Ten_in_total),.Twenty_in(Twenty_in_total),
    .Five_out(Five_out_change),.Ten_out(Ten_out_change),.Twenty_out(Twenty_out_change),
    .enable_dispense(enable_dispense));

    Item it1(.clk(clk),.rst(internal_reset),.en1(en_for_item_1),.en2(enable_dispense),
    .cost(cost_It_1),
    .amount_in(amount_in),.item_out(item_out));     //THIS IS COMPLETE

    Item it2(.clk(clk),.rst(internal_reset),.en1(en_for_item_2),.en2(enable_dispense),
    .cost(cost_It_2),
    .amount_in(amount_in),.item_out(item_out));     //THIS IS COMPLETE

    Item it3(.clk(clk),.rst(internal_reset),.en1(en_for_item_3),.en2(enable_dispense),
    .cost(cost_It_3),
    .amount_in(amount_in),.item_out(item_out));     //THIS IS COMPLETE 

    Overflow_return ov(.clk(clk),.rst(internal_reset),.en(),
    .Five_in(Five_in),.Ten_in(Ten_in),.Twenty_in(Twenty_in),
    .Five_out(Five_out_overflow),.Ten_out(Ten_out_overflow),.Twenty_out(Twenty_out_overflow))
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
            rst_counter <= 0;
            en_for_item_1 <= 0;
            en_for_item_2 <= 0;
            en_for_item_3 <= 0;
            en_for_change <= 0;
            amount_in <= 0;
            internal_reset <= 1;
            en_for_overflow <= 0;
        end

        //Here all main things happen 
        else if(en) begin
                //(Remember no putting multiple denominations at once)
            case(current_state) 
            S0:
                if(Five_in) begin
                    next_state <= S5;
                end
                else if(Ten_in) begin
                    next_state <= S10;
                end
                else if(Twenty_in) begin
                    next_state <= S20;
                end
                else
                    next_state <= S0;

            S5:
                if(Five_in) begin
                    next_state <= S10;
                end
                else if(Ten_in) begin
                    next_state <= S15;
                end
                else if(Twenty_in) begin
                    next_state <= S25;
                end
                else
                    next_state <= S5;
            
            S10:
                if(Five_in) begin
                    next_state <= S15;
                end
                else if(Ten_in) begin
                    next_state <= S20;
                end
                else if(Twenty_in) begin
                    next_state <= S30;
                end
                else
                    next_state <= S10;

            S15:
                if(Five_in) begin
                    next_state <= S20;
                end
                else if(Ten_in) begin
                    next_state <= S25;
                end
                else if(Twenty_in) begin
                    next_state <= S35;
                end
                else
                    next_state <= S15;
            
            S20:
                if(Five_in) begin
                    next_state <= S25;
                end
                else if(Ten_in) begin
                    next_state <= S30;
                end
                else if(Twenty_in) begin
                    next_state <= S40;
                end
                else
                    next_state <= S20;

            S25:
                if(Five_in) begin
                    next_state <= S30;
                end
                else if(Ten_in) begin
                    next_state <= S35;
                end
                else
                    next_state <= S25;

            S30:
                if(Five_in) begin
                    next_state <= S35;
                end
                else if(Ten_in) begin
                    next_state <= S40;
                end
                else
                    next_state <= S30;

            S35:
                if(Five_in) begin
                    next_state <= S40;
                end
                else if(Ten_in) begin
                    en_for_overflow <= 1;
                end
                else
                    next_state <= S30;
                else 
                    next_state <= S35;
            S40:
            if(Five_in | Ten_in | Twenty_in) begin
                en_for_overflow <= 1;
                next_state <= S40;
            end
            else
                next_state <= S40;  //Make a logic to not accecpt money after 40

            default:
                en_for_overflow <= 0;
                next_state = S0;
                
        endcase

            //To enable which item to select
            case(select_item)
                default:
                    en_for_item1 <= 0;
                    en_for_item2 <= 0;
                    en_for_item3 <= 0;
                2'd1:
                    en_for_item1 <= 1;
                    en_for_item2 <= 0;
                    en_for_item3 <= 0;
                2'd2:
                    en_for_item1 <= 0;
                    en_for_item2 <= 1;
                    en_for_item3 <= 0;
                2'd3:
                    en_for_item1 <= 0;
                    en_for_item2 <= 0;
                    en_for_item3 <= 1;

            endcase

            internal_reset <= 0;
            current_state <= next_state;

            case(select_item)
                2'd1: req_amt <= amount_in - cost_It_1; en_for_item1 <= 1;
                2'd2: req_amt <= amount_in - cost_It_2; en_for_item2 <= 1;
                2'd3: req_amt <= amount_in - cost_It_3; en_for_item3 <= 1;
                default: req_amt <= 0;
            endcase

            

        end

        //Resetting after item out
        else if(item_out) begin

            if(rst_counter == 4) begin    
                Five_out <= 0;
                Ten_out <= 0;
                Twenty_out <= 0;
                item_out <= 0;
                req_amt <= 0;
                rst_counter <= 0;
                en_for_item_1 <= 0;
                en_for_item_2 <= 0;
                en_for_item_3 <= 0;
                en_for_change <= 0;
                amount_in <= 0;
                internal_reset <= 1;
                en_for_overflow <= 0;
            end

            else
                rst_counter <= rst_counter + 1;

        end

        // Dont know if this is needed (not sure)
        else begin
            rst_counter <= 0;
            internal_reset <= 0;
        end

    end

    //-----------------------------------------------------------------------------------//


    //-----------------------------------------------------------------------------------//

    //Combinational circuit for amount in

    always @(*) begin
        case(current_state)
            S0:
                amount_in <= 0;

            S5:
                amount_in <= 5;
            
            S10:
                amount_in <= 10;

            S15:
                amount_in <= 15;

            S20:
                amount_in <= 20;

            S25:
                amount_in <= 25;

            S30:
                amount_in <= 30;

            S35:
                amount_in <= 35;

            S40:
                amount_in <= 40;
            
            default:
                amount_in <= 0;
        endcase
    end
    //-----------------------------------------------------------------------------------//

    
endmodule