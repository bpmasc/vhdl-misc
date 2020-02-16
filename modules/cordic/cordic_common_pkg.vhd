library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--! 
package cordic_common_pkg is
  
	function shift_right_signed (x : signed; len : integer; n : integer)
                   return signed;

--	function simple_lfsr (i_bit : bit; i_vec : std_logic_vector; len : integer)
 --                  return std_logic_vector;

end package cordic_common_pkg;

--!
package body cordic_common_pkg is

	--! Shift right of a signed number
	function shift_right_signed (x : signed; len : integer; n : integer)
				return signed is
		variable r_x : signed(len+n-1 downto 0);
	begin
    	r_x := resize(x, len + n);
    	return r_x(r_x'LEFT downto n);
	end shift_right_signed;

	--! Simple LFSR implementation
	--function simple_lfsr (i_bit : bit; i_vec : std_logic_vector; len : integer)
    --               return std_logic_vector is
	--	variable r_v : std_logic_vector(len-1 downto 0);
--	begin
 --   	r_v := i_vec;
 --   	return r_v(r_v'LEFT downto r_v'RIGHT + 1) & i_bit;
--	end simple_lfsr;


end package body cordic_common_pkg;