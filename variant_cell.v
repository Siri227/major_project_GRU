`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:27:08 12/22/2021 
// Design Name: 
// Module Name:    variant_cell 
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
module variant_cell#(parameter DATA_WIDTH = 8,
							parameter H=4,
							parameter X=4)
							(input clk1,
							 input clk2,
							 input signed [0:(X*DATA_WIDTH)-1]x,
							 input signed [0:(H*DATA_WIDTH)-1]C_tp_in,
							 input signed [0:(H*DATA_WIDTH)-1]H_tp_in,
							 output reg signed [0:(H*DATA_WIDTH)-1]C_t,
							 output reg signed [0:(H*DATA_WIDTH)-1]H_t
							);

reg signed [0:(X*DATA_WIDTH)-1]Wx[0:(3*H)-1]; 
reg signed [0:(H*DATA_WIDTH)-1]Wh[0:(3*H)-1];
reg signed [DATA_WIDTH-1:0]b[0:(3*H)-1];
reg signed [0:(X*H*DATA_WIDTH)-1]W1;
reg signed [0:(H*H*DATA_WIDTH)-1]W2;

wire signed [DATA_WIDTH-1:0]c_tp[0:H-1];
wire signed [DATA_WIDTH-1:0]h_tp[0:H-1];

wire signed [DATA_WIDTH-1:0]out_v1[0:H-1];
wire signed [DATA_WIDTH-1:0]out_v2[0:H-1];
wire signed [0:(H*DATA_WIDTH)-1]out_v_1;
wire signed [0:(H*DATA_WIDTH)-1]out_v_2;

reg signed  [DATA_WIDTH-1:0]a_dot[0:H-1];
reg signed  [DATA_WIDTH-1:0]b_dot[0:H-1];
wire signed [DATA_WIDTH-1:0]out_dot[0:H-1];

reg signed  [DATA_WIDTH-1:0]in_sig[0:H-1];
wire signed [DATA_WIDTH-1:0]out_sig[0:H-1];
reg signed  [DATA_WIDTH-1:0]in_tan1[0:H-1];
wire signed [DATA_WIDTH-1:0]out_tan1[0:H-1];
wire signed [DATA_WIDTH-1:0]in_tan2[0:H-1];
wire signed [DATA_WIDTH-1:0]out_tan2[0:H-1];

reg signed  [DATA_WIDTH-1:0]out1_2[0:H-1];
reg signed  [DATA_WIDTH-1:0]out2_3[0:H-1];
reg signed  [DATA_WIDTH-1:0]out3_4[0:H-1];
reg signed  [DATA_WIDTH-1:0]buffer[0:H-1];
reg signed  [DATA_WIDTH-1:0]buffer2[0:H-1];
reg signed  [DATA_WIDTH-1:0]out4_5[0:H-1];

integer j,k=0, start=0, count=0;

//assign clk2=~clk1;

genvar m;
generate for(m=0;m<H;m=m+1)
begin: loop
	sigmoid    	S(.out(out_sig[m]), .in(in_sig[m]));
	tanh		  	T1(.out(out_tan1[m]), .in(in_tan1[m]));	
	tanh		  	T2(.out(out_tan2[m]), .in(in_tan2[m]));	
	Dot_mult	#(.H(DATA_WIDTH))Dot(.result(out_dot[m]), .in1(a_dot[m]), .in2(b_dot[m]));	
//	assign out_v3[m]=a_v[m]*b_v[m];								
	assign h_tp[m]=H_tp_in[(m*DATA_WIDTH)+:DATA_WIDTH];
	assign c_tp[m]=C_tp_in[(m*DATA_WIDTH)+:DATA_WIDTH];
//assign H_t[(m*DATA_WIDTH)+:DATA_WIDTH]=out5_6_2[m];
	assign in_tan2[m]=C_t[(m*DATA_WIDTH)+:DATA_WIDTH];
	assign out_v1[m] = out_v_1[(m*DATA_WIDTH)+:DATA_WIDTH];
	assign out_v2[m] = out_v_2[(m*DATA_WIDTH)+:DATA_WIDTH];
	end
endgenerate

mult_n_bit	#(.X(X),.H(H),.DATA_WIDTH(DATA_WIDTH))
					mul_1(.c_out(out_v_1), .b_in(x), .a_in(W1));
mult_n_bit	#(.X(H),.H(H),.DATA_WIDTH(DATA_WIDTH))
					mul_2(.c_out(out_v_2), .b_in(H_tp_in), .a_in(W2));
	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
always@(posedge clk1)		//stage 1
begin
	if(count==2)
		count<=0;
	else
		count<=count+1;
	start<=1;
	for(j=0;j<H;j=j+1)
		begin
		W1[(j*X*DATA_WIDTH)+:(X*DATA_WIDTH)]<=Wx[j+(count*H)];
		W2[(j*H*DATA_WIDTH)+:(H*DATA_WIDTH)]<=Wh[j+(count*H)];
		out1_2[j]<= out_v1[j]+out_v2[j]+b[j+(count*H)];
		end
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
always@(posedge clk2)		//stage 2
begin
	if(count==2)
		begin
		for(j=0;j<H;j=j+1)
			begin
			in_tan1[j]<= out1_2[j];
			out2_3[j]<= out_tan1[j];			
			end
		end
	else
		begin
		for(j=0;j<H;j=j+1)
			begin
			in_sig[j]<= out1_2[j];
			out2_3[j]<= out_sig[j];
			end
		end
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
always@(posedge clk1)		//stage 3
begin
if(start==1)
	begin
		case(count)
		1:begin
				for(j=0;j<H;j=j+1)
					begin
					a_dot[j]<=out2_3[j];
					b_dot[j]<=c_tp[j];
					out3_4[j]<=out_dot[j];
					buffer[j]<=8'b00010000-out2_3[j];
					k<=1;
					end
		  end
		2:begin
				for(j=0;j<H;j=j+1)
					begin
					a_dot[j]<=out2_3[j];
					b_dot[j]<=buffer[j];
					out3_4[j]<=out_dot[j];
					k<=2;
					end
		  end
		0:begin
				for(j=0;j<H;j=j+1)
					begin
					a_dot[j]<=out2_3[j];
					b_dot[j]<=out_tan2[j];
					out3_4[j]<=out_dot[j];
					k<=3;
					end
		  end
		 endcase
	end
end	
	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
always@(posedge clk2)		//stage 4
begin
		case(k)
		1:begin
				for(j=0;j<H;j=j+1)
					buffer2[j]<=out3_4[j];
		  end
		2:begin
				for(j=0;j<H;j=j+1)
					C_t[(j*DATA_WIDTH)+:DATA_WIDTH]<=buffer2[j]+out3_4[j];
		  end
		3:begin
				for(j=0;j<H;j=j+1)
					H_t[(j*DATA_WIDTH)+:DATA_WIDTH]<=out3_4[j];
		  end
		 endcase
end

endmodule
