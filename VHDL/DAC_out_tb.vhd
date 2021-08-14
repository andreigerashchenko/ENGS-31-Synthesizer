--=============================================================
--Ben Dobbins
--CS56/ENGS31 21S
--This script is the testbench code for Lab 4, the voltmeter.
--=============================================================
--=============================================================
--Library Declarations
--=============================================================
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

 --=============================================================
--Testbench Entity Declaration
--=============================================================
ENTITY DAC_out_tb IS
END DAC_out_tb;

--=============================================================
--Testbench declarations
--=============================================================
ARCHITECTURE testbench OF DAC_out_tb IS 

component clk_wiz_0
	port
	 (-- Clock in ports
	  -- Clock out ports
	  clk_4800khz          	: out    std_logic;
	  -- Status and control signals
	  locked            	: out    std_logic;
	  clk_100mhz           	: in     std_logic
	 );
end component;

component DAC_out is
	generic(
		N_BITS			: integer);
	port(
		clk_in_port			: in  std_logic;	--Slower clock
		clk_out_port		: out std_logic;
		
		data_in_port		: in  std_logic_vector(11 downto 0);
		dac_trigger			: in  std_logic;	--datapath signals
		
		data_out_port		: out std_logic;
		cs_out_port			: out std_logic);
end component;

--=============================================================
--Local Signal Declaration
--=============================================================
-- Clock period definitions
constant clk_period : time := 10ns;		-- 100 MHz clock

signal clk_100MHz : std_logic := '0';
signal clk_divided : std_logic := '0';
signal clk_passthrough: std_logic := '0';
signal dac_trigger : std_logic := '0';
signal cs_out:	std_logic := '0';
signal bit_out:	std_logic := '0';
signal locked:  std_logic := '0';
signal clk_count : unsigned(15 downto 0) := (others => '0');
signal count_reset: std_logic := '1';
signal pulse_sent: std_logic := '0';

-- Data definitions
constant TxData : std_logic_vector(11 downto 0) := "100110111011";
signal bit_count : integer := 12;
	
BEGIN 

-- Instantiate the Unit Under Test (UUT) 
uut: DAC_out
generic map(
	N_BITS => 16)
port map(
	clk_in_port			=> clk_divided,
	clk_out_port		=> clk_passthrough,
	data_in_port		=> TxData,
	dac_trigger			=> dac_trigger,
	data_out_port		=> bit_out,
	cs_out_port			=> cs_out);  	

-- clocking: system_clock_generator 
-- generic map(
-- 	CLOCK_DIVIDER_RATIO => 100)
-- port map(
-- 	ext_clk_iport 		=> clk_100MHz,
-- 	system_clk_oport 	=> clk_1MHz,
-- 	fwd_clk_oport		=> spi_sclk);

 clocking: clk_wiz_0
	port map ( 
   -- Clock out ports  
	clk_4800khz => clk_divided,
   -- Status and control signals                
	locked => locked,
	-- Clock in ports
	clk_100mhz => clk_100MHz
  );	

--=============================================================
--Timing:
--=============================================================		      
-- Clock process definitions
clk_process :process
begin
    clk_100MHz <= '0';
    wait for clk_period/2;
    clk_100MHz <= '1';
    wait for clk_period/2;
end process;

--=============================================================
--Cycle Counter:
--=============================================================
cycle_counter: process(clk_divided)
begin
	if rising_edge(clk_divided) then
		if count_reset = '0' then
			clk_count <= clk_count + 1;
		else
			clk_count <= (others => '0');
		end if;
	end if;
end process cycle_counter;

--=============================================================
--Stimulus Process:
--=============================================================		
stim_proc: process(clk_count)
begin
	if pulse_sent = '0' then
		count_reset <= '0';

		
		if clk_count = x"20" then
			dac_trigger <= '1';
		end if;
		if clk_count = x"21" then
			dac_trigger <= '0';
			pulse_sent <= '1';
		end if;
	end if;
end process;
END;