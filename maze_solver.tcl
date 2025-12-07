# clear the environment
clear -all

analyze -sv MazeSolver.sv
analyze -sv fvm_Maze_Solver.sv

elaborate -top Maze_solver

# Set up clocks and Resets
clock clk
reset rst

prove -property Maze_Solver.fvm_Maze_Solver.find_best_path

# Set the path to the log file
set log_file_path "jgproject/sessionLogs/session_0/jg_session_0.log"

# Set a time limit to a limit of choice
set_proof_time_limit 200 

# Open the log file for reading
set file_id [open $log_file_path r]
set cycle_list {}

# Read the file line by line
while {[gets $file_id line] >= 0} {
    # Match line like: "p_cov_done was covered in X cycles"
    if {[regexp {find_best_path\" was covered in (\d+) cycles} $line -> cycles]} {
        lappend cycle_list $cycles
    }
}

# Close the file
close $file_id

# Print the extracted cycle counts
if {[llength $cycle_list] > 0} {
    # puts "minimum number of steps to find the treasure is:"
    foreach c $cycle_list {
        puts "Minimum number of steps to find the treasure is: $c"
    }
} else {
    puts "No coverage information found for find_best_path."
}

get_design_info
check_assumptions
check_assumptions -live
check_assumptions -dead_end -bg
cover -name find_paths -generate -expression {x_pos == 4'd9 && y_pos == 4'd9} -count 1:5

prove -property find_paths_count_*

visualize -property <embedded>::find_paths_count_1 -new_window
visualize -property <embedded>::find_paths_count_2 -new_window
visualize -property <embedded>::find_paths_count_3 -new_window
visualize -property <embedded>::find_paths_count_4 -new_window
