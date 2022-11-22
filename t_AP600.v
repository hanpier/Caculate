// Project #1: Calculator
// Test pattern file for "System LSI design"
// Sequence: "1 + 5 - 9 ="
//                                                  2015.10  T. Ikenaga
// 
`timescale 1ns / 10ps

module t_AP600;

  reg clk ,reset;                   // clock, reset
  reg [4:0] pswA, pswB, pswC, pswD; // push switch(NEG)
  reg [7:0] dipA, dipB;             // dip switch(NEG)
  reg [3:0] hexA, hexB;             // rotary switch
  wire buzzer;			    // buzzer
  wire [7:0] ledA, ledB, ledC, ledD;// LED
  wire [7:0] segA, segB, segC, segD, segE, segF, segG, segH; // 7SEG

  // Clock
  initial clk = 0;
  always
    #5 clk = ~clk;

  initial
    begin
      $monitor("REGA=%b, REGB=%b, SEGF=%b, SEGG=%b, SEGH=%b,ledA=%b",
               AP600.rega, AP600.regb, segF, segG, segH, ledA);
      reset <= 1; pswA <= 5'b11111; pswB <= 5'b11111; pswC <= 5'b11111; 
      pswD <= 5'b11111;
      dipA <=8'b11111111; dipB <=8'b11111111; hexA <=4'b1111; hexB <=4'b1111;
      #10 reset <= 0;
      #10 reset <= 1;

      // // input: 1
      // #10 pswC[0] <= 0;
      // #10 pswC[0] <= 1;

      // // input: +
      // #10 pswD[3] <= 0;
      // #10 pswD[3] <= 1;

      // // input: 5
      // #10 pswB[1] <= 0;
      // #10 pswB[1] <= 1;

      // // input: -
      // #10 pswC[3] <= 0;
      // #10 pswC[3] <= 1;

      // // input: 9
      // #10 pswA[2] <= 0;
      // #10 pswA[2] <= 1;

      // // input: =
      // #10 pswD[4] <= 0;
      // #10 pswD[4] <= 1;

      //       // input: 5
      // #10 pswB[1] <= 0;
      // #10 pswB[1] <= 1;

      //       // input: **
      // #10 pswC[4] <= 0;
      // #10 pswC[4] <= 1;

      //       // input: =
      // #10 pswD[4] <= 0;
      // #10 pswD[4] <= 1;

                  // input:log 
      #10 pswD[1] <= 0;
      #10 pswD[1] <= 1;

            // input: 1
      #10 pswC[0] <= 0;
      #10 pswC[0] <= 1;

      // input: 0
      #10 pswD[0] <= 0;
      #10 pswD[0] <= 1;


            // input: +
      #10 pswD[3] <= 0;
      #10 pswD[3] <= 1;

      // input: 5
      #10 pswB[1] <= 0;
      #10 pswB[1] <= 1;

            // input: =
      #10 pswD[4] <= 0;
      #10 pswD[4] <= 1;

      #100
      $finish;
    end

   AP600 AP600(clk, reset, pswA, pswB, pswC, pswD, dipA, dipB,
	      hexA, hexB, buzzer, ledA, ledB, ledC, ledD, 
              segA, segB, segC, segD, segE, segF, segG, segH);

endmodule
