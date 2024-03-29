library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.avalon_mem_pkg.all;

entity avalon_mem_tb is
end; 

architecture rtl of avalon_mem_tb is
    --! clk
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';
	signal r_start : std_logic;
    signal r_f2h_sdram_address : std_logic_vector(28 downto 0) := (others=>'0');    -- address
    signal r_f2h_sdram_address1 : std_logic_vector(29 downto 0) := (others=>'0');    -- address
    signal r_f2h_sdram_burstcount : std_logic_vector(7 downto 0);
    signal r_f2h_sdram1_burstcount : std_logic_vector(7 downto 0);
    signal r_f2h_sdram_waitrequest :std_logic;
    signal r_f2h_sdram_writedata : std_logic_vector(63 downto 0);
    signal r_f2h_sdram_byteenable : std_logic_vector(7 downto 0); -- byteenable
    signal r_f2h_sdram_write : std_logic;
    signal r_valid_write : std_logic;
	signal r_f2h_sdram1_waitrequest : std_logic;
	signal r_f2h_sdram_readdata : std_logic_vector(31 downto 0);
	signal r_f2h_sdram_readdatavalid : std_logic;
	signal r_f2h_sdram_read :  std_logic;
    signal r_valid_read :  std_logic;
	signal r_data_in : t_mem_array := (others=>(others=>'0'));
	signal r_data_out : t_mem_array;
	signal r_line : t_line_array;
	signal r_start_read : std_logic;
begin
	--============================================

	--============================================
	p_rst: process
	begin
	  rst <= '1';
	  wait for 100 ns;
	  rst <= '0';  
	  wait;
	end process;
	--============================================

	--============================================
	p_clock: process
	begin
	  wait for 20 ns;
	  clk <= not clk;
	end process;
	--============================================
	--! DUT 1
	--=============================================
	inst_write_64 : entity work.avalon_mem_write_64
	port map(
    	reset => rst,
    	clk => clk,
    	start => r_start,
    	data_in => r_data_in,
    	f2h_sdram_address => r_f2h_sdram_address,
    	f2h_sdram_burstcount => r_f2h_sdram_burstcount,
    	f2h_sdram_waitrequest => r_f2h_sdram_waitrequest,
    	f2h_sdram_writedata => 	r_f2h_sdram_writedata,
    	f2h_sdram_byteenable => r_f2h_sdram_byteenable,
    	f2h_sdram_write => r_f2h_sdram_write,
    	valid => r_valid_write);
	--=============================================
	--! DUT 1
	--=============================================
	inst_read32 : entity work.avalon_mem_read_32
	port map(
    	reset => rst,
    	clk => clk,
    	start => r_start_read,
    	data_out => r_data_out,
    	--! SDRAM If
		f2h_sdram_address => r_f2h_sdram_address1,
		f2h_sdram_burstcount => r_f2h_sdram1_burstcount,
		f2h_sdram_waitrequest => r_f2h_sdram1_waitrequest,
		f2h_sdram_readdata => r_f2h_sdram_readdata,
		f2h_sdram_readdatavalid => r_f2h_sdram_readdatavalid,
		f2h_sdram_read => r_f2h_sdram_read,
    	valid => r_valid_read);
	--============================================
	--!	
	--=============================================
	p_main : process
	begin
		r_f2h_sdram_waitrequest <='0';
		r_f2h_sdram1_waitrequest <= '0';
		r_data_in(1) <= (others=>'1');
		r_data_in(3) <= (others=>'1');
		r_data_in(5) <= (others=>'1');
		r_start<= '0';
	    wait for 200 ns;
	    r_start<= '1';
	    wait for 50 ns;
	    r_start<= '0';
	    wait;
	end process;
	--============================================
	--!	
	--=============================================
end rtl;