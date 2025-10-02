# Clock constraint
create_clock -period 12.66 [get_ports clk]

# Input delays
set_input_delay -clock [get_clocks clk] 2.0 [get_ports {nickel dime cancel rst}]
set_input_delay -clock [get_clocks clk] 2.0 [get_ports item_select[*]]

# Output delays  
set_output_delay -clock [get_clocks clk] 2.0 [get_ports {vend change_5C change_10C}]