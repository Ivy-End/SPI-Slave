###################################################################

# Created by write_sdc on Mon Apr 24 21:41:32 2023

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_ideal_network -no_propagate  [get_ports aRst_n]
create_clock [get_ports Clk]  -period 10  -waveform {0 5}
set_clock_uncertainty 3  [get_clocks Clk]
set_false_path   -from [get_ports aRst_n]
