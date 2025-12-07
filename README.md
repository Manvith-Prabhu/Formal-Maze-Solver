# Formal-Maze-Solver

This repo hosts the code that implements a maze solver using SystemVerilog and Formal Verification. The maze is defined as a 10x10 grid, where 1 represents a path and 0 represents a wall. The solver uses a simple algorithm to navigate the maze and find the shortest path to the destination. The objective is to find the path with minimum length and number of all possible paths while ensuring the formal environment is conflict free and has no dead ends and the code is synthesizable (**no recursion is possible**). More about the challenge: [Cadence Challenge Link](https://jugindia2025.vfairs.com/en/jasper-contest)

## Files 
**Maze_Solver.sv**: The top-level module that defines the maze and the solver.  
**maze_solver.tcl**: The script that runs the simulation and formal verification.  
**fvm_Maze_Solver.sv**: The formal verification module that checks the properties of the solver.

## General Rules

1) One step in X or Y direction per cycle: no diagonal movements
2) No Loops - Discard any path with loops
3) No idle Cycles - Traverser must move every cycle

## Maze Solver Module

The Maze_Solver.sv module takes the following inputs:  
- clk: The clock signal.  
- rst: The reset signal.  
- direction: The direction to move (up, down, left, or right).  
- x_pos and y_pos: The current position of the solver.  
- found: A flag indicating whether the destination has been reached.  

The module uses a simple algorithm to navigate the maze:  
1) If the current position is not the destination, move in the specified direction.
2) If the new position is a wall or has been visited before, do not move.
3) If the new position is the destination, set the found flag.

## Formal Verification Module 

The fvm_Maze_Solver.sv module checks the following properties:  
no_duplicate_path: Ensures that the solver does not repeat the path already taken.  
find_best_path: Checks that the solver reaches the destination.  

The module uses a struct to store the paths taken by the solver and checks for duplicates.

## Simulation and Formal Verification

The maze_solver.tcl script runs the simulation and formal verification. The script prints the minimum number of steps to reach the destination and the number of unique paths found. It also prints the paths taken by the solver using x and y coordinates at each step in the format 8'hxy.

## Usage

To run the simulation and formal verification, execute the maze_solver.tcl using Cadence Jaspergold  
`jg maze_solver.tcl &`

*Note*: Proof time limit has been set to 200 seconds for convenience as there are only 4 logically possible paths for the current maze and 5th cover takes very long time to fail.
