module Change_remaining (
    clk, en, rst,
    req_amt,
    Five_in, Ten_in, Twenty_in,
    Five_avl, Ten_avl, Twenty_avl,
    Five_avl_next, Ten_avl_next, Twenty_avl_next,
    Five_out, Ten_out, Twenty_out,
    enable_dispense
);

    // This is the money the user gives to the vending machine
    input [7:0] Five_in, Ten_in, Twenty_in;

    // These are the denominations available in the machine
    input [7:0] Five_avl, Ten_avl, Twenty_avl;

    // These are the denominations to be given back to user
    output reg [7:0] Five_out, Ten_out, Twenty_out;

    //These are the remaining denominations in the machine these are to be given as output to storage module via top module
    output reg [7:0] Five_avl_next , Ten_avl_next , Twenty_avl_next;

    // This is to enable the Item modules to say whether to dispense or not
    output reg enable_dispense; 

    // This is the requested value to be given
    input [7:0] req_amt;

    // Clock, enable, and reset signals
    input clk, en, rst;

    // These are secondary memory needed for logic (registered values)
    reg [7:0] amt;
    reg [7:0] temp_five, temp_ten, temp_twenty;

    // These are the combinational "next" values for next-state logic
    reg [7:0] amt_next;
    reg [7:0] temp_five_next, temp_ten_next, temp_twenty_next;
    reg [7:0] Five_out_next, Ten_out_next, Twenty_out_next;
    reg enable_dispense_next;

    //----------------------------------------------------------------------------------//
    //Now to instantiate the module which fetches number of denominations left in machine

    //----------------------------------------------------------------------------------//


    //=========================================================================
    // Sequential always block (synchronous logic)
    // Registers update on clock edge or reset
    //=========================================================================
    always @(posedge clk or posedge rst) begin

        if (rst) begin
            Five_out <= 0;
            Ten_out <= 0;
            Twenty_out <= 0;
            enable_dispense <= 0;
            amt <= 0;
            temp_five <= 0;
            temp_ten <= 0;
            temp_twenty <= 0;
        end

        else if (en) begin
            // Update all registers with next-state values
            Five_out <= Five_out_next;
            Ten_out <= Ten_out_next;
            Twenty_out <= Twenty_out_next;
            enable_dispense <= enable_dispense_next;

            amt <= amt_next;
            temp_five <= temp_five_next;
            temp_ten <= temp_ten_next;
            temp_twenty <= temp_twenty_next;
        end

    end

    //=========================================================================
    // For this to be synthesizable, the combinational logic below must execute
    // within one clock cycle (i.e., between two consecutive posedges of clk).
    // There is a limit to how fast the clock can be for this logic to settle.
    //=========================================================================

    //=========================================================================
    // Combinational always block (next-state logic)
    //=========================================================================
    always @(*) begin

        // Default assignments to prevent latches
        amt_next = req_amt;
        temp_five_next = 0;
        temp_ten_next = 0;
        temp_twenty_next = 0;
        Five_out_next = Five_in;
        Ten_out_next = Ten_in;
        Twenty_out_next = Twenty_in;
        enable_dispense_next = 0;

        // If reset is active, clear everything
        if (rst) begin
            amt_next = 0;
            temp_five_next = 0;
            temp_ten_next = 0;
            temp_twenty_next = 0;
            Five_out_next = 0;
            Ten_out_next = 0;
            Twenty_out_next = 0;
            enable_dispense_next = 0;
        end

        // When enabled, calculate denominations
        else if (en) begin

            // Calculating the denominations to give out and the number
            // Giving higher denominations first preference

            // --- 20-unit denominations ---
            if (amt_next >= 20 && Twenty_avl > 0) begin
                temp_twenty_next = ((amt_next / 20) < Twenty_avl) ? (amt_next / 20) : Twenty_avl;
                amt_next = amt_next - temp_twenty_next * 20;
            end
            else begin
                temp_twenty_next = 0;
            end

            // --- 10-unit denominations ---
            if (amt_next >= 10 && Ten_avl > 0) begin 
                temp_ten_next = ((amt_next / 10) < Ten_avl) ? (amt_next / 10) : Ten_avl;
                amt_next = amt_next - temp_ten_next * 10;
            end
            else begin
                temp_ten_next = 0;
            end

            // --- 5-unit denominations ---
            if (amt_next >= 5 && Five_avl > 0) begin 
                temp_five_next = ((amt_next / 5) < Five_avl) ? (amt_next / 5) : Five_avl;
                amt_next = amt_next - temp_five_next * 5;
            end
            else begin
                temp_five_next = 0;
            end

            // If available denominations satisfy the needed amt,
            // then we give out the change, else give user their money back and no product
            if (amt_next == 0) begin
                Five_out_next = temp_five_next;
                Ten_out_next = temp_ten_next;
                Twenty_out_next = temp_twenty_next;
                Five_avl_next = Five_avl - temp_five_next;
                Ten_avl_next = Ten_avl_avl - temp_ten_next;
                Twenty_avl_next = Twenty_avl_avl - temp_twenty_next;
                enable_dispense_next = 1'b1;
            end

            else begin
                Five_out_next = Five_in;
                Ten_out_next = Ten_in;
                Twenty_out_next = Twenty_in;
                Five_avl_next = Five_avl;
                Ten_avl_next = Ten_avl_avl;
                Twenty_avl_next = Twenty_avl_avl;
                enable_dispense_next = 1'b0;
            end
        end
    end

endmodule

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
module Mux_return_change (
    rst,en1,en2,
    Overflow,Change,Out
);

//This is a module to multiplex the outputs of two modules both of which return money to user
//Overflow represents money out from overflow module 
//Simillarly change
//Out is the multiplexed output

    input [2:0] Overflow,Change;
    output [2:0] Out;

    always @(*)
        if(rst) begin
            Out <= 0;
        end
        else begin
            if(en1)
                Out <= Change;
            else if(en2)
                Out <= Overflow
        end
endmodule
module Item (
    clk,rst,en1,en2,
    cost,
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
    input [7:0] cost;

    //always block 
    always @(posedge clk or posedge rst) begin
        
        //Reseting
        if(rst) begin
            item_out <= 0;
            dispensed <= 0;
        end

        //To send output signal only for one cycle
        else if(en1 && en2 && (amount_in >= cost) && !(dispensed)) begin
            item_out <= 1'b1;
        end

        //To make output signal zero once dispensed reset dispensed once enable from main module becomes low
        else begin
            item_out <= 0;
            if (!en1) begin
                dispensed <= 0;
            end
        end
            
    end

endmodule
module DenominationStorage (
    // Clock and Reset
    input clk,            // Clock signal
    input rst,          // Asynchronous rst
    
    // Inputs from the Computational Module (New Computed Values)
    input w_en,           // Write Enable: 1 to load new values, 0 to hold
    input [7:0] new_five_avl,
    input [7:0] new_ten_avl,
    input [7:0] new_twenty_avl,
    
    // Outputs to the Computational Module (Current Available Values)
    output reg [7:0] five_avl,   // Current stored count of 5s
    output reg [7:0] ten_avl,    // Current stored count of 10s
    output reg [7:0] twenty_avl  // Current stored count of 20s
);

    // --- State Storage Logic ---
    // This always block handles the synchronous loading of new counts 
    // and the asynchronous rst.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Asynchronous Reset: Clear all counts
            five_avl   <= 8'd0;
            ten_avl    <= 8'd0;
            twenty_avl <= 8'd0;
        end 
        else if (w_en) begin
            // Synchronous Write: Load the new available counts
            // Note: All three are updated simultaneously if w_en is high
            five_avl   <= new_five_avl;
            ten_avl    <= new_ten_avl;
            twenty_avl <= new_twenty_avl;
        end
        // If 'w_en' is 0, the counts hold their current values (five_avl <= five_avl; etc.)
    end

endmodule
//--------------------------------------------------------------------------------------//
//This is the main module where all modules connect and make the complete FSM
//This module consists of: 
//a)State change mechanism
//b)Signals to give to other blocks
//c)Combinational circuits  (will be explained later)
//-----------------------------------------------------------------------------------//


module Vending_Machine (
    clk,rst,en,
    select_item,
    Five_in,Ten_in,Twenty_in,
    Five_out,Ten_out,Twenty_out,
    item_out3
    item_out2,
    item_out1,
    //These are the ports needed the names are self explanatory
);
    //-----------------------------------------------------------------------------------//

    //Defining of the ports
    //select_item is for the user to select which item they want
    input clk,rst,en;
    input [1:0] select_item;
    input Five_in,Ten_in,Twenty_in;
    output reg [7:0] Five_out,Ten_out,Twenty_out;
    output reg item_out1,item_out3,item_out2;

    //Regs needed for other modules
    reg [7:0] req_amt;                                            // Total amt given by user minus cost of item
    reg [7:0] amount_in;                                         //Total amt given by user
    
    //Output given by return change module after getting the item
    //Output given by overflow module when excess money is given by user unnecacarily
    reg [7:0] Five_out_change;                                
    reg [7:0] Five_out_overflow;                              
    reg [7:0] Ten_out_change;
    reg [7:0] Ten_out_overflow;
    reg [7:0] Twenty_out_change;
    reg [7:0] Twenty_out_overflow;

    //This is an output signal fromreturn change block so which tells to dispense item once excess money is given out
    //If no money is available in the machine to return it gives users complete money back and dosent dispense
    reg enable_dispense;

    //enable for return change module
    reg en_for_change;
    reg en_for_change_next;

    //enable for return overflow module
    reg en_for_overflow;
    reg en_for_overflow_next;

    //enables to enable each item module
    reg en_for_item1,en_for_item2,en_for_item3;
    reg en_for_item1_next,en_for_item2_next,en_for_item3_next;

    //To reset machine after a few cycles after item given 
    //To use as reset for instantiated blocks
    reg [3:0] rst_counter;
    reg internal_reset;   
    
    //To keep track of how many Five,Ten,Twenty are input to the system
    reg [7:0] Five_in_total,Ten_in_total,Twenty_in_total;

    //To keep track of how many Five,Ten,Twenty are already existing in the system
    wire [7:0] Five_avl,Ten_avl,Twenty_avl;
    wire [7:0] Five_avl_next,Ten_avl_next,Twenty_avl_next;

    //State reg This tells the current and next state
    //Any descision taken will be with respect to this
    reg [8:0]current_state,next_state;

    //Item Cost Parameter
    //Different item different cost
    //Instantiate the item module N times for N items
    parameter cost_It_1 = 20,
                    cost_It_2 = 15,
                    cost_It_3 = 10;
                    //Code is made for max cost of item being 20
                    //Just add more states to make max cost more
                    //max cost should be <= largest money state - 20     
    //-----------------------------------------------------------------------------------//
    
    //-----------------------------------------------------------------------------------//
    //Instantiating the modules


    //This module returns excess change and signal to dispense item
    Change_remaining ch(.clk(clk),.rst(internal_reset),.en(en_for_change),
    .req_amt(req_amt),.Five_avl(Five_avl), .Ten_avl(Ten_avl), .Twenty_avl(Twenty_avl),  // COMPLETED INSTANTIATION
    .Five_in(Five_in_total),.Ten_in(Ten_in_total),.Twenty_in(Twenty_in_total),
    .Five_out(Five_out_change),.Ten_out(Ten_out_change),.Twenty_out(Twenty_out_change),
    .Five_avl_next(Five_avl_next), .Ten_avl_next(Ten_avl_next), .Twenty_avl_next(Twenty_avl_next),
    .enable_dispense(enable_dispense));

    //Instantiating item module with different item cost
    //i.e three different items 
    Item it1(.clk(clk),.rst(internal_reset),.en1(en_for_item1),.en2(enable_dispense),
    .cost(cost_It_1),
    .amount_in(amount_in),.item_out(item_out1));     //THIS IS COMPLETE

    Item it2(.clk(clk),.rst(internal_reset),.en1(en_for_item2),.en2(enable_dispense),
    .cost(cost_It_2),
    .amount_in(amount_in),.item_out(item_out2));     //THIS IS COMPLETE

    Item it3(.clk(clk),.rst(internal_reset),.en1(en_for_item3),.en2(enable_dispense),
    .cost(cost_It_3),
    .amount_in(amount_in),.item_out(item_out3));     //THIS IS COMPLETE 

    //Module to directly return money given to machine if exceeds 40 
    Overflow_return ov(.clk(clk),.rst(internal_reset),.en(en_for_overflow),
    .Five_in(Five_in),.Ten_in(Ten_in),.Twenty_in(Twenty_in),
    .Five_out(Five_out_overflow),.Ten_out(Ten_out_overflow),
    .Twenty_out(Twenty_out_overflow)); //THIS IS COMPLETE

    //Module to multplex the outputs of two money returning modules so that there are no conflicts
    Mux_return_change mx(.rst(internal_reset),.en1(en_for_change),.en2(en_for_overflow),
    .Overflow({Five_out_overflow,Ten_out_overflow,Twenty_out_overflow}),
    .Change({Five_out_change,Ten_out_change,Twenty_out_change}),
    .Out({Five_out,Ten_out,Twenty_out}));  //THIS IS COMPLETE

    DenominationStorage(.clk(clk), .rst(internal_reset), .w_en(enable_dispense), 
    .five_avl(five_avl), .Ten_avl(Ten_avl), .Twenty_avl(Twenty_avl),
    .new_five_avl(Five_avl_next), .new_ten_avl(Ten_avl_next), .new_twenty_avl(Twenty_avl_next) )
    //-----------------------------------------------------------------------------------//

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

    //always sequential block
    //This block has to change state when there is money input
    //This block has to calculate the total amount in the system depending on the state
    //This block has to give enable signals to item , change return , overflow , mux modules depending on the state and inputs 
    always @ (posedge clk or posedge rst) begin
        
        //async reset
        //all ports , regs , wires used in this block are reset
        if(rst) begin
            Five_out <= 0;
            Ten_out <= 0;
            Twenty_out <= 0;
            item_out1 <= 0;
            item_out2 <= 0;
            item_out3 <= 0;
            req_amt <= 0;
            rst_counter <= 0;
            en_for_item1 <= 0;
            en_for_item2 <= 0;
            en_for_item3 <= 0;
            en_for_change <= 0;
            en_for_overflow <= 0;
            internal_reset <= 1;
            
        end


        //Resetting after item out
        //When item is out it waits for 4 clock cycles then resets
        else if(item_out1 || item_out2 || item_out3) begin

            if(rst_counter == 4) begin    
                Five_out <= 0;
                Ten_out <= 0;
                Twenty_out <= 0;
                item_out1 <= 0;
                item_out2 <= 0;
                item_out3 <= 0;
                req_amt <= 0;
                rst_counter <= 0;
                en_for_item1 <= 0;
                en_for_item2 <= 0;
                en_for_item3 <= 0;
                en_for_change <= 0;
                internal_reset <= 1;
                en_for_overflow <= 0;
            end

            else
                rst_counter <= rst_counter + 1;

        end

        //Here all main things happen (Change of states if money is input and if device is enabled)
        else if(en) begin
            
            //Sets total amount in the machine 
            amount_in <= amount_in_next;

            internal_reset <= 0;

            //Shifting the states depending on the case
            current_state <= next_state;

            //Sets the enables for other module which were calculated combitnationally
            en_for_change <= en_for_change_next;
            en_for_item1 <= en_for_item1_next;
            en_for_item2 <= en_for_item2_next;
            en_for_item3 <= en_for_item3_next;
            en_for_overflow <= en_for_overflow_next;

        end


        // Dont know if this is needed (not sure)
        //Want everything to be latched if enable in deactivated mid run
        //20 days later i still dont know if its needed :)
        else begin
            rst_counter <= 0;
            internal_reset <= 0;
        end

    end

    //-----------------------------------------------------------------------------------//


    //-----------------------------------------------------------------------------------//
    //Combinational circuit

    //Remember no putting multiple denominations at once
                //not desigend for it

    always @(*) begin
        if(en) begin
             //When money is input
            if(Five_in || Ten_in || Twenty_in)begin   
                case(current_state) 
                    S0:
                        if(Five_in) begin
                            next_state = S5;
                            amount_in_next = 5;
                        end
                        else if(Ten_in) begin
                            next_state = S10;
                            amount_in_next = 10;
                        end
                        else if(Twenty_in) begin
                            next_state = S20;
                            amount_in_next = 20;
                        end
                        else begin
                            next_state = S0;
                            amount_in_next = 0;
                        end
                    S5:
                        if(Five_in) begin
                            next_state = S10;
                            amount_in_next = 10;
                        end
                        else if(Ten_in) begin
                            next_state = S15;
                            amount_in_next = 15;
                        end
                        else if(Twenty_in) begin
                            next_state = S25;
                            amount_in_next = 25;
                        end
                        else begin
                            next_state = S5;
                            amount_in_next = 5;
                        end
                    S10:
                        if(Five_in) begin
                            amount_in_next = 15;
                            next_state = S15;
                        end
                        else if(Ten_in) begin
                            next_state = S20;
                            amount_in_next = 20;
                        end
                        else if(Twenty_in) begin
                            next_state = S30;
                            amount_in_next = 30;
                        end
                        else begin
                            amount_in_next = 10;
                            next_state = S10;
                        end
                    S15:
                        if(Five_in) begin
                            next_state = S20;
                            amount_in_next = 20;
                        end
                        else if(Ten_in) begin
                            next_state = S25;
                            amount_in_next = 25;
                        end
                        else if(Twenty_in) begin
                            next_state = S35;
                            amount_in_next = 35;
                        end
                        else begin
                            next_state = S15;
                            amount_in_next = 15;
                        end
                    S20:
                        if(Five_in) begin
                            next_state = S25;
                            amount_in_next = 25;
                        end
                        else if(Ten_in) begin
                            next_state = S30;
                            amount_in_next = 30;
                        end
                        else if(Twenty_in) begin
                            next_state = S40;
                            amount_in_next = 40;
                        end
                        else begin
                            next_state = S20;
                            amount_in_next = 20;
                        end
                    //Until here its regular state change only
                    //After here there will be overflow conditions also therfore we need to handle it
                    //When overflow condition is reached (i.e money in system > 40)
                    //Enable signal to the overflow block is 1 and stste remains the same

                    S25:
                        if(Five_in) begin
                            next_state = S30;
                            amount_in_next = 30;
                        end
                        else if(Ten_in) begin
                            next_state = S35;
                            amount_in_next = 35;
                        end
                        else if(Twenty_in) begin
                            en_for_overflow_next = 1;
                            next_state = S25;
                            amount_in_next = 25;
                        end
                        else begin
                            next_state = S25;
                            amount_in_next = 25;
                        end

                    S30:
                        if(Five_in) begin
                            next_state = S35;
                            amount_in_next = 35;
                        end
                        else if(Ten_in) begin
                            next_state = S40;
                            amount_in_next = 40;
                        end
                        else if(Twenty_in)begin
                            next_state = S30;
                            amount_in_next = 30;
                            en_for_overflow_next = 1;
                        end
                        else begin
                            next_state = S30;
                            amount_in_next = 30;
                        end
                    S35:
                        if(Five_in) begin
                            next_state = S40;
                            amount_in_next = 40;
                        end
                        else if(Ten_in) begin
                            en_for_overflow_next = 1;
                            next_state = S35;
                            amount_in_next = 35;
                        end
                        else if(Twenty_in)begin
                            en_for_overflow_next = 1;
                            next_state = S35;
                            amount_in_next = 35;
                        end
                        else  begin
                            next_state = S35;
                            amount_in_next = 35;
                            en_for_overflow_next = 0;
                        end
                    S40:
                        if(Five_in | Ten_in | Twenty_in) begin
                            en_for_overflow_next = 1;
                            next_state = S40;
                            amount_in_next = 40;
                        end
                        else begin
                            next_state = S40;
                            amount_in_next = 40;
                            en_for_overflow_next = 0;
                        end
                    default:
                        en_for_overflow_next = 0;
                        next_state = S0;
                        amount_in_next = 0;
                        
                    endcase
            end

            //To enable the respective items module after user inputs item needed
            //And also determine the req_amount which goes to the return change block
            case(select_item)
                default:
                    req_amt = 0;
                    en_for_change_next = 0;
                    en_for_item1_next = 0;
                    en_for_item2_next = 0;
                    en_for_item3_next = 0;
                2'd1:
                    if (amount_in_next - cost_It_1 >= 0) begin
                        en_for_change_next = 1;
                        req_amt = amount_in_next - cost_It_1; 
                        en_for_item1_next = 1;
                    end
                        else begin
                        en_for_change_next = 0;
                        en_for_item1_next = 0;
                        en_for_item2_next = 0;
                        en_for_item3_next = 0;
                    end
                2'd2:
                    if (amount_in_next - cost_It_2 >= 0) begin
                        en_for_change_next = 1;
                        req_amt = amount_in_next - cost_It_2; 
                        en_for_item2_next = 1;
                    end
                        else begin
                        en_for_change_next = 0;
                        en_for_item1_next = 0;
                        en_for_item2_next = 0;
                        en_for_item3_next = 0;
                    end
                2'd3:
                    if (amount_in_next - cost_It_3 >= 0) begin
                        en_for_change_next = 1;
                        req_amt = amount_in_next - cost_It_3; 
                        en_for_item3_next = 1;
                    end
                        else begin
                        en_for_change_next = 0;
                        en_for_item1_next = 0;
                        en_for_item2_next = 0;
                        en_for_item3_next = 0;
                    end
            endcase


        end
    end


    
endmodule