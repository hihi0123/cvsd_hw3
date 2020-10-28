
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

//fsm state
reg [ 2:0]  fsm_state;

//store input image
reg [23:0]  input_img [0:63];

//store output image
reg [23:0] output_img [0:15];

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
always(fsm_state)begin
	case(fsm_state)
	
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

endmodule
