--!  IEEE VHDL standard library
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Debug / Testbed
use work.cordic_common_pkg.all;

--! @author Manuel Mascarenhas
--! @brief
entity rotational_cordic is
    generic (
      gen_iterations : integer := 16;
      gen_size : integer := 16);
    port(
      clk : in  std_logic;
      rstn : in  std_logic;
      sync : in std_logic;
      theta : in signed(gen_size-1 downto 0);  --! [0=0, 2*16=2*Pi]
      x_out : out signed(gen_size-1 downto 0);
      y_out : out signed(gen_size-1 downto 0);
      valid : out std_logic
      );
end entity rotational_cordic;


--! TODO LUT for iterations---
--! @brief
architecture rtl of rotational_cordic is
  
  subtype uint16_t is unsigned(gen_size-1 downto 0);
  subtype int16_t is signed(gen_size-1 downto 0);
  type uint16_array_t is array(0 to gen_size-1) of int16_t;
  
  constant tan_lkp : uint16_array_t := (
    to_signed(11520, gen_size),
    to_signed(6801, gen_size),
    to_signed(3595, gen_size),
    to_signed(1824, gen_size),
    to_signed(916, gen_size),
    to_signed(458, gen_size),
    to_signed(229, gen_size),
    to_signed(117, gen_size),
    to_signed(57, gen_size),
    to_signed(29, gen_size),
    to_signed(14, gen_size),
    to_signed(7, gen_size),
    to_signed(4, gen_size),
    to_signed(2, gen_size),
    to_signed(1, gen_size),
    to_signed(0, gen_size));

    constant tan_lkp1 : uint16_array_t := (
	to_signed(8191, gen_size),
	to_signed(4835, gen_size),
	to_signed(2555, gen_size),
	to_signed(1297, gen_size),
	to_signed(651, gen_size),
	to_signed(325, gen_size),
	to_signed(162, gen_size),
	to_signed(81, gen_size),
	to_signed(40, gen_size),
	to_signed(20, gen_size),
	to_signed(10, gen_size),
	to_signed(5, gen_size),
	to_signed(2, gen_size),
	to_signed(1, gen_size),
	to_signed(0, gen_size),
	to_signed(0, gen_size)
);
    
  --! 
  type t_cordic_state is (IDLE, CHECK_DIR, CHECK_QUADRANT, ITERATE, SCALING, DONE );
  --!
  signal s_state : t_cordic_state;

  --! Iteration register
  signal r_iteration : integer := 0;
  --!
  signal r_X : signed(gen_size-1 downto 0);
  --!
  signal r_Y : signed(gen_size-1 downto 0);
  --!
  signal r_Z : signed(gen_size-1 downto 0);
  --! Direction register
  signal r_dir : std_logic;
  --!
  signal r_theta : signed(gen_size-1 downto 0);
  signal r_quadrant : integer := 0;
begin

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


    --! x[i+1]=x[i] − d x 2**i x y[i]
    --! y[i+1]=y[i] + d x 2**i x y[i]

    p_cordic : process(rstn, clk)
        begin
        if (rstn = '0') then
            r_iteration <= 0;
            r_dir <= '0';
            r_X <= to_signed(0,gen_size);
            r_Y <= to_signed(0,gen_size);
            r_Z <= to_signed(0,gen_size);
            x_out <= to_signed(0,gen_size);
            y_out <= to_signed(0,gen_size);
            s_state <= IDLE;
            r_theta <= to_signed(0,gen_size);
            r_quadrant <= 0;
        elsif rising_edge(clk) then
            case s_state is
                when IDLE =>
                  r_iteration <= 0;
                  --! Load registers when sync to avoid that values change during iterations
                  r_theta <= to_signed(0,gen_size);
                  if sync = '1' then
                      r_theta <= theta;
                      r_X <= to_signed((1*2480),gen_size);
                      r_Y <= to_signed(0,gen_size);
                      r_Z <= to_signed(0,gen_size);
                      s_state <= CHECK_QUADRANT;
                  end if;
                
                
                
                when CHECK_QUADRANT=>
                  if(r_theta < -16384) then
                      r_theta <= r_theta + 2*16384;
                      r_quadrant <= 0;
                  elsif(r_theta < 0) then
                      r_theta <= r_theta + 16384;
                      r_quadrant <= 1;
                  elsif(r_theta < 16384) then
                      r_theta <= r_theta ;
                      r_quadrant <= 2;
                  else
                      r_theta <= r_theta - 16384;
                      r_quadrant <= 3;        
                  end if;
                  r_Z <= r_theta;
                  s_state <= ITERATE;                        
                        
                when ITERATE =>
 
                  
                  --! Check direction
                  if r_theta > r_Z then -->= r_theta then
                    r_dir <= '0';
                    r_X <= r_X - shift_right(r_Y,r_iteration);
                    r_Y <= r_Y + shift_right(r_X,r_iteration);
                    r_Z <= r_Z - tan_lkp1(r_iteration);
                  else
                    r_dir <= '1';
                    r_X <= r_X + shift_right(r_Y,r_iteration);
                    r_Y <= r_Y - shift_right(r_X,r_iteration);
                    r_Z <= r_Z + tan_lkp1(r_iteration);
                  end if;
                                   
                  if r_iteration < gen_iterations-1 then 
                      r_iteration <= r_iteration + 1;
                  else
                      s_state <= DONE;         
                  end if;


                when SCALING =>

                when DONE =>
                
                        if r_quadrant = 0 then
                            x_out <= -(r_X, 16);
                            y_out <= -(r_Y, 16);
                        elsif r_quadrant = 1 then
                            x_out <= (r_Y, 16);
                            y_out <= -(r_X, 16);
                        elsif r_quadrant = 2 then
                            x_out <=  (r_X, 16);
                            y_out <=  (r_Y, 16);
                        else                        
                            x_out <= -(r_Y, 16);
                            y_out <= (r_X, 16);
                        end if;
                        
                    --x_out <= r_X;
                    --y_out <= r_Y;
                    s_state <= IDLE;

                when others=>
                    s_state <= IDLE;
            end case;
        end if;
    end process p_cordic;
        
    --! Set valid only when cordic algorithm is done.
    valid <= '1' when s_state = DONE else '0';

end rtl;