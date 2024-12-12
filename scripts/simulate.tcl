# Define the simulation directory area.
set simDir ./sim
file mkdir $simDir

# Define source directories
set srcDir ../src/
# set xdcFile ./Sources/top_full.xdc

# Create a project
create_project cpupipe_sim ./sim

# Add source files
add_files $srcDir/top.sv

# Set the top module
set_property top top [current_fileset -simset]

# Run simulation
launch_simulation

# Run the simulation for a specific time
run 1000ns

# Close simulation
close_sim

start_gui