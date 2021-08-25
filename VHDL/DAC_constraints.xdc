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
#set_property PACKAGE_PIN V17 [get_ports {data_in_port[15]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[15]}]
### SWITCH 1
#set_property PACKAGE_PIN V16 [get_ports {data_in_port[14]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[14]}]
### SWITCH 2
#set_property PACKAGE_PIN W16 [get_ports {data_in_port[13]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[13]}]
### SWITCH 3
#set_property PACKAGE_PIN W17 [get_ports {data_in_port[12]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[12]}]
### SWITCH 4
#set_property PACKAGE_PIN W15 [get_ports {data_in_port[11]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[11]}]
### SWITCH 5
#set_property PACKAGE_PIN V15 [get_ports {data_in_port[10]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[10]}]
### SWITCH 6
#set_property PACKAGE_PIN W14 [get_ports {data_in_port[9]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[9]}]
### SWITCH 7
#set_property PACKAGE_PIN W13 [get_ports {data_in_port[8]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[8]}]
### SWITCH 8
#set_property PACKAGE_PIN V2 [get_ports {data_in_port[7]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[7]}]
### SWITCH 9
#set_property PACKAGE_PIN T3 [get_ports {data_in_port[6]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[6]}]
### SWITCH 10
#set_property PACKAGE_PIN T2 [get_ports {data_in_port[5]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[5]}]
### SWITCH 11
#set_property PACKAGE_PIN R3 [get_ports {data_in_port[4]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[4]}]
### SWITCH 12
#set_property PACKAGE_PIN W2 [get_ports {data_in_port[3]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[3]}]
### SWITCH 13
#set_property PACKAGE_PIN U1 [get_ports {data_in_port[2]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[2]}]
### SWITCH 14
#set_property PACKAGE_PIN T1 [get_ports {data_in_port[1]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[1]}]
### SWITCH 15
#set_property PACKAGE_PIN R2 [get_ports {data_in_port[0]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {data_in_port[0]}]

##====================================================================
## LED_ports
##====================================================================
# LED 0
set_property PACKAGE_PIN U16 [get_ports {LED_port[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[0]}]
# LED 1
set_property PACKAGE_PIN E19 [get_ports {LED_port[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[1]}]
# LED 2
set_property PACKAGE_PIN U19 [get_ports {LED_port[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[2]}]
# LED 3
set_property PACKAGE_PIN V19 [get_ports {LED_port[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[3]}]
# LED 4
set_property PACKAGE_PIN W18 [get_ports {LED_port[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[4]}]
# LED 5
set_property PACKAGE_PIN U15 [get_ports {LED_port[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[5]}]
# LED 6
set_property PACKAGE_PIN U14 [get_ports {LED_port[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[6]}]
# LED 7
set_property PACKAGE_PIN V14 [get_ports {LED_port[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[7]}]
# LED 8
set_property PACKAGE_PIN V13 [get_ports {LED_port[8]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[8]}]
# LED 9
set_property PACKAGE_PIN V3 [get_ports {LED_port[9]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[9]}]
# LED 10
set_property PACKAGE_PIN W3 [get_ports {LED_port[10]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[10]}]
# LED 11
set_property PACKAGE_PIN U3 [get_ports {LED_port[11]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[11]}]
# LED 12
set_property PACKAGE_PIN P3 [get_ports {LED_port[12]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[12]}]
# LED 13
set_property PACKAGE_PIN N3 [get_ports {LED_port[13]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[13]}]
# LED 14
set_property PACKAGE_PIN P1 [get_ports {LED_port[14]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[14]}]
# LED 15
set_property PACKAGE_PIN L1 [get_ports {LED_port[15]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[15]}]

##====================================================================
## Reversed LED_ports
##====================================================================
# # LED 0
# set_property PACKAGE_PIN U16 [get_ports {LED_port[15]}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[15]}]
# # LED 1
# set_property PACKAGE_PIN E19 [get_ports {LED_port[14]}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[14]}]
# # LED 2
# set_property PACKAGE_PIN U19 [get_ports {LED_port[13]}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[13]}]
# # LED 3
# set_property PACKAGE_PIN V19 [get_ports {LED_port[12]}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[12]}]
# # LED 4
# set_property PACKAGE_PIN W18 [get_ports {LED_port[11]}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[11]}]
# # LED 5
# set_property PACKAGE_PIN U15 [get_ports {LED_port[10]}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[10]}]
# # LED 6
# set_property PACKAGE_PIN U14 [get_ports {LED_port[9]}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[9]}]
# # LED 7
# set_property PACKAGE_PIN V14 [get_ports {LED_port[8]}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[8]}]
# # LED 8
# set_property PACKAGE_PIN V13 [get_ports {LED_port[7]}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[7]}]
# # LED 9
# set_property PACKAGE_PIN V3 [get_ports {LED_port[6]}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[6]}]
# # LED 10
# set_property PACKAGE_PIN W3 [get_ports {LED_port[5]}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[5]}]
# # LED 11
# set_property PACKAGE_PIN U3 [get_ports {LED_port[4]}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[4]}]
# # LED 12
# set_property PACKAGE_PIN P3 [get_ports {LED_port[3]}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[3]}]
# # LED 13
# set_property PACKAGE_PIN N3 [get_ports {LED_port[2]}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[2]}]
# # LED 14
# set_property PACKAGE_PIN P1 [get_ports {LED_port[1]}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[1]}]
# # LED 15
# set_property PACKAGE_PIN L1 [get_ports {LED_port[0]}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {LED_port[0]}]
	

##====================================================================
## Buttons
##====================================================================
## CENTER BUTTON
# set_property PACKAGE_PIN U18 [get_ports dac_trigger]						
# 	set_property IOSTANDARD LVCMOS33 [get_ports dac_trigger]

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
## Pmod Header JB
##====================================================================
#Sch name = JB1
set_property PACKAGE_PIN A14 [get_ports {midi_in_port}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {midi_in_port}]

##====================================================================
## Pmod Header JC
##====================================================================
##Sch name = JC1
 set_property PACKAGE_PIN K17 [get_ports {tc_half_port}]					
 	set_property IOSTANDARD LVCMOS33 [get_ports {tc_half_port}]
##Sch name = JC2
set_property PACKAGE_PIN M18 [get_ports {tc_full_port}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {tc_full_port}]
##Sch name = JC3
set_property PACKAGE_PIN N17 [get_ports {rx_sync_port}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {rx_sync_port}]
##Sch name = JC4
#set_property PACKAGE_PIN P18 [get_ports {JC_port[3]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC_port[3]}]
##Sch name = JC7
#set_property PACKAGE_PIN L17 [get_ports {JC_port[4]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC_port[4]}]
##Sch name = JC8
#set_property PACKAGE_PIN M19 [get_ports {JC_port[5]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC_port[5]}]
##Sch name = JC9
#set_property PACKAGE_PIN P17 [get_ports {JC_port[6]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC_port[6]}]
##Sch name = JC10
#set_property PACKAGE_PIN R18 [get_ports {JC_port[7]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC_port[7]}]


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