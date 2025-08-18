`default_nettype none
`timescale 1ns / 1ps
// Top-level TinyTapeout Module for 8x8 Braun Array Multiplier
// Using your original braunmul implementation
module tt_um_braun_mult(
    input  wire [7:0] ui_in,    // Dedicated inputs - Multiplicand A[7:0]
    output wire [7:0] uo_out,   // Dedicated outputs - Product P[7:0] (lower byte)
    input  wire [7:0] uio_in,   // IOs: Input path - Multiplier B[7:0]
    output wire [7:0] uio_out,  // IOs: Output path - Product P[15:8] (upper byte)
    output wire [7:0] uio_oe,   // IOs: Enable path (1 = output, 0 = input)
    input  wire       ena,      // Enable signal
    input  wire       clk,      // Clock (not used in combinational design)
    input  wire       rst_n     // Reset (not used in combinational design)
);

  // Input assignments
  wire [7:0] multiplicand = ui_in;     // A input from ui_in
  wire [7:0] multiplier = uio_in;      // B input from uio_in
  
  // Output wire for 16-bit product
  wire [15:0] product;
  
  // Instantiate YOUR original braunmul module
  braunmul multiplier_core (
    .A(multiplicand),
    .B(multiplier),
    .P(product)
  );
  
  // Output assignments
  assign uo_out = product[7:0];        // Lower 8 bits of product
  assign uio_out = product[15:8];      // Upper 8 bits of product
  assign uio_oe = 8'hFF;               // Set all uio pins as outputs
  
  // Unused inputs (prevents warnings)
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule

// =============================================================================
// YOUR ORIGINAL CODE - PRESERVED EXACTLY AS YOU WROTE IT
// =============================================================================

// half adder - YOUR CODE
module ha (input a, b, output sum, cout);
  assign sum = a ^ b;
  assign cout = a & b;
endmodule

// full adder - YOUR CODE
module fa (
    input a,
    input b,
    input cin,
    output sum,
    output cout
);

  assign sum  = a ^ b ^ cin;
  assign cout = (a & b) | (b & cin) | (a & cin);

endmodule 

// 8x8 braun mul - YOUR ORIGINAL CODE PRESERVED


module braunmul (
    input  [7:0] A,
    input  [7:0] B,
    output [15:0] P
);

  wire [7:0] pp [7:0];

  genvar i, j;
  generate
    for (i = 0; i < 8; i = i + 1) begin: row
      for (j = 0; j < 8; j = j + 1) begin: col
        assign pp[i][j] = A[j] & B[i];
      end
    end
  endgenerate

  wire c1, c2_1, c2_2, c3_1, c3_2, c3_3;
  wire s1, s2_1, s2_2, s3_1, s3_2, s3_3;

  assign P[0] = pp[0][0];

  ha ha1 (pp[0][1], pp[1][0], s1, c1);
  assign P[1] = s1;

  fa fa1 (pp[0][2], pp[1][1], pp[2][0], s2_1, c2_1);
  ha ha2 (s2_1, c1, s2_2, c2_2);
  assign P[2] = s2_2;

  fa fa2 (pp[0][3], pp[1][2], pp[2][1], s3_1, c3_1);
  fa fa3 (s3_1, pp[3][0], c2_1, s3_2, c3_2);
  ha ha3 (s3_2, c2_2, s3_3, c3_3);
  assign P[3] = s3_3;
  
  wire s4_1, s4_2, s4_3, s4_4;
  wire c4_1, c4_2, c4_3, c4_4;
  
  fa fa4 (pp[0][4], pp[1][3], pp[2][2], s4_1, c4_1);
  fa fa5 (s4_1, pp[3][1], c3_1, s4_2, c4_2);
  fa fa6 (s4_2, pp[4][0], c3_2, s4_3, c4_3);
  ha ha4 (s4_3, c3_3, s4_4, c4_4);
  
  assign P[4] = s4_4;
  
  wire s5_1,s5_2,s5_3, s5_4, s5_5;
  wire c5_1,c5_2,c5_3, c5_4, c5_5;
  
  fa fa7 (pp[0][5], pp[1][4], pp[2][3], s5_1, c5_1);
  fa fa8 (pp[3][2], pp[4][1], pp[5][0], s5_2, c5_2);
  fa fa9 (c4_1, c4_2, c4_3, s5_3,c5_3);
  fa fa10 (c4_4, s5_1, s5_2, s5_4, c5_4);
  ha ha5 (s5_3, s5_4, s5_5, c5_5);
  
  assign P[5] = s5_5;
  
  wire s6_1, s6_2, s6_3, s6_4, s6_5, s6_6;
  wire c6_1, c6_2, c6_3, c6_4, c6_5, c6_6;
  
  fa fa11 (pp[0][6], pp[1][5], pp[2][4], s6_1, c6_1);
  fa fa12 (s6_1, pp[3][3], pp[4][2], s6_2, c6_2);
  fa fa13 (s6_2, pp[5][1], pp[6][0], s6_3, c6_3);
  fa fa14 (s6_3, c5_1, c5_2, s6_4, c6_4);
  fa fa15 (s6_4, c5_3, c5_4, s6_5, c6_5);
  ha ha6  (s6_5, c5_5, s6_6, c6_6);
  
  assign P[6] = s6_6;

  wire s7_1, s7_2, s7_3, s7_4, s7_5, s7_6, s7_7;
  wire c7_1, c7_2, c7_3, c7_4, c7_5, c7_6, c7_7;

  fa fa16 (pp[0][7], pp[1][6], pp[2][5], s7_1, c7_1);
  fa fa17 (s7_1, pp[3][4], pp[4][3], s7_2, c7_2);
  fa fa18 (s7_2, pp[5][2], pp[6][1], s7_3, c7_3);
  fa fa19 (s7_3, pp[7][0], c6_1, s7_4, c7_4);
  fa fa20 (s7_4, c6_2, c6_3, s7_5, c7_5);
  fa fa21 (s7_5, c6_4, c6_5, s7_6, c7_6);
  ha ha7  (s7_6, c6_6, s7_7, c7_7);

  assign P[7] = s7_7;

  wire s8_1, s8_2, s8_3, s8_4, s8_5, s8_6, s8_7;
  wire c8_1, c8_2, c8_3, c8_4, c8_5, c8_6, c8_7;

  fa fa22 (pp[1][7], pp[2][6], pp[3][5], s8_1, c8_1);
  fa fa23 (s8_1, pp[4][4], pp[5][3], s8_2, c8_2);
  fa fa24 (s8_2, pp[6][2], pp[7][1], s8_3, c8_3);
  fa fa25 (s8_3, c7_1, c7_2, s8_4, c8_4);
  fa fa26 (s8_4, c7_3, c7_4, s8_5, c8_5);
  fa fa27 (s8_5, c7_5, c7_6, s8_6, c8_6);
  ha ha8  (s8_6, c7_7, s8_7, c8_7);

  assign P[8] = s8_7;

  wire s9_1, s9_2, s9_3, s9_4, s9_5, c9_5;
  wire c9_1, c9_2, c9_3, c9_4, s9_6, c9_6, s9_7, c9_7;

  fa fa28 (pp[2][7], pp[3][6], pp[4][5], s9_1, c9_1);
  fa fa29 (pp[5][4], pp[6][3], pp[7][2], s9_2, c9_2);
  fa fa30 (c8_1, c8_2, c8_3, s9_3, c9_3);
  fa fa31 (c8_4, c8_5, c8_6, s9_4, c9_4);
  fa fa32 (c8_7, s9_1, s9_2, s9_5, c9_5);
  ha ha9 (s9_3, s9_4, s9_6, c9_6);
  ha ha10 (s9_5, s9_6, s9_7, c9_7);

  assign P[9] = s9_7;

  wire s10_1, s10_2, s10_3, s10_4, s10_5, s10_6;
  wire c10_1, c10_2, c10_3, c10_4, c10_5, c10_6;

  fa fa33 (pp[3][7], pp[4][6], pp[5][5], s10_1, c10_1);
  fa fa34 (pp[6][4], pp[7][3], c9_1,     s10_2, c10_2);
  fa fa35 (c9_2,     c9_3,     c9_4,     s10_3, c10_3);
  fa fa36 (c9_5,     c9_6,     c9_7,     s10_4, c10_4);
  fa fa37 (s10_1, s10_2, s10_3, s10_5, c10_5);
  ha ha11 (s10_4, s10_5, s10_6, c10_6);

  assign P[10] = s10_6;

  wire s11_1, s11_2, s11_3, s11_4, s11_5;
  wire c11_1, c11_2, c11_3, c11_4, c11_5;

  fa fa38 (pp[4][7], pp[5][6], pp[6][5], s11_1, c11_1);
  fa fa39 (pp[7][4], c10_1,    c10_2,    s11_2, c11_2);
  fa fa40 (c10_3,    c10_4,    c10_5,    s11_3, c11_3);
  fa fa41 (s11_1, s11_2, s11_3, s11_4, c11_4);
  ha ha12 (s11_4, c10_6, s11_5, c11_5);

  assign P[11] = s11_5;

  wire s12_1, s12_2, s12_3, s12_4;
  wire c12_1, c12_2, c12_3, c12_4;

  fa fa42 (pp[5][7], pp[6][6], pp[7][5], s12_1, c12_1);
  fa fa43 (c11_1,    c11_2,    c11_3,    s12_2, c12_2);
  fa fa44 (s12_1, s12_2, c11_4, s12_3, c12_3);
  ha ha13 (s12_3, c11_5, s12_4, c12_4);

  assign P[12] = s12_4;

  wire s13_1, s13_2, s13_3;
  wire c13_1, c13_2, c13_3;

  fa fa45 (pp[6][7], pp[7][6], c12_1, s13_1, c13_1);
  fa fa46 (c12_2,    c12_3,    c12_4, s13_2, c13_2);
  ha ha14 (s13_1, s13_2, s13_3, c13_3);

  assign P[13] = s13_3;

  wire s14_1, s14_2;
  wire c14_1, c14_2;

  fa fa47 (pp[7][7], c13_1, c13_2, s14_1, c14_1);
  ha ha15 (s14_1, c13_3, s14_2, c14_2);

  assign P[14] = s14_2;

  wire s15_1, c15_1;

  ha ha16 (c14_1, c14_2, s15_1, c15_1);

  assign P[15] = s15_1;

endmodule
