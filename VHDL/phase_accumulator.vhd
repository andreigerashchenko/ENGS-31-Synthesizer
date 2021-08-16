library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity phase_accumulator is
    port (
        -- input ports
        --+++++++++++++++++++++++++++++++++++
        --Timing
        --+++++++++++++++++++++++++++++++++++
        clk_in_port:        in   std_logic;
        sample_rate_tick:   in   std_logic;
         --+++++++++++++++++++++++++++++++++++
        --Data Inputs
        --+++++++++++++++++++++++++++++++++++
        midi_data_in_port:  in   std_logic_vector(7 downto 0);
        
        sw1:                in   std_logic;
        sw2:                in   std_logic;
        sw3:                in   std_logic;
        
        -- output ports
--        sine_addr_out_port: out std_logic_vector(13 downto 0)
        sine_addr_out_port: out std_logic_vector(15 downto 0)
    );
end entity phase_accumulator;

architecture behavior of phase_accumulator is
    constant step_size_1kHz: integer := 343;
    constant step_size_c4: integer := 89;
    constant step_size_c2: integer := 22;
    constant step_size_10kHz: integer := 3413;
    signal step_size: unsigned(13 downto 0) := (others => '0'); -- the step size for a given note
    signal acc:     unsigned(13 downto 0) := (others => '0'); -- the address for the dds compiler


begin
    accumulator: process(clk_in_port)
    begin
        if rising_edge(clk_in_port) then
            if sample_rate_tick = '1' then
                acc <= acc + step_size;
            else
                acc <= acc;
            end if;
        end if;
    end process accumulator;

    step_size_lut: process(midi_data_in_port, sw1, sw2)
    begin
        if sw1 = '1' then
            step_size <= to_unsigned(step_size_c4, 14);
        elsif sw2 = '1' then
            step_size <= to_unsigned(step_size_c2, 14);
        elsif sw3 = '1' then 
            step_size <= to_unsigned(step_size_10kHz, 14);
        else 
            step_size <= to_unsigned(0, 14);
        end if;
    end process step_size_lut;
    sine_addr_out_port <= ("00" & std_logic_vector(acc));
    
end architecture behavior;