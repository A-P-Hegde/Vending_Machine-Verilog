`timescale 1ns/1ps

module tb_Vending_Machine;

  // Inputs
  reg clk, rst, en;
  reg [1:0] select_item;
  reg Five_in, Ten_in, Twenty_in;

  // Outputs
  wire [7:0] Five_out, Ten_out, Twenty_out;
  wire item_out1, item_out2, item_out3;
  wire [8:0]  current_state;
  wire [7:0] amount_in;
  wire Five_out_overflow,Ten_out_overflow,Twenty_out_overflow;
  wire [7:0] Five_in_total,Ten_in_total,Twenty_in_total;
  // Instantiate DUT
  Vending_Machine uut (
    .clk(clk),
    .rst(rst),
    .en(en),
    .select_item(select_item),
    .Five_in(Five_in),
    .Ten_in(Ten_in),
    .Twenty_in(Twenty_in),
    .Five_out(Five_out),
    .Ten_out(Ten_out),
    .Twenty_out(Twenty_out),
    .item_out1(item_out1),
    .item_out2(item_out2),
    .item_out3(item_out3),
    .current_state(current_state),
    .amount_in(amount_in),
    .Five_out_overflow(Five_out_overflow),
    .Ten_out_overflow(Ten_out_overflow),
    .Twenty_out_overflow(Twenty_out_overflow),
    .Five_in_total(Five_in_total),
    .Ten_in_total(Ten_in_total),
    .Twenty_in_total(Twenty_in_total)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 100 MHz clock
  end

  // Test sequence
  initial begin
    $display("==== VENDING MACHINE TEST START ====");

    // Initialize all
    rst = 1; en = 0;
    Five_in = 0; Ten_in = 0; Twenty_in = 0;
    select_item = 2'b00;
    #20;

    rst = 0; en = 1;
    #20;

    // Test 1 — Buy item 1 (say ₹20) using 2×₹10
    $display("Test 1: Buying item 1 with ₹20");
    Ten_in = 1; #10; Ten_in = 0; #10;
    Ten_in = 1; #10; Ten_in = 0; #10;
    select_item = 2'b01;  // select item 1
    #40;
    select_item = 2'b00;  // deselect
    #50;

    // Test 2 — Insert ₹30 (₹20 + ₹10) for item 2 costing ₹20
    $display("Test 2: Buying item 2 with ₹30");
    Twenty_in = 1; #10; Twenty_in = 0; #10;
    Ten_in = 1; #10; Ten_in = 0; #10;
    select_item = 2'b10;  // select item 2
    #40;
    select_item = 2'b00;
    #50;
    rst = 1; en =0; #20; rst =0 ; en =1;
    #50;

    // Test 3 — Overflow: insert more than ₹40
    $display("Test 3: Overflow scenario");
    Twenty_in = 1; #10; Twenty_in = 0; #10;
    Twenty_in = 1; #10; Twenty_in = 0; #10;
    Twenty_in = 1; #10; Twenty_in = 0; #10;
    #50;

    // Test 4 — Insufficient funds
    $display("Test 4: Not enough balance");
    Five_in = 1; #10; Five_in = 0; #10;
    select_item = 2'b01; #40;
    select_item = 2'b00; #30;

    // Test 5 — Reset mid-transaction
    $display("Test 5: Reset during transaction");
    Ten_in = 1; #10; Ten_in = 0; #10;
    Twenty_in = 1; #10; Twenty_in = 0; #10;
    select_item = 2'b11;
    #60;

    $display("==== TEST COMPLETE ====");
    $finish;
  end

  // Monitor outputs
  initial begin
    $monitor(
      "t=%0t | clk=%b rst=%b en=%b sel=%b | ₹5in=%b ₹10in=%b ₹20in=%b || out ₹5=%d ₹10=%d ₹20=%d | items={1:%b,2:%b,3:%b} | state = %d | amount_in = %d" ,
      $time, clk, rst, en, select_item,
      Five_in, Ten_in, Twenty_in,
      Five_out, Ten_out, Twenty_out,
      item_out1, item_out2, item_out3,current_state,amount_in
    );
  end

endmodule
