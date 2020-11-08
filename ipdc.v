
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
reg [23:0] current_ycbcr_img [0:63];
reg [23:0] next_current_ycbcr_img [0:63];

//for median filter
integer f_count_r,f_count_g, f_count_b;
reg [8:0] compare_flag[0:8];


//sram reg
reg        sram_wen; //write enable
reg [7:0]  sram_a;   //address
reg [7:0]  sram_d;   //data inputs
reg [7:0]  sram_q;   //data outputs


// ---------------------------------------------------------------------------
// Continuous Assignment
// ---------------------------------------------------------------------------
// ---- Add your own wire data assignments here if needed ---- //
assign o_in_ready = o_in_ready_r;
assign o_out_valid = o_out_valid_r;
assign o_out_data = o_out_data_r;



// ---------------------------------------------------------------------------
// Combinational Blocks
// ---------------------------------------------------------------------------
// ---- Write your conbinational block design here ---- //
always@(*)begin
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
			//condition when i_op_mode is valid
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
				// R channel
				for(f_count_r=0;f_count_r<64;f_count_r=f_count_r+1)begin
					if(f_count_r==0 || f_count_r==7 || f_count_r==56 || f_count_r==63)begin
						next_input_img[f_count_r] = 0;
					end
					else if(f_count_r == 1 || f_count_r == 2 || f_count_r == 3 || f_count_r == 4 || f_count_r == 5 || f_count_r==6)begin
						//left //f_count_r-1//
						if((input_img[f_count_r-1][7:0] >= input_img[f_count_r][7:0]) && (input_img[f_count_r-1][7:0] < input_img[f_count+1][7:0])  && (input_img[f_count_r-1][7:0] < input_img[f_count+7][7:0]) && (input_img[f_count_r-1][7:0] < input_img[f_count+8][7:0]) && (input_img[f_count_r-1][7:0] < input_img[f_count_r+9][7:0]) )begin
							next_input_img[f_count_r][7:0] = input_img[f_count_r-1][7:0];
						end
						else if((input_img[f_count_r-1][7:0] < input_img[f_count_r][7:0]) && (input_img[f_count_r-1][7:0] >= input_img[f_count+1][7:0])  && (input_img[f_count_r-1][7:0] < input_img[f_count+7][7:0]) && (input_img[f_count_r-1][7:0] < input_img[f_count+8][7:0]) && (input_img[f_count_r-1][7:0] < input_img[f_count_r+9][7:0]))begin
							next_input_img[f_count_r][7:0] = input_img[f_count_r-1][7:0];
						end
						else if((input_img[f_count_r-1][7:0] < input_img[f_count_r][7:0]) && (input_img[f_count_r-1][7:0] < input_img[f_count+1][7:0])  && (input_img[f_count_r-1][7:0] >= input_img[f_count+7][7:0]) && (input_img[f_count_r-1][7:0] < input_img[f_count+8][7:0]) && (input_img[f_count_r-1][7:0] < input_img[f_count_r+9][7:0]))begin
							next_input_img[f_count_r][7:0] = input_img[f_count_r-1][7:0];
						end
						else if((input_img[f_count_r-1][7:0] < input_img[f_count_r][7:0]) && (input_img[f_count_r-1][7:0] < input_img[f_count+1][7:0])  && (input_img[f_count_r-1][7:0] < input_img[f_count+7][7:0]) && (input_img[f_count_r-1][7:0] >= input_img[f_count+8][7:0]) && (input_img[f_count_r-1][7:0] < input_img[f_count_r+9][7:0]))begin
							next_input_img[f_count_r][7:0] = input_img[f_count_r-1][7:0];
						end
						else if((input_img[f_count_r-1][7:0] < input_img[f_count][7:0]) && (input_img[f_count_r-1][7:0] < input_img[f_count+1][7:0])  && (input_img[f_count_r-1][7:0] < input_img[f_count+7][7:0]) && (input_img[f_count_r-1][7:0] < input_img[f_count+8][7:0]) && (input_img[f_count_r-1][7:0] >= input_img[f_count_r+9][7:0]))begin
							next_input_img[f_count_r][7:0] = input_img[f_count_r-1][7:0];
						end
						else begin
							//do no operation
						end
						//mid  //f_count//
						


						//right
						//left down
						//down
						//right down 
					end
					else if(f_count_r == 8 || f_count_r == 16 || f_count_r == 24 || f_count_r == 32 || f_count_r == 40 || f_count_r == 48)begin
						
					end
					else if(f_count_r == 15 || f_count_r == 23 || f_count_r == 31 || f_count_r == 39 || f_count_r == 47 || f_count_r == 55)begin
						
					end
					else if(f_count_r == 57  || f_count_r == 58 || f_count_r == 59 || f_count_r == 60 || f_count_r == 61 || f_count_r == 62)begin
						
					end
					else begin
						
					end
				end
				//G channel

				//B channel



				next_fsm_state = 3'b001;
			end
			3'b110:begin
				//YcbCr, no display
				ycbcr_mode = 1'b1;	
				next_fsm_state = 3'b001;		
			end
			3'b111:begin
				//RGB mode no display
				ycbcr_mode = 1'b0;
				next_fsm_state = 3'b001;
			end
			endcase
		end
		1'b0:begin
			//condition when i_op_mode is not valid, re-choosing
			next_fsm_state = 3'b001;
		end
		endcase
	end
	3'b010:begin
		//load state
		if(i_in_valid == 1'b1)begin
			input_img[register_no] = i_in_data;
			next_register_no = register_no + 7'b0000001;			
			next_fsm_state = 3'b010;

			//------------memory operate------------
			sram_wen = 1'b1;
			sram_a = {{1'b0},register_no};
			sram_d = i_in_data;


			//--------------------------------------
		end
		else begin
			next_register_no = 0;
			next_fsm_state = 3'b011;
			
			//------------memory operate------------
			sram_wen = 1'b0;
			sram_a = 0;
			sram_d = 0;
			//--------------------------------------
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
				cb_sum[m] = 12'b0000_1000_0000 + cb_b[m] - cb_r[m] - cb_g[m];
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
				cr_sum[m] = 12'b0000_1000_0000 + cr_r[m]-cr_g1[m]-cr_g2[m]-cr_b[m];
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
	end
	endcase
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

		for(i=0; i<16; i=i+1) output_img[i] <= 0;
		for(j=0; j<64; j=j+1) input_img[j]  <= 0;

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

		for(k=0; k<64; k=k+1) next_input_img[k] <= 0;

		//---memory-----
		sram_wen = 0;
		sram_a = 0;
		sram_d = 0;
		//--------------
	end
	else begin
		o_in_ready_r <= o_in_ready_w;
		o_out_valid_r <= o_out_valid_w;
		o_out_data_r <= o_out_data_w;
	end
end
//take this part off
//All inputs are synchronized with the negative edge clock
/*always(@negedge i_clk)begin
	i_op_valid_w <= i_op_valid;
	i_op_mode_w  <= i_op_mode;
	i_in_valid_w <= i_in_valid;
	i_in_data_w  <= i_in_data;
end*/

always@(negedge i_clk)begin
	fsm_state <= next_fsm_state;
end

always@(negedge i_clk)begin
	register_no <= next_register_no;
end

always@(negedge i_clk)begin
	origin_point <= next_origin_point;
end

always@(negedge i_clk)begin
	output_counter <= next_output_counter;
end

always@(negedge i_clk)begin
	for(kk=0; kk<64; kk=kk+1) input_img[k] <= next_input_img[k];
end



sram_256x8 u_R_sram (
        .CLK(i_clk),
        .CEN(1'b0),
        .WEN(sram_wen),
        .A(sram_a),
        .D(sram_d),   //D[7:0]
        .Q(sram_q)
    );


endmodule
