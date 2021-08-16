library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity volume_control is
    port (
        -- input ports
        original_sine: in std_logic_vector(15 downto 0);
        -- output ports
        modified_sine: out std_logic_vector(15 downto 0)
    );
end entity volume_control;

architecture behavior of volume_control is
begin
    --==========================================
    -- Decrease volume
    --==========================================
    dec_volume: process(original_sine)
    begin
        modified_sine <= std_logic_vector(signed(original_sine)/4);
    end process dec_volume;
    
end behavior;
    
    

