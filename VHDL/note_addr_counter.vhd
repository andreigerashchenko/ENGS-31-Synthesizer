library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity note_addr_counter is
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
end entity note_addr_counter;

architecture behavior of note_addr_counter is
    constant NUM_NOTES: integer := 3;
    constant NUM_WAIT_CYCLES : integer := 6;

    type state_type is (idle, clear, send, acc);
    signal curr_state, next_state : state_type;

    signal note_ctr : unsigned(1 downto 0) := (others => '0'); -- keeps track of which note to send
    signal note_clr : std_logic; -- clears the note counter
    signal note_tc  : std_logic;  -- 
    signal take_note : std_logic; -- enables the note counter to run
    signal take_note_ctr: unsigned(2 downto 0) := (others => '0'); -- used to maintain timing when sending a new note
    signal take_note_clr: std_logic;
    signal acc_clr : std_logic; -- clears the accumulator for the SINE LUT
    signal acc_en  : std_logic; -- enables the accumulator for the SINE LUT

begin
    note_counter: process(clk_in_port, note_ctr)
    begin
        if rising_edge(clk_in_port) then
            if (note_clr = '1') then
                note_ctr <= (others => '0');
            else
                if (take_note = '1') then
                    note_ctr <= note_ctr + 1;
                else
                    note_ctr <= note_ctr;
              end if;
            end if;
        end if;

        if (note_ctr = NUM_NOTES) then
            note_tc <= '1';
        else 
            note_tc <= '0';
         end if;
    end process note_counter;
    
    take_note_counter: process(clk_in_port, take_note_ctr)
    begin
        if rising_edge(clk_in_port) then
            if take_note_clr = '1' then
                take_note_ctr <= (others => '0');
           else
                take_note_ctr <= take_note_ctr + 1;
            end if;
        end if;
        
        if (take_note_ctr = NUM_WAIT_CYCLES - 1) then
            take_note <= '1';
        else 
            take_note <= '0';
        end if;
    end process take_note_counter;
    
    sine_addr_send: process(note_ctr, note_1_in_port, note_2_in_port, note_3_in_port)
    begin
        case note_ctr is 
            when "00" => sine_addr_port <= note_1_in_port;
            when "01" => sine_addr_port <= note_2_in_port;
            when "10" => sine_addr_port <= note_3_in_port;
            when others => sine_addr_port <= (others => '0');
        end case;
    end process sine_addr_send;

    FSM_comb: process(curr_state, take_sample, take_note, note_tc)
    begin
        next_state <= curr_state;
        note_clr <= '0';
        take_note_clr <= '1';
        acc_en <= '0';
        acc_clr <= '0';

        case curr_state is 
            when idle => 
                note_clr <= '1';
                if take_sample = '1' then 
                    next_state <= clear;
                else 
                    next_state <= idle;
                end if;
            
            when clear => 
                acc_clr <= '1';
                take_note_clr <= '0';
                next_state <= send;
                
            when send => 
                take_note_clr <= '0';
                if take_note = '1' then
                    next_state <= acc;
                else 
                    next_state <= send;
                end if;
            
            when acc => 
                acc_en <= '1';
                if note_tc = '1' then
                    next_state <= idle;
                else 
                    next_state <= send;
                end if;
            end case;

    end process FSM_comb;

    FSM_update: process(clk_in_port)
    begin
        if rising_edge(clk_in_port) then
            curr_state <= next_state;
        end if;
    end process FSM_update;
    
    acc_clr_port <= acc_clr;
    acc_en_port <= acc_en;
end architecture behavior;