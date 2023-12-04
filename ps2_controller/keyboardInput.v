module keyboardInput(
	input wire Clock, Reset_n, key_pressed;
	input wire LoadedNum1, LoadedNum2, LoadedNum3, Done;
	input wire [7:0] received_data;
	output reg [7:0] final_data,
	output reg enter_key_pressed;
);
	
	reg [10:0] calculated_data;
	
//			Data from the PS2 keyboard is sent in as 11-bits which is 
//			described as follows:
//				shift_register[9]       : Start bit (must go high->low
//				shift_register[7:0]     : 8 inputted data bits
//			For the purposes of our final project, we will use:
//				- Keys 0-9 (hexadecimal 0x29 - 0x32)
//					Key "0": 0x29
//					Key "1": 0x22
//					Key "2": 0x1E
//					Key "3": 0x21
//					Key "4": 0x2C
//					Key "5": 0x32
//					Key "6": 0x31
//					Key "7": 0x23
//					Key "8": 0x2B
//					Key "9": 0x34
//				- <Enter> to finalize input (hexadecimal 0x5A)
//					Key "Enter": 0x5A

	always @(posedge Clock, negedge Reset_n) begin
	
		if (!Reset_n) begin
			calculated_data 	<= 11'd0;
			final_data 			<= 11'd0;
			enter_key_pressed <= 1'b0;
			
		end else begin
			if (key_pressed) begin
				if (LoadedNum1) begin
					calculated_data[10:0] <= (input_num[4:0] * 7'd100);
				end
				if (LoadedNum2) begin
					calculated_data[10:0] <= (final_data + (input_num[4:0] * 4'd10));
				end
				if (LoadedNum3) begin
					calculated_data[10:0] <= (final_data + input_num[4:0]);
				end
				if (received_data[7:0] == 8'h5A) begin
					enter_key_pressed <= 1'b1;
				end else begin
					enter_key_pressed <= 1'b0;
				end	
			end
			
			if (Done) begin
				if (calculated_data[10:0] > 7'd100) begin
					final_data <= 7'd100;
				end else begin
					final_data[7:0] <= calculated_data[7:0];				
				end
			end
		end	
	end
endmodule	
	
	

module keyboardControl(
	input wire Clock, Reset_n, iLoadNum, iLoadEnter,
	output reg LoadNum1, LoadNum2, LoadNum3, oDone
);
	
	reg [2:0] current_state, next_state;
	
	localparam	S_L1				= 3'd0;
					S_L1_WAIT		= 3'd1;
					S_L2				= 3'd2;
					S_L2_WAIT		= 3'd3;
					S_L3				= 3'd4;
					S_L3_WAIT		= 3'd5;
					S_SDATA			= 3'd6;
					S_SDATA_WAIT	= 3'd7;
					
	always @(*) begin
		case (current_state)
			S_L1: begin
				if (iLoadNum) next_state = S_L1_WAIT;
				else next_state = S_L1;
			end
			
			S_L1_WAIT: begin
				if (iLoadNum) next_state = S_L1_WAIT;
				else next_state = S_L2;
			end
			
			S_L2: begin
				if (iLoadNum) next_state = S_L2_WAIT;
				else next_state = S_L2;
			end
			
			S_L2_WAIT: begin
				if (iLoadNum) next_state = S_L2_WAIT;
				else next_state = S_L3;
			end
			
			S_L3: begin
				if (iLoadNum) next_state = S_L3_WAIT;
				else next_state = S_L3;
			end
			
			S_L3_WAIT: begin
				if (iLoadNum) next_state = S_L3_WAIT;
				else next_state = S_SDATA;
			end
				
			S_SDATA: begin
				if (iLoadEnter) next_state = S_SDATA_WAIT;
				else next_state = S_SDATA;
			end
			
			S_SDATA_WAIT: begin
				if (iLoadEnter) next_state = S_SDATA_WAIT;
				else next_state = S_L1;
			end

		endcase
	end
	
	always @(*) begin
		LoadNum1 = 1'b0;
		LoadNum2 = 1'b0;
		LoadNum3 = 1'b0;
		oDone		= 1'b0;
		
		case (current_state)
			S_L1_WAIT: begin
				LoadNum1 = 1'b1;
			end
			
			S_L2_WAIT: begin 
				LoadNum2 = 1'b1;
			end
			
			S_L3_WAIT: begin
				LoadNum3 = 1'b1;
			end
			
			S_SDATA_WAIT: begin
				oDone = 1'b1;
			end
		endcase
	end	
endmodule 