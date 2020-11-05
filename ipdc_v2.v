
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
reg [23:0]  input_img [0:63];

//store output image
reg [23:0] output_img [0:15];

//fsm state
reg [2:0] fsm_state, next_fsm_state;

//the position to store the loading image
reg [6:0] register_no, next_register_no;

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
	4'b000:begin
		next_fsm_state = fsm_state + 3'b001;
	end
	4'b001:begin
		case(i_op_valid_w)
		1'b1:begin
			//case when i_op_mode is valid
			case(i_op_mode_w)
			3'b000:begin
				//loading image, no display
				next_fsm_state = fsm_state + 3'b001;
			end
			3'b001:begin
				//origin right shift, adjust the origin, need display
			end
			3'b010:begin
				//origin down shift, adjust the origin, need display
			end
			3'b011:begin
				//default origin, shift the origin to 0, need display
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
	4'b010:begin
		//load state
		if(i_in_data_w == 1'b1)begin
			if(i_in_data_w == 1'b1)begin
				input_img[register_no] = i_in_data_w;
				next_register_no = register_no + 1;
			end
		end
	end
	4'b011:begin
		
	end
	4'b100:begin
		
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
		i_op_valid_w <= 0;
		i_op_mode_w <= 0;
		i_in_valid_w <= 0;
		i_in_data_w  <= 0;

		for(i=0; i<16; i++) output_img[i] <= 0;
		for(i=0; i<64; i++) input_img[j]  <= 0;

		fsm_state       <= 0; 
		next_fsm_state  <= 0;

		register_no      <= 0;
		next_register_no <= 0;

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
end

always(@negedge i_clk)begin
	fsm_state <= next_fsm_state;
end




endmodule
