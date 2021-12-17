`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:10:28 12/14/2021 
// Design Name: 
// Module Name:    Diff 
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
module Diff#(parameter DATA_WIDTH = 8)
				(input [DATA_WIDTH-1:0]in,
				 output [DATA_WIDTH-1:0]out
				); 
assign out=8'b00010000 - in;
endmodule
