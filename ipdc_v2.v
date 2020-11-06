
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
reg [23:0]  input_img [0:63];

//store output image
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
			end
			3'b100:begin
				//zoom-in, shift the origin to 18, need display
			end
			3'b101:begin
				//median filter, no display
			end
			3'b110:begin
				//YcbCr, no display
			end
			3'b111:begin
				//RGBm no display
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
	3'b100:begin
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
		for(i=0; i<64; i++) input_img[j]  <= 0;

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


endmodule
