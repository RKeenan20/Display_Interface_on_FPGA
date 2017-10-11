`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UCD
// Engineer: Robert Keenan Ciaran Nolan
//
// Create Date: 11.10.2017 21:05:25
// Design Name: Display Interface
// Module Name: disp1
// Project Name: Lab 4 Display Interface
// Target Devices:
// Tool Versions:
// Description: Implementing the display interface for use with a 7 segment display on an FPGA
//              Introducing the concepts of instantiation and larger designs
/// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
/*Thoughts:

          The 5Mhz clock is an input and we are processing it inside
					The output from our clockDivider is at 4kHz and called newClock
					We need to process a 16bit input of dispVal and decide how to output the
					digit and segment.

					This needs to be all included in one module so the below operations are in one containing one

					Also look at how to split the 16 bit number into 4 4 bit numbers
*/


//DisplayInterface disp1()

module clockDivide(input clk5,
                  input reset,
                  output reg newClock
                  );


          localparam  compare = 624; //Want to output on 624th clock cycle = 4kHz
          reg [9:0] countCD;

          always @(posedge clk5)
          	begin
          		if(reset)
              	countCD <= 10'b0;
                    else if (countCD == compare) //Once it hits 624, set back to zero to count again
                              countCD <= 10'b0;
                    else
                              countCD <= countCD++;
          end

          always @(posedge clk5)
          begin
                    if(reset)
                              newClock <= 1'b0;
                    else if(countCD == compare) //Inverts the output from the last 624th clock cycle
                              newClock <= ~newClock;
                    else //Else havent hit the 624th edge yet, so hold value
                              newClock <= newClock;
          end

endmodule
