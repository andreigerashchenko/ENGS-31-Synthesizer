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
--	data_in_port		: in  std_logic_vector(15 downto 0); -- changed for MIDI testbenching
	-- sw1                 : in  std_logic;
	-- sw2                 : in  std_logic;
    -- sw3                 : in  std_logic;
    rx_sync_port        : out std_logic;
    tc_full_port        : out std_logic;
    tc_half_port        : out std_logic;
    
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
	  clk_9600khz          	: out    std_logic;
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

----+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
---- Note Address Counter
----+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--component note_addr_counter is
--    port (
--        -- timing inputs
--        clk_in_port    :        in std_logic;
--        take_sample    :        in std_logic;

--        -- note inputs for SINE LUT
--        note_1_in_port :        in std_logic_vector(15 downto 0);
--        note_2_in_port :        in std_logic_vector(15 downto 0);
--        note_3_in_port :        in std_logic_vector(15 downto 0);

--        -- ouput ports
--        sine_addr_port :        out std_logic_vector(15 downto 0);
--        acc_clr_port   :        out std_logic;
--        acc_en_port    :        out std_logic
--    );
--end component;

----+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
---- Sine Wave ACC
----+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--component sine_wave_acc is
--    port (
--        -- Timing
--        clk_in_port         : in std_logic;

--        -- Sine Wave Data
--        sine_wave_in_port   : in std_logic_vector(15 downto 0);
        
--        -- Control Signals
--        acc_clr_port        : in std_logic;
--        acc_en_port         : in std_logic;
--        num_count           : in std_logic_vector(1 downto 0);
--        -- output 
--        sine_wave_acc_port  : out std_logic_vector(15 downto 0)

--    );
--end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Volume Control
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component volume_control is
    port (
        -- input ports
    
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
        rx_sync_port:   out std_logic;
        tc_half_port:   out std_logic;
        tc_full_port:   out std_logic;
        byte_port   :   out std_logic_vector(7 downto 0);
        rx_done_tick:   out std_logic);
end component uart_receiver;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--MIDI receiver
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component midi_receive is
    generic (
        BYTE_AMOUNT :   integer
       );
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

        trigger_out :   out std_logic;
        
        -- -- Information for Note 2
        -- note2_on_port:   out std_logic;
        -- channel2_port:   out std_logic_vector(3 downto 0);
        -- note2_id_port:   out std_logic_vector(7 downto 0);
        -- velocity2_port:  out std_logic_vector(7 downto 0);

        -- -- Information for Note 3
        -- note3_on_port:   out std_logic;
        -- channel3_port:   out std_logic_vector(3 downto 0);
        -- note3_id_port:   out std_logic_vector(7 downto 0);
        -- velocity3_port:  out std_logic_vector(7 downto 0);
        
        p_bend_port:    out std_logic_vector(7 downto 0));
--        note_count_port: out std_logic_vector(1 downto 0));
end component midi_decode;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--MIDI polyphony decoder
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component midi_polyphony_decode is
    port (
        clk_port    :   in  std_logic;
        note_id_port:   in  std_logic_vector(7 downto 0);
        note_on_port:   in  std_logic;
        velocity_port:  in  std_logic_vector(7 downto 0);
        trigger_port:   in  std_logic;

        note_1_id_p :   out std_logic_vector(7 downto 0);
        note_1_vel_p:   out std_logic_vector(7 downto 0);
        note_1_en_p :   out std_logic;
        note_2_id_p :   out std_logic_vector(7 downto 0);
        note_2_vel_p:   out std_logic_vector(7 downto 0);
        note_2_en_p :   out std_logic;
        note_3_id_p :   out std_logic_vector(7 downto 0);
        note_3_vel_p:   out std_logic_vector(7 downto 0);
        note_3_en_p :   out std_logic;
        note_4_id_p :   out std_logic_vector(7 downto 0);
        note_4_vel_p:   out std_logic_vector(7 downto 0);
        note_4_en_p :   out std_logic;
        note_count_p:   out std_logic_vector(2 downto 0));
end component midi_polyphony_decode;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Sine wave assembler
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component midi_polyphony_assemble is
    port (
        clk_port    :   in  std_logic;
        note_1_en_p :   in  std_logic;
        note_2_en_p :   in  std_logic;
        note_3_en_p :   in  std_logic;
        note_4_en_p :   in  std_logic;
        note_1_sine_p:  in  std_logic_vector(15 downto 0);
        note_2_sine_p:  in  std_logic_vector(15 downto 0);
        note_3_sine_p:  in  std_logic_vector(15 downto 0);
        note_4_sine_p:  in  std_logic_vector(15 downto 0);
        full_sine_p :   out std_logic_vector(15 downto 0);
        note_count_p:   in  std_logic_vector(2 downto 0) );
end component midi_polyphony_assemble;

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

signal midi_channel:    std_logic_vector(3 downto 0) := (others => '0');
signal midi_note_on :   std_logic := '0';
signal midi_note_id :   std_logic_vector(7 downto 0) := (others => '0');
signal midi_note_vel:   std_logic_vector(7 downto 0) := (others => '0');
signal midi_decode_done :   std_logic := '0';

-- Note 1
signal note_1_on:         std_logic := '0';
signal note_1_id:     std_logic_vector(7 downto 0) := (others => '0');
signal note_1_vel:   std_logic_vector(7 downto 0) := (others => '0');

-- Note 2 signal
signal note_2_on:     std_logic := '0';
signal note_2_id:     std_logic_vector(7 downto 0) := (others => '0');
signal note_2_vel:    std_logic_vector(7 downto 0) := (others => '0');

-- Note 3 signal
signal note_3_on:     std_logic := '0';
signal note_3_id:     std_logic_vector(7 downto 0) := (others => '0');
signal note_3_vel:    std_logic_vector(7 downto 0) := (others => '0');

-- Note 4 signal
signal note_4_on:     std_logic := '0';
signal note_4_id:     std_logic_vector(7 downto 0) := (others => '0');
signal note_4_vel:    std_logic_vector(7 downto 0) := (others => '0');

signal note_count:   std_logic_vector(2 downto 0) := (others => '0'); -- counts the number of notes pressed

signal pitch_offset:std_logic_vector(7 downto 0) := "01000000";

signal full_sine: std_logic_vector(15 downto 0) := (others => '0');
signal sine_1   :   std_logic_vector(15 downto 0) := (others => '0');
signal sine_2   :   std_logic_vector(15 downto 0) := (others => '0');
signal sine_3   :   std_logic_vector(15 downto 0) := (others => '0');
signal sine_4   :   std_logic_vector(15 downto 0) := (others => '0');
signal sine_1_vol   :   std_logic_vector(15 downto 0) := (others => '0');
signal sine_2_vol   :   std_logic_vector(15 downto 0) := (others => '0');
signal sine_3_vol   :   std_logic_vector(15 downto 0) := (others => '0');
signal sine_4_vol   :   std_logic_vector(15 downto 0) := (others => '0');


signal sine_addr_1: std_logic_vector(15 downto 0) := (others => '0');
signal sine_addr_2: std_logic_vector(15 downto 0) := (others => '0');
signal sine_addr_3: std_logic_vector(15 downto 0) := (others => '0');
signal sine_addr_4: std_logic_vector(15 downto 0) := (others => '0');
signal sine_addr_fin: std_logic_vector(15 downto 0) := (others => '0');
signal acc_clr      : std_logic := '0';
signal acc_en      : std_logic := '0';

signal data: std_logic_vector(11 downto 0) := (others => '0');	-- A/D data
signal sine_wave: std_logic_vector(15 downto 0) := (others => '0');
signal sine_wave_fin: std_logic_vector(15 downto 0) := (others => '0');

signal step_size_1:   std_logic_vector(11 downto 0);
signal step_size_2:   std_logic_vector(11 downto 0);
signal step_size_3:   std_logic_vector(11 downto 0);
signal step_size_4:   std_logic_vector(11 downto 0);

signal current_byte:    std_logic_vector(7 downto 0);
signal current_data:    std_logic_vector(23 downto 0);
signal data_ready:      std_logic := '0';

-- debug signals for timing
signal tc_full: std_logic := '0';
signal tc_half: std_logic := '0';


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
   clk_9600khz => clk_divided,
  -- Status and control signals                
   locked => locked,
   -- Clock in ports
   clk_100mhz => clk_iport_100MHz
   );

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--DDS Compilers
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	

dds_compiler_1 : dds_compiler_0
  PORT MAP (
    aclk => clk_divided,
    s_axis_phase_tvalid => '1',
    s_axis_phase_tdata => sine_addr_1,
    m_axis_data_tvalid => open,
    m_axis_data_tdata => sine_1
  );

  dds_compiler_2 : dds_compiler_0
  PORT MAP (
    aclk => clk_divided,
    s_axis_phase_tvalid => '1',
    s_axis_phase_tdata => sine_addr_2,
    m_axis_data_tvalid => open,
    m_axis_data_tdata => sine_2
  );

  dds_compiler_3 : dds_compiler_0
  PORT MAP (
    aclk => clk_divided,
    s_axis_phase_tvalid => '1',
    s_axis_phase_tdata => sine_addr_3,
    m_axis_data_tvalid => open,
    m_axis_data_tdata => sine_3
  );

  dds_compiler_4 : dds_compiler_0
  PORT MAP (
    aclk => clk_divided,
    s_axis_phase_tvalid => '1',
    s_axis_phase_tdata => sine_addr_4,
    m_axis_data_tvalid => open,
    m_axis_data_tdata => sine_4
  );

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Note to Step Size Block Memories
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
midi_block_memory_1 : blk_mem_gen_0
  PORT MAP (
    clka => clk_divided,
    addra => note_1_id(6 downto 0),
    douta => step_size_1
  );

midi_block_memory_2 : blk_mem_gen_0
  PORT MAP (
    clka => clk_divided,
    addra => note_2_id(6 downto 0),
    douta => step_size_2
  );

midi_block_memory_3 : blk_mem_gen_0
  PORT MAP (
    clka => clk_divided,
    addra => note_3_id(6 downto 0),
    douta => step_size_3
  );

  midi_block_memory_4 : blk_mem_gen_0
  PORT MAP (
    clka => clk_divided,
    addra => note_4_id(6 downto 0),
    douta => step_size_4
  );
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Sample Rate Tick Generator
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
tick_generation: tick_generator
generic map(
	FREQUENCY_DIVIDER_RATIO => 200)
port map( 
	system_clk_iport 	=> clk_divided,
	tick_oport			=> take_sample);
	
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Phase Accumulators
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
phase_acc_1 : phase_accumulator
    port map(
        -- input ports
        clk_in_port        => clk_divided,
        sample_rate_tick   => take_sample,
        step_size_port     => step_size_1,
        note_on_port       => note_1_on,
        p_bend_port        => pitch_offset,
        -- output ports
        sine_addr_out_port => sine_addr_1
    );

phase_acc_2 : phase_accumulator
    port map(
        -- input ports
        clk_in_port        => clk_divided,
        sample_rate_tick   => take_sample,
        step_size_port     => step_size_2,
        note_on_port       => note_2_on,
        p_bend_port        => pitch_offset,
        -- output ports
        sine_addr_out_port => sine_addr_2
    );

phase_acc_3 : phase_accumulator
    port map(
        -- input ports
        clk_in_port        => clk_divided,
        sample_rate_tick   => take_sample,
        step_size_port     => step_size_3,
        note_on_port       => note_3_on,
        p_bend_port        => pitch_offset,
        -- output ports
        sine_addr_out_port => sine_addr_3
    );
    
phase_acc_4 : phase_accumulator
    port map(
        -- input ports
        clk_in_port        => clk_divided,
        sample_rate_tick   => take_sample,
        step_size_port     => step_size_4,
        note_on_port       => note_4_on,
        p_bend_port        => pitch_offset,
        -- output ports
        sine_addr_out_port => sine_addr_4
    );

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Volume Control
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
volume_1: volume_control
    port map (
        -- input ports
        
        note_velocity_port => note_1_vel,
        original_sine => sine_1,
        -- output ports
        modified_sine => sine_1_vol
    );

volume_2: volume_control
    port map (
        -- input ports
        
        note_velocity_port => note_2_vel,
        original_sine => sine_2,
        -- output ports
        modified_sine => sine_2_vol
    );

volume_3: volume_control
    port map (
        -- input ports
        
        note_velocity_port => note_3_vel,
        original_sine => sine_3,
        -- output ports
        modified_sine => sine_3_vol
    );

    
volume_4: volume_control
    port map (
        -- input ports
        
        note_velocity_port => note_4_vel,
        original_sine => sine_4,
        -- output ports
        modified_sine => sine_4_vol
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
    data_in_port        => full_sine,
    dac_trigger         => take_sample,
	data_out_port		=> data_out_port,
	cs_out_port			=> cs_out_port);  
    
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--UART receiver
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
receive_uart: uart_receiver
    generic map(
        CYCLES_PER_BIT  =>   307,   -- 32us (31250 baud period) / 0.104166667us (9.6MHz clk period) = 307.19999 ~= 307
        CYCLES_PER_HALF =>   154,   -- 16us (half of 31250 baud period) / 0.104166667us (9.6MHz clk period) = 153.59999 ~= 154
        BIT_AMOUNT      =>   10)
    port map(
        clk_port        =>  clk_divided,
        rx_port         =>  midi_in_port,
        rx_sync_port    =>  rx_sync_port,
        tc_half_port    =>  tc_half_port,
        tc_full_port    =>  tc_full_port,
        byte_port       =>  current_byte,
        rx_done_tick    =>  data_received);

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--MIDI receiver
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
midi_receiver: midi_receive
    generic map(
        BYTE_AMOUNT     =>  3)
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
        clk_port    =>  clk_divided,
        trigger_port=>  data_ready,
        data_port   =>  current_data,

        note_on_port=>  midi_note_on,
        channel_port=>  midi_channel,
        note_id_port=>  midi_note_id,
        velocity_port=> midi_note_vel,
        p_bend_port =>  pitch_offset,
        trigger_out =>  midi_decode_done);

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--MIDI polyphony decoder
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
midi_poly_decoder: midi_polyphony_decode
    port map (
        clk_port        =>  clk_divided,
        note_id_port    =>  midi_note_id,
        note_on_port    =>  midi_note_on,
        velocity_port   =>  midi_note_vel,
        trigger_port    =>  midi_decode_done,

        note_1_id_p     =>  note_1_id,
        note_1_vel_p    =>  note_1_vel,
        note_1_en_p     =>  note_1_on,
        note_2_id_p     =>  note_2_id,
        note_2_vel_p    =>  note_2_vel,
        note_2_en_p     =>  note_2_on,
        note_3_id_p     =>  note_3_id,
        note_3_vel_p    =>  note_3_vel,
        note_3_en_p     =>  note_3_on,
        note_4_id_p     =>  note_4_id,
        note_4_vel_p    =>  note_4_vel,
        note_4_en_p     =>  note_4_on,
        note_count_p    =>  note_count
    );

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Sine wave assembler
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sine_wave_assembler: midi_polyphony_assemble
    port map (
        clk_port        =>  clk_divided,
        note_1_en_p     =>  note_1_on,
        note_2_en_p     =>  note_2_on,
        note_3_en_p     =>  note_3_on,
        note_4_en_p     =>  note_4_on,
        note_count_p    =>  note_count,
        note_1_sine_p   =>  sine_1_vol,
        note_2_sine_p   =>  sine_2_vol,
        note_3_sine_p   =>  sine_3_vol,
        note_4_sine_p   =>  sine_4_vol,
        full_sine_p     =>  full_sine
    );

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Mapping input data to LEDs:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
map_input_LED: process(inputs, note_1_id, note_2_id, note_3_id, note_1_on, current_byte, midi_in_port, current_data, note_1_vel, pitch_offset, sine_wave_fin, note_count, note_1_on, note_2_on, note_3_on, sine_addr_1)
begin
--    inputs <= data_in_port;
    -- LED_port <= inputs;
    LED_port <= sine_addr_1;
end process map_input_LED;
end Behavioral; 
