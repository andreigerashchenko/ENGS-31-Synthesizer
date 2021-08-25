library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity midi_polyphony_assemble is
    port (
        clk_port    :   in  std_logic;
        note_1_en_p :   in  std_logic;
        note_2_en_p :   in  std_logic;
        note_3_en_p :   in  std_logic;
        note_4_en_p :   in  std_logic;
        
        note_count_p:   in  std_logic_vector(2 downto 0);
        
        note_1_sine_p:  in  std_logic_vector(15 downto 0);
        note_2_sine_p:  in  std_logic_vector(15 downto 0);
        note_3_sine_p:  in  std_logic_vector(15 downto 0);
        note_4_sine_p:  in  std_logic_vector(15 downto 0);
        full_sine_p :   out std_logic_vector(15 downto 0) );

        
end entity midi_polyphony_assemble;
        
architecture behavior of midi_polyphony_assemble is
    signal note_1_en_unsigned:  unsigned(0 downto 0) := (others => '0');
    signal note_2_en_unsigned:  unsigned(0 downto 0) := (others => '0');
    signal note_3_en_unsigned:  unsigned(0 downto 0) := (others => '0');
    signal note_4_en_unsigned:  unsigned(0 downto 0) := (others => '0');
    signal note_1_sine      :   signed(15 downto 0) := (others => '0');
    signal note_2_sine      :   signed(15 downto 0) := (others => '0');
    signal note_3_sine      :   signed(15 downto 0) := (others => '0');
    signal note_4_sine      :   signed(15 downto 0) := (others => '0');
    signal full_sine_wave   :   signed(15 downto 0) := (others => '0');
begin

    check_waves: process(clk_port, note_1_sine_p, note_2_sine_p, note_3_sine_p, note_4_sine_p, note_1_en_p, note_2_en_p, note_3_en_p, note_4_en_p)
    begin
        if rising_edge(clk_port) then
            if note_1_en_p = '1' then
                note_1_sine <= signed(note_1_sine_p);
            else
                note_1_sine <= (others => '0');
            end if;
            if note_2_en_p = '1' then
                note_2_sine <= signed(note_2_sine_p);
            else
                note_2_sine <= (others => '0');
            end if;
            if note_3_en_p = '1' then
                note_3_sine <= signed(note_3_sine_p);
            else
                note_3_sine <= (others => '0');
            end if;
            if note_4_en_p = '1' then
                note_4_sine <= signed(note_4_sine_p);
            else
                note_4_sine <= (others => '0');
            end if;
        end if;
    end process check_waves;

    full_sine_p <= std_logic_vector((note_1_sine + note_2_sine + note_3_sine+ note_4_sine) / signed(note_count_p));
end architecture behavior;
