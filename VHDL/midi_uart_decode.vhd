library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity midi_uart_decode is
    port (
        clk         :   in  std_logic;
        RsRx        :   in  std_logic;
        
        rx_done_tick:   out std_logic;
        note_on_port:   out std_logic;
        note_id_port:   out std_logic_vector(7 downto 0);
        velocity_port:  out std_logic_vector(7 downto 0) -- Actually implement this later
    );
end entity midi_uart_decode;

architecture behavior of midi_uart_decode is
    constant cycles_per_bit :   integer := 154; -- 32 us / 0.2083333 us = 153.6 ~= 154
    constant half_tbit_cycles:  integer := 77;
    constant bit_amount     :   integer := 10;
    constant byte_amount    :   integer := 3;

    type state_type is (wait_bytes, wait_start_bit, read_bit, wait_bit, byte_done, check_bytes_done, bytes_done, update_output);
    signal curr_state       :   state_type := wait_bytes;
    signal next_state       :   state_type := wait_bytes;

    signal fs_flop_in       :   std_logic := '0';
    signal fs_flop_out      :   std_logic := '0';

    signal shift            :   std_logic := '0';
    signal clear            :   std_logic := '0';
    signal shift_reg_val    :   std_logic_vector(9 downto 0) := (others => '0');

    signal load_byte        :   std_logic := '0';
    signal store_byte       :   std_logic := '0';

    signal rx_data          :   std_logic_vector(7 downto 0) := (others => '0');
    
    signal full_data        :   std_logic_vector(23 downto 0) := (others => '0');
   
    signal count_done       :   std_logic := '0';
    signal count_half       :   std_logic := '0';
    signal count_reset      :   std_logic := '0';
    signal curr_count       :   unsigned(7 downto 0) := (others => '0');
    
    signal bit_count_reset  :   std_logic := '0';
    signal bit_count_run    :   std_logic := '0';
    signal bits_saved       :   unsigned(4 downto 0) := (others => '0');
    signal bits_full        :   std_logic := '0';

    signal byte_count_reset :   std_logic := '0';
    signal byte_count_run   :   std_logic := '0';
    signal bytes_saved      :   unsigned(3 downto 0) := (others => '0');
    signal bytes_full       :   std_logic := '0';
    signal clear_bytes      :   std_logic := '0';

    signal output_update    :   std_logic := '0';

    signal note_on          :   std_logic;
    signal note_id          :   std_logic_vector(7 downto 0);
    signal note_velocity    :   std_logic_vector(7 downto 0);

begin
    -- Counting cycles between data bits
    cycle_counter: process(clk, count_reset, curr_count)
    begin
        if rising_edge(clk) then
            if count_reset = '1' then
                curr_count <= (others => '0');
            else
                if curr_count = (cycles_per_bit - 1) then
                    curr_count <= (others => '0');
                else
                    curr_count <= curr_count + 1;
                end if;
            end if;
        end if;

        -- Check if tbit has been reached
        if curr_count = (cycles_per_bit - 1) then
            count_done <= '1';
        else
            count_done <= '0';
        end if;

        -- Check if tbit/2 has been reached
        if curr_count = (half_tbit_cycles - 1) then
            count_half <= '1';
        else
            count_half <= '0';
        end if;
    end process cycle_counter;

    -- Counting bits
    bit_counter: process(clk, bits_saved, bit_count_reset, bit_count_run)
    begin
        if rising_edge(clk) then
            if bit_count_reset = '1' then
                bits_saved <= (others => '0');
            else
                if bit_count_run = '1' then
                    if bits_saved = (bit_amount - 1) then
                        bits_saved <= (others => '0');
                    else
                        bits_saved <= bits_saved + 1;
                    end if;
                else
                    bits_saved <= bits_saved;
                end if;
            end if;
        end if;

        if bits_saved = (bit_amount - 1) then
            bits_full <= '1';
        else
            bits_full <= '0';
        end if;
    end process bit_counter;

    -- Counting bytes
    byte_counter: process(clk, bytes_saved, byte_count_reset, byte_count_run)
    begin
        if rising_edge(clk) then
            if byte_count_reset = '1' then
                bytes_saved <= (others => '0');
            else
                if byte_count_run = '1' then
                    if bytes_saved = (byte_amount - 1) then
                        bytes_saved <= (others => '0');
                    else
                        bytes_saved <= bytes_saved + 1;
                    end if;
                else
                    bytes_saved <= bytes_saved;
                end if;
            end if;
        end if;

        if bytes_saved = (byte_amount - 1) then
            bytes_full <= '1';
        else
            bytes_full <= '0';
        end if;
    end process byte_counter;

    -- Synchronizing incoming signals with our clock
    flop_synchronizer: process(clk, RsRx, fs_flop_out)
    begin
        if rising_edge(clk) then
            fs_flop_in <= RsRx;
            fs_flop_out <= fs_flop_out;
        end if;
    end process flop_synchronizer;

    -- 10-bit shift register
    shift_register: process(clk, shift, clear, RsRx)
    begin
        if rising_edge(clk) then
            if clear = '1' then
                shift_reg_val <= (others => '0');
            else
                if shift = '1' then
                    shift_reg_val <= RsRx & shift_reg_val(8 downto 0);
                else
                    shift_reg_val <= shift_reg_val;
                end if;
            end if;
        end if;
    end process shift_register;

    -- 8-bit parallel load register
    parallel_load: process(clk, load_byte, rx_data, shift_reg_val)
    begin
        if rising_edge(clk) then
            if load_byte = '1' then
                rx_data <= shift_reg_val(8 downto 1);
            else
                rx_data <= rx_data;
            end if;
        end if;
    end process parallel_load;

    -- Saving the byte
    save_byte: process(clk, store_byte, rx_data, full_data, clear_bytes)
    begin
        if rising_edge(clk) then
            if clear_bytes = '1' then
                full_data <= (others => '0');
            else
                if store_byte = '1' then
                    full_data <= full_data(23 downto 8) & rx_data;
                else
                    full_data <= full_data;
                end if;
            end if;
        end if;
    end process save_byte;

    -- Update outputs
    output: process(clk)
    begin
        if rising_edge(clk) then
            if output_update = '1' then
                case full_data(23 downto 20) is
                    when "1000" => -- Note off
                        note_on <= '0';
                        note_id <= full_data(15 downto 8);
                        note_velocity <= full_data(7 downto 0);
                    when "1001" => -- Note on
                        note_on <= '1';
                        note_id <= full_data(15 downto 8);
                        note_velocity <= full_data(7 downto 0);
                    when others =>
                        note_on <= '0';
                        note_id <= (others => '0');
                        note_velocity <= (others => '0');
                end case;
            else
                note_on <= note_on;
                note_id <= note_id;
                note_velocity <= note_velocity;
            end if;
        end if;
    end process output;

    MIDI_FSM_comb: process(curr_state, count_done, count_half, rx_data)
    begin
        next_state <= curr_state;
        shift <= '0';
        clear <= '0';
        load_byte <= '0';
        store_byte <= '0';
        count_reset <= '1';
        bit_count_run <= '0';
        byte_count_run <= '0';
        bit_count_reset <= '0';
        byte_count_reset <= '1';
        clear_bytes <= '0';
        output_update <= '0';

        case (curr_state) is
            when wait_bytes =>
                if RsRx = '1' then
                    next_state <= wait_bytes;
                else
                    next_state <= wait_start_bit;
                end if;

            when wait_start_bit =>
                count_reset <= '0';
                if count_half = '1' then
                    next_state <= read_bit;
                else
                    next_state <= wait_start_bit;
                end if;

            when wait_bit =>
                count_reset <= '0';
                if bits_full = '1' then
                    next_state <= byte_done;
                elsif count_half = '1' then
                    next_state <= read_bit; 
                else
                    next_state <= wait_bit;
                end if;

            when read_bit =>
                shift <= '1';
                bit_count_run <= '1';
                next_state <= wait_bit;

            when byte_done =>
                bit_count_reset <= '1';
                load_byte <= '1';
                clear <= '1';
                byte_count_run <= '1';
                next_state <= check_bytes_done;

            when check_bytes_done =>
                if bytes_full = '1' then
                    next_state <= bytes_done;
                else
                    next_state <= wait_bytes;
                end if;

            when bytes_done =>
                store_byte <= '1';
                clear <= '1';
                clear_bytes <= '1';
                next_state <= update_output;

            when update_output =>
                output_update <= '1';
                next_state <= wait_bytes;

            when others =>
                next_state <= wait_bytes;
        end case;
    end process MIDI_FSM_comb;

    MIDI_FSM_update: process(clk)
    begin
        if rising_edge(clk) then
            curr_state <= next_state;
        end if;
    end process MIDI_FSM_update;
    
end architecture behavior;