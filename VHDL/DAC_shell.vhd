--=============================================================
--Ben Dobbins
--ES31/CS56
--This script is the shell code for Lab 6, the voltmeter.
--Your name goes here: 
--=============================================================

--=============================================================
--Library Declarations
--=============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;			-- needed for arithmetic
use ieee.math_real.all;				-- needed for automatic register sizing
library UNISIM;						-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;

--=============================================================
--Shell Entitity Declarations
--=============================================================
entity DAC_out_top_level is
port (  
	clk_iport_100MHz 	: in  std_logic;					
	data_in_port		: in  std_logic_vector(11 downto 0);
	dac_trigger			: in  std_logic;

	cs_out_port			: out std_logic;						--chip select
	data_out_port		: out std_logic;						--data output
	clk_out_port		: out std_logic);						--serial clock

end entity DAC_out_top_level; 

--=============================================================
--Architecture + Component Declarations
--=============================================================
architecture Behavioral of DAC_out_top_level is
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--System Clock Generation:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

component clk_wiz_0
	port
	 (-- Clock in ports
	  -- Clock out ports
	  clk_4800khz          	: out    std_logic;
	  -- Status and control signals
	  locked            	: out    std_logic;
	  clk_100mhz           	: in     std_logic);
	end component;


--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--DAC_out
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component DAC_out is
	generic(
		N_BITS			: integer);
	port(
		clk_in_port			: in  std_logic;	--Slower clock
		clk_out_port		: out std_logic;
    	
		data_in_port		: in  std_logic_vector(11 downto 0);
		dac_trigger			: in  std_logic;	--datapath signals
		
		data_out_port		: out std_logic;
		cs_out_port			: out std_logic);
end component;

--=============================================================
--Local Signal Declaration
--=============================================================
signal clk_divided : std_logic := '0';
signal take_sample : std_logic := '0';                   
signal shift_en: std_logic := '0';
signal load_en: std_logic := '0';
signal cs_out:	std_logic := '0';
signal bit_out:	std_logic := '0';
signal locked:  std_logic := '0';

signal data: std_logic_vector(11 downto 0) := (others => '0');	-- A/D data


--=============================================================
--Port Mapping + Processes:
--=============================================================
begin
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Timing:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
clock_generation : clk_wiz_0
   port map ( 
  -- Clock out ports  
   clk_4800khz => clk_divided,
  -- Status and control signals                
   locked => locked,
   -- Clock in ports
   clk_100mhz => clk_iport_100MHz
   );

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--DAC_out:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
transmitter: DAC_out
generic map(
	N_BITS => 16)
port map(
	clk_in_port			=> clk_divided,
	clk_out_port		=> clk_out_port,
	data_in_port		=> data_in_port,
	dac_trigger			=> dac_trigger,
	data_out_port		=> data_out_port,
	cs_out_port			=> cs_out_port);   
end Behavioral; 