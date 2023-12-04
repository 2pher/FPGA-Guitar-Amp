# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog top_module.v

#load simulation using mux as the top level simulation module
vsim top_module

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {SW[9]} 0
force {KEY[3]} 1

#run simulation for a few ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {SW[9]} 1
force {ps2_key_data[7]} 0
force {ps2_key_data[6]} 0
force {ps2_key_data[5]} 0
force {ps2_key_data[4]} 1
force {ps2_key_data[3]} 0
force {ps2_key_data[2]} 1
force {ps2_key_data[1]} 1
force {ps2_key_data[0]} 0

force {Clock} 1
run 1ns
force {Clock} 0
run 1ns

# S_MAIN
force {KEY[3]} 0
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {KEY[3]} 1
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 0 1ns, 1 {1ns} -r 1ns
run 20ns

force {ps2_key_data[7]} 0
force {ps2_key_data[6]} 1
force {ps2_key_data[5]} 0
force {ps2_key_data[4]} 1
force {ps2_key_data[3]} 1
force {ps2_key_data[2]} 0
force {ps2_key_data[1]} 1
force {ps2_key_data[0]} 0

force {Clock} 0 1ns, 1 {1ns} -r 1ns
run 2000ns


