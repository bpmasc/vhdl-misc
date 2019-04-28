--! Standard IEEE libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @Author Manuel Mascarenhas
--! @Description

entity fib_seq is
	generic(
		gen_sequence_length : integer := 10;
		gen_output_length : integer := 16);
	port(
		rst : in std_logic;
		clk : in std_logic;
		fib_out : out unsigned(gen_output_length-1 downto 0);
		seq_over : out std_logic);
end fib_seq;

--! @brief Fibonacci sequence, such that each number is the sum of the two preceding ones.
--! 	   Assumptions:
--! 		   + Initial values are 0 and 1
architecture rtl of fib_seq is	
	--! Constants declaration
	constant c_max_value : integer := 2**gen_output_length-1;
	--! Signals declaration
	signal r_fib_1 : unsigned(gen_output_length-1 downto 0);
	signal r_fib_2 : unsigned(gen_output_length-1 downto 0);
	signal r_fib_next : unsigned(gen_output_length-1 downto 0);
	signal r_cnt : integer;

begin

	--! assert
	assert gen_sequence_length < 12 report "[Error] Sequence length invalid." severity error;
	assert gen_output_length < 17 report "[Error] Output length invalid." severity error;

	r_fib_next <= r_fib_1 + r_fib_2;

	--! main sequence
	p_fib_seq : process(rst, clk)
	begin
		if rst = '1' then
			r_fib_2 <= to_unsigned(0, gen_output_length);
			r_fib_1 <= to_unsigned(1, gen_output_length);
			fib_out <= to_unsigned(0, gen_output_length);
			seq_over <= '0';
			r_cnt <= 0;
		elsif rising_edge(clk) then
			seq_over <= '0';
			if r_cnt < gen_sequence_length-1 then
				r_fib_2 <= r_fib_1;
				r_fib_1 <= r_fib_next;
				r_cnt <= r_cnt + 1;
			else
				seq_over <= '1';
				fib_out <= r_fib_next;
				r_cnt <= 0;
			end if;
		end if;
	end process;

end rtl;

