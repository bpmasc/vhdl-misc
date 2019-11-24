--! Standard IEEE library and packages
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;                  

--! Auxiliary package
  use work.cordic_common_pkg.all;


--! @author Manuel Mascarenhas
--! @brief
entity cordic_vec is
    generic (
      gen_iterations : integer := 16;
      gen_size : integer := 16
    );
    port( 
      clk : in  std_logic;
      rst : in  std_logic;
      sync : in std_logic;
      x_in : in signed(gen_size-1 downto 0); -- [0=0, 2*16=2*Pi]
      y_in : in signed(gen_size-1 downto 0); -- [0=0, 2*16=2*Pi]
      x_out : out signed(gen_size-1 downto 0);
      y_out : out signed(gen_size-1 downto 0);
      valid : out std_logic);      
end cordic_vec;

    --! Xr = Xin x cos(theta) - Yin x sen(theta)
    --! Yr = Xin x sen(theta) + Yin x cos(theta)
    --! 
    --! Xin = 1; Yin = 0 ======>  Xr = cos(theta) ; Yr = sen(theta)
    --!
    --! tan(theta) = sen(theta) / cos(theta)
    --!
    --! Xr = Xin x cos(theta) - Yin x cos(theta) x tan(theta)
    --! Yr = Xin x cos(theta) x tan(theta) + Yin x cos(theta)
    --! tan(theta_i) = 2exp(-i)

    --! theta_i = arctan(2exp(-i))
    --! d_i 
    --! Iteration (i)  //    d_i   //    X_i   //     Y_i   //      Z_i  
    --!     -                 -           1            0            

architecture rtl of cordic_vec  is
    -- signals
    --signal r_cnt : integer  range 0 to 100;
    type t_cordic_state is (IDLE, RUN, DONE );
    signal r_state : t_cordic_state;
    type int16_array_t is array(0 to gen_size-1) of signed(gen_size-1 downto 0);
    signal r_X : signed(gen_size-1 downto 0);
    signal r_Y : signed(gen_size-1 downto 0);
    signal r_Z : signed(gen_size-1 downto 0);
    signal r_iteration : integer;


    --! Lookup table
    constant tan_lkp : int16_array_t := (
            --to_signed(8191, gen_size),
            --to_signed(4835, gen_size),
            --to_signed(2555, gen_size),
            --to_signed(1297, gen_size),
            --.to_signed(651, gen_size),
            --to_signed(325, gen_size),
            --to_signed(162, gen_size),
            --to_signed(81, gen_size),
            to_signed(40, gen_size),
            to_signed(20, gen_size),
            to_signed(10, gen_size),
            to_signed(5, gen_size),
            to_signed(2, gen_size),
            to_signed(1, gen_size),
            to_signed(0, gen_size),
            to_signed(0, gen_size));
 
  begin

         p_cordic : process(rst, clk)  
          begin
            
            if rst = '1' then
                r_iteration <= 0;
                r_state <= IDLE;
                r_X <= to_signed(0, gen_size);
                r_Y <= to_signed(0, gen_size);
                r_Z <= to_signed(0, gen_size);
                x_out <= to_signed(0, gen_size);
                y_out <= to_signed(0, gen_size);

            elsif rising_edge(clk) then
                    case r_state is
                        when IDLE =>
                            r_iteration <= 0;
                            r_Z <= to_signed(0, gen_size);
                            if sync = '1' then 
                                r_X <= x_in;
                                r_Y <= y_in;
                                r_Z <= to_signed(0, gen_size);
                                r_state <= RUN;
                            end if;
                                
                        when RUN =>
                            if r_Y < 0 then                       
                                r_X <= r_X + shift_right_signed(r_Y, r_Y'length, r_iteration);
                                r_Y <= r_Y - shift_right_signed(r_X, r_X'length, r_iteration);
                                r_Z <= r_Z + signed(tan_lkp(r_iteration));
                            else                    
                                r_X <= r_X - shift_right_signed(r_Y, r_Y'length, r_iteration);
                                r_Y <= r_Y + shift_right_signed(r_X, r_X'length, r_iteration);
                                r_Z <= r_Z - signed(tan_lkp(r_iteration));
                            end if;

                            if r_iteration < gen_iterations - 1 then 
                                r_iteration <= r_iteration + 1;
                            else
                                r_state <= DONE;         
                            end if;

                        when DONE =>
                            x_out <= resize(r_X, gen_size);
                            y_out <= resize(r_Y, gen_size);
                            if sync = '0' then 
                                r_state <= IDLE;
                            end if;
                            
                        when others =>
                            r_state <= IDLE;

                        end case;
            end if;
          end process;

          --! Set valid only when cordic algorithm is done.
          valid <= '1' when r_state = DONE else '0';

end rtl;
