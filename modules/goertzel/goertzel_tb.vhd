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
	  wait for 40 ns;
	  clk <= not clk;
	end process;

	--============================================
	
	p_theta : process
	begin
	    -- 0
	    wait until rst='0';
	    r_start <= '0';
	    r_theta <= to_unsigned(0,16);
	    r_start <= '1';
	    wait until clk='1';
	    r_start <= '0';
	    wait for 4 us;

	    -- pi/2
	    r_theta <= to_unsigned(16382,16);
	   	r_start <= '1';
	    wait until clk='1';
	    r_start <= '0';
	    wait for 4 us;
	    
	    -- pi
	    -- pi/2
	    r_theta <= to_unsigned(16389,16);
	   	r_start <= '1';
	    wait until clk='1';
	    r_start <= '0';
	    wait for 4 us;
	    -- pi
	    r_theta <= to_unsigned(32769,16);
	    r_start <= '1';
	    wait until clk='1';
	    wait until clk='0';
	    r_start <= '0';
	    wait for 4 us;
	    -- 3pi/2
	    r_theta <= to_unsigned(49157,16);
	    r_start <= '1';
	    wait until clk='1';
	    r_start <= '0';
	    wait for 4 us;
	    --2pi
	    r_theta <= to_unsigned(65534,16);
	    r_start <= '1';
	    wait until clk='1';
	    r_start <= '0';
	    wait;
	end process;
end rtl;
