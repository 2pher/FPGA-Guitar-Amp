module vga_plot (
	// Inputs
	Clock,
	Reset,
	VolumeTurnedOn,
	PitchTurnedOn,
	DistortionTurnedOn,
	VolumeTurnedOff,
	PitchTurnedOff,
	DistortionTurnedOff,
	VolumeGo,
	PitchGo,
	DistortionGo,
	EffectGo,
	volume_data,
	pitch_data,
	distortion_data,
	
	//Outputs
	colour,
	x,
	y,
	writeEn	
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

parameter 	S_IDLE 				= 4'd0,
				S_RESET				= 4'd1,
				S_VOLUME_ON 		= 4'd2,
				S_VOLUME_OFF 		= 4'd3,
				S_DISTORTION_ON 	= 4'd4,
				S_DISTORTION_OFF 	= 4'd5,
				S_PITCH_ON 			= 4'd6,
				S_PITCH_OFF 		= 4'd7,
				S_EFFECT 			= 4'd8,
				S_DRAW_VOLUME 		= 4'd9,
				S_DRAW_PITCH		= 4'd10,
				S_DRAW_DISTORTION	= 4'd11,

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input 		Clock;
input 		Reset;
input 		VolumeTurnedOn;
input 		PitchTurnedOn;
input 		DistortionTurnedOn;
input 		VolumeTurnedOff;
input 		PitchTurnedOff;
input			DistortionTurnedOff;
input 		VolumeGo;
input 		PitchGo;
input 		DistortionGo;
input 		EffectGo;
input [6:0]	volume_data;
input [6:0] pitch_data;
input [6:0] distortion_data;

// Outputs
output reg [11:0] colour;
output reg  [7:0] x;
output reg 	[6:0] y;
output reg			writeEn;

reg 		 	Done;
reg [4:0] 	loopX;
reg [4:0] 	loopY;
reg 			Resetting;
reg 		 	BoxDone;
reg			BoxDoneX;
reg			BoxDoneY;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Registers
reg		[3:0] current_state;
reg		[3:0] next_state;
reg		[


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge Clock)
begin
	case (current_state)
		S_IDLE: begin 	 
			if (VolumeTurnedOn) begin	
				next_state = S_VOLUME_ON;
			end else if (VolumeTurnedOff) begin	
				next_state = S_VOLUME_OFF;
			end else if (PitchTurnedOn) begin 	
				next_state = S_PITCH_ON;
			end else if (PitchTurnedOff) begin 	
				next_state = S_PITCH_OFF;
			end else if (DistortionTurnedOn) begin	
				next_state = S_DISTORTION_ON;
			end else if (DistortionTurnedOff) begin
				next_state = S_DISTORTION_OFF;
			end else if (EffectGo) begin
				next_state = S_EFFECT;
			end else begin
				next_state = S_IDLE;
			end
		end
		S_RESET: begin
			if (BoxDoneDraw) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_RESET;
			end
		end
		S_VOLUME_ON: begin
			if (BoxDoneDraw) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_VOLUME_ON;
			end
		end
		S_VOLUME_OFF: begin
			if (BoxDoneDraw) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_VOLUME_OFF;
			end
		end
		S_PITCH_ON: begin
			if (BoxDoneDraw) begin
				next_state <= S_IDLE;
			end else begin
				next_state <= S_PITCH_ON;
			end
		end
		S_PITCH_OFF: begin
			if (BoxDoneDraw) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_PITCH_OFF;
			end
		end
		S_DISTORTION_ON: begin
			if (BoxDoneDraw) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_PITCH_ON;
			end
		end
		S_DISTORTION_OFF: begin
			if (BoxDoneDraw) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_VOLUME_ON;
			end
		end
		S_EFFECT: begin
			if (VolumeGo) begin
				next_state = S_DRAW_VOLUME;
			end else if (PitchGo) begin
				next_state = S_DRAW_PITCH;
			end else if (DistortionGo) begin
				next_state = S_DRAW_DISTORTION;
			end else begin
				next_state = S_EFFECT;
			end
		end
		S_DRAW_VOLUME: begin
			if (LineDoneDraw_S || LineDoneDraw_D) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_DRAW_VOLUME;
			end
		end
		S_DRAW_PITCH: begin
			if (LineDoneDraw_S || LineDoneDraw_D) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_DRAW_PITCH;
			end
		end
		S_DRAW_DISTORTION: begin
			if (LineDoneDraw_S || LineDoneDraw_D) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_DRAW_DISTORTION;
			end
		end
		default: next_state = S_IDLE;
	endcase
end

always @(*)
begin
	writeEn <= 1'b0;
	case (current_state)
		S_IDLE: begin 
			loopX = 5'b0;
			loopY = 5'b0;
			BoxDoneDraw = 1'b0;
		end
		S_RESET: begin
			if (BoxDoneDraw) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_RESET;
			end
		end
		S_VOLUME_ON: begin
			if (BoxDoneDraw) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_VOLUME_ON;
			end
		end
		S_VOLUME_OFF: begin
			if (BoxDoneDraw) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_VOLUME_OFF;
			end
		end
		S_PITCH_ON: begin
			if (BoxDoneDraw) begin
				next_state <= S_IDLE;
			end else begin
				next_state <= S_PITCH_ON;
			end
		end
		S_PITCH_OFF: begin
			if (BoxDoneDraw) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_PITCH_OFF;
			end
		end
		S_DISTORTION_ON: begin
			if (BoxDoneDraw) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_PITCH_ON;
			end
		end
		S_DISTORTION_OFF: begin
			if (BoxDoneDraw) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_VOLUME_ON;
			end
		end
		S_EFFECT: begin
			if (VolumeGo) begin
				next_state = S_DRAW_VOLUME;
			end else if (PitchGo) begin
				next_state = S_DRAW_PITCH;
			end else if (DistortionGo) begin
				next_state = S_DRAW_DISTORTION;
			end else begin
				next_state = S_EFFECT;
			end
		end
		S_DRAW_VOLUME: begin
			if (LineDoneDraw_S || LineDoneDraw_D) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_DRAW_VOLUME;
			end
		end
		S_DRAW_PITCH: begin
			if (LineDoneDraw_S || LineDoneDraw_D) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_DRAW_PITCH;
			end
		end
		S_DRAW_DISTORTION: begin
			if (LineDoneDraw_S || LineDoneDraw_D) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_DRAW_DISTORTION;
			end
		end
	endcase
end

endmodule
