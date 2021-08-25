
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
---- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity note_addr_counter_tb is
end note_addr_counter_tb;

architecture Behavioral of note_addr_counter_tb is
--+++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Component Declarations
--+++++++++++++++++++++++++++++++++++++++++++++++++++++
component note_addr_counter is
    port (
        -- timing inputs
        clk_in_port    :        in std_logic;
        take_sample    :        in std_logic;

        -- note inputs for SINE LUT
        note_1_in_port :        in std_logic_vector(15 downto 0);
        note_2_in_port :        in std_logic_vector(15 downto 0);
        note_3_in_port :        in std_logic_vector(15 downto 0);

        -- ouput ports
        sine_addr_port :        out std_logic_vector(15 downto 0);
        acc_clr_port   :        out std_logic;
        acc_en_port    :        out std_logic
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
-- Sine Wave Accumulator
--+++++++++++++++++++++++++++++++++++++++++++++++++++++
component sine_wave_acc is
    port (
        -- Timing
        clk_in_port         : in std_logic;

        -- Sine Wave Data
        sine_wave_in_port   : in std_logic_vector(15 downto 0);

        -- Control Signals
        acc_clr_port        : in std_logic;
        acc_en_port         : in std_logic;

        -- output 
        sine_wave_acc_port  : out std_logic_vector(15 downto 0)

    );
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Signal Declarations
--+++++++++++++++++++++++++++++++++++++++++++++++++++++
constant clk_period : time := 10ns;		-- 100 MHz clock

signal clk_100MHz   : std_logic := '0';
signal clk_divided  : std_logic := '0';
signal note_1       : std_logic_vector(15 downto 0) := (others => '0');
signal note_2       : std_logic_vector(15 downto 0) := "0000000000000001";
signal note_3       : std_logic_vector(15 downto 0) := "0000000000000010";
signal take_sample  : std_logic := '0';
signal sine_data    : std_logic_vector(15 downto 0);
signal sine_data_acc: std_logic_vector(15 downto 0);
signal acc_clr      : std_logic := '0';
signal acc_en       : std_logic := '0';
signal sine_addr    : std_logic_vector(15 downto 0);
signal locked       : std_logic := '0';
-- Placeholders for MIDI inputs, might want to delete these and others related to it
signal sw1          : std_logic := '0';
signal sw2          : std_logic := '0';

begin

uut: note_addr_counter
port map (
    clk_in_port => clk_divided,
    take_sample => take_sample,
    note_1_in_port => note_1,
    note_2_in_port => note_2,
    note_3_in_port => note_3,
        -- ouput ports
    sine_addr_port => sine_addr,
    acc_clr_port => acc_clr,
    acc_en_port => acc_en
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

tick_generation: tick_generator
generic map(
	FREQUENCY_DIVIDER_RATIO => 200)
port map( 
	system_clk_iport 	=> clk_divided,
	tick_oport			=> take_sample);
	
acc: sine_wave_acc 
    port map (
        -- Timing
        clk_in_port => clk_divided,

        -- Sine Wave Data
        sine_wave_in_port => sine_data,

        -- Control Signals
        acc_clr_port => acc_clr,
        acc_en_port => acc_en,

        -- output 
        sine_wave_acc_port => sine_data_acc

    );

	

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
    
    wait;
end process; 

end Behavioral;