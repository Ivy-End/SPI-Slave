set_host_options -max_cores 16
set LIB_CORE_PATH "/backup-tools/PDK/XMC/XMC55_HP/STD/xmc55ef_hp/std_lib_20181213/hvt_std_lib_9t_20181213/lib"
set LIB_DW_PATH "/backup-tools/Synopsys/syn_vO-2018.06-SP4/libraries/syn"

#set LIB_CORE_SLOW "xmc9t_55ef_ss_1p08v_m40c.db"
set LIB_CORE_SLOW "xmc9t_55ef_ss_1p08v_m40c.db"
set LIB_DW_SLOW "dw_foundation.sldb"

##define working directory
set SYN_DDC_PATH "./dc/ddc"
set SYN_SDC_PATH "./dc/sdc"
set SYN_REPORT_PATH "./dc/report"
set SYN_NET_PATH "./dc/netlist"
set SYN_WORK_PATH "./dc/work"

define_design_lib WORK -path $SYN_WORK_PATH

##define paths to RTL and Library
set search_path "$LIB_CORE_PATH $LIB_DW_PATH"

echo $search_path

set target_library "$LIB_CORE_SLOW"
set link_library "* $target_library"
set synthetic_library "$LIB_DW_SLOW"


suppress_message {VER-130 VER-311 VER-314 VER-936 UID-95 SYNOPT-10 UCN-4 UCN-8 ELAB-311 PWR-537 VO-11}
set top_design SPI
set uniquify_naming_style "${top_design}_%s_%d"

set hdlin_while_loop_iterations 10240

#set all_blocks {WLFSM WLFSMDecoder}
#foreach block $all_blocks {
#	read_ddc ./dc/ddc/${block}.ddc
#	set_dont_touch [get_designs ${block}]
#}

#set_dont_use {xmc65_stdcell_typ/*DELAY*}

analyze -library WORK -format verilog {../Design/src/rtl/SPI.v }

elaborate $top_design 
current_design $top_design
uniquify

set_fix_multiple_port_nets -all -buffer_constants

link


##set constrains
create_clock -name "Clk" -period 10 [get_ports Clk]

set_dont_touch_network Clk


set_clock_uncertainty 3 [get_clocks Clk]

set_drive 0 [get_ports aRst_n]
set_ideal_network -no_propagate [get_nets {*aRst_n*}]

set_false_path -from [get_ports aRst_n]


##compile
write -format verilog -hier -output $SYN_NET_PATH/${top_design}_pre.cg.gv
echo "**********Begin Compile**************"
date
compile_ultra
report_constraint -all > $SYN_REPORT_PATH/${top_design}.constraint
check_design > $SYN_REPORT_PATH/${top_design}.check_design.log
##write out reports
define_name_rules port_name_rules -equal_ports_nets
define_name_rules verilog -max_length 64
define_name_rules no_case -case_insensitive

set bus_dimension_separator_style           {][}
set bus_inference_style                     {%s[%d]}
set bus_naming_style                        {%s[%d]}
set change_names_dont_change_bus_members    true
set hdlin_escape_specail_names              false
set template_naming_style                   "%s_%p"
set template_parameter_style                "%s_%p"
set template_separator_style                "_"
change_names -rule verilog -hierarchy
set uniquify_naming_style "${current_design}_%s_%d"
change_names -rule no_case -hier
change_names -rule port_name_rules -hier

write -format ddc -hier -output $SYN_DDC_PATH/${top_design}.ddc
write -format verilog -hier -output $SYN_NET_PATH/${top_design}.cg.gv
write_sdc $SYN_SDC_PATH/${top_design}.sdc
write_sdf $SYN_REPORT_PATH/${top_design}.sdf

report_area -h -nosplit > $SYN_REPORT_PATH/${top_design}.area
report_timing -max_paths 200 -capacitance -nets -transition_time  > $SYN_REPORT_PATH/${top_design}.tim
report_power  > $SYN_REPORT_PATH/${top_design}.power
 
