library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! 
package cordic_common_pkg is
  function shift_right_signed (x : signed; l : integer; n : integer)
                   return signed;
end package cordic_common_pkg;

--!
package body cordic_common_pkg is


	function shift_right_signed (x : signed; l : integer; n : integer)
                   return signed is
		variable r_x : signed(l+n-1 downto 0);
	begin
    	r_x := resize(x, l + n);
    	return r_x(r_x'LEFT downto n);
	end shift_right_signed;

end package body cordic_common_pkg;