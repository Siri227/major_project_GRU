`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:47:55 01/01/2022 
// Design Name: 
// Module Name:    mult_n_bit_accurate 
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
module mult_n_bit_accurate#(parameter X=4, H=4, DATA_WIDTH = 8)
						(
						input [0:(X*H*DATA_WIDTH)-1]a_in,
						input [0:(X*DATA_WIDTH)-1]b_in,
						output wire signed[0:(H*DATA_WIDTH)-1]c_out
						);

wire [DATA_WIDTH-1:0] A[0:H-1][0:X-1];
wire [DATA_WIDTH-1:0] B[0:X-1];
wire [(2*DATA_WIDTH)+1:0] C[0:H-1];
wire [2*DATA_WIDTH-1:0] prod[0:H-1][0:X-1];

genvar m,n;
generate for(m=0;m<H;m=m+1)
begin: loop1
	for(n=0;n<X;n=n+1)
	begin: loop2
		assign A[m][n]=a_in[(((m*X)+n)*DATA_WIDTH)+:DATA_WIDTH];
	end
		assign c_out[(m*DATA_WIDTH)+:DATA_WIDTH]=C[m][11-:DATA_WIDTH];
end
endgenerate

genvar p;
generate for(p=0;p<X;p=p+1)
begin: loop3
assign B[p]=b_in[(p*DATA_WIDTH)+:DATA_WIDTH];
end
endgenerate

genvar i,j;
generate
for(i = 0;i < H;i = i+1)
begin:loop4
	for(j = 0;j<X;j = j+1)
	begin:loop5
		dadda_8(.A(A[i][j]),.B(B[j]),.y(prod[i][j]));
	end
end

for(i = 0;i<H;i = i+1)
begin:loop6
	assign C[i] = prod[i][0] + prod[i][1] + prod[i][2]+ prod[i][3];
end

endgenerate

endmodule
