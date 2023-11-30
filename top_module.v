module top_module (
	CLOCK_50,
	SW,
	KEY,
	HEX5,
	HEX4,
	HEX3,
	VGA_CLK,   		//	VGA Clock
	VGA_HS,			//	VGA H_SYNC
	VGA_VS,			//	VGA V_SYNC
	VGA_BLANK_N,	//	VGA BLANK
	VGA_SYNC_N,		//	VGA SYNC
	VGA_R,   		//	VGA Red[9:0]
	VGA_G,	 		//	VGA Green[9:0]
	VGA_B,   			//	VGA Blue[9:0]
	PS2_CLK,
	PS2_DAT
);

// Inputs
input CLOCK_50;
input [9:0] SW;
input [3:0] KEY;

// Bidirectionals
inout PS2_CLK;
inout	PS2_DAT;

// Outputs
output [6:0] HEX5;
output [6:0] HEX4;
output [6:0] HEX3;
output		 VGA_CLK;   			//	VGA Clock
output		 VGA_HS;					//	VGA H_SYNC
output		 VGA_VS;					//	VGA V_SYNC
output		 VGA_BLANK_N;			//	VGA BLANK
output		 VGA_SYNC_N;			//	VGA SYNC
output [7:0] VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
output [7:0] VGA_G;	 				//	VGA Green[7:0]
output [7:0] VGA_B;   				//	VGA Blue[7:0]

// Internal wires
wire 	[7:0]	ps2_key_data;
wire			ps2_key_pressed;
wire 			VolumeGo;
wire 			PitchGo;
wire 			DistortionGo;
wire 			EffectGo;
wire  [6:0] volume_data;
wire  [6:0] pitch_data;
wire  [6:0] distortion_data;
wire [11:0] data;
// Create the colour, x, y and writeEn wires that are inputs to the controller.
wire [11:0] colour;
wire [7:0] x;
wire [6:0] y;
wire writeEn;


/*****************************************************************************
*                              Internal Modules                             *
*****************************************************************************/

vga_adapter VGA(
	.resetn(~KEY[0]),
	.clock(CLOCK_50),
	.colour(colour),
	.x(x),
	.y(y),
	.plot(writeEn),
	/* Signals for the DAC to drive the monitor. */
	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
	.VGA_B(VGA_B),
	.VGA_HS(VGA_HS),
	.VGA_VS(VGA_VS),
	.VGA_BLANK(VGA_BLANK_N),
	.VGA_SYNC(VGA_SYNC_N),
	.VGA_CLK(VGA_CLK));
defparam VGA.RESOLUTION = "160x120";
defparam VGA.MONOCHROME = "FALSE";
defparam VGA.BITS_PER_COLOUR_CHANNEL = 4;
defparam VGA.BACKGROUND_IMAGE = "AMP_BACKGROUND.mif";

vga_plot VGAOutput(
	// Inputs
	.Clock					(CLOCK_50),
	.Reset					(~KEY[0]),
	.VolumeOn				(SW[9]),
	.PitchOn				(SW[8]),
	.DistortionOn		(SW[7]),	
	.VolumeGo				(VolumeGo),
	.PitchGo				(PitchGo),
	.DistortionGo		(DistortionGo),
	.EffectGo				(EffectGo),
	.volume_data			(volume_data),
	.pitch_data			(pitch_data),
	.distortion_data	(distortion_data),
	
	//Outputs
	.colour				(colour),
	.x						(x),
	.y						(y),
	.writeEn				(writeEn)	
);


PS2_Demo KeyboardInput (
	// Inputs
	.Clock				(CLOCK_50),
	.Reset				(~KEY[0]),
	.ps2_key_data		(ps2_key_data),
	.ps2_key_pressed	(ps2_key_pressed),
	.VolumeOn			(SW[9]),
	.PitchOn				(SW[8]),
	.DistortionOn		(SW[7]),
	.SetVolume			(~KEY[3]),
	.SetPitch			(~KEY[2]),
	.SetDistortion		(~KEY[1]),
	
	// Outputs
	.VolumeGo			(VolumeGo),
	.PitchGo				(PitchGo),
	.DistortionGo		(DistortionGo),
	.EffectGo			(EffectGo),
	.volume_data		(volume_data),
	.pitch_data			(pitch_data),
	.distortion_data  (distortion_data),
	.data					(data)
);


PS2_Controller PS2 (
	// Inputs
	.CLOCK_50			(CLOCK_50),
	.reset				(~KEY[0]),

	// Bidirectionals
	.PS2_CLK				(PS2_CLK),
	.PS2_DAT				(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);


Hexadecimal_To_Seven_Segment Segment0 (
	// Inputs
	.hex_number			(data [11:8]),

	// Outputs
	.seven_seg_display	(HEX5)
);

Hexadecimal_To_Seven_Segment Segment1 (
	// Inputs
	.hex_number			(data [7:4]),

	// Outputs
	.seven_seg_display	(HEX4)
);

Hexadecimal_To_Seven_Segment Segment2 (
	// Inputs
	.hex_number			(data [3:0]),

	// Outputs
	.seven_seg_display	(HEX3)
);

endmodule 