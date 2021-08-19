library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shell_tb is
end entity shell_tb;

architecture testbench of shell_tb is

    component Synthesizer_top_level is
        port (  
            clk_iport_100MHz 	: in  std_logic;
            midi_in_port        : in  std_logic;		
            data_in_port		: in  std_logic_vector(15 downto 0); -- changed for MIDI testbenching
        
            cs_out_port			: out std_logic;						--chip select
            data_out_port		: out std_logic;						--data output
            clk_out_port		: out std_logic;						--serial clock
            LED_port            : out std_logic_vector(15 downto 0)
            );
        end component Synthesizer_top_level;

    constant tbit_time: time := 32us;
    constant slower_clk:time := 208ns;

    signal clk_100MHz : std_logic := '0';
    -- Clock period definitions
    constant clk_period :   time := 10ns;		-- 100 MHz clock

    -- Data definitions
    constant TxData :   std_logic_vector(29 downto 0) := ("1010010110" & "1000101000" &"1011010010"); -- Start/stop bits already in here
    signal bit_count:   integer := 10;

    signal midi_output      :   std_logic := '1';

    signal switches         :   std_logic_vector(15 downto 0) := x"003C";

    signal cs_out_port      :   std_logic := '0';
    signal data_out_port    :   std_logic := '0';
    signal clk_out_port     :   std_logic := '0';
begin
    uut: Synthesizer_top_level
    port map(
        clk_iport_100MHz    =>  clk_100MHz,
        midi_in_port        =>  midi_output,
        data_in_port        =>  switches,

        cs_out_port         =>  cs_out_port,
        data_out_port       =>  data_out_port,
        clk_out_port        =>  clk_out_port,
        LED_port            =>  open);

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


--=============================================================
--Stimulus Process:
--=============================================================	
stim_proc: process
begin
    midi_output <= '1'; -- UART is high while idle, wait for shell clock to set up
    wait for tbit_time * 5;
    --  shift out each bit
    midi_output <= TxData(0);
    wait for tbit_time;
    midi_output <= TxData(1);
    wait for tbit_time;
    midi_output <= TxData(2);
    wait for tbit_time;
    midi_output <= TxData(3);
    wait for tbit_time;
    midi_output <= TxData(4);
    wait for tbit_time;
    midi_output <= TxData(5);
    wait for tbit_time;
    midi_output <= TxData(6);
    wait for tbit_time;
    midi_output <= TxData(7);
    wait for tbit_time;
    midi_output <= TxData(8);
    wait for tbit_time;
    midi_output <= TxData(9);
    wait for tbit_time;
    midi_output <= TxData(10);
    wait for tbit_time;
    midi_output <= TxData(11);
    wait for tbit_time;
    midi_output <= TxData(12);
    wait for tbit_time;
    midi_output <= TxData(13);
    wait for tbit_time;
    midi_output <= TxData(14);
    wait for tbit_time;
    midi_output <= TxData(15);
    wait for tbit_time;
    midi_output <= TxData(16);
    wait for tbit_time;
    midi_output <= TxData(17);
    wait for tbit_time;
    midi_output <= TxData(18);
    wait for tbit_time;
    midi_output <= TxData(19);
    wait for tbit_time;
    midi_output <= TxData(20);
    wait for tbit_time;
    midi_output <= TxData(21);
    wait for tbit_time;
    midi_output <= TxData(22);
    wait for tbit_time;
    midi_output <= TxData(23);
    wait for tbit_time;
    midi_output <= TxData(24);
    wait for tbit_time;
    midi_output <= TxData(25);
    wait for tbit_time;
    midi_output <= TxData(26);
    wait for tbit_time;
    midi_output <= TxData(27);
    wait for tbit_time;
    midi_output <= TxData(28);
    wait for tbit_time;
    midi_output <= TxData(29);

    wait;
end process stim_proc;
    
end architecture testbench;