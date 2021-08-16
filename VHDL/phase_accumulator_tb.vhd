----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/15/2021 12:30:23 PM
-- Design Name: 
-- Module Name: phase_accumulator_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity phase_accumulator_tb is
end phase_accumulator_tb;

architecture Behavioral of phase_accumulator_tb is
component phase_accumulator is
    port (
        -- input ports
        clk_in_port:        in   std_logic;
        midi_data_in_port:  in   std_logic_vector(7 downto 0);
        
        -- output ports
        sine_addr_out_port: out std_logic_vector(13 downto 0)
    );
end component;
begin


end Behavioral;
