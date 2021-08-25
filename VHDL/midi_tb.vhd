library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity midi_tb is
end entity midi_tb;

architecture testbench of midi_tb is
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

    component midi_decode is
        port (
            clk_port    :   in  std_logic;
            trigger_port:   in  std_logic;
            data_port   :   in  std_logic_vector(23 downto 0);

            note_on_port:   out std_logic;
            channel_port:   out std_logic_vector(3 downto 0);
            note_id_port:   out std_logic_vector(7 downto 0);
            velocity_port:  out std_logic_vector(7 downto 0));
    end component midi_decode;


constant clk_period : time := 10ns;     -- 100 MHz period

signal clk_100MHz   :   std_logic := '0';
signal clk_divided  :   std_logic := '0';

signal midi_in_port :   std_logic := '0';
signal current_byte :   std_logic_vector(7 downto 0);
signal data_received:   std_logic := '0';
signal data_ready   :   std_logic := '0';
signal current_data :   std_logic_vector(23 downto 0);
signal note_on      :   std_logic := '0';
signal midi_channel :   std_logic_vector(3 downto 0);
signal note_id_sig  :   std_logic_vector(7 downto 0);
signal note_velocity:   std_logic_vector(7 downto 0);

begin
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

midi_receiver: midi_receive
generic map(
    BYTE_AMOUNT =>   3)
port map(
    clk_port    =>   clk_divided,
    trigger_port=>   data_received,
    byte_port   =>   current_byte,

    assembled   =>   current_data,
    done_port   =>   data_ready);

midi_decoder: midi_decode
port map(
    clk_port    =>   clk_divided,
    trigger_port=>   data_ready,
    data_port   =>   current_data,

    note_on_port=>   note_on,
    channel_port=>   midi_channel,
    note_id_port=>   note_id_sig,
    velocity_port=>  note_velocity);


    
    
end architecture testbench;