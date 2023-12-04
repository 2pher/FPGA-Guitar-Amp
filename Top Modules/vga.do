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
force {EffectGo} 0
force {volume_data[6]} 1
force {volume_data[5]} 0
force {volume_data[4]} 0
force {volume_data[3]} 1
force {volume_data[2]} 0
force {volume_data[1]} 1
force {volume_data[0]} 1

#run simulation for a few ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns

# S_MAIN
force {EffectGo} 1
force {VolumeGo} 1
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {EffectGo} 0
force {Clock} 1
run 1ns
force {Clock} 0
run 1ns
force {Clock} 0 1ns, 1 {1ns} -r 1ns
run 2500ns


