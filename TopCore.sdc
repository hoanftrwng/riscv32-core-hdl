#============================================================
# Clock Constraint for Altera DE2
# CLOCK_50 = 50 MHz -> Period = 20 ns
#============================================================

create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]

#============================================================
# Manual switches and buttons are asynchronous external inputs.
# For this student demo, we focus on internal clock timing.
#============================================================

set_false_path -from [get_ports {KEY[*]}]
set_false_path -from [get_ports {SW[*]}]