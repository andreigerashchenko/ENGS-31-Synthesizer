library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity volume_control is
    port (
        -- input ports
        clk_in_port: in std_logic;
        original_sine: in std_logic_vector(15 downto 0);
        note_velocity_port: in std_logic_vector(7 downto 0);
        -- output ports
        modified_sine: out std_logic_vector(15 downto 0)
    );
end entity volume_control;

architecture behavior of volume_control is
    constant max_velocity: unsigned(7 downto 0) := "00100000";
    type state_type is (idle, shift, loading);
    signal curr_state, next_state: state_type;
    signal done_dec: std_logic := '0';
    signal left_shift: std_logic := '0';
    signal load_en: std_logic := '0';
    signal load_sine: std_logic := '0';
    signal dec_sine: signed(15 downto 0) := (others => '0');
    signal count_shifts: unsigned(7 downto 0) := (others => '0');
    signal count_reset : std_logic := '0';
    
    
begin
    --==========================================
    -- Decrease volume
    --==========================================
    dec_volume: process(clk_in_port, dec_sine)
    begin
        if rising_edge(clk_in_port) then
            if load_en = '1' then 
                modified_sine <= std_logic_vector(dec_sine);
            else
                modified_sine <= (others => '0');
            end if;
        end if;
    end process dec_volume;
    
    shifting: process(clk_in_port, count_shifts, note_velocity_port)
    begin
        if rising_edge(clk_in_port) then
            if load_sine = '1' then 
                dec_sine <= signed(original_sine);
            else 
                if count_reset = '1' then 
                    count_shifts <= (others => '0');
                else  
                    if left_shift = '1' then 
                        count_shifts <= count_shifts + 1;
                        dec_sine <= dec_sine/2;
                    end if;
                end if;
            end if;
            
        end if;
        
        if (unsigned(note_velocity_port) < max_velocity) then
            if (count_shifts >= (max_velocity - unsigned(note_velocity_port))) then
                done_dec <= '1';
            else 
                done_dec <= '0';
            end if;
        else
            done_dec <= '1';
        end if;
    end process shifting;
    
    FSM_comb: process(curr_state, done_dec) 
    begin
        next_state <= curr_state;
        count_reset <= '1';
        left_shift <= '0';
        load_en <= '0';
        load_sine <= '0';
        
        case curr_state is 
            when idle => 
            load_sine <= '1';
            next_state <= shift;
            
            when shift => 
                left_shift <= '1';
                count_reset <= '0';
                if done_dec = '1' then
                    next_state <= loading;
                else 
                    next_state <= shift;
                end if;
            when loading => 
                load_en <= '1';
                next_state <= idle;
            end case;
   end process FSM_comb;
   
   FSM_update: process(clk_in_port)
   begin
    if rising_edge(clk_in_port) then 
        curr_state <= next_state;
    end if;
   end process FSM_update;
   
            
    
    
end behavior;
    
    

