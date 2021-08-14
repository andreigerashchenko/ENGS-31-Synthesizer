## This file is a general .xdc for the Basys3 rev B board for ENGS31/CoSc56
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

##====================================================================
## External_Clock_Port
##====================================================================
set_property PACKAGE_PIN W5 [get_ports clk_iport_100MHz]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk_iport_100MHz]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_iport_100MHz]

##====================================================================
## Switch_ports
##====================================================================
## SWITCH 0
set_property PACKAGE_PIN V17 [get_ports {data_in_port[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[0]}]
## SWITCH 1
set_property PACKAGE_PIN V16 [get_ports {data_in_port[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[1]}]
## SWITCH 2
set_property PACKAGE_PIN W16 [get_ports {data_in_port[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[2]}]
## SWITCH 3
set_property PACKAGE_PIN W17 [get_ports {data_in_port[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[3]}]
## SWITCH 4
set_property PACKAGE_PIN W15 [get_ports {data_in_port[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[4]}]
## SWITCH 5
set_property PACKAGE_PIN V15 [get_ports {data_in_port[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[5]}]
## SWITCH 6
set_property PACKAGE_PIN W14 [get_ports {data_in_port[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[6]}]
## SWITCH 7
set_property PACKAGE_PIN W13 [get_ports {data_in_port[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[7]}]
## SWITCH 8
set_property PACKAGE_PIN V2 [get_ports {data_in_port[8]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[8]}]
## SWITCH 9
set_property PACKAGE_PIN T3 [get_ports {data_in_port[9]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[9]}]
## SWITCH 10
set_property PACKAGE_PIN T2 [get_ports {data_in_port[10]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[10]}]
## SWITCH 11
set_property PACKAGE_PIN R3 [get_ports {data_in_port[11]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[11]}]

##====================================================================
## Buttons
##====================================================================
## CENTER BUTTON
set_property PACKAGE_PIN U18 [get_ports dac_trigger]						
	set_property IOSTANDARD LVCMOS33 [get_ports dac_trigger]

##====================================================================
## Pmod Header JA
##====================================================================
#Sch name = JA1
set_property PACKAGE_PIN J1 [get_ports {cs_out_port}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {cs_out_port}]
#Sch name = JA2
set_property PACKAGE_PIN L2 [get_ports {data_out_port}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {data_out_port}]
#Sch name = JA4
set_property PACKAGE_PIN G2 [get_ports {clk_out_port}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {clk_out_port}]

##====================================================================
## Implementation Assist
##====================================================================	
## These additional constraints are recommended by Digilent, do not remove!
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]