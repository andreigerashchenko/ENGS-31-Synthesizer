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
        step_size_port:  in   std_logic_vector(11 downto 0);
        note_on_port    :   in  std_logic;
        p_bend_port     : in std_logic_vector(7 downto 0);
        
        -- sw1:                in   std_logic;
        -- sw2:                in   std_logic;
        -- sw3:                in   std_logic;
        
        -- output ports
        sine_addr_out_port: out std_logic_vector(15 downto 0)
    );
end entity phase_accumulator;

architecture behavior of phase_accumulator is
    constant p_bend_center: unsigned(7 downto 0) := "01000000";

    signal step_size: unsigned(13 downto 0) := (others => '0'); -- the step size for a given note
    signal acc:     unsigned(13 downto 0) := (others => '0'); -- the address for the dds compiler
    signal pitch_offset : unsigned(7 downto 0); 


begin
    step_size_store: process(clk_in_port)
    begin
        if rising_edge(clk_in_port) then
            step_size <= unsigned("00" & step_size_port);
        end if;
    end process step_size_store;
    
    

    accumulator: process(clk_in_port)
    begin
        if rising_edge(clk_in_port) then
            if unsigned(p_bend_port) > p_bend_center then
                pitch_offset <= unsigned(p_bend_port) - p_bend_center;
            elsif unsigned(p_bend_port) < p_bend_center then
                pitch_offset <= p_bend_center - unsigned(p_bend_port);
            else
                pitch_offset <= pitch_offset;
            end if;
            
            if note_on_port = '1' then
                if sample_rate_tick = '1' then
                    if unsigned(p_bend_port) > p_bend_center then
                        acc <= acc + step_size + pitch_offset;
                    elsif unsigned(p_bend_port) < p_bend_center then
                        acc <= acc + step_size - pitch_offset;
                    else
                        acc <= acc + step_size;
                    end if;
                else
                    acc <= acc;
                end if;
            else
                acc <= (others => '0');
            end if;
        end if;
    end process accumulator;

    sine_addr_out_port <= ("00" & std_logic_vector(acc));
    
end architecture behavior;