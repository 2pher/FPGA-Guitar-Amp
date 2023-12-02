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
				S_DRAW_DISTORTION	= 4'd11;

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

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Registers
reg		[3:0] current_state;
reg		[3:0] next_state;
reg 			 	Done;
reg 		[4:0] loopX;
reg 		[3:0] loopY;
reg		[3:0]	loop1;
reg		[3:0] loop2;
reg		[3:0] loop3;

reg 		BoxDoneDraw;
reg		LineDoneDraw;

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge Clock)
begin
	case (current_state)
		S_IDLE: begin
			if (Reset) begin
				next_state = S_RESET;
			end else if (VolumeTurnedOn) begin	
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
			end else if (EffectGo && VolumeGo) begin
				next_state = S_DRAW_VOLUME;
			end else if (EffectGo && PitchGo) begin
				next_state = S_DRAW_PITCH;
			end else if (EffectGo && DistortionGo) begin
				next_state = S_DRAW_DISTORTION;
			end else begin
				next_state = S_IDLE;
			end
		end
		S_RESET: begin
			if (loop1 == 3'd7 && loop2 == 3'd7 && loop3 == 3'd7) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_RESET;
			end
		end
		S_VOLUME_ON: begin
			if (loopX == 16 && loopY == 6) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_VOLUME_ON;
			end
		end
		S_VOLUME_OFF: begin
			if (loopX == 16 && loopY == 6) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_VOLUME_OFF;
			end
		end
		S_PITCH_ON: begin
			if (loopX == 16 && loopY == 6) begin
				next_state <= S_IDLE;
			end else begin
				next_state <= S_PITCH_ON;
			end
		end
		S_PITCH_OFF: begin
			if (loopX == 16 && loopY == 6) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_PITCH_OFF;
			end
		end
		S_DISTORTION_ON: begin
			if (loopX == 16 && loopY == 6) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_PITCH_ON;
			end
		end
		S_DISTORTION_OFF: begin
			if (loopX == 16 && loopY == 6) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_VOLUME_ON;
			end
		end
		S_DRAW_VOLUME: begin
			if (loopS == 7 || loopD == 6) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_DRAW_VOLUME;
			end
		end
		S_DRAW_PITCH: begin
			if (loopS == 7 || loopD == 6) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_DRAW_PITCH;
			end
		end
		S_DRAW_DISTORTION: begin
			if (loopS == 7 || loopD == 6) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_DRAW_DISTORTION;
			end
		end
		default: next_state = S_IDLE;
	endcase
end

// Control signals
always @(posedge Clock)
begin
	case (current_state)
		S_IDLE: begin 
			Resetting = 1'b0;
			DrawVolumeBox = 1'b0;
			DrawPitchBox = 1'b0;
			DrawDistortionBox = 1'b0;
			DrawVolumeLine = 1'b0;
			DrawPitchGo = 1'b0;
			Draw
		end
		S_RESET: begin Resetting = 1'b1; end
		S_VOLUME_ON: begin DrawVolumeBox = 1'b1; end
		S_VOLUME_OFF: begin DrawVolumeBox = 1'b1; end
		S_PITCH_ON: begin DrawPitchBox = 1'b1; end
		S_PITCH_OFF: begin DrawPitchBox = 1'b1; end
		S_DISTORTION_ON: begin DrawDistortionBox = 1'b1; end
		S_DISTORTION_OFF: begin DrawDistortionBox = 1'b1; end
		S_DRAW_VOLUME: begin end
		S_DRAW_PITCH: begin end
		S_DRAW_DISTORTION: begin end
	endcase
end
		
	

always @(*)
begin
	writeEn = 1'b0;
	case (current_state)
		S_IDLE: begin 
			loopX 			= 5'b0;
			loopY 			= 5'b0;
			BoxDoneDraw 	= 1'b0;
			LineDoneDraw 	= 1'b0;
		end
		S_RESET: begin
			//
		end
		S_VOLUME_ON: begin
			colour = 12'h2c3;
			x[7:0] = loopX + 26;
			y[6:0] = loopX + 21;
			writeEn = 1'b1;
			if (loopX != 16) begin
				loopX = loopX + 1;
			end else if (loopY != 6) begin
				loopY = loopY + 1;
			end else begin
				BoxDoneDraw = 1'b1;
			end
		end
		S_VOLUME_OFF: begin
			colour = 12'h222;
			x[7:0] = loopX + 26;
			y[6:0] = loopX + 21;
			writeEn = 1'b1;
			if (loopX != 16) begin
				loopX = loopX + 1;
			end else if (loopY != 6) begin
				loopY = loopY + 1;
			end else begin
				BoxDoneDraw = 1'b1;
			end
		end
		S_PITCH_ON: begin
			colour = 12'h2c3;
			x[7:0] = loopX + 73;
			y[6:0] = loopX + 21;
			writeEn = 1'b1;
			if (loopX != 16) begin
				loopX = loopX + 1;
			end else if (loopY != 6) begin
				loopY = loopY + 1;
			end else begin
				BoxDoneDraw = 1'b1;
			end
		end
		S_PITCH_OFF: begin
			colour = 12'h222;
			x[7:0] = loopX + 73;
			y[6:0] = loopX + 21;
			writeEn = 1'b1;
			if (loopX != 16) begin
				loopX = loopX + 1;
			end else if (loopY != 6) begin
				loopY = loopY + 1;
			end else begin
				BoxDoneDraw = 1'b1;
			end
		end
		S_DISTORTION_ON: begin
			colour = 12'h2c3;
			x[7:0] = loopX + 120;
			y[6:0] = loopX + 21;
			writeEn = 1'b1;
			if (loopX != 16) begin
				loopX = loopX + 1;
			end else if (loopY != 6) begin
				loopY = loopY + 1;
			end else begin
				BoxDoneDraw = 1'b1;
			end
		end
		S_DISTORTION_OFF: begin
			colour = 12'h222;
			x[7:0] = loopX + 120;
			y[6:0] = loopX + 21;
			writeEn = 1'b1;
			if (loopX != 16) begin
				loopX = loopX + 1;
			end else if (loopY != 6) begin
				loopY = loopY + 1;
			end else begin
				BoxDoneDraw = 1'b1;
			end
		end
		S_EFFECT: begin
			//
		end
		S_DRAW_VOLUME: begin
			colour = 12'hc38;
			if (volume_data >= 7'd92 || volume_data <= 7'd8) begin
				x[7:0] = 33;
				y[6:0] = 52 - loopX;
				if (loopX != 7) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (volume_data < 7'd19) begin
				x[7:0] = 33 + loopX;
				y[6:0] = 52 - loopX;
				if (loopX != 6) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (volume_data < 7'd31) begin
				x[7:0] = 33 + loopX;
				y[6:0] = 52;
				if (loopX != 7) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (volume_data < 7'd43) begin
				x[7:0] = 33 + loopX;
				y[6:0] = 52 + loopX;
				if (loopX != 6) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (volume_data < 7'd55) begin
				x[7:0] = loopX;
				y[6:0] = 52 + loopX;
				if (loopX != 7) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (volume_data < 7'd67) begin
				x[7:0] = 33 - loopX;
				y[6:0] = 52 + loopX;
				if (loopX != 6) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (volume_data < 7'd79) begin
				x[7:0] = 33 - loopX;
				y[6:0] = 52;
				if (loopX != 7) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (volume_data < 7'd91) begin
				x[7:0] = 33 - loopX;
				y[6:0] = 52 - loopX;
				if (loopX != 6) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end
			writeEn = 1'b1;
		end
		S_DRAW_PITCH: begin
			colour = 12'hc38;
			if (pitch_data >= 7'd92 || pitch_data <= 7'd8) begin
				x[7:0] = 33;
				y[6:0] = 52 - loopX;
				if (loopX != 7) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (pitch_data < 7'd19) begin
				x[7:0] = 33 + loopX;
				y[6:0] = 52 - loopX;
				if (loopX != 6) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (pitch_data < 7'd31) begin
				x[7:0] = 33 + loopX;
				y[6:0] = 52;
				if (loopX != 7) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (pitch_data < 7'd43) begin
				x[7:0] = 33 + loopX;
				y[6:0] = 52 + loopX;
				if (loopX != 6) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (pitch_data < 7'd55) begin
				x[7:0] = loopX;
				y[6:0] = 52 + loopX;
				if (loopX != 7) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (pitch_data < 7'd67) begin
				x[7:0] = 33 - loopX;
				y[6:0] = 52 + loopX;
				if (loopX != 6) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (pitch_data < 7'd79) begin
				x[7:0] = 33 - loopX;
				y[6:0] = 52;
				if (loopX != 7) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (pitch_data < 7'd91) begin
				x[7:0] = 33 - loopX;
				y[6:0] = 52 - loopX;
				if (loopX != 6) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end
			writeEn = 1'b1;
		end
		S_DRAW_DISTORTION: begin
			colour = 12'hc38;
			if (distortion_data >= 7'd92 || distortion_data <= 7'd8) begin
				x[7:0] = 33;
				y[6:0] = 52 - loopX;
				if (loopX != 7) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (distortion_data < 7'd19) begin
				x[7:0] = 33 + loopX;
				y[6:0] = 52 - loopX;
				if (loopX != 6) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (distortion_data < 7'd31) begin
				x[7:0] = 33 + loopX;
				y[6:0] = 52;
				if (loopX != 7) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (volume_data < 7'd43) begin
				x[7:0] = 33 + loopX;
				y[6:0] = 52 + loopX;
				if (loopX != 6) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (distortion_data < 7'd55) begin
				x[7:0] = loopX;
				y[6:0] = 52 + loopX;
				if (loopX != 7) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (distortion_data < 7'd67) begin
				x[7:0] = 33 - loopX;
				y[6:0] = 52 + loopX;
				if (loopX != 6) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (distortion_data < 7'd79) begin
				x[7:0] = 33 - loopX;
				y[6:0] = 52;
				if (loopX != 7) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end else if (distortion_data < 7'd91) begin
				x[7:0] = 33 - loopX;
				y[6:0] = 52 - loopX;
				if (loopX != 6) begin
					loopX = loopX + 1;
				end else begin
					LineDoneDraw = 1'b1;
				end
			end
			writeEn = 1'b1;
		end
	endcase
end

endmodule
