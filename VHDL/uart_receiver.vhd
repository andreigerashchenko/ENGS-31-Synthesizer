library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_receiver is
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
end entity uart_receiver;

architecture behavior of uart_receiver is
    type state_type is (idle, wait_half, shift_bit, check_full, wait_full, move_bits, done);
    signal curr_state   :   state_type := idle;
    signal next_state   :   state_type := idle;

    signal fs_flop_in   :   std_logic := '1';
    signal fs_flop_out  :   std_logic := '1';

    signal curr_count   :   unsigned(8 downto 0) := (others => '0');
    signal half_done    :   std_logic := '0';
    signal count_half   :   std_logic := '0';
    signal count_full   :   std_logic := '0';
    signal count_reset  :   std_logic := '1';
    signal clear_shift  :   std_logic := '0';

    signal bit_count    :   unsigned(3 downto 0) := (others => '0');
    signal bits_done    :   std_logic := '0';
    signal bit_count_rst:   std_logic := '1';
    signal bit_count_run:   std_logic := '0';
    
    signal shift_en     :   std_logic := '0';
    signal load_en      :   std_logic := '0';

    signal packet_bits  :   std_logic_vector(9 downto 0) := (others => '0');
    signal byte_out     :   std_logic_vector(7 downto 0) := (others => '0');
    signal rx_done      :   std_logic := '0';
begin

    -- Synchronizing incoming signals with our clock
    flop_synchronizer: process(clk_port, rx_port, fs_flop_out)
    begin
        if rising_edge(clk_port) then
            fs_flop_in <= rx_port;
            fs_flop_out <= fs_flop_in;
        end if;
    end process flop_synchronizer;

    -- Counting cycles between data bits
    cycle_counter: process(clk_port, count_reset, curr_count)
    begin
        if rising_edge(clk_port) then
            if count_reset = '1' then
                curr_count <= (others => '0');
            else
                if curr_count = (CYCLES_PER_BIT - 1) then
                    curr_count <= (others => '0');
                else
                    curr_count <= curr_count + 1;
                end if;
            end if;
        end if;

        -- Check if tbit has been reached
        if curr_count = (CYCLES_PER_BIT - 1) then
            count_full <= '1';
        else
            count_full <= '0';
        end if;

        -- Check if tbit/2 has been reached
        if curr_count = (CYCLES_PER_HALF - 1) then
            count_half <= '1';
        else
            count_half <= '0';
        end if;
    end process cycle_counter;

    -- Counting bits
    bit_counter: process(clk_port, bit_count, bit_count_rst, bit_count_run)
    begin
        if rising_edge(clk_port) then
            if bit_count_rst = '1' then
                bit_count <= (others => '0');
            else
                if bit_count_run = '1' then
                    if bit_count = BIT_AMOUNT then
                        bit_count <= (others => '0');
                    else
                        bit_count <= bit_count + 1;
                    end if;
                else
                    bit_count <= bit_count;
                end if;
            end if;
        end if;

        if bit_count = BIT_AMOUNT then
            bits_done <= '1';
        else
            bits_done <= '0';
        end if;
    end process bit_counter;

    receiver_FSM_comb: process(curr_state, count_half, count_full, bits_done, fs_flop_out)
    begin
        next_state <= curr_state;
        shift_en <= '0';
        load_en <= '0';
        count_reset <= '1';
        bit_count_rst <= '0';
        bit_count_run <= '0';
        clear_shift <= '0';

        case (curr_state) is
            when idle =>
                if fs_flop_out = '1' then
                    next_state <= idle;
                else
                    next_state <= wait_half;
                end if;

            when wait_half =>
                count_reset <= '0';
                if count_half = '0' then
                    next_state <= wait_half;
                else
                    next_state <= shift_bit;
                end if;

            when check_full =>
                if bits_done = '1' then
                    next_state <= move_bits;
                else
                    next_state <= wait_full;
                end if;

            when wait_full =>
                count_reset <= '0';
                if count_full = '0' then
                    next_state <= wait_full;
                else
                    next_state <= shift_bit;
                end if;

            when shift_bit =>
                shift_en <= '1';
                bit_count_run <= '1';
                next_state <= check_full;

            when move_bits =>
                load_en <= '1';
                clear_shift <= '1';
                next_state <= done;

            when done =>
                bit_count_rst <= '1';
                next_state <= idle;
            
            when others =>
                next_state <= idle;
        end case;
    end process receiver_FSM_comb;

    
    receiver_datapath: process(clk_port, packet_bits, rx_port, shift_en, load_en)
    begin
        if rising_edge(clk_port) then
            if shift_en = '1' then
                -- Right shift
                packet_bits <= rx_port & packet_bits(9 downto 1);

                -- Left shift
                -- packet_bits <= packet_bits(8 downto 0) & rx_port;
            else
                packet_bits <= packet_bits;
            end if;

            if load_en = '1' then
                byte_out <= packet_bits(8 downto 1);
                rx_done <= '1';
            else
                byte_out <= byte_out;
                rx_done <= '0';
            end if;
        end if;
    end process receiver_datapath;

    receiver_FSM_update: process(clk_port)
    begin
        if rising_edge(clk_port) then
            curr_state <= next_state;
        end if;
    end process receiver_FSM_update;
    
    byte_port <= byte_out;
    rx_done_tick <= rx_done;
    tc_half_port <= count_half;
    tc_full_port <= count_full;
    rx_sync_port <= fs_flop_out;
end architecture behavior;