// Project #1: Calculator (Advanced)
// Verilog sample source file for "System LSI design"
//                                                  2022.10  T. Ikenaga
// 

// AP600: Interface between top_moudule of calculator and FPGA board
`define OPERATOR_ADD 0
`define OPERATOR_SUB 1
`define OPERATOR_MUL 2
`define OPERATOR_DIV 3
`define OPERATOR_POWER 4
`define OPERATOR_LOG 5
`define OPERATOR_NUMBER 2
module AP600 (clk, reset, pswA, pswB, pswC, pswD, dipA, dipB,
	      hexA, hexB, buzzer, ledA, ledB, ledC, ledD, 
             segA, segB, segC, segD, segE, segF, segG, segH);

  input      clk, reset;             // Clock, Reset
  input[4:0] pswA, pswB, pswC, pswD; // Push switch
  input[7:0] dipA, dipB;             // DIP switch
  input[3:0] hexA, hexB;             // Rotery switch
  output     buzzer ;		     // Buzzer
  output[7:0] ledA, ledB, ledC, ledD;// LED
  output[7:0] segA, segB, segC, segD, segE, segF, segG, segH; // 7SEG LED

  wire [7:0] ledh, ledm, ledl;
  reg [9:0] push;
  reg overflow, sign, ce, ac, plus, minus, mul, div, equal, power, log;

  // for Debugging
  wire [1:0] state;
  wire [20:0] regb;
  wire [9:0] rega;
  wire [1:0] count; 
  wire [`OPERATOR_NUMBER:0] operator_choose;

   // Input assignment
  always@(dipA)
  if (dipA==8'b11111111) begin
    push[0] = pswD[0];
    push[1] = pswC[0];
    push[2] = pswC[1];
    push[3] = pswC[2];
    push[4] = pswB[0];
    push[5] = pswB[1];
    push[6] = pswB[2];
    push[7] = pswA[0];
    push[8] = pswA[1];
    push[9] = pswA[2];
    plus    = pswD[3];
    minus   = pswC[3];
    power   = pswC[4];
    mul     = pswB[3];
    div     = pswA[3];
    ce      = pswA[4];
    ac      = pswB[4];
    equal   = pswD[4];
    log     = pswD[1];
    else begin
      
    end
  end
  // Output assignment
  assign buzzer = overflow ;

  assign ledA = {overflow,1'b0, count[0],count[1], 
                 operator_choose, state[0], state[1]};
  assign ledB = {regb[8], regb[9], regb[10], regb[11], 4'b0000};
  assign ledC = {regb[0],regb[1],regb[2],regb[3],
                 regb[4],regb[5],regb[6],regb[7]};
  assign ledD = {rega[0],rega[1],rega[2],rega[3],
                 rega[4],rega[5],rega[6],rega[7]};

  assign segA = 8'b00000000;
  assign segB = 8'b00000000;
  assign segC = 8'b00000000;
  assign segD = 8'b00000000;
  assign segE = {6'b000000,sign,1'b0};
  assign segF = ledh;
  assign segG = ledm;
  assign segH = ledl;

  calctop calctop(clk, reset, push, ce, ac, plus, minus, mul, div, power, log, equal, 
                  sign, ledh, ledm, ledl, overflow, state, rega, regb,
                  count, operator_choose);

endmodule
// Calctop: Calculator top module
module calctop(clk, reset, push, ce, ac, plus, minus, mul, div, power, log, equal, 
               sign, ledh, ledm, ledl, overflow, state, rega, regb,
               count, operator_choose);
  input plus, minus, mul, div, power, log, equal, ce, ac, reset, clk;
  input [9:0] push;
  output overflow, sign;
  output [7:0] ledh, ledm, ledl;

  // for Debugging
  output [1:0] state;
  output [20:0] regb;
  output [9:0] rega;
  output [1:0] count;
  output [`OPERATOR_NUMBER:0] operator_choose;

  wire plusout, minusout, mulout, divout, powerout,logout, equalout, ceout, acout;
  wire [9:0] pushout;
  wire [9:0] wout;

  calc calc(pushout, plusout, minusout, mulout, divout, powerout, logout, equalout, clk, reset, 
            ceout, acout, sign, overflow, wout, state, rega, regb, count,
            operator_choose);

  binled binled(wout, ledl, ledm, ledh);

  syncro syncroce(ceout, ce, clk, reset);
  syncro syncroac(acout, ac, clk, reset);
  syncro syncropuls(plusout, plus, clk, reset);
  syncro syncrominus(minusout, minus, clk, reset);
  syncro syncromul(mulout, mul, clk, reset);
  syncro syncrodiv(divout, div, clk, reset);
  syncro syncropower(powerout, power, clk, reset);
  syncro syncrolog(logout, log, clk, reset);
  syncro syncroequal(equalout, equal, clk, reset);
  syncro10 syncropush(pushout, push, clk, reset);

endmodule

// Calc: Calculator main module
module calc(decimal, plus, minus, mul, div, power, log, equal, clk, reset, 
            ce, ac, sign, overflow, out, state, REGA, REGB, 
            count, operator_choose);
  parameter DECIMAL = 0;
  parameter OPE = 1;
  parameter HALT = 2 ;//重新定义三种状态
  input [9:0] decimal;
  input clk, ce, ac, reset, plus, minus, mul, div, power, log, equal;
  output sign, overflow;
  output [9:0] out;

  // for Debugging
  output [1:0] state;
  output [20:0] REGB;
  output [9:0] REGA;
  output [1:0] count;
  output [`OPERATOR_NUMBER:0] operator_choose;

  wire [3:0] d;
  wire [8:0] alu_out;
  reg  [1:0] state;
  reg  [20:0] REGB;
  reg  [9:0] REGA;
  reg  [1:0] count;
  reg  [`OPERATOR_NUMBER:0] operator_choose ;

  function [3:0] dectobin;
   input [9:0] in;
    if(in[9])
     dectobin = 9;
    else if(in[8])
     dectobin = 8;
    else if(in[7])
     dectobin = 7;
    else if(in[6])
     dectobin = 6;
    else if(in[5])
     dectobin = 5;
    else if(in[4])
     dectobin = 4;
    else if(in[3])
     dectobin = 3;
    else if(in[2])
     dectobin = 2;
    else if(in[1])
     dectobin = 1;
    else if(in[0])
     dectobin = 0;
   endfunction

  assign d=dectobin(decimal);

  always @(posedge clk or negedge reset)
    begin
     if(!reset)
       begin
         REGA <= 0; REGB <= 0; count <= 0;
         operator_choose <= 0;
         state<= DECIMAL;
       end
     else if(ac)
       begin
         REGA <= 0; REGB <= 0; count <= 0;
         operator_choose <= 0;
         state<= DECIMAL;
       end
     else
       begin
        case (state)
         DECIMAL :
            begin
             if((decimal != 0) && (count < 3))
               begin
                 count <= count + 1;
                 REGA <= REGA * 10 + d;
               end
             else if(ce)
               begin
                 REGA <= 0; 
                 count <= 0;
               end
             else if(plus || minus || mul || div || power || log|| equal)
               begin
                case (operator_choose)
                   `OPERATOR_ADD: REGB <= REGB + REGA;
                   `OPERATOR_SUB: REGB <= REGB - REGA;
                   `OPERATOR_MUL: REGB <= REGB * REGA;
                   `OPERATOR_DIV: if (REGA !=0) REGB <= REGB / REGA;
                   `OPERATOR_POWER: REGB <= REGB * REGB;
                   `OPERATOR_LOG: REGB <= $log10(REGA);
                endcase
                if (plus)
                   operator_choose <= `OPERATOR_ADD;
                else if(minus)
                   operator_choose <= `OPERATOR_SUB;
                else if(mul)
                   operator_choose <= `OPERATOR_MUL;
                else if(div)
                   operator_choose <= `OPERATOR_DIV;
                else if(power)
                  operator_choose <= `OPERATOR_POWER;
                else if(log)
                    operator_choose <= `OPERATOR_LOG;
                state <= OPE;
               end
            end
         OPE:
            if (((REGB[20] ==1)&&(REGB<2096153))
                || ((REGB[20]==0)&&(REGB>999)))
               state<=HALT;
            else if(operator_choose == `OPERATOR_POWER)
               state <= DECIMAL;
            else if(decimal)begin
                REGA <= d; 
                count <= 1;
                state <= DECIMAL;
            end
         HALT:
            if(ce) begin
                REGA <= 0; 
                REGB <= 0;
                operator_choose <= 0; 
                count <= 0;
                state <= DECIMAL;
               end
         endcase
       end
    end

  assign overflow=(state==HALT)?1:0;
  assign sign=(state==DECIMAL)?0: ((state==OPE)?(REGB[20]) :0);
  assign out=out_func (state, REGA, REGB);

  function [9:0] out_func;
    input [1:0] s; input [9:0] a; input [11:0] b;
    case(s)
      DECIMAL :
        out_func = a;

      OPE :
        if(b[11]==1)
          out_func = ~b + 1;
        else
          out_func = b;
    endcase
  endfunction

endmodule

// Syncronous: Asyncronous to Syncronous (1-bit width)
module syncro(out, in, clk, reset);
  parameter WIDTH = 1;
  input    [WIDTH-1:0] in;
  output   [WIDTH-1:0] out;
  input    clk,reset;
  reg      [WIDTH-1:0] qO,q1,q2;

  always @(posedge clk or negedge reset)
   begin
    if(!reset)
     begin
       qO <= 0;
       q1 <= 0;
       q2 <= 0;
     end
    else
     begin
       qO <= ~in;
       q1 <= qO;
       q2 <= q1;
     end
   end
  assign out=q1 & (~q2);
endmodule

// Syncronous: Asyncronous to syncronous (10-bit width)
module syncro10(out, in, clk, reset);
  parameter WIDTH = 10;
  input    [WIDTH-1:0] in;
  output   [WIDTH-1:0] out;
  input     clk,reset;
  reg      [WIDTH-1:0] qO,q1,q2;

  always @(posedge clk or negedge reset)
   begin
    if(!reset)
     begin
       qO <= 0;
       q1 <= 0;
       q2 <= 0;
     end
    else
     begin
       qO <= ~in;
       q1 <= qO;
       q2 <= q1;
     end
   end
  assign out=q1 & (~q2) ;
endmodule

// Binled: Binary code translation
module binled(in, ledl, ledm, ledh);
  input [9:0] in;
  output [7:0] ledl, ledm, ledh;
  wire [3:0] wireh, wirem, wirel;

  bintobcd bintobcd(in,wirel,wirem, wireh);
  ledout ledouthigh(wireh, ledh);
  ledout ledoutmid(wirem, ledm);
  ledout ledoutlow(wirel, ledl);
endmodule

// Bintobcd: Translation from Binary to BCD
module bintobcd(in,outl,outm,outh) ;
  input [9:0] in;
  output [3:0] outl,outm,outh;
  wire [9:0] temp1, temp2, temp3, temp4, temp5, temp6, temp7;

  assign outh[3] = (in >= 800)    ? 1            : 0;
  assign temp1   = (in >= 800)    ? in - 800     : in;
  assign outh[2] = (temp1 >= 400) ? 1            : 0;
  assign temp2   = (temp1 >= 400) ? temp1 - 400  : temp1;
  assign outh[1] = (temp2 >= 200) ? 1            : 0;
  assign temp3   = (temp2 >= 200) ? temp2 - 200  : temp2;
  assign outh[0] = (temp3 >= 100) ? 1            : 0;
  assign temp4   = (temp3 >= 100) ? temp3 - 100  : temp3;

  assign outm[3] = (temp4 >= 80)  ? 1            : 0;
  assign temp5   = (temp4 >= 80)  ? temp4 - 80   : temp4;
  assign outm[2] = (temp5 >= 40) ? 1            : 0;
  assign temp6   = (temp5 >= 40) ? temp5 - 40   : temp5;
  assign outm[1] = (temp6 >= 20) ? 1            : 0;
  assign temp7   = (temp6 >= 20) ? temp6 - 20   : temp6;
  assign outm[0] = (temp7 >= 10) ? 1            : 0;
  assign outl    = (temp7 >= 10) ? temp7 - 10   : temp7;
endmodule

// Ledout: Translation from BCD to LED-out
module ledout(in, out);
  input  [3:0] in ;
  output [7:0] out;
  reg    [7:0] out;
 
  always @(in)
   begin
     case(in)
        0: out = 8'b11111100;
        1: out = 8'b01100000;
        2: out = 8'b11011010;
        3: out = 8'b11110010;
        4: out = 8'b01100110;
        5: out = 8'b10110110;
        6: out = 8'b10111110;
        7: out = 8'b11100000;
        8: out = 8'b11111110;
        9: out = 8'b11110110;
        default: out = 8'bXXXXXXXX;
      endcase
   end
endmodule
