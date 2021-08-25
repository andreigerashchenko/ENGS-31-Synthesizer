library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity midi_decode is
    port (
        clk_port    :   in  std_logic;
        trigger_port:   in  std_logic;
        data_port   :   in  std_logic_vector(23 downto 0);

        note_on_port:   out std_logic;
        channel_port:   out std_logic_vector(3 downto 0);
        note_id_port:   out std_logic_vector(7 downto 0);
        velocity_port:  out std_logic_vector(7 downto 0);
        p_bend_port :   out std_logic_vector(7 downto 0);
        trigger_out :   out std_logic);
end entity midi_decode;

architecture behavior of midi_decode is
    signal midi_data:   std_logic_vector(23 downto 0) := (others => '0');
    signal note_on:     std_logic := '0';
    signal midi_chnl:   std_logic_vector(3 downto 0) := (others => '0');
    signal note_id:     std_logic_vector(7 downto 0) := (others => '0');
    signal note_vel:    std_logic_vector(7 downto 0) := (others => '0');
    signal prev_note:   std_logic_vector(7 downto 0) := (others => '0');
    signal pitch_offset:std_logic_vector(7 downto 0) := "01000000";
    signal new_note_done  :   std_logic := '0';
    signal last_data    :   std_logic_vector(23 downto 0);

begin
    process_data: process(clk_port, trigger_port, data_port)
    begin
        if rising_edge(clk_port) then
            if trigger_port = '1' then
                midi_data <= data_port;
            else
                midi_data <= midi_data;
            end if;

            case (midi_data(23 downto 20)) is
                -- when "1000" => -- if one note
                --     if midi_data(15 downto 8) = prev_note then
                --         note_on <= '0';
                --     else
                --         note_on <= note_on;
                --     end if;
                when "1000" =>
                    note_on <= '0';
                    note_id <= midi_data(15 downto 8);

                when "1001" =>
                    note_on <= '1';
                    note_id <= midi_data(15 downto 8);
                    prev_note <= midi_data(15 downto 8);
                    note_vel <= midi_data(7 downto 0);
                when "1110" =>
                    pitch_offset <= midi_data(7 downto 0);
                when others =>
                    null; -- Do nothing
            end case;
            
            midi_chnl <= midi_data(19 downto 16);
        end if;
    end process process_data;
    
    done_check: process(clk_port, midi_data, last_data)
    begin
        if rising_edge(clk_port) then
            if midi_data = last_data or not(midi_data(23 downto 20) = "1000" or midi_data(23 downto 20) = "1001") then
                new_note_done <= '0';
            else
                new_note_done <= '1';
            end if;
            last_data <= midi_data;
        end if;
    end process done_check;

    note_on_port <= note_on;
    channel_port <= midi_chnl;
    note_id_port <= note_id;
    velocity_port <= note_vel;
    p_bend_port <= pitch_offset;
    trigger_out <= new_note_done; 
end architecture behavior;