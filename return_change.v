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
