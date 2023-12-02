module vga_plot (
	// Inputs
	Clock,
	Reset,
	VolumeOn,
	PitchOn,
	DistortionOn,
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
				S_VOLUME_BOX 		= 4'd2,
				S_PITCH_BOX 		= 4'd3,
				S_DISTORTION_BOX 	= 4'd4,
				S_DRAW_VOLUME 		= 4'd5,
				S_DRAW_PITCH		= 4'd6,
				S_DRAW_DISTORTION	= 4'd7;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input 		Clock;
input 		Reset;
input 		VolumeOn;
input			PitchOn;
input 		DistortionOn;
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
reg 			 	Idle;
reg				Resetting;
reg 				DrawVolumeBox;
reg				DrawPitchBox;
reg				DrawDistortionBox;
reg				DrawVolumeLine;
reg				DrawPitchLine;
reg				DrawDistortionLine;
reg 		[4:0] loopX;
reg 		[3:0] loopY;
reg		[3:0]	loop1;
reg		[3:0] loop2;
reg		[3:0] loop3;
reg		[3:0] loopS;
reg		[3:0] loopD;




/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge Clock)
begin
	case (current_state)
		S_IDLE: begin
			if (Reset) begin
				next_state = S_RESET;
			end else if (VolumeTurnedOn || VolumeTurnedOff) begin	
				next_state = S_VOLUME_BOX;
			end else if (PitchTurnedOn || PitchTurnedOff) begin 	
				next_state = S_PITCH_BOX;
			end else if (DistortionTurnedOn || DistortionTurnedOff) begin	
				next_state = S_DISTORTION_BOX;
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
		S_VOLUME_BOX: begin
			if (loopX == 16 && loopY == 6) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_VOLUME_BOX;
			end
		end
		S_PITCH_BOX: begin
			if (loopX == 16 && loopY == 6) begin
				next_state <= S_IDLE;
			end else begin
				next_state <= S_PITCH_BOX;
			end
		end
		S_DISTORTION_BOX: begin
			if (loopX == 16 && loopY == 6) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_PITCH_BOX;
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
			Idle = 1'b1;
			Resetting = 1'b0;
			DrawVolumeBox = 1'b0;
			DrawPitchBox = 1'b0;
			DrawDistortionBox = 1'b0;
			DrawVolumeLine = 1'b0;
			DrawPitchLine = 1'b0;
			DrawDistortionLine = 1'b0;
		end
		S_RESET: begin Resetting = 1'b1; end
		S_VOLUME_BOX: begin DrawVolumeBox = 1'b1; end
		S_PITCH_BOX: begin DrawPitchBox = 1'b1; end
		S_DISTORTION_BOX: begin DrawDistortionBox = 1'b1; end
		S_DRAW_VOLUME: begin DrawVolumeLine = 1'b1; end
		S_DRAW_PITCH: begin DrawPitchLine = 1'b1; end
		S_DRAW_DISTORTION: begin DrawDistortionLine = 1'b1; end
	endcase
end
		

always @(posedge Clock)
begin
	writeEn = 1'b0;
	colour <= 12'hc38;
	
	if (Idle) begin
		loopX <= 5'd0;
		loopY <= 4'd0;
		loop1 <= 4'd0;
		loop2 <= 4'd0;
		loop3 <= 4'd0;
	end
	
	else if (Resetting) begin
		if (loop1 != 7) begin
			x[7:0] <= 33;
			y[6:0] <= 52 - loop1;
			loop1 <= loop1 + 1'b1;
		end else if (loop2 != 7) begin
			x[7:0] <= 80;
			y[6:0] <= 52 - loop2;
			loop2 <= loop2 + 1'b1;
		end else if (loop3 != 16) begin
			x[7:0] <= 127;
			y[6:0] <= 52- loop3;
			loop3 <= loop3 + 1'b1;
		end else begin
			loop1 <= 4'd0;
			loop2 <= 4'd0;
			loop3 <= 4'd0;
		end
	end 
	
	else if (DrawVolumeBox) begin
		if (VolumeOn) begin colour <= 12'h2c3; end 
		else begin colour <= 12'h222; end
		if ((loopX == 16) && (loopY != 6)) begin
			loopX <= 4'd0;
			loopY <= loopY + 1'b1;
		end else begin loopX <= loopX + 1'b1; end
		x[7:0] <= loopX + 26;
		y[6:0] <= loopY + 21;
	end 
	
	else if (DrawPitchBox) begin
		if (PitchOn) begin colour <= 12'h2c3; end 
		else begin colour <= 12'h222; end
		if ((loopX == 16) && (loopY != 6)) begin
			loopX <= 4'd0;
			loopY <= loopY + 1'b1;
		end else begin loopX <= loopX + 1'b1; end
		x[7:0] <= loopX + 73;
		y[6:0] <= loopY + 21;
	end 
	
	else if (DrawDistortionBox) begin
		if (DistortionOn) begin colour <= 12'h2c3; end 
		else begin colour <= 12'h222; end
		if ((loopX == 16) && (loopY != 6)) begin
			loopX <= 4'd0;
			loopY <= loopY + 1'b1;
		end else begin loopX <= loopX + 1'b1; end
		x[7:0] <= loopX + 120;
		y[6:0] <= loopY + 21;
	end
	
	else if (DrawVolumeLine) begin
		if (volume_data >= 7'd92 || volume_data <= 7'd8) begin
			x[7:0] <= 33;
			y[6:0] <= 52 - loopS;
			if (loopS != 7) begin loopS <= loopS + 1; end
		end else if (volume_data < 7'd19) begin
			x[7:0] <= 33 + loopD;
			y[6:0] <= 52 - loopD;
			if (loopD != 6) begin loopD <= loopD + 1; end
		end else if (volume_data < 7'd31) begin
			x[7:0] <= 33 + loopS;
			y[6:0] <= 52;
			if (loopS != 7) begin loopS <= loopS + 1; end
		end else if (volume_data < 7'd43) begin
			x[7:0] = 33 + loopD;
			y[6:0] = 52 + loopD;
			if (loopD != 6) begin loopD <= loopD + 1; end
		end else if (volume_data < 7'd55) begin
			x[7:0] <= loopX;
			y[6:0] <= 52 + loopS;
			if (loopS != 7) begin loopS <= loopS + 1; end
		end else if (volume_data < 7'd67) begin
			x[7:0] <= 33 - loopD;
			y[6:0] <= 52 + loopD;
			if (loopD != 6) begin loopD <= loopD + 1; end
		end else if (volume_data < 7'd79) begin
			x[7:0] <= 33 - loopS;
			y[6:0] <= 52;
			if (loopS != 7) begin loopS <= loopS + 1; end
		end else if (volume_data < 7'd91) begin
			x[7:0] <= 33 - loopD;
			y[6:0] <= 52 - loopD;
			if (loopD != 6) begin loopD <= loopD + 1; end
		end
	end
	
	else if (DrawPitchLine) begin
		if (pitch_data >= 7'd92 || pitch_data <= 7'd8) begin
			x[7:0] <= 33;
			y[6:0] <= 52 - loopS;
			if (loopS != 7) begin loopS <= loopS + 1; end
		end else if (pitch_data < 7'd19) begin
			x[7:0] <= 33 + loopD;
			y[6:0] <= 52 - loopD;
			if (loopD != 6) begin loopD <= loopD + 1; end
		end else if (pitch_data < 7'd31) begin
			x[7:0] <= 33 + loopS;
			y[6:0] <= 52;
			if (loopS != 7) begin loopS <= loopS + 1; end
		end else if (pitch_data < 7'd43) begin
			x[7:0] = 33 + loopD;
			y[6:0] = 52 + loopD;
			if (loopD != 6) begin loopD <= loopD + 1; end
		end else if (pitch_data < 7'd55) begin
			x[7:0] <= loopX;
			y[6:0] <= 52 + loopS;
			if (loopS != 7) begin loopS <= loopS + 1; end
		end else if (pitch_data < 7'd67) begin
			x[7:0] <= 33 - loopD;
			y[6:0] <= 52 + loopD;
			if (loopD != 6) begin loopD <= loopD + 1; end
		end else if (pitch_data < 7'd79) begin
			x[7:0] <= 33 - loopS;
			y[6:0] <= 52;
			if (loopS != 7) begin loopS <= loopS + 1; end
		end else if (pitch_data < 7'd91) begin
			x[7:0] <= 33 - loopD;
			y[6:0] <= 52 - loopD;
			if (loopD != 6) begin loopD <= loopD + 1; end
		end
	end
	
	else if (DrawDistortionLine) begin
		if (distortion_data >= 7'd92 || distortion_data <= 7'd8) begin
			x[7:0] <= 33;
			y[6:0] <= 52 - loopS;
			if (loopS != 7) begin loopS <= loopS + 1; end
		end else if (distortion_data < 7'd19) begin
			x[7:0] <= 33 + loopD;
			y[6:0] <= 52 - loopD;
			if (loopD != 6) begin loopD <= loopD + 1; end
		end else if (distortion_data < 7'd31) begin
			x[7:0] <= 33 + loopS;
			y[6:0] <= 52;
			if (loopS != 7) begin loopS <= loopS + 1; end
		end else if (distortion_data < 7'd43) begin
			x[7:0] = 33 + loopD;
			y[6:0] = 52 + loopD;
			if (loopD != 6) begin loopD <= loopD + 1; end
		end else if (distortion_data < 7'd55) begin
			x[7:0] <= loopX;
			y[6:0] <= 52 + loopS;
			if (loopS != 7) begin loopS <= loopS + 1; end
		end else if (distortion_data < 7'd67) begin
			x[7:0] <= 33 - loopD;
			y[6:0] <= 52 + loopD;
			if (loopD != 6) begin loopD <= loopD + 1; end
		end else if (distortion_data < 7'd79) begin
			x[7:0] <= 33 - loopS;
			y[6:0] <= 52;
			if (loopS != 7) begin loopS <= loopS + 1; end
		end else if (distortion_data < 7'd91) begin
			x[7:0] <= 33 - loopD;
			y[6:0] <= 52 - loopD;
			if (loopD != 6) begin loopD <= loopD + 1; end
		end
	end

	writeEn <= 1'b1;
	
end
	
endmodule
