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
	writeEn,
	state
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
output reg 	[3:0] state;

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
reg		[3:0] loopEraseX1;
reg		[3:0] loopEraseY1;
reg		[3:0] loopEraseX2;
reg		[3:0] loopEraseY2;
reg		[3:0] loopEraseX3;
reg		[3:0] loopEraseY3;






/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(*)
begin
	case (current_state)
		S_IDLE: begin
			state = 4'd0;
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
			state = 4'd1;
			if (loop3 == 3'd7) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_RESET;
			end
		end
		S_VOLUME_BOX: begin
			state = 4'd2;
			if (loopX == 16 && loopY == 3'd6) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_VOLUME_BOX;
			end
		end
		S_PITCH_BOX: begin
			state = 4'd3;
			if (loopX == 16 && loopY == 3'd6) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_PITCH_BOX;
			end
		end
		S_DISTORTION_BOX: begin
			state = 4'd4;
			if (loopX == 16 && loopY == 3'd6) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_DISTORTION_BOX;
			end
		end
		S_DRAW_VOLUME: begin
			state = 4'd5;
			if (loopS == 3'd7 || loopD == 3'd6) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_DRAW_VOLUME;
			end
		end
		S_DRAW_PITCH: begin
			state = 4'd6;
			if (loopS == 3'd7 || loopD == 3'd6) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_DRAW_PITCH;
			end
		end
		S_DRAW_DISTORTION: begin
			state = 4'd7;
			if (loopS == 3'd7 || loopD == 3'd6) begin
				next_state = S_IDLE;
			end else begin
				next_state = S_DRAW_DISTORTION;
			end
		end
		default: next_state = S_IDLE;
	endcase
end

// Control signals
always @(*)
begin
	Idle = 1'b0;
	Resetting = 1'b0;
	DrawVolumeBox = 1'b0;
	DrawPitchBox = 1'b0;
	DrawDistortionBox = 1'b0;
	DrawVolumeLine = 1'b0;
	DrawPitchLine = 1'b0;
	DrawDistortionLine = 1'b0;
	case (current_state)
		S_IDLE: begin Idle = 1'b1; end
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
	current_state <= next_state; 
end
		
always @(posedge Clock)
begin

	writeEn = 1'b0;
	
	if (Idle) begin
		loopX <= 5'd0;
		loopY <= 4'd0;
		loop1 <= 4'd0;
		loop2 <= 4'd0;
		loop3 <= 4'd0;
		loopS <= 4'd0;
		loopD <= 4'd0;
		loopEraseX1 <= 4'd0;
		loopEraseY1 <= 4'd0;
		loopEraseX2 <= 4'd0;
		loopEraseY2 <= 4'd0;
		loopEraseX3 <= 4'd0;
		loopEraseY3 <= 4'd0;
	end
	
	else if (Resetting) begin
		if ((loopEraseX1 <= 4'd14) && (loopEraseY1 <= 4'd14)) begin
			if ((loopEraseX1 == 4'd14) && (loopEraseY1 != 4'd14)) begin
				loopEraseX1 <= 4'd0;
				loopEraseY1 <= loopEraseY1 + 1'b1;
			end else begin loopEraseX1 <= loopEraseX1 + 1'b1; end
			x[7:0] <= loopEraseX1 + 5'd26;
			y[6:0] <= loopEraseY1 + 6'd44;
			colour <= 12'h222;
		end else if ((loopEraseX2 <= 4'd14) && (loopEraseY2 <= 4'd14)) begin
			if ((loopEraseX2 == 4'd14) && (loopEraseY2 != 4'd14)) begin
				loopEraseX2 <= 4'd0;
				loopEraseY2 <= loopEraseY2 + 1'b1;
			end else begin loopEraseX2 <= loopEraseX2 + 1'b1; end
			x[7:0] <= loopEraseX2 + 7'd73;
			y[6:0] <= loopEraseY2 + 6'd44;
			colour <= 12'h222;
		end else if ((loopEraseX3 <= 4'd14) && (loopEraseY3 <= 4'd14)) begin
			if ((loopEraseX3 == 4'd14) && (loopEraseY3 != 4'd14)) begin
				loopEraseX3 <= 4'd0;
				loopEraseY3 <= loopEraseY3 + 1'b1;
			end else begin loopEraseX3 <= loopEraseX3 + 1'b1; end
			x[7:0] <= loopEraseX3 + 7'd120;
			y[6:0] <= loopEraseY3 + 6'd44;
			colour <= 12'h222;
		end else	if (loop1 != 3'd7) begin
			x[7:0] <= 6'd33;
			y[6:0] <= 6'd51 - loop1;
			colour <= 12'hc38;
			loop1 <= loop1 + 1'b1;
		end else if (loop2 != 3'd7) begin
			x[7:0] <= 7'd80;
			y[6:0] <= 6'd51 - loop2;
			colour <= 12'hc38;
			loop2 <= loop2 + 1'b1;
		end else if (loop3 != 3'd7) begin
			x[7:0] <= 7'd127;
			y[6:0] <= 6'd51 - loop3;
			colour <= 12'hc38;
			loop3 <= loop3 + 1'b1;
		end
	end 
	
	else if (DrawVolumeBox) begin
		if (VolumeOn) begin colour <= 12'h2c3; end 
		else begin colour <= 12'h222; end
		if ((loopX == 5'd16) && (loopY != 3'd6)) begin
			loopX <= 4'd0;
			loopY <= loopY + 1'b1;
		end else begin loopX <= loopX + 1'b1; end
		x[7:0] <= loopX + 5'd25;
		y[6:0] <= loopY + 5'd21;
	end 
	
	else if (DrawPitchBox) begin
		if (PitchOn) begin colour <= 12'h2c3; end 
		else begin colour <= 12'h222; end
		if ((loopX == 5'd16) && (loopY != 3'd6)) begin
			loopX <= 4'd0;
			loopY <= loopY + 1'b1;
		end else begin loopX <= loopX + 1'b1; end
		x[7:0] <= loopX + 7'd72;
		y[6:0] <= loopY + 5'd21;
	end 
	
	else if (DrawDistortionBox) begin
		if (DistortionOn) begin colour <= 12'h2c3; end 
		else begin colour <= 12'h222; end
		if ((loopX == 5'd16) && (loopY != 3'd6)) begin
			loopX <= 4'd0;
			loopY <= loopY + 1'b1;
		end else begin loopX <= loopX + 1'b1; end
		x[7:0] <= loopX + 7'd119;
		y[6:0] <= loopY + 5'd21;
	end
	
	else if (DrawVolumeLine) begin
		if ((loopEraseX1 <= 4'd14) && (loopEraseY1 <= 4'd14)) begin
			if ((loopEraseX1 == 4'd14) && (loopEraseY1 != 4'd14)) begin
				loopEraseX1 <= 4'd0;
				loopEraseY1 <= loopEraseY1 + 1'b1;
			end else begin loopEraseX1 <= loopEraseX1 + 1'b1; end
			x[7:0] <= loopEraseX1 + 5'd26;
			y[6:0] <= loopEraseY1 + 6'd44;
			colour <= 12'h222;
		end else if (volume_data >= 7'd92 || volume_data <= 7'd8) begin
			x[7:0] <= 6'd33;
			y[6:0] <= 6'd51 - loopS;
			colour <= 12'hc38;
			if (loopS != 3'd7) begin loopS <= loopS + 1'b1; end
		end else if (volume_data < 7'd19) begin
			x[7:0] <= 6'd33 + loopD;
			y[6:0] <= 6'd51 - loopD;
			colour <= 12'hc38;
			if (loopD != 3'd6) begin loopD <= loopD + 1'b1; end
			else begin loopD <= 4'd0; end
		end else if (volume_data < 7'd31) begin
			x[7:0] <= 6'd33 + loopS;
			y[6:0] <= 6'd51;
			colour <= 12'hc38;
			if (loopS != 3'd7) begin loopS <= loopS + 1'b1; end
		end else if (volume_data < 7'd43) begin
			x[7:0] <= 6'd33 + loopD;
			y[6:0] <= 6'd51 + loopD;
			colour <= 12'hc38;
			if (loopD != 3'd6) begin loopD <= loopD + 1'b1; end
		end else if (volume_data < 7'd55) begin
			x[7:0] <= 6'd33;
			y[6:0] <= 6'd51 + loopS;
			colour <= 12'hc38;
			if (loopS != 3'd7) begin loopS <= loopS + 1'b1; end
		end else if (volume_data < 7'd67) begin
			x[7:0] <= 6'd33 - loopD;
			y[6:0] <= 6'd51 + loopD;
			colour <= 12'hc38;
			if (loopD != 3'd6) begin loopD <= loopD + 1'b1; end
		end else if (volume_data < 7'd79) begin
			x[7:0] <= 6'd33 - loopS;
			y[6:0] <= 6'd51;
			colour <= 12'hc38;
			if (loopS != 3'd7) begin loopS <= loopS + 1'b1; end
		end else if (volume_data < 7'd91) begin
			x[7:0] <= 6'd33 - loopD;
			y[6:0] <= 6'd51 - loopD;
			colour <= 12'hc38;
			if (loopD != 3'd6) begin loopD <= loopD + 1'b1; end
		end
	end
	
	else if (DrawPitchLine) begin
		if ((loopEraseX2 <= 4'd14) && (loopEraseY2 <= 4'd14)) begin
			if ((loopEraseX2 == 4'd14) && (loopEraseY2 != 4'd14)) begin
				loopEraseX2 <= 4'd0;
				loopEraseY2 <= loopEraseY2 + 1'b1;
			end else begin loopEraseX2 <= loopEraseX2 + 1'b1; end
			x[7:0] <= loopEraseX2 + 7'd73;
			y[6:0] <= loopEraseY2 + 6'd44;
			colour <= 12'h222;
		end else if (pitch_data >= 7'd92 || pitch_data <= 7'd8) begin
			x[7:0] <= 7'd80;
			y[6:0] <= 6'd51 - loopS;
			colour <= 12'hc38;
			if (loopS != 3'd7) begin loopS <= loopS + 1'b1; end
		end else if (pitch_data < 7'd19) begin
			x[7:0] <= 7'd80 + loopD;
			y[6:0] <= 6'd51 - loopD;
			colour <= 12'hc38;
			if (loopD != 3'd6) begin loopD <= loopD + 1'b1; end
		end else if (pitch_data < 7'd31) begin
			x[7:0] <= 7'd80 + loopS;
			y[6:0] <= 6'd51;
			colour <= 12'hc38;
			if (loopS != 3'd7) begin loopS <= loopS + 1'b1; end
		end else if (pitch_data < 7'd43) begin
			x[7:0] <= 7'd80 + loopD;
			y[6:0] <= 6'd51 + loopD;
			colour <= 12'hc38;
			if (loopD != 3'd6) begin loopD <= loopD + 1'b1; end
		end else if (pitch_data < 7'd55) begin
			x[7:0] <= 7'd80;
			y[6:0] <= 6'd51 + loopS;
			colour <= 12'hc38;
			if (loopS != 3'd7) begin loopS <= loopS + 1'b1; end
		end else if (pitch_data < 7'd67) begin
			x[7:0] <= 7'd80 - loopD;
			y[6:0] <= 6'd51 + loopD;
			colour <= 12'hc38;
			if (loopD != 3'd6) begin loopD <= loopD + 1'b1; end
		end else if (pitch_data < 7'd79) begin
			x[7:0] <= 7'd80 - loopS;
			y[6:0] <= 6'd51;
			colour <= 12'hc38;
			if (loopS != 3'd7) begin loopS <= loopS + 1'b1; end
		end else if (pitch_data < 7'd91) begin
			x[7:0] <= 7'd80 - loopD;
			y[6:0] <= 6'd51 - loopD;
			colour <= 12'hc38;
			if (loopD != 3'd6) begin loopD <= loopD + 1'b1; end
		end
	end
	
	else if (DrawDistortionLine) begin
		if ((loopEraseX3 <= 4'd14) && (loopEraseY3 <= 4'd14)) begin
			if ((loopEraseX3 == 4'd14) && (loopEraseY3 != 4'd14)) begin
				loopEraseX3 <= 4'd0;
				loopEraseY3 <= loopEraseY3 + 1'b1;
			end else begin loopEraseX3 <= loopEraseX3 + 1'b1; end
			x[7:0] <= loopEraseX3 + 7'd120;
			y[6:0] <= loopEraseY3 + 6'd44;
			colour <= 12'h222;
		end else if (distortion_data >= 7'd92 || distortion_data <= 7'd8) begin
			x[7:0] <= 7'd127;
			y[6:0] <= 6'd51 - loopS;
			colour <= 12'hc38;
			if (loopS != 3'd7) begin loopS <= loopS + 1'b1; end
		end else if (distortion_data < 7'd19) begin
			x[7:0] <= 7'd127 + loopD;
			y[6:0] <= 6'd51 - loopD;
			colour <= 12'hc38;
			if (loopD != 3'd6) begin loopD <= loopD + 1'b1; end
		end else if (distortion_data < 7'd31) begin
			x[7:0] <= 7'd127 + loopS;
			y[6:0] <= 6'd51;
			colour <= 12'hc38;
			if (loopS != 3'd7) begin loopS <= loopS + 1'b1; end
		end else if (distortion_data < 7'd43) begin
			x[7:0] <= 7'd127 + loopD;
			y[6:0] <= 6'd51 + loopD;
			colour <= 12'hc38;
			if (loopD != 3'd6) begin loopD <= loopD + 1'b1; end
		end else if (distortion_data < 7'd55) begin
			x[7:0] <= 7'd127;
			y[6:0] <= 6'd51 + loopS;
			colour <= 12'hc38;
			if (loopS != 3'd7) begin loopS <= loopS + 1'b1; end
		end else if (distortion_data < 7'd67) begin
			x[7:0] <= 7'd127 - loopD;
			y[6:0] <= 6'd51 + loopD;
			colour <= 12'hc38;
			if (loopD != 3'd6) begin loopD <= loopD + 1'b1; end
		end else if (distortion_data < 7'd79) begin
			x[7:0] <= 7'd127 - loopS;
			y[6:0] <= 6'd51;
			colour <= 12'hc38;
			if (loopS != 3'd7) begin loopS <= loopS + 1'b1; end
		end else if (distortion_data < 7'd91) begin
			x[7:0] <= 7'd127 - loopD;
			y[6:0] <= 6'd51 - loopD;
			colour <= 12'hc38;
			if (loopD != 3'd6) begin loopD <= loopD + 1'b1; end
		end
	end

	writeEn <= 1'b1;
	
end
	
endmodule
