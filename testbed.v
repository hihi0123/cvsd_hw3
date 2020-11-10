`timescale 1ns/100ps
`define CYCLE       100.0     // CLK period.
`define HCYCLE      (`CYCLE/2)
`define MAX_CYCLE   10000
`define RST_DELAY   5

`define tb0   1




`ifdef tb1
    `define INFILE "./PATTERN/indata1.dat"
    `define OPFILE "./PATTERN/opmode1.dat"
    `define GOLDEN "./PATTERN/golden1.dat"
`elsif tb2
    `define INFILE "./PATTERN/indata2.dat"
    `define OPFILE "./PATTERN/opmode2.dat"
    `define GOLDEN "./PATTERN/golden2.dat"
`else
    `define INFILE "./PATTERN/indata0.dat"
    `define OPFILE "./PATTERN/opmode0.dat"
    `define GOLDEN "./PATTERN/golden0.dat"
`endif

`define SDFFILE "ipdc_syn.sdf"  // Modify your sdf file name



module testbed;

    reg clk, rst_n;
    wire        op_valid;
    wire [ 2:0] op_mode;
    wire        in_valid;
    wire [23:0] in_data;
    wire        in_ready;
    wire        out_valid;
    wire [23:0] out_data;

    reg [23:0] indata_mem [ 63:0];
    reg [ 2:0] opmode_mem [ 63:0];
    reg [23:0] golden_mem [511:0];


    // ==============================================
    // TODO: Declare regs and wires you need
    // ==============================================
    
    reg                 op_valid_w, op_valid_r;
    reg     [ 2:0]      op_mode_w, op_mode_r;
    reg                 in_valid_w, in_valid_r;
    reg     [23:0]      in_data_w, in_data_r;

    reg                 flag_rst;
    reg                 flag_out_valid;
    reg     [5:0]       op_idx, op_idx_w;
    reg     [6:0]       data_idx, data_idx_w;
    reg     [8:0]       golden_idx, golden_idx_w;

    integer             g_idx;



    reg                 status, status_w;

    assign      op_valid    =   op_valid_r;
    assign      op_mode     =   op_mode_r;
    assign      in_valid    =   in_valid_r;
    assign      in_data     =   in_data_r;


    // For gate-level simulation only
    `ifdef SDF
        initial $sdf_annotate(`SDFFILE, u_ipdc);
        initial #1 $display("SDF File %s were used for this simulation.", `SDFFILE);
    `endif

    // Write out waveform file
    initial begin
    $fsdbDumpfile("ipdc.fsdb");
    $fsdbDumpvars(0, "+mda");
    end


    ipdc u_ipdc (
        .i_clk(clk),
        .i_rst_n(rst_n),


        .i_op_valid(op_valid),
        .i_op_mode(op_mode),
        .i_in_valid(in_valid),
        .i_in_data(in_data),


        .o_in_ready(in_ready),
        .o_out_valid(out_valid),
        .o_out_data(out_data)
    );

    // Read in test pattern and golden pattern
    initial $readmemb(`INFILE, indata_mem);
    initial $readmemb(`OPFILE, opmode_mem);
    initial $readmemb(`GOLDEN, golden_mem);

    // Clock generation
    initial clk = 1'b0;
    always begin #(`CYCLE/2) clk = ~clk; end

    // Reset generation
    initial begin
        rst_n = 1; # (               0.25 * `CYCLE);
        rst_n = 0; # ((`RST_DELAY - 0.25) * `CYCLE);
        rst_n = 1; # (         `MAX_CYCLE * `CYCLE);
        $display("the last op mode is %d", op_mode);
        $display("Error! Runtime exceeded!");
        $finish;
    end

    // ==============================================
    // TODO: Check pattern after process finish
    // ==============================================

    always@(*) begin
        
        status_w = status;
        in_valid_w = in_valid;
        in_data_w = in_data_r;

        op_valid_w = 0;
        op_idx_w = op_idx;
	    op_mode_w = op_mode_r;
        golden_idx_w = golden_idx;


        if(rst_n && (!flag_rst) ) begin
            op_valid_w = 1;
            op_mode_w = opmode_mem[op_idx];
            op_idx_w = (op_idx + 1)%64;
            status_w = 1;

        end
        else if(flag_out_valid && (!out_valid))begin
            op_valid_w = 1;
            op_mode_w = opmode_mem[op_idx];
            op_idx_w = (op_idx +1)%64;

        end
        
        
        

        case(status)

            0: begin
                in_data_w = 0;
                data_idx_w = 0;
                in_valid_w = 0;
            end

            1: begin
                in_data_w = in_data_r;
                in_valid_w = 1;
                data_idx_w = data_idx;

                if(in_ready) begin
                    in_data_w = indata_mem[ data_idx ][23:0];
                    data_idx_w = data_idx + 1;
                    
                    if(data_idx == 64 && in_ready) begin
                        status_w = 0;
                        in_valid_w = 0;
                    end
                end
                    
            end

        endcase     
        
    end


    always@(negedge clk or negedge rst_n) begin
        if(!rst_n) begin
            op_valid_r <= 0;
            op_mode_r <= 0;
            in_valid_r <= 0;
            in_data_r <= 0;

            flag_rst <= 0;
            flag_out_valid <= 0;

            op_idx <= 0;
            data_idx <= 0;
            golden_idx <= 0;
            status <= 0;
            g_idx = 0;

        end
        else begin

            
            
            op_valid_r <= op_valid_w;
            op_mode_r <= op_mode_w;
            in_valid_r <= in_valid_w;
            in_data_r <= in_data_w;

            flag_rst <= 1;
            flag_out_valid <= out_valid   ?   1:0;

            op_idx <= op_idx_w;
            data_idx <= data_idx_w;
            golden_idx <= golden_idx_w;
            status <= status_w;


            if(out_valid && (op_mode!=5) && (op_mode!=6) && (op_mode!=7)) begin
                if(out_data!==golden_mem[g_idx]) begin
                    if((op_mode!=0) && (op_mode!=5) && (op_mode!=6) && (op_mode!=7)) begin
                        $display("================================================================================");
                        $display(" op_idx: %d,\n op_mode: %d,\n golden_idx: %d\n ERROR!", op_idx, op_mode, g_idx );
                        $display(" out_data: %x\n", out_data);
                        $display(" golden_mem: %x\n", golden_mem[g_idx]);
                        $display("================================================================================");

                        g_idx = g_idx + 1;
                    end

                end
                else begin
                    
                    $display("################################################################################");
                    $display(" op_idx: %d,\n op_mode: %d,\n golden_idx: %d\n PASS!", op_idx, op_mode, g_idx );
                    $display(" out_data: %x\n", out_data);
                    $display(" golden_mem: %x\n", golden_mem[g_idx]);
                    $display("#################################################################################");
                    //$display("PASS!");

                    g_idx = g_idx + 1;
                end
            end

        end





    end

endmodule
