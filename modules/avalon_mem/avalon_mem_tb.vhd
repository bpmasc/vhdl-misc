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
    signal r_data_in_0 :std_logic_vector(31 downto 0) := (others => '1');
    signal r_data_in_1 :std_logic_vector(31 downto 0) := (others => '0');
    signal r_data_in_2 :std_logic_vector(31 downto 0) := (others => '1');
    signal r_data_in_3 :std_logic_vector(31 downto 0) := (others => '0');
    signal r_data_in_0_out :std_logic_vector(31 downto 0);
    signal r_data_in_1_out :std_logic_vector(31 downto 0);
    signal r_data_in_2_out :std_logic_vector(31 downto 0);
    signal r_data_in_3_out :std_logic_vector(31 downto 0);
    signal r_f2h_sdram_address : std_logic_vector(28 downto 0) := (others=>'0');    -- address
    signal r_f2h_sdram_address1 : std_logic_vector(29 downto 0) := (others=>'0');    -- address
    signal r_f2h_sdram_burstcount : std_logic_vector(7 downto 0); -- burstcount
    signal r_f2h_sdram1_burstcount : std_logic_vector(7 downto 0); -- burstcount
    signal r_f2h_sdram_waitrequest :std_logic;                                        -- waitrequest
    signal r_f2h_sdram_writedata : std_logic_vector(63 downto 0);  -- writedata
    signal r_f2h_sdram_byteenable : std_logic_vector(7 downto 0); -- byteenable
    signal r_f2h_sdram_write : std_logic;
    signal r_valid_write : std_logic;
	signal r_f2h_sdram1_waitrequest : std_logic;
	signal r_f2h_sdram_readdata : std_logic_vector(31 downto 0);
	signal r_f2h_sdram_readdatavalid : std_logic;
	signal r_f2h_sdram_read :  std_logic;
    signal r_valid_read :  std_logic;



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
	  wait for 20 ns;
	  clk <= not clk;
	end process;
	--============================================
	--! DUT 1
	inst_write_64 : entity work.avalon_mem_write_64
	port map(
    	reset => rst,
    	clk => clk,
    	start => r_start,
    	--data_in : in t_mem_array(2**sel_width - 1 downto 0)(bus_width - 1 downto 0);
    	data_in_0 => r_data_in_0,
    	data_in_1 => r_data_in_1,
    	data_in_2 => r_data_in_2,
    	data_in_3 => r_data_in_3,
    	f2h_sdram_address => r_f2h_sdram_address,    -- address
    	f2h_sdram_burstcount => r_f2h_sdram_burstcount, -- burstcount
    	f2h_sdram_waitrequest => r_f2h_sdram_waitrequest,                                        -- waitrequest
    	f2h_sdram_writedata => r_f2h_sdram_writedata,  -- writedata
    	f2h_sdram_byteenable => r_f2h_sdram_byteenable,
    	f2h_sdram_write => r_f2h_sdram_write,
    	valid => r_valid_write);
	--============================================
	--! DUT 1
	--inst_read32 : entity work.avalon_mem_read_32
	--port map(
    --	reset => rst,
    --	clk => clk,
    --	start => r_valid_write,
    --	--data_in : out t_mem_array(2**sel_width - 1 downto 0)(bus_width - 1 downto 0);
    --	data_in_0 => r_data_in_0_out,
    --	data_in_1 => r_data_in_1_out,
    --	data_in_2 => r_data_in_2_out,
    --	data_in_3 => r_data_in_3_out,
	--	f2h_sdram_address => r_f2h_sdram_address1,
	--	f2h_sdram_burstcount => r_f2h_sdram1_burstcount,
	--	f2h_sdram_waitrequest => r_f2h_sdram1_waitrequest,
	--	f2h_sdram_readdata => r_f2h_sdram_readdata,
	--	f2h_sdram_readdatavalid => r_f2h_sdram_readdatavalid,
	--	f2h_sdram_read => r_f2h_sdram_read,
    --	valid => r_valid_read);
	--============================================
	p_main : process
	begin
		r_f2h_sdram_waitrequest <='0';
		r_f2h_sdram1_waitrequest <= '0';
		r_start<= '0';
	    wait for 200 ns;
	    r_start<= '1';
	    wait for 50 ns;
	    r_start<= '0';
	    wait;
	end process;
end rtl;
