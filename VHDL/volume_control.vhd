library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity volume_control is
		port (
				-- input ports
				
				original_sine       :   in  std_logic_vector(15 downto 0);
				note_velocity_port  :   in  std_logic_vector(7 downto 0);
				-- output ports
				modified_sine       :   out std_logic_vector(15 downto 0)
		);
end entity volume_control;

architecture behavior of volume_control is
		constant lowest     :   integer := 25;
		constant new_1      :   integer := 38;
		constant mid_low    :   integer := 51;
		constant new_2      :   integer := 64;
		constant mid_high   :   integer := 76;
		constant new_3      :   integer := 89;
		constant high       :   integer := 102;
		constant new_4      :   integer := 115;
-- velocity ranges from 0 to 127
begin
		--==========================================
		-- Decrease volume
		--==========================================
		dec_volume: process(note_velocity_port, original_sine)
		begin
			if unsigned(note_velocity_port) < lowest then
				modified_sine <= std_logic_vector(signed(original_sine) / 256);
			elsif unsigned(note_velocity_port) >= lowest and unsigned(note_velocity_port) < new_1 then
				modified_sine <= std_logic_vector(signed(original_sine) / 128);
			elsif unsigned(note_velocity_port) >= new_1 and unsigned(note_velocity_port) < mid_low then
				modified_sine <= std_logic_vector(signed(original_sine) / 64);
			elsif unsigned(note_velocity_port) >= mid_low and unsigned(note_velocity_port) < new_2 then
				modified_sine <= std_logic_vector(signed(original_sine) / 32);
			elsif unsigned(note_velocity_port) >= new_2 and unsigned(note_velocity_port) < mid_high then
				modified_sine <= std_logic_vector(signed(original_sine) / 16);
			elsif unsigned(note_velocity_port) >= mid_high and unsigned(note_velocity_port) < new_3 then
				modified_sine <= std_logic_vector(signed(original_sine) / 8);
			elsif unsigned(note_velocity_port) >= new_3 and unsigned(note_velocity_port) < high then
				modified_sine <= std_logic_vector(signed(original_sine) / 4);
			elsif unsigned(note_velocity_port) >= high and unsigned(note_velocity_port) < new_4 then
				modified_sine <= std_logic_vector(signed(original_sine) / 2);
			elsif unsigned(note_velocity_port) >= new_4 then
				modified_sine <= original_sine;
			else 
				modified_sine <= original_sine;
			end if;
			
		end process dec_volume;
		
		
end behavior;
		
		

