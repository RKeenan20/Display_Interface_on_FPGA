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


module DisplayInterface(input clk5,								//5MHz clock
												input reset,							//Synchronous Reset
												input [3:0] point,				//Point Marker Controller
												input [15:0] dispVal,			//Display Value to display
												output reg [7:0] digit,		//Controls the 8 separate digits on the display
												output [7:0] segment			//Controls each individual segment on one digit
												);

					localparam  compare = 1023; 						//Want to output on 1023rd clock cycle = 4.88kHz
          reg [9:0] countClkDiv;									//This is the Counter for our clock divider
					reg [1:0] counterDisplay;								//The 2 bit counter that cycles the 4 digits
					reg Enable;															//Enable input to 2 bit counter upon 1023rd edge
					reg [3:0] hexOutput;										//Output from segment MUX
					reg pointOn;														//Flag Variable for the Point Markers

					//Clock Divider Counter/11 bit
          always @(posedge clk5)
          	begin
          			if(reset)
              		countClkDiv <= 10'b0;
									Enable <= 1'b0;
                else if (countClkDiv == compare) //Once it hits 1023, set back to zero to count again
                  countClkDiv <= 10'b0;
									Enable <= 1'b1;									//Enable set high so our 2 bit counter can count
								else
                  countClkDiv <= countClkDiv + 1'b1;	//Else keep counting up by 1 with Enable off
									Enable <= 1'b0;
						end

					//Now to actually displaying the values to the screen
					//2 bit counter for controlling input to MUXs
					always @(posedge clk5)
						begin
							if(reset)
								counterDisplay <= 1'b0;
							else if(Enable)
								counterDisplay <= counterDisplay + 1'b1;		//If Enable is 1, increment by 1
							else
								counterDisplay <= counterDisplay;						//Else hold Value
						end

					//Segment MUX
					always @(counterDisplay, dispVal)
						case(counterDisplay)
							2'b00: hexOutput = dispVal[3:0];							//Set Hexoutput to 4bits of dispVal
							2'b01: hexOutput = dispVal[7:4];							//These 4 bits will be process by hex2seg
							2'b10: hexOutput = dispVal[11:8];
							2'b11: hexOutput = dispVal[15:12];
						endcase

					//Digit Display MUX
					always @(counterDisplay,point)
						case(counterDisplay)
							2'b00: begin
											digit = 8'b11111110;									//On the first digit on the right
											if(point[0] == 1'b1)									//If user has selected for first point marker to be on
												pointOn = 1'b1;											//Set pointOn = 1, else =0
											else
												pointOn = 1'b0;
										 end
							2'b01: begin
											digit = 8'b11111101;
											if(point[1] == 1'b1)
												pointOn = 1'b1;
											else
												pointOn = 1'b0;
										 end
							2'b10: begin
											digit = 8'b11111011;
											if(point[2] == 1'b1)
												pointOn = 1'b1;
											else
												pointOn = 1'b0;
										 end
							2'b11: begin
											digit = 8'b11110111;
											if(point[3] == 1'b1)
												pointOn = 1'b1;
											else
												pointOn = 1'b0;
										end
						endcase

						assign segment[0] = ~pointOn;									//Assign point marker value - Active Low

						//Instantiation of hex2seg for 4 bits of hexOutput and left 7 bits of segment
						hex2seg seg1 (.number(hexOutput),
													.pattern (segment[7:1])
													);

endmodule
