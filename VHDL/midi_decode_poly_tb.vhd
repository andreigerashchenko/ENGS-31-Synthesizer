library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity midi_decode_poly_tb is
end entity midi_decode_poly_tb;

architecture testbench of midi_decode_poly_tb is
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- Clock Generation
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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

    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- UART Receiver
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
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
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- Midi Receiver
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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


    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- Midi Decoder
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    component midi_decode is
        port (
            clk_port    :   in  std_logic;
            trigger_port:   in  std_logic;
            data_port   :   in  std_logic_vector(23 downto 0);
    
            -- Information for Note 1
            note_on_port:   out std_logic;
            channel_port:   out std_logic_vector(3 downto 0);
            note_id_port:   out std_logic_vector(7 downto 0);
            velocity_port:  out std_logic_vector(7 downto 0);
    
            -- Information for Note 2
            note2_on_port:   out std_logic;
            channel2_port:   out std_logic_vector(3 downto 0);
            note2_id_port:   out std_logic_vector(7 downto 0);
            velocity2_port:  out std_logic_vector(7 downto 0);
    
            -- Information for Note 3
            note3_on_port:   out std_logic;
            channel3_port:   out std_logic_vector(3 downto 0);
            note3_id_port:   out std_logic_vector(7 downto 0);
            velocity3_port:  out std_logic_vector(7 downto 0);
            
            p_bend_port :   out std_logic_vector(7 downto 0); 
            note_count_port: out std_logic_vector(1 downto 0)
    
            );
    end component;

    constant clk_period : time := 10ns;		-- 100 MHz clock
    constant tbit_time: time := 32us;
    -- Data definitions
--    constant note_1 : std_logic_vector(29 downto 0) :=  "0111111111" & "0100000001" & "0000100011";
--    constant note_2 : std_logic_vector(29 downto 0) :=  "0111111111" & "0010000001" & "0000100011";
--    constant note_3 : std_logic_vector(29 downto 0) :=  "0111111111" & "0001000001" & "0000100011";
    constant TxData :   std_logic_vector(149 downto 0) := ("1111111110" & "1100000000" & "1100100000" & "1111111110" & "1010000000" & "1100000000" & "1111111110" & "1100000000" & "1100100000" & "1111111110" & "1010000000" & "1100100000" & "1111111110" & "1001000000" & "1100100000"); -- Start/stop bits already in here
    constant TxData_Reversed : std_logic_vector(89 downto 0) := ("0100100001" & "0000001001" & "0111111101" & "0100100001" & "1000000100" & "1111111110" & "1100100000" & "1000000010" & "1111111110");
    -- Clocking Signals -----------------------------------------------
    signal clk_100MHz : std_logic := '0';
    signal clk_divided: std_logic := '0';
    signal locked : std_logic     := '0';

    -- UART Signals ---------------------------------------------------
    signal midi_output: std_logic := '1';
    signal rx_done : std_logic := '0';
    signal byte : std_logic_vector(7 downto 0) := (others => '0');

    -- Midi Receiver Signals ------------------------------------------
    signal assembled : std_logic_vector(23 downto 0) := (others => '0');
    signal data_ready : std_logic := '0';

    -- Decoder Signals ------------------------------------------------
    signal note1_on : std_logic := '0';
    signal note1_chnl : std_logic_vector(3 downto 0) := (others => '0');
    signal note1_id : std_logic_vector(7 downto 0) := (others => '0');
    signal note1_vel : std_logic_vector(7 downto 0) := (others => '0');
    -- Note 2
    signal note2_on : std_logic := '0';
    signal note2_chnl : std_logic_vector(3 downto 0) := (others => '0');
    signal note2_id : std_logic_vector(7 downto 0) := (others => '0');
    signal note2_vel : std_logic_vector(7 downto 0) := (others => '0');
    -- Note 3
    signal note3_on : std_logic := '0';
    signal note3_chnl : std_logic_vector(3 downto 0) := (others => '0');
    signal note3_id : std_logic_vector(7 downto 0) := (others => '0');
    signal note3_vel : std_logic_vector(7 downto 0) := (others => '0');

    signal note_count : std_logic_vector(1 downto 0);
    signal p_bend : std_logic_vector(7 downto 0) := (others => '0');
    begin
    uut: midi_decode 
        port map (
            clk_port    => clk_divided, 
            trigger_port => data_ready,
            data_port  => assembled,
    
            -- Information for Note 1
            note_on_port => note1_on,
            channel_port => note1_chnl,
            note_id_port => note1_id,
            velocity_port => note1_vel,
    
            -- Information for Note 2
            note2_on_port => note2_on,
            channel2_port => note2_chnl,
            note2_id_port => note2_id, 
            velocity2_port => note2_vel, 
    
            -- Information for Note 3
            note3_on_port => note3_on, 
            channel3_port => note3_chnl,
            note3_id_port => note3_id,
            velocity3_port => note3_vel,
            
            p_bend_port => p_bend,
            note_count_port => note_count
    
        );

        m_receive: midi_receive 
            generic map(
                BYTE_AMOUNT =>   3)
            port map(
                clk_port => clk_divided,
                trigger_port => rx_done,
                byte_port => byte,
        
                assembled   => assembled,
                done_port  => data_ready
            );
        
        receive_uart: uart_receiver
        generic map(
            CYCLES_PER_BIT  =>   307, -- 32 us / 0.2083333 us = 153.6 ~= 154
            CYCLES_PER_HALF =>   154,
            BIT_AMOUNT      =>   10)
        port map(
            clk_port    =>   clk_divided,
            rx_port     =>   midi_output,
        
            byte_port   =>   byte,
            rx_done_tick=>   rx_done);

        clocking: clk_wiz_0
            port map ( 
            -- Clock out ports  
            clk_9600khz => clk_divided,
            -- Status and control signals                
            locked => locked,
            -- Clock in ports
            clk_100mhz => clk_100MHz
            );	
    
        clk_process :process
        begin
            clk_100MHz <= '0';
            wait for clk_period/2;
            clk_100MHz <= '1';
            wait for clk_period/2;
        end process;

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
            wait for tbit_time;
            midi_output <= TxData(30);
            wait for tbit_time;
            midi_output <= TxData(31);
            wait for tbit_time;
            midi_output <= TxData(32);
            wait for tbit_time;
            midi_output <= TxData(33);
            wait for tbit_time;
            midi_output <= TxData(34);
            wait for tbit_time;
            midi_output <= TxData(35);
            wait for tbit_time;
            midi_output <= TxData(36);
            wait for tbit_time;
            midi_output <= TxData(37);
            wait for tbit_time;
            midi_output <= TxData(38);
            wait for tbit_time;
            midi_output <= TxData(39);
            wait for tbit_time;
            midi_output <= TxData(40);
            wait for tbit_time;
            midi_output <= TxData(41);
            wait for tbit_time;
            midi_output <= TxData(42);
            wait for tbit_time;
            midi_output <= TxData(43);
            wait for tbit_time;
            midi_output <= TxData(44);
            wait for tbit_time;
            midi_output <= TxData(45);
            wait for tbit_time;
            midi_output <= TxData(46);
            wait for tbit_time;
            midi_output <= TxData(47);
            wait for tbit_time;
            midi_output <= TxData(48);
            wait for tbit_time;
            midi_output <= TxData(49);
            wait for tbit_time;
            midi_output <= TxData(50);
            wait for tbit_time;
            midi_output <= TxData(51);
            wait for tbit_time;
            midi_output <= TxData(52);
            wait for tbit_time;
            midi_output <= TxData(53);
            wait for tbit_time;
            midi_output <= TxData(54);
            wait for tbit_time;
            midi_output <= TxData(55);
            wait for tbit_time;
            midi_output <= TxData(56);
            wait for tbit_time;
            midi_output <= TxData(57);
            wait for tbit_time;
            midi_output <= TxData(58);
            wait for tbit_time;
            midi_output <= TxData(59);
            wait for tbit_time;
            midi_output <= TxData(60);
            wait for tbit_time;
            midi_output <= TxData(61);
            wait for tbit_time;
            midi_output <= TxData(62);
            wait for tbit_time;
            midi_output <= TxData(66);
            wait for tbit_time;
            midi_output <= TxData(66);
            wait for tbit_time;
            midi_output <= TxData(65);
            wait for tbit_time;
            midi_output <= TxData(66);
            wait for tbit_time;
            midi_output <= TxData(67);
            wait for tbit_time;
            midi_output <= TxData(68);
            wait for tbit_time;
            midi_output <= TxData(69);
            wait for tbit_time;
            midi_output <= TxData(70);
            wait for tbit_time;
            midi_output <= TxData(71);
            wait for tbit_time;
            midi_output <= TxData(72);
            wait for tbit_time;
            midi_output <= TxData(73);
            wait for tbit_time;
            midi_output <= TxData(74);
            wait for tbit_time;
            midi_output <= TxData(75);
            wait for tbit_time;
            midi_output <= TxData(76);
            wait for tbit_time;
            midi_output <= TxData(77);
            wait for tbit_time;
            midi_output <= TxData(78);
            wait for tbit_time;
            midi_output <= TxData(79);
            wait for tbit_time;
            midi_output <= TxData(80);
            wait for tbit_time;
            midi_output <= TxData(81);
            wait for tbit_time;
            midi_output <= TxData(82);
            wait for tbit_time;
            midi_output <= TxData(83);
            wait for tbit_time;
            midi_output <= TxData(84);
            wait for tbit_time;
            midi_output <= TxData(85);
            wait for tbit_time;
            midi_output <= TxData(86);
            wait for tbit_time;
            midi_output <= TxData(87);
            wait for tbit_time;
            midi_output <= TxData(88);
            wait for tbit_time;
            midi_output <= TxData(89);
            wait for tbit_time;
            midi_output <= TxData(90);
            wait for tbit_time;
            midi_output <= TxData(91);
            wait for tbit_time;
            midi_output <= TxData(92);
            wait for tbit_time;
            midi_output <= TxData(93);
            wait for tbit_time;
            midi_output <= TxData(94);
            wait for tbit_time;
            midi_output <= TxData(95);
            wait for tbit_time;
            midi_output <= TxData(96);
            wait for tbit_time;
            midi_output <= TxData(97);
            wait for tbit_time;
            midi_output <= TxData(98);
            wait for tbit_time;
            midi_output <= TxData(99);
            wait for tbit_time;
            midi_output <= TxData(100);
            wait for tbit_time;
            midi_output <= TxData(101);
            wait for tbit_time;
            midi_output <= TxData(102);
            wait for tbit_time;
            midi_output <= TxData(106);
            wait for tbit_time;
            midi_output <= TxData(106);
            wait for tbit_time;
            midi_output <= TxData(105);
            wait for tbit_time;
            midi_output <= TxData(106);
            wait for tbit_time;
            midi_output <= TxData(107);
            wait for tbit_time;
            midi_output <= TxData(108);
            wait for tbit_time;
            midi_output <= TxData(109);
            wait for tbit_time;
            midi_output <= TxData(110);
            wait for tbit_time;
            midi_output <= TxData(111);
            wait for tbit_time;
            midi_output <= TxData(112);
            wait for tbit_time;
            midi_output <= TxData(113);
            wait for tbit_time;
            midi_output <= TxData(114);
            wait for tbit_time;
            midi_output <= TxData(115);
            wait for tbit_time;
            midi_output <= TxData(116);
            wait for tbit_time;
            midi_output <= TxData(117);
            wait for tbit_time;
            midi_output <= TxData(118);
            wait for tbit_time;
            midi_output <= TxData(119);    
            wait for tbit_time;
            midi_output <= TxData(120);
            wait for tbit_time;
            midi_output <= TxData(121);
            wait for tbit_time;
            midi_output <= TxData(122);
            wait for tbit_time;
            midi_output <= TxData(123);
            wait for tbit_time;
            midi_output <= TxData(124);
            wait for tbit_time;
            midi_output <= TxData(125);
            wait for tbit_time;
            midi_output <= TxData(126);
            wait for tbit_time;
            midi_output <= TxData(127);
            wait for tbit_time;
            midi_output <= TxData(128);
            wait for tbit_time;
            midi_output <= TxData(129);   
            wait for tbit_time;
            midi_output <= TxData(130);
            wait for tbit_time;
            midi_output <= TxData(131);
            wait for tbit_time;
            midi_output <= TxData(132);
            wait for tbit_time;
            midi_output <= TxData(133);
            wait for tbit_time;
            midi_output <= TxData(134);
            wait for tbit_time;
            midi_output <= TxData(135);
            wait for tbit_time;
            midi_output <= TxData(136);
            wait for tbit_time;
            midi_output <= TxData(137);
            wait for tbit_time;
            midi_output <= TxData(138);
            wait for tbit_time;
            midi_output <= TxData(139);
            wait for tbit_time;
            midi_output <= TxData(140);
            wait for tbit_time;
            midi_output <= TxData(141);
            wait for tbit_time;
            midi_output <= TxData(142);
            wait for tbit_time;
            midi_output <= TxData(143);
            wait for tbit_time;
            midi_output <= TxData(144);
            wait for tbit_time;
            midi_output <= TxData(145);
            wait for tbit_time;
            midi_output <= TxData(146);
            wait for tbit_time;
            midi_output <= TxData(147);
            wait for tbit_time;
            midi_output <= TxData(148);
            wait for tbit_time;
            midi_output <= TxData(149);   
            wait;

        end process stim_proc;
        
    


    
    
    
end architecture testbench;