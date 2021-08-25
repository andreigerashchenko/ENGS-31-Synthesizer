library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sine_wave_acc is
    port (
        -- Timing
        clk_in_port         : in std_logic;

        -- Sine Wave Data
        sine_wave_in_port   : in std_logic_vector(15 downto 0);
        
        -- Control Signals
        acc_clr_port        : in std_logic;
        acc_en_port         : in std_logic;
        num_count           : in std_logic_vector(1 downto 0);
        -- output 
        sine_wave_acc_port  : out std_logic_vector(15 downto 0)

    );
end entity sine_wave_acc;

architecture behavior of sine_wave_acc is
    signal sine_wave_acc: signed(15 downto 0) := (others => '0');

begin
    
    accumulator: process(clk_in_port)
    begin
        if rising_edge(clk_in_port) then
            if acc_clr_port = '1' then
                sine_wave_acc <= (others => '0');
                

            else
            
                if acc_en_port = '1' then   
                    if signed(num_count) /= 0 then
                        sine_wave_acc <= sine_wave_acc + (signed(sine_wave_in_port)/signed(num_count));
                    else
                        sine_wave_acc <= sine_wave_acc;
                    end if;
                else 
                    sine_wave_acc <= sine_wave_acc;
                end if;
            end if;
        end if;
    end process accumulator;
    
    sine_wave_acc_port <= std_logic_vector(sine_wave_acc);
    
end architecture behavior;  