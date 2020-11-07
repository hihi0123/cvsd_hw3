
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
/*reg        i_op_valid_w;
reg [ 2:0] i_op_mode_w;
reg 	   i_in_valid_w;
reg [23:0] i_in_data_w;  */

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
integer k,l;
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

//detect the mode to output
integer s,t;
reg ycbcr_mode;
reg [23:0] current_ycbcr_img [0:63];
reg [23:0] next_current_ycbcr_img [0:63];


// ---------------------------------------------------------------------------
// Continuous Assignment
// ---------------------------------------------------------------------------
// ---- Add your own wire data assignments here if needed ---- //
assign o_in_ready = o_in_ready_r;
assign o_out_valid = o_out_valid_r;
assign o_out_data = o_out_data_r


// ---------------------------------------------------------------------------
// Combinational Blocks
// ---------------------------------------------------------------------------
// ---- Write your conbinational block design here ---- //
always(*)begin
	case(fsm_state)
	3'b000:begin
		//do no operation
		next_fsm_state = fsm_state + 3'b001;
	end
	3'b001:begin
		//after loading finished,need to reset the o_out_valid_w
		o_out_valid_w = 1'b0;

		case(i_op_valid)
		1'b1:begin
			//case when i_op_mode is valid
			case(i_op_mode)
			3'b000:begin
				//loading image, no display
				next_fsm_state = fsm_state + 3'b001;
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
			end
			3'b011:begin
				//default origin, shift the origin to 0, need display
				next_origin_point = 0;
				//go to output 16 cycles state
				next_fsm_state = 3'b100;
			end
			3'b100:begin
				//zoom-in, shift the origin to 18, need display
				next_origin_point = 7'b0010010;
				next_fsm_state = 3'b100;
			end
			3'b101:begin
				//median filter, no display
				

			end
			3'b110:begin
				//YcbCr, no display
				//calculate Ycbcr
				ycbcr_mode = 1'b1;

				for(m=0;m<64;m++)begin
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
					if(y_sum_round[m] > 9'b0_1111_1111)begin
						next_input_img[m][7:0] = 8'b1111_1111; 
					end
					else begin
						next_input_img[m][7:0] = y_sum_round[m][7:0];
					end
					//-----------cb = -0.125R -0.25 G +0.5 B +128-----//
					cb_r[m]  = {{4{1'b0}},input_img[m][7:0]};
					cb_g[m]  = {{3{1'b0}},input_img[m][15:8],{1'b0}};
					cb_b[m]  = {{2{1'b0}},input_img[m][23:16],{2{1'b0}}};
					cb_sum[m] = cb_b[m] - cb_r[m] - cb_g[m];
					if(cb_sum[m][2]==1'b1)begin                           //2^7 = 128 
						cb_sum_round = cb_sum[m][11:3] + 9'b0_0000_0001+9'b0_1000_0000;
					end
					else begin
						cb_sum_round = cb_sum[m][11:3];
					end
					if(cb_sum_round > 9'b0_1111_1111)begin
						next_input_img[15:8] = 8'b1111_1111;
					end
					else begin
						
					end
					

				end
				
			end
			3'b111:begin
				//RGB mode no display
				ycbcr_mode = 1'b0;
			end
		end
		1'b0:begin
			//case when i_op_mode is not valid, re-choosing
			next_fsm_state = 3'b001;
		end
	end
	3'b010:begin
		//load state
		if(i_in_data == 1'b1)begin
			input_img[register_no] = i_in_data_w;
			next_register_no = register_no + 7'b0000001;			
			next_fsm_state = 3'b010;
		end
		else begin
			next_register_no = 0;
			next_fsm_state = 3'b011;
		end
	end
	3'b011:begin
		//loading finish, set the o_out_valid 1 cycle
		o_out_valid_w = 1'b1;
		next_fsm_state = 3'b001;
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
		else begin
			
		end
	end

end



// ---------------------------------------------------------------------------
// Sequential Block
// ---------------------------------------------------------------------------
// ---- Write your sequential block design here ---- //

//All outputs should be synchronized at clock rising edge.
//reset signal
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin
		//initialize

		//output register
		o_in_ready_r <= 1'b1;
		o_in_ready_w <= 1'b1;
		o_out_valid_r <= 0;
		o_out_valid_w <= 0;
		o_out_data_w <= 0;
		o_out_data_r <= 0;

		//input register
		/*i_op_valid_w <= 0;
		i_op_mode_w <= 0;
		i_in_valid_w <= 0;
		i_in_data_w  <= 0;*/

		for(i=0; i<16; i++) output_img[i] <= 0;
		for(j=0; j<64; j++) input_img[j]  <= 0;

		fsm_state       <= 0; 
		next_fsm_state  <= 0;

		register_no      <= 0;
		next_register_no <= 0;

		origin_point      <= 0;
		next_origin_point <= 0;

		output_counter      <= 0;
		next_output_counter <= 0;

		output_position     <= 0;
		position_bias       <= 0;

		for(n=0; n<64;n++) yr[n] <= 0; 
		for(o=0; o<64;o++) yg_1[o] <= 0; 
		for(p=0; p<64;p++) yg_2[p] <= 0;
		for(q=0; q<64;q++) y_sum[q] <= 0;
		for(r=0; r<64;r++) y_sum_round[r] <= 0;

		for(nn=0; nn<64;nn++) cb_r[nn] <= 0;
		for(oo=0; oo<64;oo++) cb_g[oo] <= 0;
		for(pp=0; pp<64;pp++) cb_b[pp] <= 0;
		for(qq=0; qq<64;qq++) cb_sum[qq] <= 0;
		for(rr=0; rr<64;rr++) cb_sum_round[rr] <= 0;
		
		ycbcr_mode <= 0;
		for(s=0; s<64; s++) current_ycbcr_img[s] <= 0;
		for(t=0; t<64; t++) next_current_ycbcr_img[t] <= 0;

		for(k=0; k<64; k++) next_input_img[k] <= 0;

	end
	else begin
		o_in_ready_r <= o_in_ready_w;
		o_out_valid_r <= o_out_valid_w;
		o_out_data_r <= o_out_data_w;
	end
end
//這段要拿掉，input應該可以直接拿來用
//All inputs are synchronized with the negative edge clock
/*always(@negedge i_clk)begin
	i_op_valid_w <= i_op_valid;
	i_op_mode_w  <= i_op_mode;
	i_in_valid_w <= i_in_valid;
	i_in_data_w  <= i_in_data;
end*/

always(@negedge i_clk)begin
	fsm_state <= next_fsm_state;
end

always(@negedge i_clk)begin
	register_no <= next_register_no;
end

always(@negedge i_clk)begin
	origin_point <= next_origin_point;
end

always(@negedge i_clk)begin
	output_counter <= next_output_counter;
end

always(@negedge i_clk)begin
	for(k=0; k<64; k++) input_img[k] <= next_input_img[k];
end

endmodule
