`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:31:03 01/01/2022 
// Design Name: 
// Module Name:    dadda_8 
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
// dadda multiplier
// A - 8 bits , B - 8bits, y(output) - 16bits

module dadda_8(A,B,y);
    
    input [7:0] A;
    input [7:0] B;
    output wire [15:0] y;
    wire  gen_pp [0:7][7:0];
// stage-1 sum and carry
    wire [0:5]s1,c1;
// stage-2 sum and carry
    wire [0:13]s2,c2;   
// stage-3 sum and carry
    wire [0:9]s3,c3;
// stage-4 sum and carry
    wire [0:11]s4,c4;
// stage-5 sum and carry
    wire [0:13]s5,c5;




// generating partial products 
genvar i;
genvar j;

for(i = 0; i<8; i=i+1)begin

   for(j = 0; j<8;j = j+1)begin
      assign gen_pp[i][j] = A[j]*B[i];
end
end

 

//Reduction by stages.
// di_values = 2,3,4,6,8,13...


//Stage 1 - reducing fom 8 to 6  


    HA h1(.a(gen_pp[6][0]),.b(gen_pp[5][1]),.sum(s1[0]),.cout(c1[0]));
    HA h2(.a(gen_pp[4][3]),.b(gen_pp[3][4]),.sum(s1[2]),.cout(c1[2]));
    HA h3(.a(gen_pp[4][4]),.b(gen_pp[3][5]),.sum(s1[4]),.cout(c1[4]));

    FA c11(.a(gen_pp[7][0]),.b(gen_pp[6][1]),.cin(gen_pp[5][2]),.sum(s1[1]),.cout(c1[1]));
    FA c12(.a(gen_pp[7][1]),.b(gen_pp[6][2]),.cin(gen_pp[5][3]),.sum(s1[3]),.cout(c1[3]));     
    FA c13(.a(gen_pp[7][2]),.b(gen_pp[6][3]),.cin(gen_pp[5][4]),.sum(s1[5]),.cout(c1[5]));
    
//Stage 2 - reducing fom 6 to 4

    HA h4(.a(gen_pp[4][0]),.b(gen_pp[3][1]),.sum(s2[0]),.cout(c2[0]));
    HA h5(.a(gen_pp[2][3]),.b(gen_pp[1][4]),.sum(s2[2]),.cout(c2[2]));


    FA c21(.a(gen_pp[5][0]),.b(gen_pp[4][1]),.cin(gen_pp[3][2]),.sum(s2[1]),.cout(c2[1]));
    FA c22(.a(s1[0]),.b(gen_pp[4][2]),.cin(gen_pp[3][3]),.sum(s2[3]),.cout(c2[3]));
    FA c23(.a(gen_pp[2][4]),.b(gen_pp[1][5]),.cin(gen_pp[0][6]),.sum(s2[4]),.cout(c2[4]));
    FA c24(.a(s1[1]),.b(s1[2]),.cin(c1[0]),.sum(s2[5]),.cout(c2[5]));
    FA c25(.a(gen_pp[2][5]),.b(gen_pp[1][6]),.cin(gen_pp[0][7]),.sum(s2[6]),.cout(c2[6]));
    FA c26(.a(s1[3]),.b(s1[4]),.cin(c1[1]),.sum(s2[7]),.cout(c2[7]));
    FA c27(.a(c1[2]),.b(gen_pp[2][6]),.cin(gen_pp[1][7]),.sum(s2[8]),.cout(c2[8]));
    FA c28(.a(s1[5]),.b(c1[3]),.cin(c1[4]),.sum(s2[9]),.cout(c2[9]));
    FA c29(.a(gen_pp[4][5]),.b(gen_pp[3][6]),.cin(gen_pp[2][7]),.sum(s2[10]),.cout(c2[10]));
    FA c210(.a(gen_pp[7][3]),.b(c1[5]),.cin(gen_pp[6][4]),.sum(s2[11]),.cout(c2[11]));
    FA c211(.a(gen_pp[5][5]),.b(gen_pp[4][6]),.cin(gen_pp[3][7]),.sum(s2[12]),.cout(c2[12]));
    FA c212(.a(gen_pp[7][4]),.b(gen_pp[6][5]),.cin(gen_pp[5][6]),.sum(s2[13]),.cout(c2[13]));
    
//Stage 3 - reducing fom 4 to 3

    HA h6(.a(gen_pp[3][0]),.b(gen_pp[2][1]),.sum(s3[0]),.cout(c3[0]));

    FA c31(.a(s2[0]),.b(gen_pp[2][2]),.cin(gen_pp[1][3]),.sum(s3[1]),.cout(c3[1]));
    FA c32(.a(s2[1]),.b(s2[2]),.cin(c2[0]),.sum(s3[2]),.cout(c3[2]));
    FA c33(.a(c2[1]),.b(c2[2]),.cin(s2[3]),.sum(s3[3]),.cout(c3[3]));
    FA c34(.a(c2[3]),.b(c2[4]),.cin(s2[5]),.sum(s3[4]),.cout(c3[4]));
    FA c35(.a(c2[5]),.b(c2[6]),.cin(s2[7]),.sum(s3[5]),.cout(c3[5]));
    FA c36(.a(c2[7]),.b(c2[8]),.cin(s2[9]),.sum(s3[6]),.cout(c3[6]));
    FA c37(.a(c2[9]),.b(c2[10]),.cin(s2[11]),.sum(s3[7]),.cout(c3[7]));
    FA c38(.a(c2[11]),.b(c2[12]),.cin(s2[13]),.sum(s3[8]),.cout(c3[8]));
    FA c39(.a(gen_pp[7][5]),.b(gen_pp[6][6]),.cin(gen_pp[5][7]),.sum(s3[9]),.cout(c3[9]));

//Stage 4 - reducing fom 3 to 2

    HA h7(.a(gen_pp[2][0]),.b(gen_pp[1][1]),.sum(s4[0]),.cout(c4[0]));


    FA c41(.a(s3[0]),.b(gen_pp[1][2]),.cin(gen_pp[0][3]),.sum(s4[1]),.cout(c4[1]));
    FA c42(.a(c3[0]),.b(s3[1]),.cin(gen_pp[0][4]),.sum(s4[2]),.cout(c4[2]));
    FA c43(.a(c3[1]),.b(s3[2]),.cin(gen_pp[0][5]),.sum(s4[3]),.cout(c4[3]));
    FA c44(.a(c3[2]),.b(s3[3]),.cin(s2[4]),.sum(s4[4]),.cout(c4[4]));
    FA c45(.a(c3[3]),.b(s3[4]),.cin(s2[6]),.sum(s4[5]),.cout(c4[5]));
    FA c46(.a(c3[4]),.b(s3[5]),.cin(s2[8]),.sum(s4[6]),.cout(c4[6]));
    FA c47(.a(c3[5]),.b(s3[6]),.cin(s2[10]),.sum(s4[7]),.cout(c4[7]));
    FA c48(.a(c3[6]),.b(s3[7]),.cin(s2[12]),.sum(s4[8]),.cout(c4[8]));
    FA c49(.a(c3[7]),.b(s3[8]),.cin(gen_pp[4][7]),.sum(s4[9]),.cout(c4[9]));
    FA c410(.a(c3[8]),.b(s3[9]),.cin(c2[13]),.sum(s4[10]),.cout(c4[10]));
    FA c411(.a(c3[9]),.b(gen_pp[7][6]),.cin(gen_pp[6][7]),.sum(s4[11]),.cout(c4[11]));
    
//Stage 5 - reducing fom 2 to 1
    // adding total sum and carry to get final output

    HA h8(.a(gen_pp[1][0]),.b(gen_pp[0][1]),.sum(y[1]),.cout(c5[0]));



    FA c51(.a(s4[0]),.b(gen_pp[0][2]),.cin(c5[0]),.sum(y[2]),.cout(c5[1]));
    FA c52(.a(c4[0]),.b(s4[1]),.cin(c5[1]),.sum(y[3]),.cout(c5[2]));
    FA c54(.a(c4[1]),.b(s4[2]),.cin(c5[2]),.sum(y[4]),.cout(c5[3]));
    FA c55(.a(c4[2]),.b(s4[3]),.cin(c5[3]),.sum(y[5]),.cout(c5[4]));
    FA c56(.a(c4[3]),.b(s4[4]),.cin(c5[4]),.sum(y[6]),.cout(c5[5]));
    FA c57(.a(c4[4]),.b(s4[5]),.cin(c5[5]),.sum(y[7]),.cout(c5[6]));
    FA c58(.a(c4[5]),.b(s4[6]),.cin(c5[6]),.sum(y[8]),.cout(c5[7]));
    FA c59(.a(c4[6]),.b(s4[7]),.cin(c5[7]),.sum(y[9]),.cout(c5[8]));
    FA c510(.a(c4[7]),.b(s4[8]),.cin(c5[8]),.sum(y[10]),.cout(c5[9]));
    FA c511(.a(c4[8]),.b(s4[9]),.cin(c5[9]),.sum(y[11]),.cout(c5[10]));
    FA c512(.a(c4[9]),.b(s4[10]),.cin(c5[10]),.sum(y[12]),.cout(c5[11]));
    FA c513(.a(c4[10]),.b(s4[11]),.cin(c5[11]),.sum(y[13]),.cout(c5[12]));
    FA c514(.a(c4[11]),.b(gen_pp[7][7]),.cin(c5[12]),.sum(y[14]),.cout(c5[13]));

    assign y[0] =  gen_pp[0][0];
    assign y[15] = c5[13];
    
  
    
endmodule 


