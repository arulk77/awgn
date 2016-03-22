/* 
 Project : AWGN using Box Mueler method
 Author  : Arul K. Subbiah
 Email   : asubbiah@scu.edu
 Desc    : This module produces the additive whit gaussian noise
           using the Box Mueler method
 */
module awgn 
  ( 
	 input wire 		  clk,
	 input wire 		  rst_n,
	 input wire 		  enable, 
	 input wire [15:0]  seed,
	 output wire [15:0] wnoise
	 );

	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	// Funnctions used in this module
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	function [15:0] nxt_pseudo_rndm;
		input [15:0] 	  cur_pseudo_rndm;
		reg 				  random_bit;
		begin
			random_bit = cur_pseudo_rndm[15] ^ cur_pseudo_rndm[3] ^ cur_pseudo_rndm[2] ^ cur_pseudo_rndm[0];
			nxt_pseudo_rndm = {cur_pseudo_rndm[14:0],random_bit};
		end
	endfunction // nxt_pseudo_rndm

	// Varaibles and signals for this module
   genvar 	  g_i;
	
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	// Declaration of the wire and reg
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
	// Generate 4 seeds from the given seed
	reg [15:0] l_seed [3:0];
	wire [15:0] nxt_seed [3:0];


	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	// Logic to generate multiple seeds from the single seed
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	// Detect the posedge of the enable and load the seed
	reg 		  d_enable;
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			d_enable <= 'd0;
		end else begin
			d_enable <= enable;
		end
	end

	assign load_begin = ~d_enable & enable;
	
	// Generate a loop for 4 seeds 
	generate
		for (g_i=0;g_i<4;g_i=g_i+1) begin : gen_seeds
			if(g_i == 0) begin : gen_for_s0
				assign nxt_seed[g_i] = seed ^ 16'h80f1;
			end else begin
				assign nxt_seed[g_i] =  (nxt_seed[g_i-1] << g_i) ^ 16'h80f1;
			end
			
			// Register the seed value into a flop
			always @(posedge clk or negedge rst_n) begin
				if(!rst_n) begin
					l_seed[g_i] <= 'd0;
				end else begin
					if(load_begin) begin
						l_seed[g_i] <= nxt_seed[g_i];
					end else begin
						l_seed[g_i] <= nxt_pseudo_rndm(l_seed[g_i]);
					end
				end
			end
		end
	endgenerate

	// Generate the leading zero indicator for the input
	reg [5:0] leading_zero;
	wire [31:0] u0;

	assign u0 = {l_seed[0],l_seed[1]}; // Concatenated to get a 32 bit valuenn

	integer 		i;
	always @(*) begin
		leading_zero = 0;
		for(i=0;i<32;i=i+1) begin
			if(u0[i] == 1'b1) begin
				leading_zero = i;
			end
		end
	end

	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	// ROM table entry for first order 
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
	
endmodule