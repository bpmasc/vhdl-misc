library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_rot_tb is
end; 

architecture rtl of cordic_rot_tb is
  
    --! clk
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';

    --! cordic
    signal r_theta : unsigned(15 downto 0) := to_unsigned(0,16);
    signal r_x_out : signed(15 downto 0);
    signal r_y_out : signed(15 downto 0);
    signal r_start : std_logic := '0';
    signal r_valid : std_logic;
    signal r_x_small : signed(11 downto 0);
    signal r_y_small : signed(11 downto 0);
begin

    --! Instatiation DUT
    inst_cordic : entity work.cordic_rot(rtl)
    port map(
      clk => clk,
      rst => rst,
      sync => r_start,
      angle => r_theta,
      x_out => r_x_out,
      y_out => r_y_out,
      valid => r_valid);
      
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
	  wait for 20 ns;
	  clk <= not clk;
	end process;

	--============================================
	
	p_theta : process
	begin
	    -- 0
	    --wait until rst='0';
	    r_start <= '0';
	    r_theta <= r_theta + to_unsigned(32,16);--to_unsigned(32767,16); --90
	    r_start <= '1';
	    wait until clk='1' and rst='0';
	    r_start <= '0';
	    --! Falling edge from fvalid
	    wait until r_valid='1';
	    wait until r_valid='0';
	    r_start <= '0';

	end process;


	--" hard logic
	r_x_small <= r_x_out(15 downto 4);
	r_y_small <= r_y_out(15 downto 4);

end rtl;
