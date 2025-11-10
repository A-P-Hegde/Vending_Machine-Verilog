`timescale 1ns / 1ps

module tb_Vending_Machine;

  // Inputs
  reg clk;
  reg reset;
  reg [1:0] item_select;
  reg [2:0] coin_in;

  // Outputs
  wire [3:0] change_out;
  wire [3:0] total_out;
  wire item_dispensed;
  wire overflow_flag;

  // Instantiate the Unit Under Test (UUT)
  Vending_Machine uut (
    .clk(clk),
    .reset(reset),
    .item_select(item_select),
    .coin_in(coin_in),
    .change_out(change_out),
    .total_out(total_out),
    .item_dispensed(item_dispensed),
    .overflow_flag(overflow_flag)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock
  end

  // Test sequence
  initial begin
    $display("=== Vending Machine Testbench Started ===");

    // Initialize inputs
    reset = 1;
    item_select = 2'b00;
    coin_in = 3'b000;
    #10;

    reset = 0;
    #10;

    // Test Case 1: Insert coins worth 20 and buy item 0 (cost = 20)
    $display("Test 1: Buying item 0 with exact change");
    coin_in = 3'b001; // insert ₹10
    #10;
    coin_in = 3'b010; // insert another ₹10
    #10;
    coin_in = 3'b000; // stop inserting
    item_select = 2'b00; // select item 0
    #50;

    // Test Case 2: Insert ₹30 and buy item 1 (cost = 20, expect ₹10 change)
    $display("Test 2: Buying item 1 with change expected");
    coin_in = 3'b001; // ₹10
    #10;
    coin_in = 3'b010; // ₹20 total
    #10;
    coin_in = 3'b011; // ₹30 total
    #10;
    coin_in = 3'b000;
    item_select = 2'b01;
    #50;

    // Test Case 3: Overflow scenario (>₹40)
    $display("Test 3: Overflow scenario");
    coin_in = 3'b011; // ₹30
    #10;
    coin_in = 3'b011; // ₹60 total → overflow
    #10;
    coin_in = 3'b000;
    #30;

    // Test Case 4: Buy item 2 without enough coins
    $display("Test 4: Insufficient coins");
    coin_in = 3'b001; // ₹10
    #10;
    item_select = 2'b10; // cost maybe ₹30
    #50;

    // Test Case 5: Normal flow + Reset mid-operation
    $display("Test 5: Reset during transaction");
    coin_in = 3'b010; // ₹20
    #10;
    reset = 1;
    #10;
    reset = 0;
    coin_in = 3'b011; // ₹30 after reset
    item_select = 2'b10;
    #50;

    $display("=== Testbench Completed ===");
    $finish;
  end

  // Monitor signals
  initial begin
    $monitor($time, ": clk=%b reset=%b item=%b coin_in=%b total=%d change=%d disp=%b overflow=%b",
             clk, reset, item_select, coin_in, total_out, change_out, item_dispensed, overflow_flag);
  end

endmodule
