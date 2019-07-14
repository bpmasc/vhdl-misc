library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cordic_common_pkg.all;

entity srs_tb is
end; 

architecture rtl of srs_tb is
  
    --! clk
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';

    --! test shift_right_signed
    signal r_x_out : signed(15 downto 0);
    signal r_y_out : signed(15 downto 0);

begin

      
	--============================================
	p_rst: process
	begin
	  rst <= '1';
	  wait for 100 ns;
	  rst <= '0';  
	  wait;
	end process;

	--============================================
	p_clock: process
	begin
	  wait for 40 ns;
	  clk <= not clk;
	end process;


	p_main : process
	begin
	    r_x_out <= to_signed(0,16);
	    r_y_out <= to_signed(0,16);
	    wait for 4 us;
	    -- 0
	    r_x_out <= to_signed(15,16);
	    wait for 1 us;
	    r_y_out <= shift_right_signed(r_x_out, r_x_out'length, 1);
	    wait for 4 us;
	    
	    r_x_out <= to_signed(-31,16);
	    wait for 1 us;
	    --r_y_out <= shift_right_signed(r_x_out, r_x_out'length, 1);
	    r_y_out <= r_y_out - shift_right_signed(r_x_out, r_x_out'length, 1);
	    wait;
	end process;
end rtl;
