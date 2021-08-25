----------------------------------------------------------------------------------

----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
---- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity volume_control_tb is
end volume_control_tb;

architecture Behavioral of volume_control_tb is
--+++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Component Declarations
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
-- Clock Generator
--+++++++++++++++++++++++++++++++++++++++++++++++++++++
component clk_wiz_0
	port
	 (-- Clock in ports
	  -- Clock out ports
	  clk_9600khz          	: out    std_logic;
	  -- Status and control signals
	  locked            	: out    std_logic;
	  clk_100mhz           	: in     std_logic
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

--+++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Signal Declarations
--+++++++++++++++++++++++++++++++++++++++++++++++++++++
constant clk_period : time := 10ns;		-- 100 MHz clock

signal clk_100MHz   : std_logic := '0';
signal clk_divided  : std_logic := '0';
signal midi_data    : std_logic_vector(7 downto 0);
signal take_sample  : std_logic := '0';
signal sine_data    : std_logic_vector(15 downto 0);
signal dec_vol_sine : std_logic_vector(15 downto 0);
signal sine_addr    : std_logic_vector(15 downto 0);
signal locked       : std_logic := '0';
-- Placeholders for MIDI inputs, might want to delete these and others related to it
signal sw1          : std_logic := '0';
signal sw2          : std_logic := '0';

begin

uut: phase_accumulator
port map (
    clk_in_port => clk_divided,
    sample_rate_tick => take_sample,
    midi_data_in_port => midi_data,
    sine_addr_out_port => sine_addr,
    sw1 => sw1,
    sw2 => sw2
);

 clocking: clk_wiz_0
	port map ( 
   -- Clock out ports  
	clk_9600khz => clk_divided,
   -- Status and control signals                
	locked => locked,
	-- Clock in ports
	clk_100mhz => clk_100MHz
  );	
dds: dds_compiler_0
  port map(
    aclk => clk_divided,
    s_axis_phase_tvalid => '1',
    s_axis_phase_tdata => sine_addr,
    m_axis_data_tvalid => open,
    m_axis_data_tdata => sine_data
  );

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Volume Control
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
volume: volume_control
    port map (
        -- input ports
        original_sine => sine_data,
        -- output ports
        modified_sine => dec_vol_sine
    );
    
tick_generation: tick_generator
generic map(
	FREQUENCY_DIVIDER_RATIO => 100)
port map( 
	system_clk_iport 	=> clk_divided,
	tick_oport			=> take_sample);
	

--+++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Clock Gen
--+++++++++++++++++++++++++++++++++++++++++++++++++++++
clk_process :process
begin
    clk_100MHz <= '0';
    wait for clk_period/2;
    clk_100MHz <= '1';
    wait for clk_period/2;
end process;

stim_proc: process
begin
    sw1 <= '1';
    wait;
end process; 

end Behavioral;
