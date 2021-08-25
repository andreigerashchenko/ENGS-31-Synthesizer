library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity midi_polyphony_decode is
    port (
        clk_port    :   in  std_logic;
        note_id_port:   in  std_logic_vector(7 downto 0);
        note_on_port:   in  std_logic;
        velocity_port:  in  std_logic_vector(7 downto 0);
        trigger_port:   in  std_logic;

        note_1_id_p :   out std_logic_vector(7 downto 0);
        note_1_vel_p:   out std_logic_vector(7 downto 0);
        note_1_en_p :   out std_logic;
        note_2_id_p :   out std_logic_vector(7 downto 0);
        note_2_vel_p:   out std_logic_vector(7 downto 0);
        note_2_en_p :   out std_logic;
        note_3_id_p :   out std_logic_vector(7 downto 0);
        note_3_vel_p:   out std_logic_vector(7 downto 0);
        note_3_en_p :   out std_logic;
        note_4_id_p :   out std_logic_vector(7 downto 0);
        note_4_vel_p:   out std_logic_vector(7 downto 0);
        note_4_en_p :   out std_logic;
        note_count_p:   out std_logic_vector(2 downto 0));
end entity midi_polyphony_decode;

architecture behavior of midi_polyphony_decode is
    signal note_1_id    :   std_logic_vector(7 downto 0) := (others => '0');
    signal note_1_en    :   std_logic := '0';
    signal note_1_vel   :   std_logic_vector(7 downto 0) := (others => '0');
    signal note_2_id    :   std_logic_vector(7 downto 0) := (others => '0');
    signal note_2_en    :   std_logic := '0';
    signal note_2_vel   :   std_logic_vector(7 downto 0) := (others => '0');
    signal note_3_id    :   std_logic_vector(7 downto 0) := (others => '0');
    signal note_3_en    :   std_logic := '0';
    signal note_3_vel   :   std_logic_vector(7 downto 0);
    signal note_4_id    :   std_logic_vector(7 downto 0) := (others => '0');
    signal note_4_en    :   std_logic := '0';
    signal note_4_vel   :   std_logic_vector(7 downto 0);
    signal note_count   :   unsigned(2 downto 0) := (others => '0');


begin
    track_notes: process(clk_port, trigger_port, note_id_port, note_on_port, velocity_port, note_1_en, note_2_en, note_3_en, note_4_en, note_1_id, note_2_id, note_3_id, note_4_id, note_1_vel, note_2_vel, note_3_vel, note_4_vel)
    begin
        if rising_edge(clk_port) then
            if trigger_port = '1' then
                if note_on_port = '1' then
                    if note_count < 4 then
                        note_count <= note_count + 1;
                    end if;
                    note_1_en <= '1';
                    note_1_id <= note_id_port;
                    note_1_vel <= velocity_port;
                    note_2_en <= note_1_en;
                    note_2_vel <= note_1_vel;
                    note_2_id <= note_1_id;
                    note_3_en <= note_2_en;
                    note_3_vel <= note_2_vel;
                    note_3_id <= note_2_id;
                    note_4_en <= note_3_en;
                    note_4_vel <= note_3_vel;
                    note_4_id <= note_3_id;

                else -- if note_on_port = '0'
                    if note_id_port = note_4_id then
                        note_4_en <= '0';
                        note_4_vel <= (others => '0');
                        note_4_id <= (others => '0');
                        note_count <= note_count - 1;
                    elsif note_id_port = note_3_id then
                        if note_4_en = '1' then
                            note_3_en <= note_4_en;
                            note_3_vel <= note_4_vel;
                            note_3_id <= note_4_id;
                            note_4_en <= '0';
                            note_4_vel <= (others => '0');
                            note_4_id <= (others => '0');
                        else
                            note_3_en <= '0';
                            note_3_vel <= (others => '0');
                            note_3_id <= (others => '0');
                        end if;          
                        note_count <= note_count - 1;
                    elsif note_id_port = note_2_id then
                        if note_3_en = '1' then
                            note_2_en <= note_3_en;
                            note_2_vel <= note_3_vel;
                            note_2_id <= note_3_id;
                            note_3_en <= note_4_en;
                            note_3_vel <= note_4_vel;
                            note_3_id <= note_4_id;
                            note_4_en <= '0';
                            note_4_vel <= (others => '0');
                            note_4_id <= (others => '0');
                        else
                            note_2_en <= '0';
                            note_2_vel <= (others => '0');
                            note_2_id <= (others => '0');
                        end if;          
                        note_count <= note_count - 1;
                    elsif note_id_port = note_1_id then
                        if note_2_en = '1' then
                            note_1_en <= note_2_en;
                            note_1_vel <= note_2_vel;
                            note_1_id <= note_2_id;
                            note_2_en <= note_3_en;
                            note_2_vel <= note_3_vel;
                            note_2_id <= note_3_id;
                            note_3_en <= note_4_en;
                            note_3_vel <= note_4_vel;
                            note_3_id <= note_4_id;
                            note_4_en <= '0';
                            note_4_vel <= (others => '0');
                            note_4_id <= (others => '0');
                        else
                            note_1_id <= (others => '0');
                            note_1_en <= '0';
                            note_1_vel <= (others => '0');
                        end if;
                        note_count <= note_count - 1;
                    else
                        null; -- Don't do anything since this note wasn't stored anyway
                    end if;
                end if;
            end if;
        end if;
    end process track_notes;


    note_1_id_p <= note_1_id;
    note_1_vel_p <= note_1_vel;
    note_1_en_p <= note_1_en;
    note_2_id_p <= note_2_id;
    note_2_vel_p <= note_2_vel;
    note_2_en_p <= note_2_en;
    note_3_id_p <= note_3_id;
    note_3_vel_p <= note_3_vel;
    note_3_en_p <= note_3_en;
    note_4_id_p <= note_4_id;
    note_4_vel_p <= note_4_vel;
    note_4_en_p <= note_4_en;
    note_count_p <= std_logic_vector(note_count);
    
end architecture behavior;