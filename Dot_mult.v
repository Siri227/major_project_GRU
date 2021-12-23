`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:47:23 12/22/2021 
// Design Name: 
// Module Name:    Dot_mult 
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
module Dot_mult#(parameter H=8)(in1, in2, result);

input [H-1:0] in1,in2;
output [(2*H)-1:0] result;
wire [H-1:0] t1,t2;


applowergeneric inacc1(in1,in2,t1);
dadda8x8upper acc1(in1,in2,t2);

assign result= {t2,t1};

endmodule