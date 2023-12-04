
module AudioTesting (
	// Inputs
	Clock,
	Reset,
	VolumeOn,
	PitchOn,
	DistortionOn,
	volume_data,
	pitch_data,
	distortion_data,

	AUD_ADCDAT,
	
	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,

);


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// inputs
input Clock; 
input Reset;
input AUD_ADCDAT;
input VolumeOn;
input PitchOn;
input DistortionOn;
input [6:0] volume_data;
input [6:0] pitch_data;
input [6:0] distortion_data;

// bidirectionals
inout	AUD_BCLK;
inout	AUD_ADCLRCK;
inout	AUD_DACLRCK;
inout	FPGA_I2C_SDAT;

// outputs
output AUD_XCK;
output AUD_DACDAT;
output FPGA_I2C_SCLK;

//parameters
//when instantiating in top level, change to variable value based on 1 - 100 value
reg [31:0] distortionGain; // Not sure

// main wires (don't edit)
wire audio_in_available;
wire [31:0] left_channel_audio_in;
wire [31:0] right_channel_audio_in;
wire read_audio_in;

wire audio_out_allowed;
wire [31:0] left_channel_audio_out;
wire [31:0] right_channel_audio_out;
wire write_audio_out;

// effect wires (can edit)

reg [31:0] left_volume_audio_in;
reg [31:0] right_volume_audio_in;

always@ (posedge Clock)
begin
	distortionGain [31:0] <= 32'd7000000 * distortion_data;
	if(DistortionOn) begin //distortion on
		if(left_channel_audio_in > distortionGain)
			left_volume_audio_in <= distortionGain;
		else if(left_channel_audio_in < -distortionGain)
			left_volume_audio_in <= -distortionGain;
		else 
			left_volume_audio_in <= left_channel_audio_in; 
				
		if(right_channel_audio_in > distortionGain)
			right_volume_audio_in <= distortionGain;
		else if(right_channel_audio_in < -distortionGain)
			right_volume_audio_in <= -distortionGain;
		else 
			right_volume_audio_in <= right_channel_audio_in; 
	end
	else
		left_volume_audio_in <= left_channel_audio_in; 
		right_volume_audio_in <= right_channel_audio_in; 
end



// main audio assign (don't edit)

assign read_audio_in	= audio_in_available & audio_out_allowed;

assign left_channel_audio_out	= volume_data * left_volume_audio_in; //test with low filter removed
assign right_channel_audio_out = volume_data * right_volume_audio_in;
assign write_audio_out = audio_in_available & audio_out_allowed;

// instantiations
Audio_Controller audiooooo (
		// inputs
	.CLOCK_50(Clock),
	.reset(Reset),

	.clear_audio_in_memory(), //no memory
	.read_audio_in(read_audio_in),
	
	.clear_audio_out_memory(), //no memory
	.left_channel_audio_out(left_channel_audio_out),
	.right_channel_audio_out(right_channel_audio_out),
	.write_audio_out(write_audio_out),

	.AUD_ADCDAT(AUD_ADCDAT),

	// bidirectionals
	.AUD_BCLK(AUD_BCLK),
	.AUD_ADCLRCK(AUD_ADCLRCK),
	.AUD_DACLRCK(AUD_DACLRCK),


	// outputs
	.audio_in_available(audio_in_available),
	.left_channel_audio_in(left_channel_audio_in),
	.right_channel_audio_in(right_channel_audio_in),

	.audio_out_allowed(audio_out_allowed),

	.AUD_XCK(AUD_XCK),
	.AUD_DACDAT(AUD_DACDAT)

);

avconf #(.USE_MIC_INPUT(1)) mic_or_line_in ( // 1 for mic, 0 for line in
	.FPGA_I2C_SCLK(FPGA_I2C_SCLK),
	.FPGA_I2C_SDAT(FPGA_I2C_SDAT),
	.CLOCK_50(Clock),
	.reset(Reset)
);

endmodule

