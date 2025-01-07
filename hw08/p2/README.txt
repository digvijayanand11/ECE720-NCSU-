SystemC High Level Synthesis Tutorial
(c) 11/5/2024 W. Rhett Davis (rhett_davis@ncsu.edu)

This tutorial introduces High-Level Synthesis (HLS) using Siemens EDA
Catapult with the Nvidia Labs Connections library at NC State
University.  It is assumed that you already know how to compile and
execute SystemC simulations.

Quick Start Instructions:

1) Log in to a Linux Lab Machine
2) Change to the directory that contains this file
3) Source the setup script with the command "source setup.sh"
4) Change to the "sc" directory
5) Build the SystemC simulation with the command "make"
6) Simulate the SystemC project with the command "make sim".
     This simulation is successful if you see the message "Simulation PASSED"
7) Repeat the "make" and "make sim" commands as needed to rebuild
     and re-simulate the project.
8) Change to the directory "../hls"
9) Use the command "make setup" to initialize the results.csv file
10) Execute High-Level Synthesis with the command "make"
     - The log-file will be written to "catapult_hls.log".
     - Synthesis is successful when the file Catapult/${TOP_NAME}.v1/rtl.v
       is generated.  
     - The report is written to the file rtl.rpt in this same directory.
     - Parsed results from rtl.rpt will be appended to results.csv.
11) Use "make clean" followed by "make" as needed to re-run HLS as needed.
12) Change to the directory "../vsim"
13) Build the RTL simulation with the command "make"
14) Copy any stimulus files needed from the ../sc directory
     (e.g. "cp ../sc *.dat .")
15) Simulate the RTL project with the command "make sim".
     This simulation will use the same testbench as the SystemC project
     but will use the Catapult rtl.v file in place of the SystemC design.
     As before, it is successful if you see the message "Simulation PASSED".
     

Notes:

- There is a bug in the Dest module: if it is unable to open its
    stimulus file, then it will print the message "Simulation PASSED"
    at 31 ns and end the simulation.  Do not let this fool you into
    thinking that the HLS has generated a super-fast implementation.
- See the examples directory for more design examples.
- The following changes can be made when modifying this tutorial
  for a new design:
    -- Change TOP_NAME in hls/Makefile and vsim/Makefile
         if the top-level module name changes
    -- Change CLK_PERIOD in hls/Makefile to change the clock period
    -- Set loop constraint directives in the usercmd_post_assembly 
         procedure in hls/go_hls.tcl.  For example, try adding the 
         following line to unroll the mult_acc loop with the DotProd design:
            directive set /$TOP_NAME/run/while/mult_acc -UNROLL 2

