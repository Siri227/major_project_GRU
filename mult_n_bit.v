`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:30:52 12/07/2021 
// Design Name: 
// Module Name:    mult_n_bit 
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
module mult_n_bit#(parameter X=4, H=4, DATA_WIDTH = 8)
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
		//upper bits
		dadda4x4mul8b init1(A[i][0],B[0],A[i][1],B[1],A[i][2],B[2],A[i][3],B[3],C[i][17:7]);
		//lower bits
		lower4x4app8b init2(A[i][0][6:0],B[0][6:0],A[i][1][6:0],B[1][6:0],
										A[i][2][6:0],B[2][6:0],A[i][3][6:0],B[3][6:0],C[i][6:0]);
end
endgenerate

endmodule

///////////////////////////////////////////////////////////////////////////////////////////

module dadda4x4mul8b( op1,op2,op3,op4,op5,op6,op7,op8,res  );

input [7:0] op1,op2,op3,op4,op5,op6,op7,op8;
output [10:0] res;

wire [7:0] pp[0:7];
//level 1
wire [7:0] n[0:1];
wire [7:0] m[0:1];
//level 2
wire [7:0] p[0:1];
wire [7:1] q[0:1];
//level 3
wire [8:0] k[0:1];
//level 4
wire [8:1] s[0:1];
//level 5
wire [9:3] crr;

dadda8x8upper init1(op1,op2,{pp[0],pp[1]});
dadda8x8upper init2(op3,op4,{pp[2],pp[3]});
dadda8x8upper init3(op5,op6,{pp[4],pp[5]});
dadda8x8upper init4(op7,op8,{pp[6],pp[7]});

genvar i;
generate for(i = 0;i<8;i = i+1)//level 1
begin:level_1
	FA fa1n(.a(pp[0][i]),.b(pp[1][i]),.cin(pp[2][i]),.sum(n[0][i]),.cout(n[1][i]));
	FA fa1m(.a(pp[3][i]),.b(pp[4][i]),.cin(pp[5][i]),.sum(m[0][i]),.cout(m[1][i]));
end

//level 2
for(i = 0;i<8;i = i+1)
begin:level_2_p
	FA fa2p(.a(pp[6][i]),.b(pp[7][i]),.cin(n[0][i]),.sum(p[0][i]),.cout(p[1][i]));
end

for(i = 1;i<8;i = i+1)
begin:level_2_q
	FA fa2q(.a(n[1][i-1]),.b(m[0][i]),.cin(m[1][i-1]),.sum(q[0][i]),.cout(q[1][i]));
end

//level 3
HA ha30(.a(p[0][0]),.b(m[0][0]),.sum(k[0][0]),.cout(k[1][0]));

for(i = 1;i<8;i = i+1)
begin:level_3
	FA fa3k(.a(p[0][i]),.b(p[1][i-1]),.cin(q[0][i]),.sum(k[0][i]),.cout(k[1][i]));
end
FA fa38(.a(n[1][7]),.b(p[1][7]),.cin(m[1][7]),.sum(k[0][8]),.cout(k[1][8]));

assign res[0] = k[0][0];

//level 4
HA ha41(.a(k[0][1]),.b(k[1][0]),.sum(s[0][1]),.cout(s[1][1]));
for(i = 2;i<9;i = i+1)
begin:level_4
	FA fa4s(.a(k[0][i]),.b(k[1][i-1]),.cin(q[1][i-1]),.sum(s[0][i]),.cout(s[1][i]));
end
//FA ha416(.a(k[0][16]),.b(k[1][15]),.cin(m[1][15]),.sum(s[0][16]),.cout(s[1][16]));

assign res[1] = s[0][1];

//level 5
HA ha52(.a(s[0][2]),.b(s[1][1]),.sum(res[2]),.cout(crr[3]));

for(i = 3;i<9;i = i+1)
begin:level_5
	FA fa5r(.a(s[0][i]),.b(s[1][i-1]),.cin(crr[i]),.sum(res[i]),.cout(crr[i+1]));
end

FA fa59(.a(k[1][8]),.b(s[1][8]),.cin(crr[9]),.sum(res[9]),.cout(res[10]));
endgenerate


endmodule

///////////////////////////////////////////////////////////////////////////////////////////

module dadda8x8upper(  a,b,pp  );

input [7:0] a,b;
output [15:0] pp;

wire [35:0] p;
wire [9:7] n1 [1:0];
wire [10:8] q2 [1:0];
wire [11:7] n2 [1:0];
wire [12:7] n3 [1:0];
wire [13:7] n4 [1:0];

genvar i,j;
generate
for(i = 0;i<8;i= i+1)
begin:loop_a
	for(j = 0;j <= i;j = j+1)
	begin:loop_b
		assign p[((i*(i+1))/2) + j] = a[i]&b[7-i+j];
	end
end
endgenerate

// level 1
FA fa01(p[28],p[21],p[15],n1[0][7],n1[1][7]);
FA fa02(p[29],p[22],p[16],n1[0][8],n1[1][8]);
HA ha01(p[30],p[23],n1[0][9],n1[1][9]);

//leve2
FA fa11(p[10],p[6],p[3],n2[0][7],n2[1][7]);
FA fa12(p[11],p[7],p[4],n2[0][8],n2[1][8]);
FA fa13(p[17],p[12],p[8],n2[0][9],n2[1][9]);
FA fa14(p[31],p[24],p[18],n2[0][10],n2[1][10]);
FA fa15(p[32],p[25],p[19],n2[0][11],n2[1][11]);

HA ha11(p[2],n1[0][8],q2[0][8],q2[1][8]);
FA fa16(p[5],n1[0][9],n1[1][8],q2[0][9],q2[1][9]);
FA fa17(p[13],p[9],n1[1][9],q2[0][10],q2[1][10]);

//level 3
HA ha21(p[1],p[0],n3[0][7],n3[1][7]);
FA fa21(n2[0][8],n2[1][7],q2[0][8],n3[0][8],n3[1][8]);
FA fa22(n2[0][9],n2[1][8],q2[0][9],n3[0][9],n3[1][9]);
FA fa23(n2[0][10],n2[1][9],q2[0][10],n3[0][10],n3[1][10]);
FA fa24(p[14],n2[0][11],n2[1][10],n3[0][11],n3[1][11]);
FA fa25(p[33],p[26],p[20],n3[0][12],n3[1][12]);

//level4
HA ha31(n2[0][7],n1[0][7],n4[0][7],n4[1][7]);
FA fa31(n1[1][7],n3[0][8],n3[1][7],n4[0][8],n4[1][8]);
FA fa32(q2[1][8],n3[0][9],n3[1][8],n4[0][9],n4[1][9]);
FA fa33(q2[1][9],n3[0][10],n3[1][9],n4[0][10],n4[1][10]);
FA fa34(q2[1][10],n3[0][11],n3[1][10],n4[0][11],n4[1][11]);
FA fa35(n2[1][11],n3[0][12],n3[1][11],n4[0][12],n4[1][12]);
FA fa36(p[34],p[27],n3[1][12],n4[0][13],n4[1][13]);

//assign c = {p[35],n4[0]} + {n4[1],n3[0][7]};	// to use fast addr like eta2
assign pp = {p[35],n4[0],n4[1],n3[0][7]};

endmodule

///////////////////////////////////////////////////////////////////////////////////////////

module FA( a,b,cin,sum,cout  );

input a,b,cin;
output sum,cout;

wire s1,c1,c2;

xor(s1,a,b);
xor(sum,s1,cin);
and(c1,a,b);
and(c2,s1,cin);
or(cout,c1,c2);

endmodule

module HA(a,b,sum,cout    );

input a,b;
output sum,cout;

and(cout,a,b);
xor(sum,a,b);

endmodule

///////////////////////////////////////////////////////////////////////////////////////////

module lower4x4app8b( op1,op2,op3,op4,op5,op6,op7,op8,res  );

input [6:0] op1,op2,op3,op4,op5,op6,op7,op8;
output [6:0] res;

wire [6:0] pp[0:3];

applowergeneric #(7) init1(op1,op2,pp[0]);
applowergeneric #(7) init2(op3,op4,pp[1]);
applowergeneric #(7) init3(op5,op6,pp[2]);
applowergeneric #(7) init4(op7,op8,pp[3]);

genvar i;
generate
for(i = 0;i<7;i = i+1)
begin:or_array
	assign res[i] = pp[0][i]|pp[1][i]|pp[2][i]|pp[3][i];
end
endgenerate

endmodule

///////////////////////////////////////////////////////////////////////////////////////////
module applowergeneric #(parameter width = 7)( a,b,c );

input [width-1:0] a,b;
output [width-1:0] c;

wire [(width*(width+1)/2)-1:0] pp;	//lower byte partial product

//// lower byte approximation
genvar i,j;
generate 
for(i = 0;i<width;i = i+1)
begin:loop_1
	for(j = 0;j<=i;j = j+1)
	begin:loop_2
		//and2 init(a[i],b[j],pp[((i*(i+1))/2) + j]);
		assign pp[((i*(i+1))/2) + j] = a[i]&b[j];
	end
end
endgenerate

assign c[0] = pp[0];

genvar k;
generate 
for(k = 1;k<width;k = k+1)
begin:loop_3
	assign c[k] = |pp[(k*(k+3))/2:(k*(k+1))/2];
end
endgenerate

///// approximation ends
endmodule
