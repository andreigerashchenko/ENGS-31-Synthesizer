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
entity Synthesizer_top_level is
port (  
	clk_iport_100MHz 	: in  std_logic;
--	midi_in_port        : in std_logic_vector(8 downto 0); -- will be used for the MIDI input, the value 8 downto 0 is just for testing need to change when actually using midi					
	data_in_port		: in  std_logic_vector(7 downto 0); -- changed for MIDI testbenching
	dac_trigger			: in  std_logic;
	sw1                 : in  std_logic;
	sw2                 : in  std_logic;
    sw3                 : in  std_logic;

	cs_out_port			: out std_logic;						--chip select
	data_out_port		: out std_logic;						--data output
	clk_out_port		: out std_logic;						--serial clock
	load_debug_port     : out std_logic
	);

end entity Synthesizer_top_level; 

--=============================================================
--Architecture + Component Declarations
--=============================================================
architecture Behavioral of Synthesizer_top_level is
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
--DDS Compiler
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component dds_compiler_0
  port (
    aclk                     : in       std_logic;
    s_axis_phase_tvalid      : in       std_logic;
    s_axis_phase_tdata       : in       std_logic_vector(15 downto 0);
--    s_axis_phase_tdata       : in       std_logic_vector(13 downto 0);
    m_axis_data_tvalid       : out      std_logic;
    m_axis_data_tdata       : out       std_logic_vector(15 downto 0)
--    m_axis_data_tdata        : out      std_logic_vector(11 downto 0)
  );
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Sample Rate Tick Generator
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component tick_generator is
	generic (
	   FREQUENCY_DIVIDER_RATIO : integer);
	port (
		system_clk_iport : in  std_logic;
		tick_oport		 : out std_logic);
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Phase Accumulator
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component phase_accumulator is
    port (
        -- input ports
        clk_in_port:        in   std_logic;
        sample_rate_tick:   in   std_logic;
        midi_data_in_port:  in   std_logic_vector(7 downto 0);
        sw1:                in   std_logic;
        sw2:                in   std_logic;
        sw3:                in   std_logic;
        
        -- output ports
--        sine_addr_out_port: out std_logic_vector(13 downto 0)
        sine_addr_out_port: out std_logic_vector(15 downto 0)
    );
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Volume Control
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component volume_control is
    port (
        -- input ports
        original_sine: in std_logic_vector(15 downto 0);
        -- output ports
        modified_sine: out std_logic_vector(15 downto 0)
    );
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
    	
		data_in_port		: in  std_logic_vector(15 downto 0);
		dac_trigger			: in  std_logic;	--datapath signals
		
		data_out_port		: out std_logic;
		cs_out_port			: out std_logic;
		load_debug_port     : out std_logic);
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

signal dec_vol_sine: std_logic_vector(15 downto 0) := (others => '0');

signal sine_addr: std_logic_vector(15 downto 0) := (others => '0');
signal data: std_logic_vector(11 downto 0) := (others => '0');	-- A/D data
signal sine_wave: std_logic_vector(15 downto 0) := (others => '0');
signal data_ready : std_logic := '0'; 


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
--DDS Compiler
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	

dds_compiler : dds_compiler_0
  PORT MAP (
    aclk => clk_divided,
    s_axis_phase_tvalid => '1',
    s_axis_phase_tdata => sine_addr,
    m_axis_data_tvalid => data_ready,
    m_axis_data_tdata => sine_wave
  );

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Sample Rate Tick Generator
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
tick_generation: tick_generator
generic map(
	FREQUENCY_DIVIDER_RATIO => 100)
port map( 
	system_clk_iport 	=> clk_divided,
	tick_oport			=> take_sample
	);
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Phase Accumulator
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
phase_acc : phase_accumulator
    port map(
        -- input ports
        clk_in_port        => clk_divided,
        sample_rate_tick   => take_sample,
        midi_data_in_port  => data_in_port,
        sw1                => sw1,
        sw2                => sw2,
        sw3                => sw3,
        
        -- output ports
        sine_addr_out_port => sine_addr
    );
    
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Volume Control
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
volume: volume_control
    port map (
        -- input ports
        original_sine => sine_wave,
        -- output ports
        modified_sine => dec_vol_sine
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
--	data_in_port		=> data_in_port,
    data_in_port        => dec_vol_sine,
--	dac_trigger			=> dac_trigger,
    dac_trigger         => take_sample,
	data_out_port		=> data_out_port,
	cs_out_port			=> cs_out_port,
	load_debug_port     => load_debug_port);   
end Behavioral; 

