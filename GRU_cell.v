`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:28:06 12/07/2021 
// Design Name: 
// Module Name:    GRU_cell 
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
module GRU_cell#(parameter DATA_WIDTH = 8,
				parameter H=4,
				parameter X=4)
				(input clk1,
				 input clk2,
				 input signed [0:(X*DATA_WIDTH)-1]x,
				 input signed [0:(H*DATA_WIDTH)-1]H_tp_in,
				 output wire signed [0:(H*DATA_WIDTH)-1]H_t
				);
reg signed [0:(X*DATA_WIDTH)-1]Wx[0:(3*H)-1]; //registers for weights
reg signed [0:(H*DATA_WIDTH)-1]Wh[0:(3*H)-1]; //registers for weights
reg signed [DATA_WIDTH-1:0]b[0:(3*H)-1];		 //register for bias
reg signed [0:(X*H*DATA_WIDTH)-1]W1;		
reg signed [0:(H*H*DATA_WIDTH)-1]W2;	

wire signed [DATA_WIDTH-1:0]h_tp[0:H-1];
wire signed [DATA_WIDTH-1:0]out_v1[0:H-1];
wire signed [DATA_WIDTH-1:0]out_v2[0:H-1];
reg signed	[DATA_WIDTH-1:0]in_v2[0:H-1];
wire signed [0:(H*DATA_WIDTH)-1]out_v_1;
wire signed [0:(H*DATA_WIDTH)-1]out_v_2;
wire signed [0:(H*DATA_WIDTH)-1]in_v_2;

reg signed  [DATA_WIDTH-1:0]a_dot[0:H-1];
reg signed  [DATA_WIDTH-1:0]b_dot[0:H-1];
wire signed [DATA_WIDTH-1:0]out_dot[0:H-1];

reg signed  [DATA_WIDTH-1:0]in_sig[0:H-1];
wire signed [DATA_WIDTH-1:0]out_sig[0:H-1];
reg signed  [DATA_WIDTH-1:0]in_tan[0:H-1];
wire signed [DATA_WIDTH-1:0]out_tan[0:H-1];
wire signed [DATA_WIDTH-1:0]out_diff[0:H-1];

reg signed  [DATA_WIDTH-1:0]out1_2[0:H-1];
reg signed  [DATA_WIDTH-1:0]out2_3[0:H-1];
reg signed  [DATA_WIDTH-1:0]out3_4[0:H-1];
reg signed  [DATA_WIDTH-1:0]buffer[0:H-1];
reg signed  [DATA_WIDTH-1:0]out4_5[0:H-1];

integer j,start=0,count=0;
//assign clk2 = ~clk1;

genvar m;
generate for(m=0;m<H;m=m+1)
begin: loop
	sigmoid	#(.DATA_WIDTH(DATA_WIDTH))
				S(.out(out_sig[m]), .in(in_sig[m]));
	tanh		#(.DATA_WIDTH(DATA_WIDTH))
				T(.out(out_tan[m]), .in(in_tan[m]));	
	Diff		#(.DATA_WIDTH(DATA_WIDTH))
				diff(.out(out_diff[m]), .in(out2_3[m]));
	Dot_mult	#(.H(DATA_WIDTH))
				Dot(.result(out_dot[m]), .in1(a_dot[m]), .in2(b_dot[m]));	
//	assign out_dot[m]=a_dot[m]*b_dot[m];								
	assign h_tp[m]=H_tp_in[(m*DATA_WIDTH)+:DATA_WIDTH];
	assign H_t[(m*DATA_WIDTH)+:DATA_WIDTH]=out4_5[m];
	assign in_v_2[(m*DATA_WIDTH)+:DATA_WIDTH]=in_v2[m];
	assign out_v1[m] = out_v_1[(m*DATA_WIDTH)+:DATA_WIDTH];
	assign out_v2[m] = out_v_2[(m*DATA_WIDTH)+:DATA_WIDTH];
	end
endgenerate

mult_n_bit	#(.X(X),.H(H),.DATA_WIDTH(DATA_WIDTH))
					mul_1(.c_out(out_v_1), .b_in(x), .a_in(W1));
mult_n_bit	#(.X(H),.H(H),.DATA_WIDTH(DATA_WIDTH))
					mul_2(.c_out(out_v_2), .b_in(in_v_2), .a_in(W2));

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
always@(posedge clk1)		//stage 1
begin
	if(count==2)
		begin
		count<=0;
		for(j=0;j<H;j=j+1)
			in_v2[j]<=out3_4[j];
		end
	else
		begin
		count<=count+1;
		for(j=0;j<H;j=j+1)
			in_v2[j]<=h_tp[j];
		end
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
	if(count!=0)
		begin
		for(j=0;j<H;j=j+1)
			begin
			in_sig[j]<= out1_2[j];
			out2_3[j]<= out_sig[j];
			end
		end
	else
		begin
		for(j=0;j<H;j=j+1)
			begin
			in_tan[j]<= out1_2[j];
			out2_3[j]<= out_tan[j];			
			end
		end
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always@(posedge clk1)		//stage 3
begin
if(start==1)
	begin
		for(j=0;j<H;j=j+1)
			out3_4[j]<=out_dot[j];
		case(count)
		1:begin
				for(j=0;j<H;j=j+1)
					begin
					a_dot[j]<=out2_3[j];
					b_dot[j]<=h_tp[j];
					end
		  end
		2:begin
				for(j=0;j<H;j=j+1)
					begin
					a_dot[j]<=out_diff[j];
					b_dot[j]<=h_tp[j];
					buffer[j]<=out2_3[j];
					end
		  end
		0:begin
				for(j=0;j<H;j=j+1)
					begin
					a_dot[j]<=out2_3[j];
					b_dot[j]<=buffer[j];
					end
		  end
		endcase
	end
end	

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
always@(posedge clk2)		//stage 4
begin
   if(count==1)
		begin
		for(j=0;j<H;j=j+1)
			out4_5[j]<=8'b0;
		end
   else
		begin
		for(j=0;j<H;j=j+1)
			out4_5[j]<=out4_5[j]+out3_4[j];
		end
end

endmodule
				