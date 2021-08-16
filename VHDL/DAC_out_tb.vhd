--=============================================================
--Ben Dobbins
--CS56/ENGS31 21S
--This script is the testbench code for Lab 4, the voltmeter.
--=============================================================
--=============================================================
--Library Declarations
--=============================================================
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

 --=============================================================
--Testbench Entity Declaration
--=============================================================
ENTITY DAC_out_tb IS
END DAC_out_tb;

--=============================================================
--Testbench declarations
--=============================================================
ARCHITECTURE testbench OF DAC_out_tb IS 

component clk_wiz_0
	port
	 (-- Clock in ports
	  -- Clock out ports
	  clk_4800khz          	: out    std_logic;
	  -- Status and control signals
	  locked            	: out    std_logic;
	  clk_100mhz           	: in     std_logic
	 );
end component;

component DAC_out is
	generic(
		N_BITS			: integer);
	port(
		clk_in_port			: in  std_logic;	--Slower clock
		clk_out_port		: out std_logic;
		
		data_in_port		: in  std_logic_vector(15 downto 0);
		dac_trigger			: in  std_logic;	--datapath signals
		
		data_out_port		: out std_logic;
		cs_out_port			: out std_logic);
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Test to see if the DAC works with the Phase Accumulator
--+++++++++++++++++++++++++++++++++++++++++++++++++++++

--+++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Phase Accumulator
--+++++++++++++++++++++++++++++++++++++++++++++++++++++
component phase_accumulator is
    port (
        -- input ports
        clk_in_port:        in   std_logic;
        midi_data_in_port:  in   std_logic_vector(7 downto 0);
        sample_rate_tick:   in   std_logic;
        -- output ports
        sw1:                in   std_logic;
        sw2:                in   std_logic;
--        sine_addr_out_port: out std_logic_vector(13 downto 0)
        sine_addr_out_port: out std_logic_vector(15 downto 0)
    );
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DDS Compiler
--+++++++++++++++++++++++++++++++++++++++++++++++++++++
component dds_compiler_0
  port (
    aclk                     : in       std_logic;
    s_axis_phase_tvalid      : in       std_logic;
--    s_axis_phase_tdata       : in       std_logic_vector(13 downto 0);
    s_axis_phase_tdata       : in       std_logic_vector(15 downto 0);
    m_axis_data_tvalid       : out      std_logic;
--    m_axis_data_tdata        : out      std_logic_vector(11 downto 0)
    m_axis_data_tdata        : out      std_logic_vector(15 downto 0)
  );
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Volume Control
--+++++++++++++++++++++++++++++++++++++++++++++++++++++
component volume_control is
    port (
        -- input ports
        original_sine: in std_logic_vector(15 downto 0);
        -- output ports
        modified_sine: out std_logic_vector(15 downto 0)
    );
end component;


--+++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Tick Generator
--+++++++++++++++++++++++++++++++++++++++++++++++++++++
component tick_generator is
	generic (
	   FREQUENCY_DIVIDER_RATIO : integer);
	port (
		system_clk_iport : in  std_logic;
		tick_oport		 : out std_logic);
end component;


--=============================================================
--Local Signal Declaration
--=============================================================
-- Clock period definitions
constant clk_period : time := 10ns;		-- 100 MHz clock

signal clk_100MHz : std_logic := '0';
signal clk_divided : std_logic := '0';
signal clk_passthrough: std_logic := '0';
signal dac_trigger : std_logic := '0';
signal cs_out:	std_logic := '0';
signal bit_out:	std_logic := '0';
signal locked:  std_logic := '0';
signal clk_count : unsigned(15 downto 0) := (others => '0');
signal count_reset: std_logic := '1';
signal pulse_sent: std_logic := '0';

-- Data definitions
--constant TxData : std_logic_vector(15 downto 0) := "0000100110111011";
signal TxData: std_logic_vector(15 downto 0) := (others => '0');

-- Definitions for the Phase Accumulator
signal midi_data    : std_logic_vector(7 downto 0);
signal take_sample  : std_logic := '0';
signal sine_data    : std_logic_vector(15 downto 0);
signal sine_addr    : std_logic_vector(15 downto 0);
signal sw1          : std_logic := '1';
signal sw2          : std_logic := '0';

-- Definitions for the Volume Control
signal dec_vol_sine : std_logic_vector(15 downto 0);
	
BEGIN 

-- Instantiate the Unit Under Test (UUT) 
uut: DAC_out
generic map(
	N_BITS => 16)
port map(
	clk_in_port			=> clk_divided,
	clk_out_port		=> clk_passthrough,
	data_in_port		=> dec_vol_sine,
	dac_trigger			=> take_sample,
	data_out_port		=> bit_out,
	cs_out_port			=> cs_out);  	

-- clocking: system_clock_generator 
-- generic map(
-- 	CLOCK_DIVIDER_RATIO => 100)
-- port map(
-- 	ext_clk_iport 		=> clk_100MHz,
-- 	system_clk_oport 	=> clk_1MHz,
-- 	fwd_clk_oport		=> spi_sclk);

 clocking: clk_wiz_0
	port map ( 
   -- Clock out ports  
	clk_4800khz => clk_divided,
   -- Status and control signals                
	locked => locked,
	-- Clock in ports
	clk_100mhz => clk_100MHz
  );	

--=============================================================
--Timing:
--=============================================================		      
-- Clock process definitions
clk_process :process
begin
    clk_100MHz <= '0';
    wait for clk_period/2;
    clk_100MHz <= '1';
    wait for clk_period/2;
end process;


phase: phase_accumulator
port map (
    clk_in_port => clk_divided,
    sample_rate_tick => take_sample,
    midi_data_in_port => midi_data,
    sine_addr_out_port => sine_addr,
    sw1 => sw1,
    sw2 => sw2
);

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Volume Control
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
volume: volume_control
    port map (
        -- input ports
        original_sine => TxData,
        -- output ports
        modified_sine => dec_vol_sine
    );
    
dds: dds_compiler_0
  port map(
    aclk => clk_divided,
    s_axis_phase_tvalid => '1',
    s_axis_phase_tdata => sine_addr,
    m_axis_data_tvalid => open,
    m_axis_data_tdata => TxData
  );
  
  tick_generation: tick_generator
generic map(
	FREQUENCY_DIVIDER_RATIO => 100)
port map( 
	system_clk_iport 	=> clk_divided,
	tick_oport			=> take_sample);
--=============================================================
--Cycle Counter:
--=============================================================
cycle_counter: process(clk_divided)
begin
	if rising_edge(clk_divided) then
		if count_reset = '0' then
			clk_count <= clk_count + 1;
		else
			clk_count <= (others => '0');
		end if;
	end if;
end process cycle_counter;

--=============================================================
--Stimulus Process:
--=============================================================		
--stim_proc: process(clk_count)
stim_proc: process
begin
    
--	if pulse_sent = '0' then
--		count_reset <= '0';

		
--		if clk_count = x"20" then
--			dac_trigger <= '1';
--		end if;
--		if clk_count = x"21" then
--			dac_trigger <= '0';
--			pulse_sent <= '1';
--		end if;
--	end if;
    sw1 <= '1';
    wait;
end process;
END;