# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog vga_plot.v

#load simulation using mux as the top level simulation module
vsim vga_plot

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {VolumeOn} 0
force {PitchOn} 0
force {DistortionOn} 0

#run simulation for a few ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns

# S_MAIN
force {VolumeOn} 1
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns

# S_VOLUME


