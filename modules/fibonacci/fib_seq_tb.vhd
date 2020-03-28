--! Standard signal package
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity fib_seq_tb is
end fib_seq_tb; 

--! @brief 
architecture test of fib_seq_tb is

	--! DUT component declaration
	component fib_seq
	generic(
		gen_sequence_length : integer := 10;
		gen_output_length : integer := 16);
	port(
		rst : in std_logic;
		clk : in std_logic;
		fib_out : out unsigned(gen_output_length-1 downto 0);
		seq_over : out std_logic);
	end component;

	--! Constant declaration
	constant c_clk_period : time := 200 ns;
	constant c_sequence_length : integer := 10;
	constant c_output_length : integer := 16;

	--! Signals declaration
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';
	signal seq_over : std_logic;
	signal fib_out : unsigned(c_output_length-1 downto 0);

begin
	--! D.U.T. instatiation
	inst_dut : fib_seq 
				generic map(
					gen_sequence_length => c_sequence_length,
					gen_output_length => c_output_length)					
				port map(
					rst => rst,
					clk => clk,
					fib_out => fib_out,
					seq_over => seq_over);


	--============================================
	--! Reset instatiation
	p_reset: process
	begin
	  rst <='1';
	  wait for c_clk_period*2;
	  rst <= '0';  
	  wait;
	end process;

	--============================================
	--! Clock instatiation
	p_clock: process
	begin
	  wait for c_clk_period;
	  clk <= not clk;
	end process;


	--! Main instatiation
	p_main : process begin
		wait until seq_over = '1';
		assert (fib_out > to_unsigned(0,c_output_length)) report "Simulation failed.";
	end process;

end test;