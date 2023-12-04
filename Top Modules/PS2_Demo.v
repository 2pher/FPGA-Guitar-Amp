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
	VolumeTurnedOn,
	PitchTurnedOn,
	DistortionTurnedOn,
	VolumeTurnedOff,
	PitchTurnedOff,
	DistortionTurnedOff,
	VolumeBeingChanged,
	PitchBeingChanged,
	DistortionBeingChanged,
	EffectGo,
	volume_data,
	pitch_data,
	distortion_data,
	final_data,
	state
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
output reg			VolumeTurnedOn;
output reg			PitchTurnedOn;
output reg 			DistortionTurnedOn;
output reg			VolumeTurnedOff;
output reg			PitchTurnedOff;
output reg			DistortionTurnedOff;
output reg			VolumeBeingChanged;
output reg			PitchBeingChanged;
output reg 			DistortionBeingChanged;
output reg 			EffectGo;
output reg 	[6:0] volume_data;
output reg 	[6:0] pitch_data;
output reg 	[6:0] distortion_data;
output reg [11:0] final_data;
output reg  [3:0] state;


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
reg		[3:0] input_num;
reg				Pre_VSwitch;
reg				Pre_PSwitch;
reg				Pre_DSwitch;
reg				MainGo;
reg				Load1;
reg				Load2;
reg				Load3;
reg				Count;
reg				CalculateData;
reg				VolumeGo;
reg				PitchGo;
reg				DistortionGo;

// Internal Registers
reg		[3:0] current_state;
reg		[3:0] next_state;
reg	  [23:0] counter;
reg 	  [11:0] data;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

// Logic for NEWLY-flipped switches
always @(posedge Clock)
begin
	Pre_VSwitch <= VolumeOn;
	Pre_PSwitch <= PitchOn;
	Pre_DSwitch <= DistortionOn;
	
	if (Pre_VSwitch == 1'b0 && VolumeOn == 1'b1) begin
		VolumeTurnedOn 	<= 1'b1;
	end else if (Pre_VSwitch == 1'b1 && VolumeOn == 1'b0) begin
		VolumeTurnedOff 	<= 1'b1;
	end else begin
		VolumeTurnedOn 	<= 1'b0;
		VolumeTurnedOff	<= 1'b0;
	end
	
	if (Pre_PSwitch == 1'b0 && PitchOn == 1'b1) begin
		PitchTurnedOn 		<= 1'b1;
	end else if (Pre_PSwitch == 1'b1 && PitchOn == 1'b0) begin
		PitchTurnedOff 	<= 1'b1;
	end else begin
		PitchTurnedOn 		<= 1'b0;
		PitchTurnedOff		<= 1'b0;
	end
	
	if (Pre_DSwitch == 1'b0 && DistortionOn == 1'b1) begin
		DistortionTurnedOn 	<= 1'b1;
	end else if (Pre_DSwitch == 1'b1 && DistortionOn == 1'b0) begin
		DistortionTurnedOff 	<= 1'b1;
	end else begin
		DistortionTurnedOn 	<= 1'b0;
		DistortionTurnedOff	<= 1'b0;
	end
end

 
// Always block to convert ps2_key_data into numbers
always @(*)
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
always @(*) 
begin
	case (current_state)
		S_MAIN: begin
			state = 4'd0;
			if (VolumeOn && SetVolume) begin
				next_state = S_VOLUME;
			end else if (PitchOn && SetPitch) begin
				next_state = S_PITCH;
			end else if (DistortionOn && SetDistortion) begin 
				next_state = S_DISTORTION;
			end else begin
				next_state = S_MAIN;
			end
		end
		
		// Purpose of these states is to set control signals
		S_VOLUME: 		begin state = 4'd1; next_state = S_L1;	end
		S_PITCH: 		begin state = 4'd2; next_state = S_L1;	end
		S_DISTORTION: 	begin state = 4'd3; next_state = S_L1;	end
		
		S_L1: begin
			state = 4'd4;
			if (ps2_key_pressed) begin
				next_state = S_L1_SAVE;
			end else begin
				next_state = S_L1;
			end
		end
		
		S_L1_SAVE: begin state = 4'd5; next_state = S_L1_WAIT; end
		
		S_L1_WAIT: begin
			state = 4'd6; 
			if (counter == 24'd12500000) begin
				next_state = S_L2;
			end else begin
				next_state = S_L1_WAIT;
			end
		end
		
		S_L2: begin
			state = 4'd7; 
			if (ps2_key_pressed) begin
				next_state = S_L2_SAVE;
			end else begin
				next_state = S_L2;
			end
		end
		
		S_L2_SAVE: begin state = 4'd8; next_state = S_L2_WAIT; end
		
		S_L2_WAIT: begin
			state = 4'd9; 
			if (counter == 24'd12500000) begin
				next_state = S_L3;
			end else begin
				next_state = S_L2_WAIT;
			end
		end
		
		S_L3: begin
			state = 4'd10; 
			if (ps2_key_pressed) begin
				next_state = S_L3_SAVE;
			end else begin
				next_state = S_L3;
			end
		end
		
		S_L3_SAVE: begin state = 4'd11; next_state = S_L3_WAIT; end
		
		S_L3_WAIT: begin
			state = 4'd12; 
			if (counter == 24'd12500000) begin
				next_state = S_SETDATA;
			end else begin
				next_state = S_L3_WAIT;
			end
		end
		
		S_SETDATA: begin
			state = 4'd13; 
			if (ps2_key_data == 8'h5A) begin
				next_state = S_OUTPUT;
			end else begin
				next_state = S_SETDATA; 
			end
		end
		
		S_OUTPUT: begin state = 4'd14; next_state = S_MAIN; end
			
		default: next_state = S_MAIN;
	endcase
end

always @(posedge Clock)
begin
	if (Reset) begin
		current_state <= S_MAIN;
	end else if(VolumeGo && !VolumeOn) begin
		current_state <= S_MAIN;
	end else if (PitchGo && !PitchOn) begin
		current_state <= S_MAIN;
	end else if (DistortionGo && !DistortionOn) begin
		current_state <= S_MAIN; 
	end else begin		
		current_state <= next_state;
	end
end


// Control Signals
always @(*)
begin
	MainGo			= 1'b0;
	VolumeGo			= 1'b0;
	PitchGo			= 1'b0;
	DistortionGo	= 1'b0;
	EffectGo			= 1'b0;
	Load1				= 1'b0;
	Load2				= 1'b0;
	Load3				= 1'b0;
	Count				= 1'b0;
	CalculateData 	= 1'b0;
	case (current_state)
		S_MAIN: begin
			MainGo = 1'b1;
		end
		S_VOLUME: begin VolumeGo = 1'b1; end
		S_PITCH: begin PitchGo = 1'b1; end
		S_DISTORTION: begin DistortionGo = 1'b1; end
		S_L1_SAVE: begin Load1 = 1'b1; end
		S_L1_WAIT: begin Count = 1'b1; end
		S_L2_SAVE: begin Load2 = 1'b1; end		
		S_L2_WAIT: begin Count = 1'b1; end
		S_L3_SAVE: begin Load3 = 1'b1; end
		S_L3_WAIT: begin Count = 1'b1; end
		S_SETDATA: begin CalculateData = 1'b1; end
		S_OUTPUT: begin EffectGo = 1'b1; end
	endcase
end

// Datapath
always @(posedge Clock)
begin
	if (Reset) begin
		VolumeBeingChanged <= 1'b0;
		PitchBeingChanged <= 1'b0;
		DistortionBeingChanged <= 1'b0;
		data					<= 12'd0;
		final_data			<= 12'd0;
		volume_data 		<= 7'd0;
		pitch_data 			<= 7'd0;
		distortion_data	<= 7'd0;
		counter 				<= 24'd0;
	end else begin
		if (MainGo) begin
			VolumeBeingChanged <= 1'b0;
			PitchBeingChanged <= 1'b0;
			DistortionBeingChanged <= 1'b0;
			final_data <= 12'd0;
		end else if (VolumeGo) begin
			VolumeBeingChanged <= 1'b1;
		end else if (PitchGo) begin
			PitchBeingChanged <= 1'b1;
		end else if (DistortionGo) begin
			DistortionBeingChanged <= 1'b1;
		end else	if (Load1) begin
			data [11:8] <= input_num;
			final_data [11:8] <= input_num;
		end else if (Load2) begin
			data [ 7:4] <= input_num;
			final_data [ 7:4] <= input_num;
		end else if (Load3) begin
			data [ 3:0] <= input_num;
			final_data [ 3:0] <= input_num;
		end else if (Count) begin
			if (counter == 24'd12500000) begin
				counter <= 24'd0;
			end else begin
				counter <= counter + 1'b1;
			end
		end else if (CalculateData) begin
			if (((data [11:8] * 7'd100) + (data [7:4] * 4'd10) + data[3:0]) > 7'd100) begin
				final_data <= 12'b000100000000;
				if (VolumeBeingChanged) begin volume_data[6:0] <= 7'd100; end
				else if (PitchBeingChanged) begin pitch_data[6:0] <= 7'd100; end
				else if (DistortionBeingChanged) begin distortion_data[6:0] <= 7'd100; end
			end else begin
				final_data <= data;
				if (VolumeBeingChanged) begin volume_data [6:0] <= ((data [11:8] * 7'd100) + (data [7:4] * 4'd10) + data[3:0]); end
				else if (PitchBeingChanged) begin pitch_data [6:0] <= ((data [11:8] * 7'd100) + (data [7:4] * 4'd10) + data[3:0]); end
				else if (DistortionBeingChanged) begin distortion_data [6:0] <= ((data [11:8] * 7'd100) + (data [7:4] * 4'd10) + data[3:0]); end
			end
		end
	end
end

endmodule
