--! TODO description
library ieee;
--! TODO description
use ieee.numeric_std.all;
--! TODO description
use ieee.std_logic_1164.all;

package spi_3x_utils_pkg is

    --function function_name (parameters) return type;
    type t_array12 is array (3 downto 0) of std_logic_vector(11 downto 0);
    type t_array12_4 is array (integer range <>) of t_array12;  

    constant c_adc_t_en : time := 20 ns;
    --! Assuming Fclk=10MHz -> t_sck = 0.5 * Fclk
    constant c_adc_t_sck: time := 50 ns;

end spi_3x_utils_pkg;

package body spi_3x_utils_pkg is
  
  --function function_name (parameters) return type is
  --  declarations
  -- begin
  --   sequential statements
  --end function function_name;

end spi_3x_utils_pkg;
