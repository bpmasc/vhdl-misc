--! Standard signal package
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
library work;
use work.spi_3x_utils_pkg.all;


entity spi_3x_master_tb is
end spi_3x_master_tb; 

--! @brief 
architecture test of spi_3x_master_tb is

	--! Constant declaration
	constant c_clk_period : time := 20 ns;

	--! Signals declaration
    signal clk 			: std_logic := '0';
    signal reset 		: std_logic := '1';
    signal r_start		: std_logic;
    signal r_data_out	: t_array12_4(0 downto 0);
    signal r_spi_miso 	: std_logic_vector(0 downto 0);
	signal r_spi_sclk 	: std_logic;
	signal r_valid 		: std_logic;
	signal r_spi_mosi 	: std_logic;
	signal r_do_a 	: std_logic_vector(11 downto 0);
	signal r_do_b 	: std_logic_vector(11 downto 0);
	signal r_do_c 	: std_logic_vector(11 downto 0);
	signal r_do_d 	: std_logic_vector(11 downto 0);
		


begin
	--! D.U.T. instatiation
	inst_dut : entity work.spi_3x_master(rtl)
		port map(
			rst => reset,
			clk => clk,
			start => r_start,
        	data_in => r_data_in,
        	data_out => r_data_out,
			spi_miso => (others => '1'),
			spi_sclk => r_spi_sclk,
			spi_mosi => r_spi_mosi,
			valid => r_valid);

	--============================================
	--! Reset instatiation
	p_reset: process
	begin
	  reset <='1';
	  wait for c_clk_period * 2;
	  reset <= '0';
	  wait;
	end process;

	p_start: process
	begin
		r_start <= '0';
		--wait until r_valid = '1';
		wait for 4*c_clk_period ;
		r_start <= '1';
		wait for 2*c_clk_period;
		r_start <= '0';
		wait until r_valid= '1';
		wait for 20*c_clk_period ;
		r_start <= '1';
		wait for 2*c_clk_period;
		r_start <= '0';
		wait;
	end process;

	--============================================
	--! Clock instatiation
	p_clock: process
	begin
	  wait for c_clk_period/2;
	  clk <= not clk;
	end process;

	r_do_a <= r_data_out(0)(0);
	r_do_b <= r_data_out(0)(1);
	r_do_c <= r_data_out(0)(2);
	r_do_d <= r_data_out(0)(3);

end test;/