module vga_plot (
	// Inputs
	Clock,
	Reset,
	VolumeTurnedOn,
	PitchTurnedOn,
	DistortionTurnedOn,
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

// Inputs
input 		Clock;
input 		Reset;
input 		VolumeOn;
input 		PitchOn;
input 		DistortionOn;
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

reg 		 Done;
reg [7:0] loopX;
reg [6:0] loopY;

always @(*)
begin
	writeEn <= 1'b0;
	if (Reset) begin
		colour <= 12h'222;
		if (!BoxDone) begin
			if (!BoxDoneX) begin
				x[7:0] <= loopX + 8'd25;
				loopX <= loopX + 1'b1;
			end else if (!BoxDoneY) begin
				y[7:0] <= loopY + 7'd21;
				loopY <= loopY + 1'b1;
			end else begin
				loopX <= 8'b0;
				loopY <= 7'b0;
			end
			writeEn <= 1'b1;
		end else if (!BoxDone) begin
			if (!BoxDoneX) begin
				x[7:0] <= loopX + 8'd72;
				loopX <= loopX + 1'b1;
			end else if (!BoxDoneY) begin
				y[7:0] <= loopY + 7'd21;
				loopY <= loopY + 1'b1;
			end else begin
				loopX <= 8'b0;
				loopY <= 7'b0;
			end
			writeEn <= 1'b1;
		end else if (!BoxDone) begin
			if (!BoxDoneX) begin
				x[7:0] <= loopX + 8'd119;
				loopX <= loopX + 1'b1;
			end else if (!BoxDoneY) begin
				y[7:0] <= loopY + 7'd21;
				loopY <= loopY + 1'b1;
			end else begin
				loopX <= 8'b0;
				loopY <= 7'b0;
			end
			writeEn <= 1'b1;
		end
	end else if (VolumeTurnedOn) begin
		colour <= 12h'2c3;
	end else if (PitchTurnedOn) begin
		colour <= 12h'2c3;	
	end else if (DistortionTurnedOn) begin
		colour <= 12h'2c3;
	end else if (EffectGo) begin
end

always @(*)
begin
	BoxDone
	if (loopX == 8'd16) begin BoxDoneX <= 1'b1; end
	if (loopY == 7'd14) begin BoxDoneY <= 1'b1; end
end

		
	
	
	
	
//		for (index=25; index<=41; index=index+1) begin
//			for (sub_index=21; sub_index<=7; sub_index=sub_index+1) begin
//				x[7:0] <= index;
//				y[6:0] <= sub_index;
//				colour[11:0] <= 12'h2c3;
//				writeEn <= 1'b1;
//			end
//		end
//	end else begin
//		for (index=25; index<=41; index=index+1) begin
//			for (sub_index=21; sub_index<=27; sub_index=sub_index+1) begin
//				x[7:0] <= index;
//				y[6:0] <= sub_index;
//				colour[11:0] <= 12'h222;
//				writeEn <= 1'b1;
//			end
//		end
//	end
//	
//	if (PitchOn) begin
//		for (index=72; index<=88; index=index+1) begin
//			for (sub_index=21; sub_index<=27; sub_index=sub_index+1) begin
//				x[7:0] <= index;
//				y[6:0] <= sub_index;
//				colour[11:0] <= 12'h2c3;
//				writeEn <= 1'b1;
//			end
//		end
//	end else begin
//		for (index=72; index<=88; index=index+1) begin
//			for (sub_index=21; sub_index<=27; sub_index=sub_index+1) begin
//				x[7:0] <= index;
//				y[6:0] <= sub_index;
//				colour[11:0] <= 12'h222;
//				writeEn <= 1'b1;
//			end
//		end
//	end
//	
//	if (DistortionOn) begin
//		for (index=119; index<=135; index=index+1) begin
//			for (sub_index=21; sub_index<=27; sub_index=sub_index+1) begin
//				x[7:0] <= index;
//				y[6:0] <= sub_index;
//				colour[11:0] <= 12'h2c3;
//				writeEn <= 1'b1;
//			end
//		end
//	end else begin
//		for (index=119; index<=135; index=index+1) begin
//			for (sub_index=21; sub_index<=27; sub_index=sub_index+1) begin
//				x[7:0] <= index;
//				y[6:0] <= sub_index;
//				colour[11:0] <= 12'h222;
//				writeEn <= 1'b1;
//			end
//		end
//	end
end
endmodule
