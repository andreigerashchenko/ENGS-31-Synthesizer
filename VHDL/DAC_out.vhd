library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DAC_out is
    generic (
        N_BITS        :   integer);
    
    port (
       -- Inputs
       clk_in_port      :   in  std_logic;
       data_in_port     :   in  std_logic_vector(15 downto 0); -- Signed 16-bit sine wave generator output
       dac_trigger      :   in  std_logic;
       note_on_port     :   in  std_logic;

       -- Outputs
       data_out_port    :   out std_logic;
       cs_out_port      :   out std_logic;
       clk_out_port     :   out std_logic
    );
end entity DAC_out;

architecture behavior of DAC_out is
    
    type state_type is (idle, load_data, send_bit);
    signal curr_state   :   state_type := idle;
    signal next_state   :   state_type := idle;

    signal cs_out       :   std_logic := '1'; -- Low-true, start disabled
    signal load_en      :   std_logic := '0';
    signal shift_en     :   std_logic := '0';

    signal bit_out      :   std_logic := '0';
    signal data_out     :   std_logic_vector(15 downto 0) := (others => '0');

    signal count_reset  :   std_logic := '0'; -- For counting out the output bits
    signal count_done   :   std_logic := '0';
    signal curr_count   :   unsigned(4 downto 0) := (others => '0');
begin
    shift_counter: process(clk_in_port, count_reset, curr_count)
    begin
        if rising_edge(clk_in_port) then
            if count_reset = '0' then
                if curr_count = (N_BITS - 1) then
                    curr_count <= (others => '0');
                     
                else
                    curr_count <= curr_count + 1;
                      
                end if;
            else
                curr_count <= (others => '0');
            end if;    
        end if;
        if curr_count = (N_BITS - 1) then 
            count_done <= '1';
        else 
            count_done <= '0';
        end if;
        
    end process shift_counter;

    -- Datapath for DAC
    DAC_datapath: process(clk_in_port, load_en, shift_en, data_out, note_on_port)
    begin
        if rising_edge(clk_in_port) then
            if load_en = '1' then
                data_out <= "0000" & not(data_in_port(11)) & data_in_port(10 downto 0);
                -- data_out <= "0000" & std_logic_vector(signed(data_in_port(11 downto 0)) + x"800");
            end if;

            if shift_en = '1' then
                data_out <= data_out(14 downto 0) & '0';
            end if;
        end if;
 
        bit_out <= data_out(15);
    end process DAC_datapath;

    -- Controller for DAC
    DAC_FSM_comb: process(curr_state, count_done, dac_trigger)
    begin
        next_state <= curr_state;
        cs_out <= '1'; -- Low true, default is off
        load_en <= '0';
        shift_en <= '0';
        count_reset <= '1';

        case (curr_state) is
            when idle =>
                if dac_trigger = '0' then
                    next_state <= idle;
                else
                    next_state <= load_data;
                end if;

            when load_data =>
                load_en <= '1';
                next_state <= send_bit;

            when send_bit =>
                count_reset <= '0';
                shift_en <= '1';
                cs_out <= '0';
                
                if count_done = '0' then
                    next_state <= send_bit;
                else
                    next_state <= idle;
                end if;

            when others => -- Should never happen, just go to idle if this ever happens somehow
                next_state <= idle;
            end case;
    end process DAC_FSM_comb;

    DAC_FSM_update: process(clk_in_port)
    begin
        if rising_edge(clk_in_port) then
            curr_state <= next_state;
        end if;
    end process DAC_FSM_update;

    data_out_port <= bit_out;
    cs_out_port <= cs_out;
    clk_out_port <= clk_in_port; -- Pass through clock

end architecture behavior;