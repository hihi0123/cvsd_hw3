
module ipdc (                       //Don't modify interface
	input         i_clk,
	input         i_rst_n,
	input         i_op_valid,
	input  [ 2:0] i_op_mode,
	input         i_in_valid,
	input  [23:0] i_in_data,
	output        o_in_ready,
	output        o_out_valid,
	output [23:0] o_out_data
);

// ---------------------------------------------------------------------------
// Wires and Registers
// ---------------------------------------------------------------------------
// ---- Add your own wires and registers here if needed ---- //

//output register
reg 	   o_in_ready_w, o_in_ready_r;
reg        o_out_valid_w, o_out_valid_r;
reg [23:0] o_out_data_w, o_out_data_r;

//input register
reg        i_op_valid_w;
reg [ 2:0] i_op_mode_w;
reg 	   i_in_valid_w;
reg [23:0] i_in_data_w;  

//store input image
integer i;
reg [23:0]  input_img [0:63];

//store output image
integer j;
reg [23:0] output_img [0:15];

//fsm state
reg [2:0] fsm_state, next_fsm_state;

//the position to store the loading image
reg [6:0] register_no, next_register_no;

//the current origin position
reg [6:0] origin_point;
reg [6:0] next_origin_point;

//output counters
reg [4:0]  output_counter;
reg [4:0]  next_output_counter;

//to decide which to output
reg [6:0]  output_position;
reg [6:0]  position_bias;

//
integer k,kk,l;
reg [23:0]  next_input_img [0:63];

//to calculate the ycbcr
integer m,n,o,p,q,r; //m for cbcr mode
reg [11:0] yr[0:63];
reg [11:0] yg_1[0:63];
reg [11:0] yg_2[0:63];
reg [11:0] y_sum[0:63];
reg  [8:0] y_sum_round[0:63];

integer nn,oo,pp,qq,rr;
reg [11:0] cb_r[0:63];
reg [11:0] cb_g[0:63];
reg [11:0] cb_b[0:63];
reg [11:0] cb_sum[0:63];
reg  [8:0] cb_sum_round[0:63];

integer nnn,ooo,ppp,qqq,rrr,sss;
reg [11:0] cr_r[0:63];
reg [11:0] cr_g1[0:63];
reg [11:0] cr_g2[0:63];
reg [11:0] cr_b[0:63];
reg [11:0] cr_sum[0:63];
reg [ 8:0] cr_sum_round[0:63];

//detect the mode to output
integer s,t;
reg ycbcr_mode;
reg next_ycbcr_mode;

reg [23:0] current_ycbcr_img [0:63];
reg [23:0] next_current_ycbcr_img [0:63];

//for median filter
integer f_r,f_g, f_b;
integer cf1,cf2,cf3,cf4,cf5;
/*reg     compare_flag1_r[0:63];
reg     compare_flag2_r[0:63];
reg     compare_flag3_r[0:63];
reg     compare_flag4_r[0:63];
reg     compare_flag5_r[0:63];
reg     compare_flag6_r[0:63];*/

reg [7:0] filter_counter;
reg [7:0] next_filter_counter;
reg[23:0] filter_img[0:63];
reg[23:0] next_filter_img[0:63];


//integer for kill latch
integer latch_1,latch_2,latch_3,latch_4,latch_5,latch_6,latch_7,latch_8,latch_9;
integer latch_11,latch_12,latch_13,latch_14;


//sram reg
wire        sram_wen; //write enable
wire [7:0]  sram_a;   //address
wire [7:0]  sram_d;   //data inputs
wire [7:0]  sram_q;   //data outputs

reg [7:0] sram_wen_w;
reg [7:0] sram_d_w;
reg [7:0] sram_a_w;

reg [7:0] next_sram_wen_w;
reg [7:0] next_sram_d_w;
reg [7:0] next_sram_a_w;


//R channel declaration
wire [7:0] m11_r, m21_r, m31_r;
wire [7:0] m12_r, m22_r, m32_r;
wire [7:0] m13_r, m23_r, m33_r;
wire [7:0] answer_r;

reg [7:0] m11_r_w, m21_r_w, m31_r_w;
reg [7:0] m12_r_w, m22_r_w, m32_r_w;
reg [7:0] m13_r_w, m23_r_w, m33_r_w;
/*
reg [7:0] next_m11_r_w, next_m21_r_w, next_m31_r_w;
reg [7:0] next_m12_r_w, next_m22_r_w, next_m32_r_w;
reg [7:0] next_m13_r_w, next_m23_r_w, next_m33_r_w;
*/
//G channel declaration
wire [7:0] m11_g, m21_g, m31_g;
wire [7:0] m12_g, m22_g, m32_g;
wire [7:0] m13_g, m23_g, m33_g;
wire [7:0] answer_g;

reg [7:0] m11_g_w, m21_g_w, m31_g_w;
reg [7:0] m12_g_w, m22_g_w, m32_g_w;
reg [7:0] m13_g_w, m23_g_w, m33_g_w;
/*
reg [7:0] next_m11_g_w, next_m21_g_w, next_m31_g_w;
reg [7:0] next_m12_g_w, next_m22_g_w, next_m32_g_w;
reg [7:0] next_m13_g_w, next_m23_g_w, next_m33_g_w;
*/
//B channel declaration
wire [7:0] m11_b, m21_b, m31_b;
wire [7:0] m12_b, m22_b, m32_b;
wire [7:0] m13_b, m23_b, m33_b;
wire [7:0] answer_b;

reg [7:0] m11_b_w, m21_b_w, m31_b_w;
reg [7:0] m12_b_w, m22_b_w, m32_b_w;
reg [7:0] m13_b_w, m23_b_w, m33_b_w;
/*
reg [7:0] next_m11_b_w, next_m21_b_w, next_m31_b_w;
reg [7:0] next_m12_b_w, next_m22_b_w, next_m32_b_w;
reg [7:0] next_m13_b_w, next_m23_b_w, next_m33_b_w;
*/
//R channel assing
assign m11_r = m11_r_w;
assign m21_r = m21_r_w;
assign m31_r = m31_r_w;

assign m12_r = m12_r_w;
assign m22_r = m22_r_w;
assign m32_r = m32_r_w;

assign m13_r = m13_r_w;
assign m23_r = m23_r_w;
assign m33_r = m33_r_w;




//G channel assign
assign m11_g = m11_g_w;
assign m21_g = m21_g_w;
assign m31_g = m31_g_w;

assign m12_g = m12_g_w;
assign m22_g = m22_g_w;
assign m32_g = m32_g_w;

assign m13_g = m13_g_w;
assign m23_g = m23_g_w;
assign m33_g = m33_g_w;

//B channel assign
assign m11_b = m11_b_w;
assign m21_b = m21_b_w;
assign m31_b = m31_b_w;

assign m12_b = m12_b_w;
assign m22_b = m22_b_w;
assign m32_b = m32_b_w;

assign m13_b = m13_b_w;
assign m23_b = m23_b_w;
assign m33_b = m33_b_w;


//memory assign
assign sram_wen = sram_wen_w;
assign sram_d = sram_d_w;
assign sram_a = sram_a_w;
// ---------------------------------------------------------------------------
// Continuous Assignment
// ---------------------------------------------------------------------------
// ---- Add your own wire data assignments here if needed ---- //
// assign wire = reg/wire
assign o_in_ready = o_in_ready_r;
assign o_out_valid = o_out_valid_r;
assign o_out_data = o_out_data_r;




choose_median channel_r(
							.i_position_1_1(m11_r),
							.i_position_2_1(m21_r),
							.i_position_3_1(m31_r),

							.i_position_1_2(m12_r),
							.i_position_2_2(m22_r),
							.i_position_3_2(m32_r),

							.i_position_1_3(m13_r),
							.i_position_2_3(m23_r),
							.i_position_3_3(m33_r),

							.median(answer_r)
						);

choose_median channel_g(
							.i_position_1_1(m11_g),
							.i_position_2_1(m21_g),
							.i_position_3_1(m31_g),

							.i_position_1_2(m12_g),
							.i_position_2_2(m22_g),
							.i_position_3_2(m32_g),

							.i_position_1_3(m13_g),
							.i_position_2_3(m23_g),
							.i_position_3_3(m33_g),

							.median(answer_g)
						);

choose_median channel_b(
							.i_position_1_1(m11_b),
							.i_position_2_1(m21_b),
							.i_position_3_1(m31_b),

							.i_position_1_2(m12_b),
							.i_position_2_2(m22_b),
							.i_position_3_2(m32_b),

							.i_position_1_3(m13_b),
							.i_position_2_3(m23_b),
							.i_position_3_3(m33_b),

							.median(answer_b)
						);


sram_256x8 u_R_sram (
        .CLK(i_clk),
        .CEN(1'b0),
        .WEN(sram_wen),
        .A(sram_a),
        .D(sram_d),   //D[7:0]
        .Q(sram_q)
    );


// ---------------------------------------------------------------------------
// Combinational Blocks
// ---------------------------------------------------------------------------
// ---- Write your conbinational block design here ---- //
always@(*)begin

	//input register
	i_op_valid_w = i_op_valid;
	i_op_mode_w = i_op_mode;
	i_in_valid_w = i_in_valid;
	i_in_data_w = i_in_data;

	for(latch_1=0; latch_1<64;latch_1 = latch_1+1) next_input_img[latch_1] = input_img[latch_1];
	next_fsm_state = fsm_state;
	next_register_no = register_no;
	next_origin_point = origin_point;
	next_output_counter = output_counter;
	next_ycbcr_mode = ycbcr_mode;
	
	next_filter_counter = filter_counter;
	for(latch_3=0;latch_3<64;latch_3 = latch_3+1) next_filter_img[latch_3] = filter_img[latch_3];
/*
	next_m11_r_w = m11_r_w ;
	next_m21_r_w = m21_r_w ;	
	next_m31_r_w = m31_r_w ;

	next_m12_r_w = m12_r_w ;
	next_m22_r_w = m22_r_w ;
	next_m32_r_w = m32_r_w;

	next_m13_r_w = m13_r_w;
	next_m23_r_w = m23_r_w;
	next_m33_r_w = m33_r_w;

	next_m11_g_w = m11_g_w;
	next_m21_g_w = m21_g_w;	
	next_m31_g_w = m31_g_w;

	next_m12_g_w = m12_g_w;
	next_m22_g_w = m22_g_w;
	next_m32_g_w = m32_g_w;

	next_m13_g_w = m13_g_w;
	next_m23_g_w = m23_g_w;
	next_m33_g_w = m33_g_w;

	next_m11_b_w = m11_b_w;
	next_m21_b_w = m21_b_w;	
	next_m31_b_w = m31_b_w;

	next_m12_b_w = m12_b_w;
	next_m22_b_w = m22_b_w;
	next_m32_b_w = m32_b_w;

	next_m13_b_w = m13_b_w;
	next_m23_b_w = m23_b_w;
	next_m33_b_w = m33_b_w;
*/
	next_sram_wen_w = sram_wen_w;
	next_sram_d_w = sram_d_w;
	next_sram_a_w = sram_a_w;
	
	o_in_ready_w = o_in_ready_r;
	o_out_valid_w = o_out_valid_r;
	o_out_data_w = o_out_data_r;

	case(fsm_state)
	3'b000:begin
		//do no operation
		next_fsm_state = fsm_state + 3'b001;

		//latch
		o_out_valid_w = 1'b0;
		
		m11_r_w	= 0;
		m21_r_w	= 0;	
		m31_r_w = 0;

		m12_r_w = 0;
		m22_r_w = 0;
		m32_r_w = 0;

		m13_r_w = 0;
		m23_r_w = 0;
		m33_r_w = 0;

		m11_g_w	= 0;
		m21_g_w	= 0;	
		m31_g_w = 0;

		m12_g_w = 0;
		m22_g_w = 0;
		m32_g_w = 0;

		m13_g_w = 0;
		m23_g_w = 0;
		m33_g_w = 0;

		m11_b_w	= 0;
		m21_b_w	= 0;	
		m31_b_w = 0;

		m12_b_w = 0;
		m22_b_w = 0;
		m32_b_w = 0;

		m13_b_w = 0;
		m23_b_w = 0;
		m33_b_w = 0;
		
	end
	3'b001:begin
		//after loading finished,need to reset the o_out_valid_w
		o_out_valid_w = 1'b0;
		case(i_op_valid_w)
		1'b1:begin
			//condition when i_op_mode_w is valid
			case(i_op_mode_w)
			3'b000:begin
				//loading image, no display
				next_fsm_state = fsm_state + 3'b001;
				
				//latch
				m11_r_w	= 0;
				m21_r_w	= 0;	
				m31_r_w = 0;

				m12_r_w = 0;
				m22_r_w = 0;
				m32_r_w = 0;

				m13_r_w = 0;
				m23_r_w = 0;
				m33_r_w = 0;

				m11_g_w	= 0;
				m21_g_w	= 0;	
				m31_g_w = 0;

				m12_g_w = 0;
				m22_g_w = 0;
				m32_g_w = 0;

				m13_g_w = 0;
				m23_g_w = 0;
				m33_g_w = 0;

				m11_b_w	= 0;
				m21_b_w	= 0;	
				m31_b_w = 0;

				m12_b_w = 0;
				m22_b_w = 0;
				m32_b_w = 0;

				m13_b_w = 0;
				m23_b_w = 0;
				m33_b_w = 0;
				
				
			end
			3'b001:begin
				//origin right shift, adjust the origin, need display
				//               %          8  >          3
				if((origin_point % 7'b0001000) > 7'b0000011)begin
					//will over boundary, do nothing
					next_origin_point = origin_point;
				end
				else begin
					next_origin_point = origin_point + 7'b0000001;
				end
				next_fsm_state = 3'b100;

				//latch
				
				m11_r_w	= 0;
				m21_r_w	= 0;	
				m31_r_w = 0;

				m12_r_w = 0;
				m22_r_w = 0;
				m32_r_w = 0;

				m13_r_w = 0;
				m23_r_w = 0;
				m33_r_w = 0;

				m11_g_w	= 0;
				m21_g_w	= 0;	
				m31_g_w = 0;

				m12_g_w = 0;
				m22_g_w = 0;
				m32_g_w = 0;

				m13_g_w = 0;
				m23_g_w = 0;
				m33_g_w = 0;

				m11_b_w	= 0;
				m21_b_w	= 0;	
				m31_b_w = 0;

				m12_b_w = 0;
				m22_b_w = 0;
				m32_b_w = 0;

				m13_b_w = 0;
				m23_b_w = 0;
				m33_b_w = 0;
				
				
				//for(latch_7=0; latch_7 <64;latch_7 = latch_7 + 1) next_input_img[latch_7] = input_img[latch_7];

			end
			3'b010:begin
				//origin down shift, adjust the origin, need display
				//               /          8 >          3
				if((origin_point / 7'b0001000)> 7'b0000011)begin
					//will over boundary, don't shift
					next_origin_point = origin_point;
				end
				else begin
					next_origin_point = origin_point + 7'b0001000;
				end
				next_fsm_state = 3'b100;

				//latch
				
				m11_r_w	= 0;
				m21_r_w	= 0;	
				m31_r_w = 0;

				m12_r_w = 0;
				m22_r_w = 0;
				m32_r_w = 0;

				m13_r_w = 0;
				m23_r_w = 0;
				m33_r_w = 0;

				m11_g_w	= 0;
				m21_g_w	= 0;	
				m31_g_w = 0;

				m12_g_w = 0;
				m22_g_w = 0;
				m32_g_w = 0;

				m13_g_w = 0;
				m23_g_w = 0;
				m33_g_w = 0;

				m11_b_w	= 0;
				m21_b_w	= 0;	
				m31_b_w = 0;

				m12_b_w = 0;
				m22_b_w = 0;
				m32_b_w = 0;

				m13_b_w = 0;
				m23_b_w = 0;
				m33_b_w = 0;
				

				//for(latch_8=0; latch_8 <64;latch_8 = latch_8 + 1) next_input_img[latch_8] = input_img[latch_8];
			end
			3'b011:begin
				//default origin, shift the origin to 0, need display
				next_origin_point = 0;
				//go to output 16 cycles state
				next_fsm_state = 3'b100;

				//latch
				
				m11_r_w	= 0;
				m21_r_w	= 0;	
				m31_r_w = 0;

				m12_r_w = 0;
				m22_r_w = 0;
				m32_r_w = 0;

				m13_r_w = 0;
				m23_r_w = 0;
				m33_r_w = 0;

				m11_g_w	= 0;
				m21_g_w	= 0;	
				m31_g_w = 0;

				m12_g_w = 0;
				m22_g_w = 0;
				m32_g_w = 0;

				m13_g_w = 0;
				m23_g_w = 0;
				m33_g_w = 0;

				m11_b_w	= 0;
				m21_b_w	= 0;	
				m31_b_w = 0;

				m12_b_w = 0;
				m22_b_w = 0;
				m32_b_w = 0;

				m13_b_w = 0;
				m23_b_w = 0;
				m33_b_w = 0;
				

				//for(latch_9=0; latch_9 <64;latch_9 = latch_9 + 1) next_input_img[latch_9] = input_img[latch_9];

			end
			3'b100:begin
				//zoom-in, shift the origin to 18, need display
				next_origin_point = 7'b0010010;
				next_fsm_state = 3'b100;

				//latch
				
				m11_r_w	= 0;
				m21_r_w	= 0;	
				m31_r_w = 0;

				m12_r_w = 0;
				m22_r_w = 0;
				m32_r_w = 0;

				m13_r_w = 0;
				m23_r_w = 0;
				m33_r_w = 0;

				m11_g_w	= 0;
				m21_g_w	= 0;	
				m31_g_w = 0;

				m12_g_w = 0;
				m22_g_w = 0;
				m32_g_w = 0;

				m13_g_w = 0;
				m23_g_w = 0;
				m33_g_w = 0;

				m11_b_w	= 0;
				m21_b_w	= 0;	
				m31_b_w = 0;

				m12_b_w = 0;
				m22_b_w = 0;
				m32_b_w = 0;

				m13_b_w = 0;
				m23_b_w = 0;
				m33_b_w = 0;
				
				//for(latch_11=0; latch_11 <64;latch_11 = latch_11 + 1) next_input_img[latch_11] = input_img[latch_11];

			end
			3'b101:begin
				//median filter, no display
				
				m11_r_w	= 0;
				m21_r_w	= 0;	
				m31_r_w = 0;

				m12_r_w = 0;
				m22_r_w = 0;
				m32_r_w = 0;

				m13_r_w = 0;
				m23_r_w = 0;
				m33_r_w = 0;

				m11_g_w	= 0;
				m21_g_w	= 0;	
				m31_g_w = 0;

				m12_g_w = 0;
				m22_g_w = 0;
				m32_g_w = 0;

				m13_g_w = 0;
				m23_g_w = 0;
				m33_g_w = 0;

				m11_b_w	= 0;
				m21_b_w	= 0;	
				m31_b_w = 0;

				m12_b_w = 0;
				m22_b_w = 0;
				m32_b_w = 0;

				m13_b_w = 0;
				m23_b_w = 0;
				m33_b_w = 0;
				

			/*	for(f_r=0;f_r<64;f_r=f_r+1)begin
					if(f_r==0 || f_r==7 || f_r==56 || f_r==63)begin
						next_input_img[f_r] = 0;		

						m11_r_w	= 0;
						m21_r_w	= 0;	
						m31_r_w = 0;

						m12_r_w = 0;
						m22_r_w = 0;
						m32_r_w = 0;

						m13_r_w = 0;
						m23_r_w = 0;
						m33_r_w = 0;

						m11_g_w	= 0;
						m21_g_w	= 0;	
						m31_g_w = 0;

						m12_g_w = 0;
						m22_g_w = 0;
						m32_g_w = 0;

						m13_g_w = 0;
						m23_g_w = 0;
						m33_g_w = 0;

						m11_b_w	= 0;
						m21_b_w	= 0;	
						m31_b_w = 0;

						m12_b_w = 0;
						m22_b_w = 0;
						m32_b_w = 0;

						m13_b_w = 0;
						m23_b_w = 0;
						m33_b_w = 0;

					end  
					//------------------------------------------------------------------------------------------------//
					//-------------------------------------------------up row-----------------------------------------//
					else if(f_r == 1 || f_r == 2 || f_r == 3 || f_r == 4 || f_r == 5 || f_r==6)begin
						//R channel
						m11_r_w = 8'b0000_0000;
						m21_r_w = input_img[f_r-1][7:0];
						m31_r_w = input_img[f_r+7][7:0];

						m12_r_w = 8'b0000_0000;
						m22_r_w = input_img[f_r][7:0];
						m32_r_w = input_img[f_r+8][7:0];

						m13_r_w = 8'b0000_0000;
						m23_r_w = input_img[f_r+1][7:0];
						m33_r_w = input_img[f_r+9][7:0];

						next_input_img[f_r][7:0] = answer_r;

						//G channel
						m11_g_w = 8'b0000_0000;
						m21_g_w = input_img[f_r-1][15:8];
						m31_g_w = input_img[f_r+7][15:8];

						m12_g_w = 8'b0000_0000;
						m22_g_w = input_img[f_r][15:8];
						m32_g_w = input_img[f_r+8][15:8];

						m13_g_w = 8'b0000_0000;
						m23_g_w = input_img[f_r+1][15:8];
						m33_g_w = input_img[f_r+9][15:8];

						next_input_img[f_r][15:8] = answer_g;

						//B channel
						m11_b_w = 8'b0000_0000;
						m21_b_w = input_img[f_r-1][23:16];
						m31_b_w = input_img[f_r+7][23:16];

						m12_b_w = 8'b0000_0000;
						m22_b_w = input_img[f_r][23:16];
						m32_b_w = input_img[f_r+8][23:16];

						m13_b_w = 8'b0000_0000;
						m23_b_w = input_img[f_r+1][23:16];
						m33_b_w = input_img[f_r+9][23:16];

						next_input_img[f_r][23:16] = answer_b;

					end
					//--------------------------------------------------------------------------------------------//					
					//------------------------------------------left column---------------------------------------//
					else if(f_r == 8 || f_r == 16 || f_r == 24 || f_r == 32 || f_r == 40 || f_r == 48)begin
						//R channel
						m11_r_w = 8'b0000_0000;
						m21_r_w = 8'b0000_0000;
						m31_r_w = 8'b0000_0000;

						m12_r_w = input_img[f_r-8][7:0];
						m22_r_w = input_img[f_r][7:0];
						m32_r_w = input_img[f_r+8][7:0];

						m13_r_w = input_img[f_r-7][7:0];
						m23_r_w = input_img[f_r+1][7:0];
						m33_r_w = input_img[f_r+9][7:0];

						next_input_img[f_r][7:0] = answer_r;

						//G channel
						m11_g_w = 8'b0000_0000;
						m21_g_w = 8'b0000_0000;
						m31_g_w = 8'b0000_0000;

						m12_g_w = input_img[f_r-8][15:8];
						m22_g_w = input_img[f_r][15:8];
						m32_g_w = input_img[f_r+8][15:8];

						m13_g_w = input_img[f_r-7][15:8];
						m23_g_w = input_img[f_r+1][15:8];
						m33_g_w = input_img[f_r+9][15:8];

						next_input_img[f_r][15:8] = answer_g;

						//B channel
						m11_b_w = 8'b0000_0000;
						m21_b_w = 8'b0000_0000;
						m31_b_w = 8'b0000_0000;

						m12_b_w = input_img[f_r-8][23:16];
						m22_b_w = input_img[f_r][23:16];
						m32_b_w = input_img[f_r+8][23:16];

						m13_b_w = input_img[f_r-7][23:16];
						m23_b_w = input_img[f_r+1][23:16];
						m33_b_w = input_img[f_r+9][23:16];

						next_input_img[f_r][23:16] = answer_b;

					end
					//--------------------------------------------------------------------------------------------//
					//------------------------------------------------right---------------------------------------//
					else if(f_r == 15 || f_r == 23 || f_r == 31 || f_r == 39 || f_r == 47 || f_r == 55)begin
						//R channel
						m11_r_w = input_img[f_r-9][7:0];
						m21_r_w = input_img[f_r-1][7:0];
						m31_r_w = input_img[f_r+7][7:0];

						m12_r_w = input_img[f_r-8][7:0];
						m22_r_w = input_img[f_r][7:0];
						m32_r_w = input_img[f_r+8][7:0];

						m13_r_w = 8'b0000_0000;
						m23_r_w = 8'b0000_0000;
						m33_r_w = 8'b0000_0000;

						next_input_img[f_r][7:0] = answer_r;

						//G channel
						m11_g_w = input_img[f_r-9][15:8];
						m21_g_w = input_img[f_r-1][15:8];
						m31_g_w = input_img[f_r+7][15:8];

						m12_g_w = input_img[f_r-8][15:8];
						m22_g_w = input_img[f_r][15:8];
						m32_g_w = input_img[f_r+8][15:8];

						m13_g_w = 8'b0000_0000;
						m23_g_w = 8'b0000_0000;
						m33_g_w = 8'b0000_0000;

						next_input_img[f_r][15:8] = answer_g;

						//B channel
						m11_b_w = input_img[f_r-9][23:16];
						m21_b_w = input_img[f_r-1][23:16];
						m31_b_w = input_img[f_r+7][23:16];

						m12_b_w = input_img[f_r-8][23:16];
						m22_b_w = input_img[f_r][23:16];
						m32_b_w = input_img[f_r+8][23:16];

						m13_b_w = 8'b0000_0000;
						m23_b_w = 8'b0000_0000;
						m33_b_w = 8'b0000_0000;

						next_input_img[f_r][23:16] = answer_b;

					end
					//--------------------------------------------------------------------------------------------//
					//------------------------------------------------down----------------------------------------//
					else if(f_r == 57  || f_r == 58 || f_r == 59 || f_r == 60 || f_r == 61 || f_r == 62)begin
						//R channel
						m11_r_w = input_img[f_r-9][7:0];
						m21_r_w = input_img[f_r-1][7:0];
						m31_r_w = 8'b0000_0000;

						m12_r_w = input_img[f_r-8][7:0];
						m22_r_w = input_img[f_r][7:0];
						m32_r_w = 8'b0000_0000;

						m13_r_w = input_img[f_r-7][7:0];
						m23_r_w = input_img[f_r+1][7:0];
						m33_r_w = 8'b0000_0000;

						next_input_img[f_r][7:0] = answer_r;

						//G channel
						m11_g_w = input_img[f_r-9][15:8];
						m21_g_w = input_img[f_r-1][15:8];
						m31_g_w = 8'b0000_0000;

						m12_g_w = input_img[f_r-8][15:8];
						m22_g_w = input_img[f_r][15:8];
						m32_g_w = 8'b0000_0000;

						m13_g_w = input_img[f_r-7][15:8];
						m23_g_w = input_img[f_r+1][15:8];
						m33_g_w = 8'b0000_0000;

						next_input_img[f_r][15:8] = answer_g;

						//B channel
						m11_b_w = input_img[f_r-9][23:16];
						m21_b_w = input_img[f_r-1][23:16];
						m31_b_w = 8'b0000_0000;

						m12_b_w = input_img[f_r-8][23:16];
						m22_b_w = input_img[f_r][23:16];
						m32_b_w = 8'b0000_0000;

						m13_b_w = input_img[f_r-7][23:16];
						m23_b_w = input_img[f_r+1][23:16];
						m33_b_w = 8'b0000_0000;

						next_input_img[f_r][23:16] = answer_b;
					end
					//--------------------------------------------------------------------------------------------//
					//------------------------------------------------mid-----------------------------------------//
					else begin
						//R channel
						m11_r_w = input_img[f_r-9][7:0];
						m21_r_w = input_img[f_r-1][7:0];
						m31_r_w = input_img[f_r+7][7:0];

						m12_r_w = input_img[f_r-8][7:0];
						m22_r_w = input_img[f_r][7:0];
						m32_r_w = input_img[f_r+8][7:0];

						m13_r_w = input_img[f_r-7][7:0];
						m23_r_w = input_img[f_r+1][7:0];
						m33_r_w = input_img[f_r+9][7:0];

						next_input_img[f_r][7:0] = answer_r;

						//G channel
						m11_g_w = input_img[f_r-9][15:8];
						m21_g_w = input_img[f_r-1][15:8];
						m31_g_w = input_img[f_r+7][15:8];

						m12_g_w = input_img[f_r-8][15:8];
						m22_g_w = input_img[f_r][15:8];
						m32_g_w = input_img[f_r+8][15:8];

						m13_g_w = input_img[f_r-7][15:8];
						m23_g_w = input_img[f_r+1][15:8];
						m33_g_w = input_img[f_r+9][15:8];

						next_input_img[f_r][15:8] = answer_g;

						//B channel
						m11_b_w = input_img[f_r-9][23:16];
						m21_b_w = input_img[f_r-1][23:16];
						m31_b_w = input_img[f_r+7][23:16];

						m12_b_w = input_img[f_r-8][23:16];
						m22_b_w = input_img[f_r][23:16];
						m32_b_w = input_img[f_r+8][23:16];

						m13_b_w = input_img[f_r-7][23:16];
						m23_b_w = input_img[f_r+1][23:16];
						m33_b_w = input_img[f_r+9][23:16];

						next_input_img[f_r][23:16] = answer_b;
					end
				end

				o_out_valid_w = 1'b1;
				next_fsm_state = 3'b001;*/
				next_fsm_state = 3'b101;
				
			end
			3'b110:begin
				//YcbCr, no display
				next_ycbcr_mode = 1'b1;	
				o_out_valid_w = 1'b0;
				next_fsm_state = 3'b011;		

				//latch
				
				m11_r_w	= 0;
				m21_r_w	= 0;	
				m31_r_w = 0;

				m12_r_w = 0;
				m22_r_w = 0;
				m32_r_w = 0;

				m13_r_w = 0;
				m23_r_w = 0;
				m33_r_w = 0;

				m11_g_w	= 0;
				m21_g_w	= 0;	
				m31_g_w = 0;

				m12_g_w = 0;
				m22_g_w = 0;
				m32_g_w = 0;

				m13_g_w = 0;
				m23_g_w = 0;
				m33_g_w = 0;

				m11_b_w	= 0;
				m21_b_w	= 0;	
				m31_b_w = 0;

				m12_b_w = 0;
				m22_b_w = 0;
				m32_b_w = 0;

				m13_b_w = 0;
				m23_b_w = 0;
				m33_b_w = 0;
				

				//for(latch_12=0; latch_12 <64;latch_12 = latch_12 + 1) next_input_img[latch_12] = input_img[latch_12];

			end
			3'b111:begin
				//RGB mode no display
				next_ycbcr_mode = 1'b0;
				o_out_valid_w = 1'b0;
				next_fsm_state = 3'b011;

				//latch
				
				m11_r_w	= 0;
				m21_r_w	= 0;	
				m31_r_w = 0;

				m12_r_w = 0;
				m22_r_w = 0;
				m32_r_w = 0;

				m13_r_w = 0;
				m23_r_w = 0;
				m33_r_w = 0;

				m11_g_w	= 0;
				m21_g_w	= 0;	
				m31_g_w = 0;

				m12_g_w = 0;
				m22_g_w = 0;
				m32_g_w = 0;

				m13_g_w = 0;
				m23_g_w = 0;
				m33_g_w = 0;

				m11_b_w	= 0;
				m21_b_w	= 0;	
				m31_b_w = 0;

				m12_b_w = 0;
				m22_b_w = 0;
				m32_b_w = 0;

				m13_b_w = 0;
				m23_b_w = 0;
				m33_b_w = 0;
				

				//for(latch_13=0; latch_13 <64;latch_13 = latch_13 + 1) next_input_img[latch_13] = input_img[latch_13];
			end
			endcase
		end
		1'b0:begin
			//condition when i_op_mode_w is not valid, re-choosing
			next_fsm_state = 3'b001;

			//latch
			
		m11_r_w	= 0;
		m21_r_w	= 0;	
		m31_r_w = 0;

		m12_r_w = 0;
		m22_r_w = 0;
		m32_r_w = 0;

		m13_r_w = 0;
		m23_r_w = 0;
		m33_r_w = 0;

		m11_g_w	= 0;
		m21_g_w	= 0;	
		m31_g_w = 0;

		m12_g_w = 0;
		m22_g_w = 0;
		m32_g_w = 0;

		m13_g_w = 0;
		m23_g_w = 0;
		m33_g_w = 0;

		m11_b_w	= 0;
		m21_b_w	= 0;	
		m31_b_w = 0;

		m12_b_w = 0;
		m22_b_w = 0;
		m32_b_w = 0;

		m13_b_w = 0;
		m23_b_w = 0;
		m33_b_w = 0;
		

		//for(latch_14=0; latch_14 <64;latch_14 = latch_14 + 1) next_input_img[latch_14] = input_img[latch_14];

		end
		endcase
	end
	3'b010:begin
		//load state
		if(i_in_valid_w == 1'b1)begin
			next_input_img[register_no] = i_in_data_w;
			next_register_no = register_no + 7'b0000001;			
			next_fsm_state = 3'b010;
			//$display("reg num. %d = %b",register_no,next_input_img[register_no]);

			//------------memory operate------------
			next_sram_wen_w = 1'b1;
			next_sram_a_w = {{1'b0},register_no};
			next_sram_d_w = i_in_data_w;
			//--------------------------------------
		end
		else begin
			next_register_no = 0;
			next_fsm_state = 3'b011;			
			//------------memory operate------------
			next_sram_wen_w = 1'b0;
			next_sram_a_w = 0;
			next_sram_d_w = 0;
			//--------------------------------------
		end
		o_out_valid_w = 1'b0;

		//latch
		
		m11_r_w	= 0;
		m21_r_w	= 0;	
		m31_r_w = 0;

		m12_r_w = 0;
		m22_r_w = 0;
		m32_r_w = 0;

		m13_r_w = 0;
		m23_r_w = 0;
		m33_r_w = 0;

		m11_g_w	= 0;
		m21_g_w	= 0;	
		m31_g_w = 0;

		m12_g_w = 0;
		m22_g_w = 0;
		m32_g_w = 0;

		m13_g_w = 0;
		m23_g_w = 0;
		m33_g_w = 0;

		m11_b_w	= 0;
		m21_b_w	= 0;	
		m31_b_w = 0;

		m12_b_w = 0;
		m22_b_w = 0;
		m32_b_w = 0;

		m13_b_w = 0;
		m23_b_w = 0;
		m33_b_w = 0;
		
		

	end
	3'b011:begin
		//loading finish, set the o_out_valid 1 cycle
		o_out_valid_w = 1'b1;
		next_fsm_state = 3'b001;

		//latch
		
		m11_r_w	= 0;
		m21_r_w	= 0;	
		m31_r_w = 0;

		m12_r_w = 0;
		m22_r_w = 0;
		m32_r_w = 0;

		m13_r_w = 0;
		m23_r_w = 0;
		m33_r_w = 0;

		m11_g_w	= 0;
		m21_g_w	= 0;	
		m31_g_w = 0;

		m12_g_w = 0;
		m22_g_w = 0;
		m32_g_w = 0;

		m13_g_w = 0;
		m23_g_w = 0;
		m33_g_w = 0;

		m11_b_w	= 0;
		m21_b_w	= 0;	
		m31_b_w = 0;

		m12_b_w = 0;
		m22_b_w = 0;
		m32_b_w = 0;

		m13_b_w = 0;
		m23_b_w = 0;
		m33_b_w = 0;
		
		
	end
	3'b100:begin  //output 16 cycles
		if(ycbcr_mode == 1'b0)begin //now is rgb mode
			if(output_counter != 5'b10000)begin
				//              (               /        4) *        4 
				position_bias = (output_counter / 5'b00100) * 5'b00100 + output_counter;
				output_position = position_bias + origin_point ;
				
				o_out_valid_w = 1'b1;
				o_out_data_w  = input_img[output_position];

				next_output_counter = output_counter + 5'b00001;
				next_fsm_state = fsm_state;
			end
			else begin
				position_bias = 0;
				output_position = 0;

				o_out_valid_w = 1'b0;
				o_out_data_w = 0;

				next_output_counter = 0;
				next_fsm_state = 3'b001;
			end
		end
		else begin    //now use ycbcr mode
			//calculate ycbcr first
			for(m=0;m<64;m=m+1)begin
				//------------y = 0.25R + 0.5 G + 0.125G -------------//
				yr[m]   = {{3{1'b0}},input_img[m][7:0],{1'b0}};
				yg_1[m] = {{2{1'b0}},input_img[m][15:8],{2{1'b0}}};
				yg_2[m] = {{4{1'b0}},input_img[m][15:8]};
				y_sum[m] = yr[m] + yg_1[m] + yg_2[m];
				//round and delete the last 3 bits
				if(y_sum[m][2]==1'b1)begin
					y_sum_round[m] = y_sum[m][11:3]+9'b0_0000_0001;
				end
				else begin
					y_sum_round[m] = y_sum[m][11:3];
				end
				//check if overflow
				if(y_sum_round[m] > 9'b0_1111_1111)begin
					current_ycbcr_img[m][7:0] = 8'b1111_1111; 
				end
				else begin
					current_ycbcr_img[m][7:0] = y_sum_round[m][7:0];
				end
				//-----------------------------------------------------//
				//-----------cb = -0.125R -0.25 G +0.5 B +128----------//
				cb_r[m]  = {{4{1'b0}},input_img[m][7:0]};
				cb_g[m]  = {{3{1'b0}},input_img[m][15:8],{1'b0}};
				cb_b[m]  = {{2{1'b0}},input_img[m][23:16],{2{1'b0}}};
				cb_sum[m] = 12'b0100_0000_0000 + cb_b[m] - cb_r[m] - cb_g[m];
				//round and delete the last 3 bits
				if(cb_sum[m][2]==1'b1)begin                           
					cb_sum_round[m] = cb_sum[m][11:3] + 9'b0_0000_0001;
				end
				else begin                          
					cb_sum_round[m] = cb_sum[m][11:3] ;
				end
				//check if overflow
				if(cb_sum_round[m] > 9'b0_1111_1111)begin
					current_ycbcr_img[m][15:8] = 8'b1111_1111;
				end
				else begin
					current_ycbcr_img[m][15:8] = cb_sum_round[m][7:0];
				end					
				//-----------------------------------------------------//
				//---------Cr = 0.5 R -0.25 G -0.125 G - 0.125 B +128----------//
				cr_r[m]  = {{2{1'b0}},input_img[m][7:0],{2{1'b0}}};
				cr_g1[m] = {{3{1'b0}},input_img[m][15:8],{1'b0}};
				cr_g2[m] = {{4{1'b0}},input_img[m][15:8]};
				cr_b[m]  = {{4{1'b0}},input_img[m][23:16]};
				cr_sum[m] = 12'b0100_0000_0000 + cr_r[m]-cr_g1[m]-cr_g2[m]-cr_b[m];
				//round and delete the last 3 bits
				if(cr_sum[m][2]==1'b1)begin
					cr_sum_round[m] = cr_sum[m][11:3] + 9'b0+0000_0001;
				end
				else begin
					cr_sum_round[m] = cr_sum[m][11:3];
				end
				//check if overflow
				if(cr_sum_round[m] > 9'b0_1111_1111)begin
					current_ycbcr_img[m][23:16] = 8'b1111_1111;
				end
				else begin
					current_ycbcr_img[m][23:16] = cr_sum_round[m][7:0];
				end
				//-------------------------------------------------------//
			end
			if(output_counter != 5'b10000)begin
				//              (               /        4) *        4 
				position_bias = (output_counter / 5'b00100) * 5'b00100 + output_counter;
				output_position = position_bias + origin_point ;
				
				o_out_valid_w = 1'b1;
				o_out_data_w  = current_ycbcr_img[output_position];

				next_output_counter = output_counter + 5'b00001;
				next_fsm_state = fsm_state;
			end
			else begin
				position_bias = 0;
				output_position = 0;

				o_out_valid_w = 1'b0;
				o_out_data_w = 0;

				next_output_counter = 0;
				next_fsm_state = 3'b001;
			end
		end

		//latch
		
		m11_r_w	= 0;
		m21_r_w	= 0;	
		m31_r_w = 0;

		m12_r_w = 0;
		m22_r_w = 0;
		m32_r_w = 0;

		m13_r_w = 0;
		m23_r_w = 0;
		m33_r_w = 0;

		m11_g_w	= 0;
		m21_g_w	= 0;	
		m31_g_w = 0;

		m12_g_w = 0;
		m22_g_w = 0;
		m32_g_w = 0;

		m13_g_w = 0;
		m23_g_w = 0;
		m33_g_w = 0;

		m11_b_w	= 0;
		m21_b_w	= 0;	
		m31_b_w = 0;

		m12_b_w = 0;
		m22_b_w = 0;
		m32_b_w = 0;

		m13_b_w = 0;
		m23_b_w = 0;
		m33_b_w = 0;
		

	end
	3'b101:begin
		//do the median filter,64cycles
		if(filter_counter != 7'b1000000)begin
			if(filter_counter == 7'd0 || filter_counter ==7'd7 || filter_counter == 7'd56 || filter_counter == 7'd63 )begin
				next_filter_img[filter_counter] = 0;
				//maybe lack something?
				//latch
				m11_r_w	= 0;
				m21_r_w	= 0;	
				m31_r_w = 0;

				m12_r_w = 0;
				m22_r_w = 0;
				m32_r_w = 0;

				m13_r_w = 0;
				m23_r_w = 0;
				m33_r_w = 0;

				m11_g_w	= 0;
				m21_g_w	= 0;	
				m31_g_w = 0;

				m12_g_w = 0;
				m22_g_w = 0;
				m32_g_w = 0;

				m13_g_w = 0;
				m23_g_w = 0;
				m33_g_w = 0;

				m11_b_w	= 0;
				m21_b_w	= 0;	
				m31_b_w = 0;

				m12_b_w = 0;
				m22_b_w = 0;
				m32_b_w = 0;

				m13_b_w = 0;
				m23_b_w = 0;
				m33_b_w = 0;
			end
			else if(filter_counter ==7'd1 || filter_counter ==7'd2 || filter_counter ==7'd3 || filter_counter == 7'd4 ||filter_counter == 7'd5 || filter_counter == 7'd6)begin
				// R channel
				m11_r_w = 8'b0000_0000;
				m21_r_w = input_img[filter_counter-1][7:0];
				m31_r_w = input_img[filter_counter+7][7:0];

				m12_r_w = 8'b0000_0000;
				m22_r_w = input_img[filter_counter][7:0];
				m32_r_w = input_img[filter_counter+8][7:0];

				m13_r_w = 8'b0000_0000;
				m23_r_w = input_img[filter_counter+1][7:0];
				m33_r_w = input_img[filter_counter+9][7:0];

				next_filter_img[filter_counter][7:0] = answer_r;

				//G channel
				m11_g_w = 8'b0000_0000;
				m21_g_w = input_img[filter_counter-1][15:8];
				m31_g_w = input_img[filter_counter+7][15:8];

				m12_g_w = 8'b0000_0000;
				m22_g_w = input_img[filter_counter][15:8];
				m32_g_w = input_img[filter_counter+8][15:8];

				m13_g_w = 8'b0000_0000;
				m23_g_w = input_img[filter_counter+1][15:8];
				m33_g_w = input_img[filter_counter+9][15:8];

				next_filter_img[filter_counter][15:8] = answer_g;

				//B channel
				m11_b_w = 8'b0000_0000;
				m21_b_w = input_img[filter_counter-1][23:16];
				m31_b_w = input_img[filter_counter+7][23:16];

				m12_b_w = 8'b0000_0000;
				m22_b_w = input_img[filter_counter][23:16];
				m32_b_w = input_img[filter_counter+8][23:16];

				m13_b_w = 8'b0000_0000;
				m23_b_w = input_img[filter_counter+1][23:16];
				m33_b_w = input_img[filter_counter+9][23:16];

				next_filter_img[filter_counter][23:16] = answer_b;
			end
			else if(filter_counter ==7'd8 || filter_counter ==7'd16 || filter_counter ==7'd24 || filter_counter ==7'd32 || filter_counter ==7'd40 || filter_counter==7'd48)begin
				//R channel
				m11_r_w = 8'b0000_0000;
				m21_r_w = 8'b0000_0000;
				m31_r_w = 8'b0000_0000;

				m12_r_w = input_img[filter_counter-8][7:0];
				m22_r_w = input_img[filter_counter][7:0];
				m32_r_w = input_img[filter_counter+8][7:0];

				m13_r_w = input_img[filter_counter-7][7:0];
				m23_r_w = input_img[filter_counter+1][7:0];
				m33_r_w = input_img[filter_counter+9][7:0];

				next_filter_img[filter_counter][7:0] = answer_r;

				//G channel
				m11_g_w = 8'b0000_0000;
				m21_g_w = 8'b0000_0000;
				m31_g_w = 8'b0000_0000;

				m12_g_w = input_img[filter_counter-8][15:8];
				m22_g_w = input_img[filter_counter][15:8];
				m32_g_w = input_img[filter_counter+8][15:8];

				m13_g_w = input_img[filter_counter-7][15:8];
				m23_g_w = input_img[filter_counter+1][15:8];
				m33_g_w = input_img[filter_counter+9][15:8];

				next_filter_img[filter_counter][15:8] = answer_g;

				//B channel
				m11_b_w = 8'b0000_0000;
				m21_b_w = 8'b0000_0000;
				m31_b_w = 8'b0000_0000;

				m12_b_w = input_img[filter_counter-8][23:16];
				m22_b_w = input_img[filter_counter][23:16];
				m32_b_w = input_img[filter_counter+8][23:16];

				m13_b_w = input_img[filter_counter-7][23:16];
				m23_b_w = input_img[filter_counter+1][23:16];
				m33_b_w = input_img[filter_counter+9][23:16];

				next_filter_img[filter_counter][23:16] = answer_b;

			end
			else if(filter_counter ==7'd15 || filter_counter ==7'd23 || filter_counter ==7'd31 || filter_counter ==7'd39 || filter_counter ==7'd47 || filter_counter==7'd55)begin
				//R channel
				m11_r_w = input_img[filter_counter-9][7:0];
				m21_r_w = input_img[filter_counter-1][7:0];
				m31_r_w = input_img[filter_counter+7][7:0];

				m12_r_w = input_img[filter_counter-8][7:0];
				m22_r_w = input_img[filter_counter][7:0];
				m32_r_w = input_img[filter_counter+8][7:0];

				m13_r_w = 8'b0000_0000;
				m23_r_w = 8'b0000_0000;
				m33_r_w = 8'b0000_0000;

				next_filter_img[filter_counter][7:0] = answer_r;

				//G channel
				m11_g_w = input_img[filter_counter-9][15:8];
				m21_g_w = input_img[filter_counter-1][15:8];
				m31_g_w = input_img[filter_counter+7][15:8];

				m12_g_w = input_img[filter_counter-8][15:8];
				m22_g_w = input_img[filter_counter][15:8];
				m32_g_w = input_img[filter_counter+8][15:8];

				m13_g_w = 8'b0000_0000;
				m23_g_w = 8'b0000_0000;
				m33_g_w = 8'b0000_0000;

				next_filter_img[filter_counter][15:8] = answer_g;

				//B channel
				m11_b_w = input_img[filter_counter-9][23:16];
				m21_b_w = input_img[filter_counter-1][23:16];
				m31_b_w = input_img[filter_counter+7][23:16];

				m12_b_w = input_img[filter_counter-8][23:16];
				m22_b_w = input_img[filter_counter][23:16];
				m32_b_w = input_img[filter_counter+8][23:16];

				m13_b_w = 8'b0000_0000;
				m23_b_w = 8'b0000_0000;
				m33_b_w = 8'b0000_0000;

				next_filter_img[filter_counter][23:16] = answer_b;
				
			end
			else if(filter_counter ==7'd57 || filter_counter ==7'd58 || filter_counter ==7'd59 || filter_counter ==7'd60 || filter_counter ==7'd61 || filter_counter==7'd62)begin
				//R channel
				m11_r_w = input_img[filter_counter-9][7:0];
				m21_r_w = input_img[filter_counter-1][7:0];
				m31_r_w = 8'b0000_0000;

				m12_r_w = input_img[filter_counter-8][7:0];
				m22_r_w = input_img[filter_counter][7:0];
				m32_r_w = 8'b0000_0000;

				m13_r_w = input_img[filter_counter-7][7:0];
				m23_r_w = input_img[filter_counter+1][7:0];
				m33_r_w = 8'b0000_0000;

				next_filter_img[filter_counter][7:0] = answer_r;

				//G channel
				m11_g_w = input_img[filter_counter-9][15:8];
				m21_g_w = input_img[filter_counter-1][15:8];
				m31_g_w = 8'b0000_0000;

				m12_g_w = input_img[filter_counter-8][15:8];
				m22_g_w = input_img[filter_counter][15:8];
				m32_g_w = 8'b0000_0000;

				m13_g_w = input_img[filter_counter-7][15:8];
				m23_g_w = input_img[filter_counter+1][15:8];
				m33_g_w = 8'b0000_0000;

				next_filter_img[filter_counter][15:8] = answer_g;

				//B channel
				m11_b_w = input_img[filter_counter-9][23:16];
				m21_b_w = input_img[filter_counter-1][23:16];
				m31_b_w = 8'b0000_0000;

				m12_b_w = input_img[filter_counter-8][23:16];
				m22_b_w = input_img[filter_counter][23:16];
				m32_b_w = 8'b0000_0000;

				m13_b_w = input_img[filter_counter-7][23:16];
				m23_b_w = input_img[filter_counter+1][23:16];
				m33_b_w = 8'b0000_0000;

				next_filter_img[filter_counter][23:16] = answer_b;
			end
			else begin
				//R channel
				m11_r_w = input_img[filter_counter-9][7:0];
				m21_r_w = input_img[filter_counter-1][7:0];
				m31_r_w = input_img[filter_counter+7][7:0];

				m12_r_w = input_img[filter_counter-8][7:0];
				m22_r_w = input_img[filter_counter][7:0];
				m32_r_w = input_img[filter_counter+8][7:0];

				m13_r_w = input_img[filter_counter-7][7:0];
				m23_r_w = input_img[filter_counter+1][7:0];
				m33_r_w = input_img[filter_counter+9][7:0];

				next_filter_img[filter_counter][7:0] = answer_r;

				//G channel
				m11_g_w = input_img[filter_counter-9][15:8];
				m21_g_w = input_img[filter_counter-1][15:8];
				m31_g_w = input_img[filter_counter+7][15:8];

				m12_g_w = input_img[filter_counter-8][15:8];
				m22_g_w = input_img[filter_counter][15:8];
				m32_g_w = input_img[filter_counter+8][15:8];

				m13_g_w = input_img[filter_counter-7][15:8];
				m23_g_w = input_img[filter_counter+1][15:8];
				m33_g_w = input_img[filter_counter+9][15:8];

				next_filter_img[filter_counter][15:8] = answer_g;

				//B channel
				m11_b_w = input_img[filter_counter-9][23:16];
				m21_b_w = input_img[filter_counter-1][23:16];
				m31_b_w = input_img[filter_counter+7][23:16];

				m12_b_w = input_img[filter_counter-8][23:16];
				m22_b_w = input_img[filter_counter][23:16];
				m32_b_w = input_img[filter_counter+8][23:16];

				m13_b_w = input_img[filter_counter-7][23:16];
				m23_b_w = input_img[filter_counter+1][23:16];
				m33_b_w = input_img[filter_counter+9][23:16];

				next_filter_img[filter_counter][23:16] = answer_b;
			end
			next_filter_counter = filter_counter + 7'b000_0001;
			next_fsm_state = fsm_state;
		end
		else begin
			next_filter_counter = 0;
			next_fsm_state = 3'b110;

			//latch
			m11_r_w	= 0;
			m21_r_w	= 0;	
			m31_r_w = 0;

			m12_r_w = 0;
			m22_r_w = 0;
			m32_r_w = 0;

			m13_r_w = 0;
			m23_r_w = 0;
			m33_r_w = 0;

			m11_g_w	= 0;
			m21_g_w	= 0;	
			m31_g_w = 0;

			m12_g_w = 0;
			m22_g_w = 0;
			m32_g_w = 0;

			m13_g_w = 0;
			m23_g_w = 0;
			m33_g_w = 0;

			m11_b_w	= 0;
			m21_b_w	= 0;	
			m31_b_w = 0;

			m12_b_w = 0;
			m22_b_w = 0;
			m32_b_w = 0;

			m13_b_w = 0;
			m23_b_w = 0;
			m33_b_w = 0;
		end

	end
	3'b110:begin
		for(latch_5=0; latch_5<64; latch_5=latch_5+1) next_input_img[latch_5] = filter_img[latch_5];
		next_fsm_state = 3'b001;
		o_out_valid_w = 1'b1;

		//latch
		
		m11_r_w	= 0;
		m21_r_w	= 0;	
		m31_r_w = 0;

		m12_r_w = 0;
		m22_r_w = 0;
		m32_r_w = 0;

		m13_r_w = 0;
		m23_r_w = 0;
		m33_r_w = 0;

		m11_g_w	= 0;
		m21_g_w	= 0;	
		m31_g_w = 0;

		m12_g_w = 0;
		m22_g_w = 0;
		m32_g_w = 0;

		m13_g_w = 0;
		m23_g_w = 0;
		m33_g_w = 0;

		m11_b_w	= 0;
		m21_b_w	= 0;	
		m31_b_w = 0;

		m12_b_w = 0;
		m22_b_w = 0;
		m32_b_w = 0;

		m13_b_w = 0;
		m23_b_w = 0;
		m33_b_w = 0;
		
	end
	
	default:begin
		//do no operation
		next_fsm_state = 3'b001;
		o_out_valid_w = 1'b0;

		//latch
		m11_r_w	= 0;
		m21_r_w	= 0;	
		m31_r_w = 0;

		m12_r_w = 0;
		m22_r_w = 0;
		m32_r_w = 0;

		m13_r_w = 0;
		m23_r_w = 0;
		m33_r_w = 0;

		m11_g_w	= 0;
		m21_g_w	= 0;	
		m31_g_w = 0;

		m12_g_w = 0;
		m22_g_w = 0;
		m32_g_w = 0;

		m13_g_w = 0;
		m23_g_w = 0;
		m33_g_w = 0;

		m11_b_w	= 0;
		m21_b_w	= 0;	
		m31_b_w = 0;

		m12_b_w = 0;
		m22_b_w = 0;
		m32_b_w = 0;

		m13_b_w = 0;
		m23_b_w = 0;
		m33_b_w = 0;

		
	end
	endcase
end


// ---------------------------------------------------------------------------
// Sequential Block
// ---------------------------------------------------------------------------
// ---- Write your sequential block design here ---- //

//All outputs should be synchronized at clock rising edge.
//reset signal
always@(posedge i_clk or negedge i_rst_n )begin
	if(!i_rst_n)begin
		//output register
		o_in_ready_r <= 1'b1;
		//o_in_ready_w <= 1'b1;
		o_out_valid_r <= 0;
		//o_out_valid_w <= 0;
		o_out_data_r <= 0;
		//o_out_data_w <= 0;
	end
	else begin
		o_in_ready_r <= o_in_ready_w;
		o_out_valid_r <= o_out_valid_w;
		o_out_data_r <= o_out_data_w;
	end
end

always@(negedge i_clk  or negedge i_rst_n )begin
	if(!i_rst_n)begin
		//initialize

		for(i=0; i<16; i=i+1) output_img[i] <= 0;
		for(j=0; j<64; j=j+1) input_img[j]  <= 0;
		//for(k=0; k<64; k=k+1) next_input_img[k] <= 0;

		fsm_state       <= 3'b001; 
		//next_fsm_state  <= 3'b001;

		register_no      <= 0;
		//next_register_no <= 0;

		origin_point      <= 0;
		//next_origin_point <= 0;

		output_counter      <= 0;
		//next_output_counter <= 0;

		output_position     <= 0;
		position_bias       <= 0;

		for(n=0; n<64;n=n+1) yr[n] <= 0; 
		for(o=0; o<64;o=o+1) yg_1[o] <= 0; 
		for(p=0; p<64;p=p+1) yg_2[p] <= 0;
		for(q=0; q<64;q=q+1) y_sum[q] <= 0;
		for(r=0; r<64;r=r+1) y_sum_round[r] <= 0;

		for(nn=0; nn<64;nn=nn+1) cb_r[nn] <= 0;
		for(oo=0; oo<64;oo=oo+1) cb_g[oo] <= 0;
		for(pp=0; pp<64;pp=pp+1) cb_b[pp] <= 0;
		for(qq=0; qq<64;qq=qq+1) cb_sum[qq] <= 0;
		for(rr=0; rr<64;rr=rr+1) cb_sum_round[rr] <= 0;
		
		for(nnn=0; nnn<64;nnn=nnn+1) cr_r[nnn]  <= 0;
		for(ooo=0; ooo<64;ooo=ooo+1) cr_g1[ooo] <= 0;
		for(ppp=0; ppp<64;ppp=ppp+1) cr_g2[ppp] <= 0;
		for(qqq=0; qqq<64;qqq=qqq+1) cr_b[qqq]  <= 0;
		for(rrr=0; rrr<64;rrr=rrr+1) cr_sum[rrr]<= 0;
		for(sss=0; sss<64;sss=sss+1) cr_sum_round[sss] <= 0;

		ycbcr_mode <= 0;
		
		for(s=0; s<64; s=s+1) current_ycbcr_img[s] <= 0;
		for(t=0; t<64; t=t+1) next_current_ycbcr_img[t] <= 0;

		filter_counter <= 0;
		for(latch_4=0;latch_4<64;latch_4=latch_4+1) filter_img[latch_4] <=0;

		/*
		m11_r_w	<= 0;
		m21_r_w	<= 0;	
		m31_r_w <= 0;

		m12_r_w <= 0;
		m22_r_w <= 0;
		m32_r_w <= 0;

		m13_r_w <= 0;
		m23_r_w <= 0;
		m33_r_w <= 0;

		m11_g_w	<= 0;
		m21_g_w	<= 0;	
		m31_g_w <= 0;

		m12_g_w <= 0;
		m22_g_w <= 0;
		m32_g_w <= 0;

		m13_g_w <= 0;
		m23_g_w <= 0;
		m33_g_w <= 0;

		m11_b_w	<= 0;
		m21_b_w	<= 0;	
		m31_b_w <= 0;

		m12_b_w <= 0;
		m22_b_w <= 0;
		m32_b_w <= 0;

		m13_b_w <= 0;
		m23_b_w <= 0;
		m33_b_w <= 0;
		*/

		//---memory-----
		sram_wen_w <= 0;
		sram_a_w <= 0;
		sram_d_w <= 0;
		//--------------
	end
	else begin
		fsm_state <= next_fsm_state;
		register_no <= next_register_no;
		origin_point <= next_origin_point;
		output_counter <= next_output_counter;
		ycbcr_mode <= next_ycbcr_mode;
		for(kk=0; kk<64; kk=kk+1) input_img[kk] <= next_input_img[kk];
		
		filter_counter <= next_filter_counter;
		for(latch_6=0; latch_6 <64;latch_6 = latch_6 + 1) filter_img[latch_6] <= next_filter_img[latch_6];
		/*
		m11_r_w	<= next_m11_r_w;
		m21_r_w	<= next_m21_r_w;	
		m31_r_w <= next_m31_r_w;

		m12_r_w <= next_m12_r_w;
		m22_r_w <= next_m22_r_w;
		m32_r_w <= next_m32_r_w;

		m13_r_w <= next_m13_r_w;
		m23_r_w <= next_m23_r_w;
		m33_r_w <= next_m33_r_w;

		m11_g_w	<= next_m11_g_w;
		m21_g_w	<= next_m21_g_w;	
		m31_g_w <= next_m31_g_w;

		m12_g_w <= next_m12_g_w;
		m22_g_w <= next_m22_g_w;
		m32_g_w <= next_m32_g_w;

		m13_g_w <= next_m13_g_w;
		m23_g_w <= next_m23_g_w;
		m33_g_w <= next_m33_g_w;

		m11_b_w	<= next_m11_b_w;
		m21_b_w	<= next_m21_b_w;	
		m31_b_w <= next_m31_b_w;

		m12_b_w <= next_m12_b_w;
		m22_b_w <= next_m22_b_w;
		m32_b_w <= next_m32_b_w;

		m13_b_w <= next_m13_b_w;
		m23_b_w <= next_m23_b_w;
		m33_b_w <= next_m33_b_w;
		*/


		//----memory---
		sram_wen_w <= next_sram_wen_w;
		sram_a_w <= next_sram_d_w;
		sram_d_w <= next_sram_a_w;
		//----memory---

	end	
end


endmodule


// modules for choose the median
//moduele for only 3 numbers
//------------------------

module sort_3_number(

	input [7:0] num1,
	input [7:0] num2,
	input [7:0] num3,

	output [7:0] max,
	output [7:0] mid,
	output [7:0] min

);

reg [7:0] next_max;
reg [7:0] next_mid;
reg [7:0] next_min;

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

sort_3_number column_1(
	.num1(i_position_1_1),
	.num2(i_position_2_1),
	.num3(i_position_3_1),
	
	.max(temp_1_1),
	.mid(temp_2_1),
	.min(temp_3_1)
);
sort_3_number column_2(
	.num1(i_position_1_2),
	.num2(i_position_2_2),
	.num3(i_position_3_2),
	
	.max(temp_1_2),
	.mid(temp_2_2),
	.min(temp_3_2)
);

sort_3_number column_3(
	.num1(i_position_1_3),
	.num2(i_position_2_3),
	.num3(i_position_3_3),
	
	.max(temp_1_3),
	.mid(temp_2_3),
	.min(temp_3_3)
);

sort_3_number row_1(
	.num1(temp_1_1),
	.num2(temp_1_2),
	.num3(temp_1_3),
	
	.max(temp_max_1),
	.mid(temp_max_2),
	.min(temp_max_3)
);
sort_3_number row_2(
	.num1(temp_2_1),
	.num2(temp_2_2),
	.num3(temp_2_3),
	
	.max(temp_mid_1),
	.mid(temp_mid_2),
	.min(temp_mid_3)
);
sort_3_number row_3(
	.num1(temp_3_1),
	.num2(temp_3_2),
	.num3(temp_3_3),
	
	.max(temp_min_1),
	.mid(temp_min_2),
	.min(temp_min_3)
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

