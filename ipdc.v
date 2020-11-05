
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

//an counter for loading image
integer register_no, temp_register_no;
integer i, j;
integer counter_for_loading, temp_for_counter;
//integer origin_point;
//integer temp_for_origin_point;
reg [5:0] origin_point;
reg [5:0] temp_for_origin_point;

//which position to output
reg [5:0] out_position;
reg [5:0] position_bias;

//output cycles counters
reg  [4:0]  output_counter;

//output register
reg 	   o_in_ready_w, o_in_ready_r;
reg        o_out_valid_w, o_out_valid_r;
reg [23:0] o_out_data_w, o_out_data_r;

//input register
reg        i_op_valid_w;
reg [ 2:0] i_op_mode_w;
reg 	   i_in_valid_w;
reg [23:0] i_in_data_w;      

//fsm state
reg [ 2:0]  fsm_state;

//store input image
reg [23:0]  input_img [0:63];

//store output image
reg [23:0] output_img [0:15];

//loading flag
reg        loading_flag;

//state choosing flag
reg        state_change;

//decide jump to output or jump to process
reg        output_flag;

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
always(state_change)begin
	
	//o_out_valid_w = 1'b1;

	case(fsm_state)
	3'b000:begin
		//initial state, never in this state,do nothing
	end
	3'b001:begin   
		//operation mode choosing state
		case(i_op_valid_w)
		1'b1:begin
			//case when i_op_mode is valid
			case(i_op_mode_w)
			3'b000:begin
				//loading image, no display
				loading_flag = 1'b1;
			end
			3'b001:begin
				//origin right shift, adjust the, need display
				loading_flag = 0;
				temp_for_origin_point = origin_point + 6'b1;
				origin_point = temp_for_origin_point;
				//check if output will exceeds the image boundary
				if((origin_point % 6'd8) > 6'd4)begin
					//output will exceed, retain the same
					temp_for_origin_point = origin_point - 6'b1;
					origin_point = temp_for_origin_point;
				end
				output_flag = 1;
				
			end
			3'b010:begin
				//origin down shift, need display
				temp_for_origin_point = origin_point 
			end
			3'b011:begin
				//default origin, need display
			end
			3'b100:begin
				//zoom-in, need display
			end
			3'b101:begin
				//median filter operation, no display
			end
			3'b110:begin
				//YCbCr, no display
			end
			3'b111:begin
				//RGB display, no display
			end
		end
		1'b0:begin
			//case when i_op_mode is not valid, re-choosing
			fsm_state = 3'b000;
		end
	end
	3'b010:begin
		//loading image state
		if(i_in_data_w == 1'b1)begin			
			input_img[register_no] = i_in_data_w;
			temp_register_no = register_no + 1;
			register_no = temp_register_no;
		end
		else begin
			//loading finish
			loading_flag = 1'b0;
			register_no = 0;
			temp_register_no = 0;
		end
	end
	3'b011:begin
		//loading state finish, set o_out_valid state only 1cycles
		o_out_valid_w = 1'b1;
	end
	3'b100:begin
		//processing state
		if(output_flag==1)begin
			output_counter = 5'b00000;
		end
		else begin
			//process the image
		end
	end
	3'b101:begin
		//output 16 cycles state
		if(output_counter != 5'b10000)begin
			position_bias = (output_counter / 5'd4) * 5'd4 + output_counter;
			out_position = position_bias + origin_point;
			o_out_valid_w = 1'b1;
			o_out_data_w = input_img[out_position];
		end
	end
	default:begin
		
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
		o_in_ready_r  <= 1'b1;   //not for sure
		o_out_valid_r <= 0;
		o_out_data_r  <= 0;

		//my register
		i_op_valid_w  <= 0;
        i_op_mode_w   <= 0;
        i_in_valid_w  <= 0;
        i_in_data_w   <= 0;    

		o_in_ready_w  <= 1'b1;    //not for sure
		o_out_valid_w <= 0;
		o_out_data_w  <= 0;

		fsm_state     <= 0;

		input_img     <= 0;
		output_img    <= 0; 

		register_no          <= 0;
		temp_register_no     <= 0;

		state_change  <= 0;

		origin_point <= 0;
		temp_for_origin_point <= 0;

		output_flag <= 0;

		output_counter <=0;

		for(i=0; i<16; i++) output_img[i] <= 0;
		for(i=0; i<64; i++) input_img[j]  <= 0;
	end
	else begin 
		o_in_ready_r <= o_in_ready_w;
		o_out_valid_r <= o_out_valid_w;
		o_out_data_r <= o_out_data_w;
	end
end

//All inputs are synchronized with the negative edge clock
always(@negedge i_clk)begin
	 i_op_valid_w <= i_op_valid;
	 i_op_mode_w  <= i_op_mode;
	 i_in_valid_w <= i_in_valid;
	 i_in_data_w  <= i_in_data;
	 
	 state_change <= ~state_change;

	 if(fsm_state == 3'b000)begin
		 //"initial state" jump to "choosing operation mode state"
		 fsm_state <= 3'b001;
	 end
	 else if(fsm_state == 3'b001 && loading_flag != 0)begin
		 //from "choosing operation mode state" jump to "loading state"
		 fsm_state <= 3'b010;
	 end
	 else if(fsm_state == 3'b001 && loading_flag == 0)begin
		 //from "choosing operation mode state" jump to "processing state"
		 fsm_state <= 3'b100;
	 end
	 else if(fsm_state == 3'b010 && loading_flag !=0)begin
		 //from "loading state" jump to "loading state", keep loading
		 fsm_state <= 3'b010;
	 end
	 else if(fsm_state == 3'b010 && loading_flag ==0)begin
		 //loading finish, from "loading state" jump to "load set o_out_valid state"
		 fsm_state <= 3'b011;
	 end
	 else if(fsm_state == 3'b011)begin
		 //from "load set o_out_valid state"  jump to "choosing operation mode state"
		 fsm_state <= 3'b001;
	 end
	 else if(fsm_state == 3'b100 && output_flag != 0)begin
		 //from "processing state" jump to "output 16cycle state"
		 fsm_state <= 101;
	 end
	 else if(fsm_state == 3'b100 && output_flag == 0)begin
		 //from "processing state" jump to ""
	 end
	 else if(fsm_state == 3'b101)begin
		 //from output 16cycles state jump to
	 end

end

endmodule
