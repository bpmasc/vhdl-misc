library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--! 
package avalon_mem_pkg is
  
	--!  
	constant AVALON_MEM_WRITE_ADDRESS : std_logic_vector(28 downto 0) := std_logic_vector(to_unsigned(1,29)); -- get base addr from pkg
	--! 
	constant AVALON_MEM_READ_ADDRESS : std_logic_vector(29 downto 0) := std_logic_vector(to_unsigned(1,30)); -- get base addr from pkg
	--!  
	constant AVALON_MEM_BURSTCOUNT : integer := 128;
	--!  
	constant AVALON_MEM_N_BURST : integer := 10;
	--! Assuming 1920 x 1080
	--!		A line needs 10 bursts of 128 (Max burst count is 128). Check docu 
	type t_mem_array is array(AVALON_MEM_BURSTCOUNT-1 downto 0) of std_logic_vector(31 downto 0);
	type t_line_array is array(AVALON_MEM_N_BURST-1 downto 0) of t_mem_array;
end package avalon_mem_pkg;
