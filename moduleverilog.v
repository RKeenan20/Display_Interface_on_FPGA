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


module DisplayInterface(input clk5,
												input reset,
												input [15:0] dispVal,
												output reg [7:0] digit,
												output reg [7:0] segment
												);

					localparam  compare = 624; //Want to output on 624th clock cycle = 4kHz
          reg [9:0] countCD;
					reg [1:0] counterDisplay;
					reg Enable;
					reg [3:0] hexOutput;

					assign segment[0] = 1'b0;

          always @(posedge clk5)
          	begin
          			if(reset)
              		countCD <= 10'b0;
                else if (countCD == compare) //Once it hits 624, set back to zero to count again
                  countCD <= 10'b0;
                else
                  countCD <= countCD + 1'b1;
          	end

          always @(posedge clk5)
          	begin
                if(reset)
                	Enable <= 1'b0;
                else if(countCD == compare) //Inverts the output from the last 624th clock cycle
                	Enable <= ~Enable;
                else //Else havent hit the 624th edge yet, so hold value
                  Enable <= Enable;
          	end

					//Now to the actually displaying the values to the screen
					//2 bit counter for controlling input to MUX
					always @(posedge clk5)
						begin
							if(reset)
								counterDisplay <= 1'b0;
							else if(Enable)
								counterDisplay <= counterDisplay + 1'b1;
							else
								counterDisplay <= counterDisplay;
						end

					//Segment MUX
					always @(counterDisplay)
						case(counterDisplay)
							2'b00: hexOutput = dispVal[3:0];
							2'b01: hexOutput = dispVal[7:4];
							2'b10: hexOutput = dispVal[11:8];
							2'b11: hexOutput = dispVal[15:12];
						endcase
					//Digit Display MUX
					always @(counterDisplay)
						case(counterDisplay)
							2'b00: digit = 8'b11111110;
							2'b01: digit = 8'b11111101;
							2'b10: digit = 8'b11111011;
							2'b11: digit = 8'b11110111;
						endcase

					hex2seg seg1 (.number (hexOutput),           // 4-bit number
												.pattern (segment[7:1])
												);


endmodule
