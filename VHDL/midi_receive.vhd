library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity midi_receive is
    generic (
        BYTE_AMOUNT :   integer);
    port (
        clk_port    :   in  std_logic;
        trigger_port:   in  std_logic;
        byte_port   :   in  std_logic_vector(7 downto 0);

        assembled   :   out std_logic_vector(23 downto 0);
        done_port   :   out std_logic);
end entity midi_receive;

architecture behavior of midi_receive is
    type state_type is (idle, shift_byte, check_done, done);
    signal curr_state   :   state_type := idle;
    signal next_state   :   state_type := idle;

    signal curr_count   :   unsigned(1 downto 0) := (others => '0');
    signal count_reset  :   std_logic := '0';
    signal count_run    :   std_logic := '0';
    signal count_done   :   std_logic := '0';

    signal shift_en     :   std_logic := '0';
    signal load_en      :   std_logic := '0';

    signal saved_bytes  :   std_logic_vector(23 downto 0) := (others => '0');

    signal output_bytes :   std_logic_vector(23 downto 0) := (others => '0');
    signal bytes_ready  :   std_logic := '0';
begin
    
    -- Counting bytes
    byte_counter: process(clk_port, curr_count, count_reset, count_run)
    begin
        if rising_edge(clk_port) then
            if count_reset = '1' then
                curr_count <= (others => '0');
            else
                if count_run = '1' then
                    if curr_count = BYTE_AMOUNT then
                        curr_count <= (others => '0');
                    else
                        curr_count <= curr_count + 1;
                    end if;
                else
                    curr_count <= curr_count;
                end if;
            end if;
        end if;

        if curr_count = BYTE_AMOUNT then
            count_done <= '1';
        else
            count_done <= '0';
        end if;
    end process byte_counter;
    
    midi_receive_FSM_comb: process(curr_state, count_done, trigger_port)
    begin
        count_reset <= '0';
        count_run <= '0';
        shift_en <= '0';
        load_en <= '0';

        case (curr_state) is
            when idle =>
                if trigger_port = '0' then
                    next_state <= idle;
                else
                    next_state <= shift_byte;
                end if;

            when shift_byte =>
                count_run <= '1';
                shift_en <= '1';
                next_state <= check_done;

            when check_done =>
                if count_done = '1' then
                    next_state <= done;
                else
                    next_state <= idle;
                end if;

            when done =>
                load_en <= '1';
                count_reset <= '1';
                next_state <= idle;
        
            when others =>
                next_state <= idle;
        end case;
        end process midi_receive_FSM_comb;
        
        midi_receive_datapath: process(clk_port, shift_en, load_en, byte_port)
        begin
            if rising_edge(clk_port) then
                if shift_en = '1' then
                    saved_bytes <= saved_bytes(15 downto 0) & byte_port; -- Left shift
                else
                    saved_bytes <= saved_bytes;
                end if;

                if load_en = '1' then
                    output_bytes <= saved_bytes;
                    bytes_ready <= '1';
                else
                    output_bytes <= output_bytes;
                    bytes_ready <= '0';
                end if;
            end if;
        end process midi_receive_datapath;

        midi_receive_FSM_update: process(clk_port)
        begin
            if rising_edge(clk_port) then
                curr_state <= next_state;
            end if;
        end process midi_receive_FSM_update;
    
        assembled <= output_bytes;
        done_port <= bytes_ready;
end architecture behavior;