library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity goertzel_tb is
end; 

architecture rtl of goertzel_tb is
  
    --! clk
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';

    --! goertzel
    signal r_x_in : signed(15 downto 0) := to_signed(0,16);
    signal r_y_out : signed(15 downto 0);
    signal r_start : std_logic := '0';
    signal r_valid : std_logic;

begin

    --! Instatiation DUT
    inst_dut_goertzel : entity work.basic_goertzel(rtl)
    port map(
      clk => clk,
      rst => rst,
      sync => r_start,
      x_in => r_x_in,
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
	    r_x_in <= to_signed(0,16);
	    r_start <= '1';
	    wait until clk='1';
	    r_start <= '0';
	    wait for 4 us;

	    -- pi/2
	    r_x_in <= to_signed(16382,16);
	   	r_start <= '1';
	    wait until clk='1';
	    r_start <= '0';
	    wait for 4 us;
	    
	    -- pi
	    -- pi/2
	    r_x_in <= to_signed(16389,16);
	   	r_start <= '1';
	    wait until clk='1';
	    r_start <= '0';
	    wait for 4 us;
	    -- pi
	    r_x_in <= to_signed(1234,16);
	    r_start <= '1';
	    wait until clk='1';
	    wait until clk='0';
	    r_start <= '0';
	    wait for 4 us;
	    -- 3pi/2
	    r_x_in <= to_signed(19157,16);
	    r_start <= '1';
	    wait until clk='1';
	    r_start <= '0';
	    wait for 4 us;
	    --2pi
	    r_x_in <= to_signed(435,16);
	    r_start <= '1';
	    wait until clk='1';
	    r_start <= '0';
	    wait;
	end process;
end rtl;
