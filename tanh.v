`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:30:00 12/07/2021 
// Design Name: 
// Module Name:    tanh 
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
module tanh#(	parameter DATA_WIDTH = 8)
				(	input signed [DATA_WIDTH-1:0]in,
					output reg signed [DATA_WIDTH-1:0]out
					);

wire signed[DATA_WIDTH-1:0]r;	
sigmoid #(.DATA_WIDTH(DATA_WIDTH))
			A(.out(r), .in(in<<1));	
always@(*)
 out = (r<<1)-8'b00010000;
endmodule
