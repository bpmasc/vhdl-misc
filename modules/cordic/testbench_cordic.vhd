library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.cordic_common_pkg.all;

entity testbench_cordic is
 
end; 

architecture rtl of testbench_cordic is
  
    --! clk
    signal clk: std_logic   := '0';
    signal reset: std_logic := '1';
    signal rstn : std_logic := '0';
    --! cordic
    signal r_theta : signed(15 downto 0) := to_signed(0,16);
    signal r_x_out : signed(15 downto 0);
    signal r_y_out : signed(15 downto 0);
    signal r_start : std_logic := '0';
    signal r_valid : std_logic := '0';
    signal r_sin : signed(15 downto 0);
    signal r_cos : signed(15 downto 0);
    signal r_valid_maxime : std_logic; 
begin

  rstn <= not reset;
    
    -- New parspi version
    inst_cordic : entity work.rotational_cordic(rtl)
    port map(
      clk => clk,
      rstn => rstn,
      sync => r_start,
      theta => r_theta,
      x_out => r_x_out,
      y_out => r_y_out,
      valid => r_valid
      );

    -- New parspi version
    inst_cordic_maxime : entity work.cordic_cos(rtl)
    port map(
      clk => clk,
      rstn => rstn,      
      start => r_start,
      angle => r_theta,
      cos => r_cos,
      sin => r_sin,
      valid => r_valid_maxime
      );



--============================================
p_clock: process
begin
  wait for 40 ns;
  clk <= not clk;  
  
end process;

--============================================
p_start_cordic: process
begin
  
  
    r_start <= '0';
    wait until clk='1' and reset = '0';
    --wait until r_valid='0';
    --wait until rstn = '1';
    r_start <= '1';
    --r_theta <= r_theta + 1;
    wait until clk='1';
    r_start <= '0';
    wait until r_valid='1';
    
    
    --wait for 200 ns;
end process;

p_theta : process
begin
    -- 0
    r_theta <= to_signed(0,16);
    wait for 200 us;
    -- pi/2
    r_theta <= to_signed(16384,16);
    wait for 200 us;
    -- pi
    r_theta <= to_signed(32766,16);
    wait for 200 us;
    -- 3pi/2
    r_theta <= to_signed(49152,16);
    wait for 200 us;
    --2pi
    r_theta <= to_signed(65534,16);
    wait;
end process;

--============================================
p_reset: process
begin
  reset <='1';
  wait for 100 ns;
  reset <= '0';  
  wait;
end process;





end rtl;






