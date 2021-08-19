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
  	midi_in_port        : in  std_logic;		
	data_in_port		: in  std_logic_vector(15 downto 0); -- changed for MIDI testbenching
	-- sw1                 : in  std_logic;
	-- sw2                 : in  std_logic;
    -- sw3                 : in  std_logic;

	cs_out_port			: out std_logic;						--chip select
	data_out_port		: out std_logic;						--data output
	clk_out_port		: out std_logic;						--serial clock
    LED_port            : out std_logic_vector(15 downto 0)
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
-- Note to Step Size Block Memory
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
END COMPONENT;

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
        step_size_port:     in   std_logic_vector(11 downto 0);
        note_on_port:       in   std_logic;
        p_bend_port     : in std_logic_vector(7 downto 0);
        -- sw1:                in   std_logic;
        -- sw2:                in   std_logic;
        -- sw3:                in   std_logic;
        
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
        clk_in_port: in std_logic;
        note_velocity_port: in std_logic_vector(7 downto 0);
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
        note_on_port        : in  std_logic;
    	
		data_in_port		: in  std_logic_vector(15 downto 0);
		dac_trigger			: in  std_logic;	--datapath signals
		
		data_out_port		: out std_logic;
		cs_out_port			: out std_logic);
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--UART receiver
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component uart_receiver is
    generic (
        CYCLES_PER_BIT  :   integer;
        CYCLES_PER_HALF :   integer;
        BIT_AMOUNT      :   integer);
    port (
        clk_port    :   in  std_logic;
        rx_port     :   in  std_logic;

        byte_port   :   out std_logic_vector(7 downto 0);
        rx_done_tick:   out std_logic);
end component uart_receiver;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--MIDI receiver
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component midi_receive is
    generic (
        BYTE_AMOUNT :   integer);
    port (
        clk_port    :   in  std_logic;
        trigger_port:   in  std_logic;
        byte_port   :   in  std_logic_vector(7 downto 0);

        assembled   :   out std_logic_vector(23 downto 0);
        done_port   :   out std_logic);
end component midi_receive;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--MIDI decoder
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component midi_decode is
    port (
        clk_port    :   in  std_logic;
        trigger_port:   in  std_logic;
        data_port   :   in  std_logic_vector(23 downto 0);

        note_on_port:   out std_logic;
        channel_port:   out std_logic_vector(3 downto 0);
        note_id_port:   out std_logic_vector(7 downto 0);
        velocity_port:  out std_logic_vector(7 downto 0);
        p_bend_port:    out std_logic_vector(7 downto 0));
end component midi_decode;


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
signal inputs:  std_logic_vector(15 downto 0) := (others => '0');


signal data_received:   std_logic := '0';
signal note_on:         std_logic := '0';
signal midi_channel:    std_logic_vector(3 downto 0) := (others => '0');
signal note_id_sig:     std_logic_vector(7 downto 0) := (others => '0');
signal note_velocity:   std_logic_vector(7 downto 0) := (others => '0');
signal pitch_offset:std_logic_vector(7 downto 0) := "01000000";

signal dec_vol_sine: std_logic_vector(15 downto 0) := (others => '0');

signal sine_addr: std_logic_vector(15 downto 0) := (others => '0');
signal data: std_logic_vector(11 downto 0) := (others => '0');	-- A/D data
signal sine_wave: std_logic_vector(15 downto 0) := (others => '0');
signal sine_ready : std_logic := '0';

signal step_size:   std_logic_vector(11 downto 0);

signal current_byte:    std_logic_vector(7 downto 0);
signal current_data:    std_logic_vector(23 downto 0);
signal data_ready:      std_logic := '0';


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
    m_axis_data_tvalid => sine_ready,
    m_axis_data_tdata => sine_wave
  );


--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Note to Step Size Block Memory
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
midi_block_memory : blk_mem_gen_0
  PORT MAP (
    clka => clk_divided,
    addra => note_id_sig(6 downto 0),
    -- addra => inputs(6 downto 0),
    douta => step_size
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
        step_size_port     => step_size,
        note_on_port       => note_on,
        p_bend_port        => pitch_offset,
        -- output ports
        sine_addr_out_port => sine_addr
    );
    
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Volume Control
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
volume: volume_control
    port map (
        -- input ports
        clk_in_port => clk_divided,
        note_velocity_port => note_velocity,
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
    data_in_port        => dec_vol_sine,
    dac_trigger         => take_sample,
	data_out_port		=> data_out_port,
	cs_out_port			=> cs_out_port,
    note_on_port        => note_on);  
    
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--UART receiver
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
receive_uart: uart_receiver
    generic map(
        CYCLES_PER_BIT  =>   154, -- 32 us / 0.2083333 us = 153.6 ~= 154
        CYCLES_PER_HALF =>   77,
        BIT_AMOUNT      =>   10)
    port map(
        clk_port    =>   clk_divided,
        rx_port     =>   midi_in_port,

        byte_port   =>   current_byte,
        rx_done_tick=>   data_received);

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--MIDI receiver
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
midi_receiver: midi_receive
    generic map(
        BYTE_AMOUNT =>   3)
    port map(
        clk_port    =>   clk_divided,
        trigger_port=>   data_received,
        byte_port   =>   current_byte,

        assembled   =>   current_data,
        done_port   =>   data_ready);

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--MIDI decoder
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
midi_decoder: midi_decode
    port map(
        clk_port    =>   clk_divided,
        trigger_port=>   data_ready,
        data_port   =>   current_data,

        note_on_port=>   note_on,
        channel_port=>   midi_channel,
        note_id_port=>   note_id_sig,
        velocity_port=>  note_velocity,
        p_bend_port =>   pitch_offset);



--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Mapping input data to LEDs:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
map_input_LED: process(data_in_port, inputs, note_id_sig, note_on, current_byte, midi_in_port, current_data, note_velocity, pitch_offset)
begin
    inputs <= data_in_port;
    -- LED_port <= inputs;
    LED_port <= current_data(23 downto 20) & "0" & not(note_on) & note_on & "0" & pitch_offset;
end process map_input_LED;
end Behavioral; 

