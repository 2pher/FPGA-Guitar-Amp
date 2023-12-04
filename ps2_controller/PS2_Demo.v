module PS2_Demo (
	// Inputs
	CLOCK_50,
	KEY,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	HEX6,
	HEX7
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				CLOCK_50;
input		[3:0]	KEY;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Outputs
output		[6:0]	HEX0;
output		[6:0]	HEX1;
output		[6:0]	HEX2;
output		[6:0]	HEX3;
output		[6:0]	HEX4;
output		[6:0]	HEX5;
output		[6:0]	HEX6;
output		[6:0]	HEX7;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
wire 		[7:0] final_data;
wire				ps2_key_pressed;
wire 				enter_key_pressed;
wire 				load_num_1;
wire 				load_num_2;
wire 				load_num_3;
wire 				done;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLOCK_50) begin
	if (KEY[0] == 1'b0)
		last_data_received <= 8'h00;
	else if (ps2_key_pressed == 1'b1)
		last_data_received <= ps2_key_data;
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

assign HEX2 = 7'h7F;
assign HEX3 = 7'h7F;
assign HEX4 = 7'h7F;
assign HEX5 = 7'h7F;
assign HEX6 = 7'h7F;
assign HEX7 = 7'h7F;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

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

ps2 datapath (
	// Inputs
	.Clock (CLOCK_50),
	.Reset_n (~KEY[0]),
	.key_pressed (ps2_key_pressed),
	.LoadedNum1 (load_num_1),
	.LoadedNum2 (load_num_2),
	.LoadedNum3 (load_num_3),
	.Done (done),
	.received_data (ps2_key_data),
	
	// Outputs
	.final_data (final_data),
	.enter_key_pressed(enter_key_pressed)	
);

keyboardControl control (
	// Inputs
	.Clock (CLOCK_50),
	.Reset_n (~KEY[0]),
	.iLoadNum (ps2_key_pressed),
	.iLoadEnter (enter_key_pressed),
	
	// Outputs
	.LoadNum1 (load_num_1),
	.LoadNum2 (load_num_2),
	.LoadNum3 (load_num_3),
	.oDone (done)
);

Hexadecimal_To_Seven_Segment Segment0 (
	// Inputs
	.hex_number			(last_data_received[3:0]),

	// Outputs
	.seven_seg_display	(HEX0)
);

Hexadecimal_To_Seven_Segment Segment1 (
	// Inputs
	.hex_number			(last_data_received[7:4]),

	// Outputs
	.seven_seg_display	(HEX1)
);


endmodule
