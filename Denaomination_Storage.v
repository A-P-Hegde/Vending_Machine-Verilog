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