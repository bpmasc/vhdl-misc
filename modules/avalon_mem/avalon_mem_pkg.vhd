library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--! 
package avalon_mem_pkg is
  
	type t_mem_array is array(natural range <>) of std_logic_vector(7 downto 0);
	--!  
	constant AVALON_MEM_WRITE_ADDRESS : std_logic_vector(28 downto 0) := std_logic_vector(to_unsigned(1,29)); -- get base addr from pkg
	--! 
	constant AVALON_MEM_READ_ADDRESS : std_logic_vector(29 downto 0) := std_logic_vector(to_unsigned(1,30)); -- get base addr from pkg
	--!  
	constant AVALON_MEM_BURSTCOUNT : std_logic_vector(7 downto 0) := "00000010";

end package avalon_mem_pkg;
