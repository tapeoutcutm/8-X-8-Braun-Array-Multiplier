`default_nettype none
`timescale 1ns / 1ps

module tb;
  // DUT interface signals
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;      // Multiplicand A
  wire [7:0] uo_out;    // Product lower 8 bits
  reg [7:0] uio_in;     // Multiplier B
  wire [7:0] uio_out;   // Product upper 8 bits
  wire [7:0] uio_oe;    // IO enable
  
  // Instantiate the DUT (Braun Multiplier)
  tt_um_braun_mult dut (
    .clk(clk),
    .rst_n(rst_n),
    .ena(ena),
    .ui_in(ui_in),        // A input
    .uo_out(uo_out),      // P[7:0]
    .uio_in(uio_in),      // B input
    .uio_out(uio_out),    // P[15:8]
    .uio_oe(uio_oe)
  );
  
  // Clock generation - slower for gate-level compatibility
  initial clk = 0;
  always #50 clk = ~clk;  // 100ns period -> 10 MHz
  
  // Test vectors and expected results
  reg [15:0] expected_product;
  wire [15:0] actual_product = {uio_out, uo_out};
  
  // Test cases
  initial begin
    $display("Starting Braun Multiplier Testbench");
    $display("=====================================");
    
    // Initialize signals
    rst_n = 0;
    ena = 1;
    ui_in = 8'b0;
    uio_in = 8'b0;
    
    #200;
    rst_n = 1;
    #100;
    
    // Test Case 1: 0 × 0 = 0
    test_multiplication(8'd0, 8'd0, "Test 1: 0 × 0");
    
    // Test Case 2: 1 × 1 = 1
    test_multiplication(8'd1, 8'd1, "Test 2: 1 × 1");
    
    // Test Case 3: 15 × 15 = 225
    test_multiplication(8'd15, 8'd15, "Test 3: 15 × 15");
    
    // Test Case 4: 255 × 1 = 255
    test_multiplication(8'd255, 8'd1, "Test 4: 255 × 1");
    
    // Test Case 5: 1 × 255 = 255
    test_multiplication(8'd1, 8'd255, "Test 5: 1 × 255");
    
    // Test Case 6: 16 × 16 = 256
    test_multiplication(8'd16, 8'd16, "Test 6: 16 × 16");
    
    // Test Case 7: 255 × 255 = 65025 (maximum case)
    test_multiplication(8'd255, 8'd255, "Test 7: 255 × 255 (max)");
    
    // Test Case 8: 100 × 200 = 20000
    test_multiplication(8'd100, 8'd200, "Test 8: 100 × 200");
    
    // Test Case 9: Random test cases
    test_multiplication(8'd85, 8'd51, "Test 9: 85 × 51");
    test_multiplication(8'd128, 8'd64, "Test 10: 128 × 64");
    
    #1000;
    $display("=====================================");
    $display("Testbench completed successfully!");
    $finish;
  end
  
  // Task for testing multiplication
  task test_multiplication;
    input [7:0] a;
    input [7:0] b;
    input [200*8:1] test_name; // String for test name
    begin
      ui_in = a;
      uio_in = b;
      expected_product = a * b;
      
      #200; // Wait for combinational logic to settle
      
      $display("%s", test_name);
      $display("  A = %d (0x%02h), B = %d (0x%02h)", a, a, b, b);
      $display("  Expected: %d (0x%04h)", expected_product, expected_product);
      $display("  Actual:   %d (0x%04h)", actual_product, actual_product);
      
      if (actual_product == expected_product) begin
        $display("  ✓ PASS");
      end else begin
        $display("  ✗ FAIL - Mismatch!");
        $display("  Expected P[15:8] = 0x%02h, P[7:0] = 0x%02h", expected_product[15:8], expected_product[7:0]);
        $display("  Actual   P[15:8] = 0x%02h, P[7:0] = 0x%02h", uio_out, uo_out);
      end
      $display("");
      
      #100; // Small delay between tests
    end
  endtask
  
  // Monitor key signals
  initial begin
    $monitor("Time: %0t | A=%d, B=%d | Product=%d (0x%04h) | uio_oe=0x%02h", 
             $time, ui_in, uio_in, actual_product, actual_product, uio_oe);
  end
  
  // VCD dump for waveform viewing
  initial begin
    $dumpfile("braun_multiplier_tb.vcd");
    $dumpvars(0, tb);
  end
  
endmodule

`default_nettype wire
