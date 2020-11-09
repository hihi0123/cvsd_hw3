// modules for choose the median
//moduele for only 3 numbers
module sort_3_number(

	input [7:0] num1,
	input [7:0] num2,
	input [7:0] num3,

	output [7:0] max,
	output [7:0] mid,
	output [7:0] min

);

reg [7:0] next_max,next_mid,next_min;
assign max = next_max;
assign mid = next_mid;
assign min = next_min;

always@(*)begin
	if(num1>=num2)begin
		if(num2>=num3)begin
			next_max = num1;
			next_mid = num2;
			next_min = num3;
		end
		else begin    //num3>num2
			if(num1>=num3)begin 
				next_max = num1;
				next_mid = num3;
				next_min = num2;
			end
			else begin   //num3>num1
				next_max = num3;
				next_mid = num1;
				next_min = num2;
			end
		end		
	end
	else begin //num2>num1
		if(num1>=num3)begin
			next_max = num2;
			next_mid = num1;
			next_min = num3;
		end
		else begin //num3>num1
			if(num2>=num3)begin
				next_max = num2;
				next_mid = num3;
				next_min = num1;
			end
			else begin //num3>num2
				next_max = num3;
				next_mid = num2;
				next_min = num1;
			end
		end
	end	




end

endmodule


//module for sort row
module sort_row(
	input [7:0] i_position_1_1,
	input [7:0] i_position_2_1,
	input [7:0] i_position_3_1,

	input [7:0] i_position_1_2,
	input [7:0] i_position_2_2,
	input [7:0] i_position_3_2,

	input [7:0] i_position_1_3,
	input [7:0] i_position_2_3,
	input [7:0] i_position_3_3,

	output [7:0] o_position_1_1,
	output [7:0] o_position_2_1,
	output [7:0] o_position_3_1,

	output [7:0] o_position_1_2,
	output [7:0] o_position_2_2,
	output [7:0] o_position_3_2,

	output [7:0] o_position_1_3,
	output [7:0] o_position_2_3,
	output [7:0] o_position_3_3
);

wire [7:0] max_1,mid_1,min_1;
wire [7:0] max_2,mid_2,min_2;
wire [7:0] max_3,mid_3,min_3;

sort_3_number s_1(
	.num1(i_position_1_1),
	.num2(i_position_2_1),
	.num3(i_position_3_1),

	.max(max_1),
	.mid(mid_1),
	.min(min_1)	
);
sort_3_number s_2(
	.num1(i_position_1_2),
	.num2(i_position_2_2),
	.num3(i_position_3_2),

	.max(max_2),
	.mid(mid_2),
	.min(min_2)	
);
sort_3_number s_3(
	.num1(i_position_1_3),
	.num2(i_position_2_3),
	.num3(i_position_3_3),

	.max(max_3),
	.mid(mid_3),
	.min(min_3)	
);


assign o_position_1_1 = max_1;
assign o_position_2_1 = mid_1;
assign o_position_3_1 = min_1;

assign o_position_1_2 = max_2;
assign o_position_2_2 = mid_2;
assign o_position_3_2 = min_2;

assign o_position_1_3 = max_3;
assign o_position_2_3 = mid_3;
assign o_position_3_3 = min_3;

endmodule


// last module for choose the median
module choose_median(
	input [7:0] i_position_1_1,
	input [7:0] i_position_2_1,
	input [7:0] i_position_3_1,

	input [7:0] i_position_1_2,
	input [7:0] i_position_2_2,
	input [7:0] i_position_3_2,

	input [7:0] i_position_1_3,
	input [7:0] i_position_2_3,
	input [7:0] i_position_3_3,

	output [7:0] median
);

wire [7:0]  temp_1_1,temp_2_1,temp_3_1;
wire [7:0]  temp_1_2,temp_2_2,temp_3_2;
wire [7:0]  temp_1_3,temp_2_3,temp_3_3;

wire [7:0]  temp_max_1,temp_mid_1,temp_min_1;
wire [7:0]  temp_max_2,temp_mid_2,temp_min_2;
wire [7:0]  temp_max_3,temp_mid_3,temp_min_3;

wire [7:0]  last_max,last_mid,last_min;


sort_row sort_row_1(
	.i_position_1_1(i_position_1_1),
	.i_position_2_1(i_position_2_1),
	.i_position_3_1(i_position_3_1),

	.i_position_1_2(i_position_1_2),
	.i_position_2_2(i_position_2_2),
	.i_position_3_2(i_position_3_2),

	.i_position_1_3(i_position_1_3),
	.i_position_2_3(i_position_2_3),
	.i_position_3_3(i_position_3_3),

	.o_position_1_1(temp_1_1),
	.o_position_2_1(temp_2_1),
	.o_position_3_1(temp_3_1),

	.o_position_1_2(temp_1_2),
	.o_position_2_2(temp_2_2),
	.o_position_3_2(temp_3_2),

	.o_position_1_3(temp_1_3),
	.o_position_2_3(temp_2_3),
	.o_position_3_3(temp_3_3)
);

sort_row sort_row_2(
	.i_position_1_1(temp_1_1),
	.i_position_2_1(temp_1_2),
	.i_position_3_1(temp_1_3),

	.i_position_1_2(temp_2_1),
	.i_position_2_2(temp_2_2),
	.i_position_3_2(temp_2_3),

	.i_position_1_3(temp_3_1),
	.i_position_2_3(temp_3_2),
	.i_position_3_3(temp_3_3),	

	.o_position_1_1(temp_max_1),
	.o_position_2_1(temp_max_2),
	.o_position_3_1(temp_max_3),

	.o_position_1_2(temp_mid_1),
	.o_position_2_2(temp_mid_2),
	.o_position_3_2(temp_mid_3),

	.o_position_1_3(temp_min_1),
	.o_position_2_3(temp_min_2),
	.o_position_3_3(temp_min_3)
);

sort_3_number last_sort(
	.num1(temp_max_3),
	.num2(temp_mid_2),
	.num3(temp_min_1),

	.max(last_max),
	.mid(last_mid),
	.min(last_min)
);

assign median = last_mid;

endmodule    