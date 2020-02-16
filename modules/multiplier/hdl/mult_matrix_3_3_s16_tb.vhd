library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.mult_common_pkg.all;

entity mult_matrix_3_3_s16_tb is
end; 

architecture rtl of mult_matrix_3_3_s16_tb is
  
    constant c_1 : signed(15 downto 0) := to_signed(1, 16);
    constant c_2 : signed(15 downto 0) := to_signed(2, 16);
    constant c_3 : signed(15 downto 0) := to_signed(3, 16);
    constant c_4 : signed(15 downto 0) := to_signed(4, 16);
    constant c_5 : signed(15 downto 0) := to_signed(5, 16);

    --! clk
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';

    --! DUT glue logic
    signal r_start : std_logic := '0';
    signal r_valid : std_logic;

    signal r_m_in_1 : t_matrix_3_3_s16 := ((c_1,c_1,c_1), (c_2,c_2,c_2), (c_3,c_3,c_3));
    signal r_m_in_2 : t_matrix_3_3_s16 := ((c_3,c_3,c_3), (c_2,c_2,c_2), (c_1,c_1,c_1));
    signal r_m_out : t_matrix_3_3_s32;

    --! debug only..
    signal r_o_row_0_0 : signed(31 downto 0);
    signal r_o_row_0_1 : signed(31 downto 0);
    signal r_o_row_0_2 : signed(31 downto 0);
    signal r_o_row_1_0 : signed(31 downto 0);
    signal r_o_row_1_1 : signed(31 downto 0);
    signal r_o_row_1_2 : signed(31 downto 0);
    signal r_o_row_2_0 : signed(31 downto 0);
    signal r_o_row_2_1 : signed(31 downto 0);
    signal r_o_row_2_2 : signed(31 downto 0);    


begin

    --! Instatiation DUT
    --inst_cordic : entity work.cordic_rot(rtl)
    --port map(
    --  clk => clk,
    --  rst => rst,
    --  sync => r_start,
    --  angle => r_theta,
    --  x_out => r_x_out,
    --  y_out => r_y_out,
    --  valid => r_valid);
    inst_dut : entity work.mult_matrix_3_3_s16(rtl)
    port map( 
        clk => clk,
        reset => rst,
        start => r_start,
        m_in_1 => r_m_in_1,
        m_in_2 => r_m_in_2,
        m_out => r_m_out,
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
	    r_start <= '1';
	    wait until clk='1';
	    r_start <= '0';

		wait until r_valid='1';
		wait until clk='1';
		wait until clk='0';
		r_m_in_1 <= ((c_2,c_2,c_2), (c_2,c_2,c_2), (c_2,c_2,c_2));
		r_m_in_2 <= ((c_1,c_1,c_1), (c_1,c_1,c_1), (c_1,c_1,c_1));
	    r_start <= '1';
	    wait until clk='1';
	    r_start <= '0';


		wait until r_valid='1';
		wait until clk='1';
		wait until clk='0';
		r_m_in_1 <= ((c_2,c_2,c_2), (c_2,c_2,c_2), (c_2,c_2,c_2));
		r_m_in_2 <= ((-c_1,-c_1,-c_1), (-c_1,-c_1,-c_1), (-c_1,-c_1,-c_1));
	    r_start <= '1';
	    wait until clk='1';
	    r_start <= '0';


	    wait;
	end process;

	r_o_row_0_0 <= r_m_out(0)(0);
	r_o_row_0_1 <= r_m_out(0)(1);
	r_o_row_0_2 <= r_m_out(0)(2);

	r_o_row_1_0 <= r_m_out(1)(0);
	r_o_row_1_1 <= r_m_out(1)(1);
	r_o_row_1_2 <= r_m_out(1)(2);

	r_o_row_2_0 <= r_m_out(2)(0);
	r_o_row_2_1 <= r_m_out(2)(1);
	r_o_row_2_2 <= r_m_out(2)(2);
end rtl;
