library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--! 
package mult_common_pkg is

	type t_array_3_s8 is array (0 to 2) of signed(7 downto 0);
	type t_array_3_s16 is array (0 to 2) of signed(15 downto 0);
	type t_matrix_3_3_s16 is array (0 to 2) of t_array_3_s16;
	type t_array_3_s32 is array (0 to 2) of signed(31 downto 0);
	type t_matrix_3_3_s32 is array (0 to 2) of t_array_3_s32;

--! TODO!!!
-- type INT_ARRAY is array (integer range <>) of integer;
-- variable INT_TABLE: INT_ARRAY(0 to 9);

	function shift_right_signed (x : signed; len : integer; n : integer)
                   return signed;

--	function simple_lfsr (i_bit : bit; i_vec : std_logic_vector; len : integer)
 --                  return std_logic_vector;

end package mult_common_pkg;

--!
package body mult_common_pkg is

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


end package body mult_common_pkg;