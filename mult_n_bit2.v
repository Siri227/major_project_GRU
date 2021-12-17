`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:03:58 12/14/2021 
// Design Name: 
// Module Name:    mult_n_bit2 
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
module mult_n_bit2#(parameter X=2, H=2, DATA_WIDTH = 8)
						(
						input [0:(X*H*DATA_WIDTH)-1]a_in,
						input [0:(X*DATA_WIDTH)-1]b_in,
						output wire signed[0:(H*DATA_WIDTH)-1]c_out
						);

wire [DATA_WIDTH-1:0] A[0:H-1][0:X-1];
wire [DATA_WIDTH-1:0] B[0:X-1];
wire [(2*DATA_WIDTH)+1:0] C[0:H-1];

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

genvar i;
generate
for(i = 0;i < H;i = i+1)
begin:loop
		// exact upper part
		dadda_testing init1(A[i][0],B[0],A[i][1],B[1],C[i][16:7]);
		// approx lower or gate matrix
		lower2x2app8b init2(A[i][0][6:0],B[0][6:0],A[i][1][6:0],B[1][6:0],C[i][6:0]);
end
endgenerate

endmodule

module dadda_testing( op1,op2,op3,op4,res   );

input [7:0] op1,op2,op3,op4;
output [9:0] res;

wire [7:0] pp[0:3];
wire [7:0] n[0:1];
wire [7:0] m[0:1];
wire [8:2] carry;

dadda8x8upper init1(op1,op2,{pp[0],pp[1]});
dadda8x8upper init2(op3,op4,{pp[2],pp[3]});

genvar i;
generate
for(i = 0;i<8;i = i+1)
begin:loop_a
	FA fa1(.a(pp[0][i]),.b(pp[1][i]),.cin(pp[2][i]),.sum(n[0][i]),.cout(n[1][i]));
end

HA ha2(.a(n[0][1]),.b(pp[3][0]),.sum(m[0][0]),.cout(m[1][0]));
for(i = 1;i<8;i=i+1)
begin:loop_b
	FA fa2(.a(n[0][i]),.b(n[1][i-1]),.cin(pp[3][i]),.sum(m[0][i]),.cout(m[1][i]));
end

assign res[0] = m[0][0];
HA ha3(.a(m[0][1]),.b(m[1][0]),.sum(res[1]),.cout(carry[2]));
for(i = 2;i<=7;i = i+1)
begin:loop_c
	FA fa3(.a(m[0][i]),.b(m[1][i-1]),.cin(carry[i]),.sum(res[i]),.cout(carry[i+1]));
end

endgenerate
FA fa4(.a(n[1][7]),.b(m[1][7]),.cin(carry[8]),.sum(res[8]),.cout(res[9]));

endmodule

module lower2x2app8b( op1,op2,op3,op4,res   );

input [6:0] op1,op2,op3,op4;
output [6:0] res;

wire [6:0] pp[0:1];

applowergeneric #(7) init1(op1,op2,pp[0]);
applowergeneric #(7) init2(op3,op4,pp[1]);

genvar i;
generate
for(i = 0;i<7;i = i+1)
begin:or_array
	assign res[i] = pp[0][i]|pp[1][i];
end
endgenerate


endmodule
