`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:28:59 12/07/2021 
// Design Name: 
// Module Name:    sigmoid 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module sigmoid#(parameter DATA_WIDTH = 8)
				   (input signed [DATA_WIDTH-1:0]in,
					 output reg signed [DATA_WIDTH-1:0]out
					 );

always@(*)
begin
if(in<8'b10110000)
 out = 8'b0;
else if(8'b10110000<=in<8'b11011010)
 out = 8'b00000010-(in>>>32);
else if(8'b11011010<=in<8'b11110000)
 out = 8'b00000110-(in>>>8);
else if(8'b11110000<=in<8'b0)
 out = 8'b00001100-(in>>>4);
else if(8'b0<=in<8'b00010000)
 out = 8'b00000100+(in>>>4);
else if(8'b00010000<=in<8'b00100110)
 out = 8'b00001010+(in>>>8);
else if(8'b00100110<=in<8'b01010000)
 out = 8'b00001101+(in>>>32);
else if(in>8'b01010000)
 out = 8'b00010000;
end
endmodule
