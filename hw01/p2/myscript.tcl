##################
# HW01 - Q2	 #
# Digvijay Anand #
# Print cl args  #
##################


# Check if exactly 3 arguments are provided
if { $argc != 3 } {
    puts "\[Error\]: usage tclsh myscript.tcl num1 num2 num3"
    exit 1
}

# Get the command-line arguments
set num1 [lindex $argv 0]
set num2 [lindex $argv 1]
set num3 [lindex $argv 2]

# Print in new line
puts "Num\[1\]: $num1"
puts "Num\[2\]: $num2"
puts "Num\[3\]: $num3"
