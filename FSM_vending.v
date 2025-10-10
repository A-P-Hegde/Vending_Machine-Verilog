module Vending_Machine (
    clk,rst,en,
    select_item,
    Five_in,Ten_in,Twenty_in,
    Five_out,Ten_out,Twenty_out,
    enable_dispense,
    item_out,
);

    //Defining of the ports wires
    input clk,rst,en;
    input [3:0] select_item;
    input [7:0] Five_in,Ten_in,Twenty_in;
    output [7:0] Five_out,Ten_out,Twenty_out;
    output item_out;

    //Wires needed for other modules
    wire [7:0] req_amt;
    wire en_for_change;
    wire [3:0] rst_counter;
    wire internal_reset;   //To reset machine after a few cycles after item given 
                                   //To use as reset for instantiated blocks

    //-----------------------------------------------------------------------------------//
    //Instantiating the modules
    Change_remaining ch(.clk(clk),.rst(internal_reset),.en(en_for_change),
    .req_amt(req_amt),                                             //NOT COMPLETED INSTANTIATION (missing ports)!!!!
    .Five_in(Five_in),.Ten_in(Ten_in),.Twenty_in(Twenty_in),
    .Five_out(Five_out),.Ten_out(Ten_out),.Twenty_out(Twenty_out)
    .enable_dispense(enable_dispense));

    Item1(.clk(clk),)
    //-----------------------------------------------------------------------------------//

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

        //Here all main things happen
        else if(en) begin
            internal_reset <= rst;
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
    
endmodule