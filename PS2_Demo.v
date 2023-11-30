module PS2_Demo (
	// Inputs
	Clock,
	Reset,
	ps2_key_data,
	ps2_key_pressed,
	VolumeOn,
	PitchOn,
	DistortionOn,
	SetVolume,
	SetPitch,
	SetDistortion,
	
	// Outputs
	VolumeGo,
	PitchGo,
	DistortionGo,
	EffectGo,
	volume_data,
	pitch_data,
	distortion_data,
	data
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

 parameter 	S_MAIN 			= 4'd0,
				S_VOLUME 		= 4'd1,
				S_PITCH 			= 4'd2,
				S_DISTORTION 	= 4'd3,
				S_L1 				= 4'd4,
				S_L1_SAVE 		= 4'd5,
				S_L1_WAIT 		= 4'd6,
				S_L2 				= 4'd7,
				S_L2_SAVE 		= 4'd8,
				S_L2_WAIT 		= 4'd9,
				S_L3 				= 4'd10,
				S_L3_SAVE 		= 4'd11,
				S_L3_WAIT 		= 4'd12,
				S_SETDATA		= 4'd13,
				S_OUTPUT			= 4'd14;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				Clock;
input				Reset;
input 	[7:0] ps2_key_data;
input				ps2_key_pressed;
input				VolumeOn;
input 			PitchOn;
input				DistortionOn;
input				SetVolume;
input				SetPitch;
input 			SetDistortion;

// Outputs
output reg			VolumeGo;
output reg			PitchGo;
output reg 			DistortionGo;
output reg 			EffectGo;
output reg 	[6:0] volume_data;
output reg 	[6:0] pitch_data;
output reg 	[6:0] distortion_data;
output reg [11:0] data;


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
reg		[3:0] input_num;

// Internal Registers
reg		[3:0] current_state;
reg		[3:0] next_state;
reg	  [23:0] loop1;
reg	  [23:0] loop2;
reg	  [23:0] loop3;
reg		[6:0] final_data;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

// Always block to convert ps2_key_data into numbers
always @(posedge Clock)
begin
	case (ps2_key_data)
		8'h45: input_num = 4'b0000; 		//0
		8'h16: input_num = 4'b0001; 		//1
		8'h1E: input_num = 4'b0010; 		//2
		8'h26: input_num = 4'b0011; 		//3
		8'h25: input_num = 4'b0100; 		//4
		8'h2E: input_num = 4'b0101; 		//5
		8'h36: input_num = 4'b0110; 		//6
		8'h3D: input_num = 4'b0111; 		//7
		8'h3E: input_num = 4'b1000; 		//8
		8'h46: input_num = 4'b1001; 		//9
		default: input_num = 4'b0000;
	endcase
end
		

// FSM to accept 3 user-inputted numbers
always @(posedge Clock) 
begin
	case (current_state)
		S_MAIN: begin
			if (VolumeOn) begin
				if (SetVolume) begin
					next_state <= S_VOLUME;
				end
			end 
			else if (PitchOn) begin
				if (SetPitch) begin
					next_state <= S_PITCH;
				end
			end 
			else if (DistortionOn) begin
				if (SetDistortion) begin
					next_state <= S_DISTORTION;
				end
			end 
			else begin
				next_state <= S_MAIN;
			end
		end
		
		// Purpose of these states is to set control signals
		S_VOLUME: 		begin next_state <= S_L1;	end
		S_PITCH: 		begin next_state <= S_L1;	end
		S_DISTORTION: 	begin next_state <= S_L1;	end
		
		S_L1: begin
			if (ps2_key_pressed) begin
				next_state <= S_L1_SAVE;
			end else
				next_state <= S_L1;
		end
		
		S_L1_SAVE: begin next_state <= S_L1_WAIT; end
		
		S_L1_WAIT: begin
			if (loop1 == 24'd12500000) begin
				next_state <= S_L2;
			end else begin
				next_state <= S_L1_WAIT;
			end
		end
		
		S_L2: begin
			if (ps2_key_pressed) begin
				next_state <= S_L2_SAVE;
			end else begin
				next_state <= S_L2;
			end
		end
		
		S_L2_SAVE: begin next_state <= S_L2_WAIT; end
		
		S_L2_WAIT: begin
			if (loop2 == 24'd12500000) begin
				next_state <= S_L3;
			end else begin
				next_state <= S_L2_WAIT;
			end
		end
		
		S_L3: begin
			if (ps2_key_pressed) begin
				next_state <= S_L3_SAVE;
			end else begin
				next_state <= S_L3;
			end
		end
		
		S_L3_SAVE: begin next_state <= S_L3_WAIT; end
		
		S_L3_WAIT: begin
			if (loop3 == 24'd12500000) begin
				next_state <= S_SETDATA;
			end else begin
				next_state <= S_L3_WAIT;
			end
		end
		
		S_SETDATA: begin 
			if (ps2_key_data == 8'h5A) begin
				next_state <= S_OUTPUT;
			end else begin
				next_state <= S_SETDATA; 
			end
		end
		
		S_OUTPUT: begin next_state <= S_MAIN; end
		
		default: next_state <= S_MAIN;
	endcase
end


always @(posedge Clock)
begin
	if (Reset) begin
		current_state <= S_MAIN;
	end else begin
		if (VolumeGo) begin
			if (!VolumeOn) begin current_state <= S_MAIN; end
		end else if (PitchGo) begin
			if (!PitchOn) begin current_state <= S_MAIN; end
		end else if (DistortionGo) begin
			if (!DistortionOn) begin current_state <= S_MAIN; end
		end else begin
			current_state <= next_state;
		end
	end
end


// Control Signals
always @(*)
begin
	if (Reset) begin
		volume_data <= 7'b0;
		pitch_data <= 7'b0;
		distortion_data <= 7'b0;
	end else begin
		case (current_state)
			S_MAIN: begin VolumeGo 		= 1'b0; 
							  PitchGo 		= 1'b0; 
							  DistortionGo = 1'b0; 
							  EffectGo 		= 1'b0;
							  loop1 			= 24'b0;
							  loop2 			= 24'b0;
							  loop3 		 	= 24'b0;
							  data			= 12'b0;
							  final_data 	= 7'b0;
					  end
			S_VOLUME: VolumeGo = 1'b1;
			S_PITCH: PitchGo = 1'b1;
			S_DISTORTION: DistortionGo = 1'b1;
			S_L1_SAVE: data [11:8] = input_num;
			S_L1_WAIT: loop1 = loop1 + 1'b1;
			S_L2_SAVE: data  [7:4] = input_num;
			S_L2_WAIT: loop2 = loop2 + 1'b1;
			S_L3_SAVE: data  [3:0] = input_num;
			S_L3_WAIT: loop3 = loop3 + 1'b1;
			S_SETDATA: begin
								if (((data [11:8] * 7'd100) + (data [7:4] * 4'd10) + data [3:0]) > 7'd100) begin
									final_data = 7'd100;
								end else begin
									final_data = ((data [11:8] * 7'd100) + (data [7:4] * 4'd10) + data [3:0]);
								end
								
								if (VolumeGo) begin 					volume_data = final_data;							
								end else if (PitchGo) begin 		pitch_data = final_data;
								end else if (DistortionGo) begin distortion_data = final_data;
								end
						  end
			S_OUTPUT: EffectGo = 1'b1;
		endcase
	end
end


endmodule
