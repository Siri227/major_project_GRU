`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:07:04 12/14/2021 
// Design Name: 
// Module Name:    mult_n_bit6 
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
module mult_n_bit6#(parameter X=6, H=6, DATA_WIDTH = 8)
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
		dadda6x6mul8b init1(A[i][0],B[0],A[i][1],B[1],A[i][2],B[2],A[i][3],B[3],A[i][4],B[4],A[i][5],B[5],C[i][17:7]);
		// approx lower or gate matrix
		lower6x6app8b init2(A[i][0][6:0],B[0][6:0],A[i][1][6:0],B[1][6:0],A[i][2][6:0],B[2][6:0],A[i][3][6:0],B[3][6:0],A[i][4][6:0],B[4][6:0],A[i][5][6:0],B[5][6:0],C[i][6:0]);
end
endgenerate

endmodule

module dadda6x6mul8b( op1,op2,op3,op4,op5,op6,op7,op8,op9,op10,op11,op12,res
    );
input [7:0] op1,op2,op3,op4,op5,op6,op7,op8,op9,op10,op11,op12;
output [11:0] res;

wire [7:0] pp[0:11];
//layer1
wire [7:0] m[0:3];
wire [8:1] n[0:3];
//layer2
wire [7:0] p[0:1];
wire [7:0] q[0:1];
//layer3
wire [7:0] r[0:1];
wire [7:0] s[0:1];
//layer4
wire [7:0] k[0:1];
//layer5
wire [7:0] z[0:1];
//layer6-rca
wire [6:0] cr;

dadda8x8upper init1(op1,op2,{pp[0],pp[1]});
dadda8x8upper init2(op3,op4,{pp[2],pp[3]});
dadda8x8upper init3(op5,op6,{pp[4],pp[5]});
dadda8x8upper init4(op7,op8,{pp[6],pp[7]});
dadda8x8upper init5(op9,op10,{pp[8],pp[9]});
dadda8x8upper init6(op11,op12,{pp[10],pp[11]});

genvar i,j;
generate;
// level 1
for(i = 0;i<=7;i = i+1)
begin:level_1_i
	for(j = 0;j<=3;j = j+1)
	begin:level_1_j
		FA fa1nm(.a(pp[3*j][i]),.b(pp[3*j+1][i]),.cin(pp[3*j+2][i]),.sum(m[j][i]),.cout(n[j][i+1]));
	end
end

//layer 2
for(i = 0;i<=7;i=i+1)
begin:level_2
	FA fa20(.a(m[0][i]),.b(m[1][i]),.cin(m[2][i]),.sum(p[0][i]),.cout(q[0][i]));
	FA fa21(.a(n[0][i+1]),.b(n[1][i+1]),.cin(n[2][i+1]),.sum(p[1][i]),.cout(q[1][i]));
end

//layer 3
HA ha20(.a(p[0][0]),.b(m[3][0]),.sum(s[0][0]),.cout(r[0][0]));
HA ha21(.a(q[0][0]),.b(n[3][1]),.sum(s[1][0]),.cout(r[1][0]));
for(i = 1;i<8;i = i+1)
begin:level_3
	FA fa30(.a(p[0][i]),.b(m[3][i]),.cin(p[1][i-1]),.sum(s[0][i]),.cout(r[0][i]));
	FA fa31(.a(q[0][i]),.b(n[3][i+1]),.cin(q[1][i-1]),.sum(s[1][i]),.cout(r[1][i]));
end

//layer 4
for(i = 0;i<=6;i = i+1)
begin:level_4
	FA fa4(.a(s[0][i+1]),.b(s[1][i]),.cin(r[0][i]),.sum(k[0][i]),.cout(k[1][i]));
end
FA fa47(.a(p[1][7]),.b(s[1][7]),.cin(r[0][7]),.sum(k[0][7]),.cout(k[1][7]));

//layer 5
for(i = 0; i<= 6;i = i+1)
begin:level_5
	FA fa5(.a(k[0][i+1]),.b(k[1][i]),.cin(r[1][i]),.sum(z[0][i]),.cout(z[1][i]));
end
FA fa57(.a(q[1][7]),.b(k[1][7]),.cin(r[1][7]),.sum(z[0][7]),.cout(z[1][7]));

//layer 6
assign res[0] = s[0][0];
assign res[1] = k[0][0];
assign res[2] = z[0][0];

HA ha53(.a(z[0][1]),.b(z[1][0]),.sum(res[3]),.cout(cr[0]));
for(i = 1;i<=6;i = i+1)
begin:level_6_rca
		FA fa6(.a(z[0][i+1]),.b(z[1][i]),.cin(cr[i-1]),.sum(res[i+3]),.cout(cr[i]));
end
HA ha510(.a(z[1][7]),.b(cr[6]),.sum(res[10]),.cout(res[11]));

endgenerate


endmodule

module lower6x6app8b( op1,op2,op3,op4,op5,op6,op7,op8,op9,op10,op11,op12,res
    );
input [6:0] op1,op2,op3,op4,op5,op6,op7,op8,op9,op10,op11,op12;
output [6:0] res;

wire [6:0] pp [0:5];

applowergeneric #(7) init1(op1,op2,pp[0]);
applowergeneric #(7) init2(op3,op4,pp[1]);
applowergeneric #(7) init3(op5,op6,pp[2]);
applowergeneric #(7) init4(op7,op8,pp[3]);
applowergeneric #(7) init5(op9,op10,pp[4]);
applowergeneric #(7) init6(op11,op12,pp[5]);

genvar i;
generate
for(i = 0;i<7;i = i+1)
begin:or_array
	assign res[i] = pp[0][i]|pp[1][i]|pp[2][i]|pp[3][i]|pp[4][i]|pp[5][i];
end
endgenerate


endmodule
