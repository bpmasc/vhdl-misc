--! Standard IEEE library and packages
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		  	 	   

--! Auxiliary package
use work.goertzel_common_pkg.all;


--! @author Manuel Mascarenhas
--! @brief Goertzel implementation. Based on Doc. ....
--!     1. Decide on the sampling rate.
--!     2. Choose the block size, N.
--!     3. Precompute one cosine and one sine term.
--!     4. Precompute one coefficient.
--! @Relevant Documentation
--! [1] https://courses.cs.washington.edu/courses/cse466/12au/calendar/Goertzel-EETimes.pdf
entity basic_goertzel is
    generic (
      gen_block_ssize : integer := 205;
      gen_tone_period : time := 20 ms;
      gen_sampling_period : time := 20 us;
      gen_size : integer := 16
    );
    port( 
      clk : in  std_logic;
      rst : in  std_logic;
      sync : in std_logic;
      x_in : in signed(gen_size-1 downto 0); -- [0=0, 2*16=2*Pi]
      sample_real : out signed(gen_size-1 downto 0);
      sample_imag : out signed(gen_size-1 downto 0);
      sample_magnitude : out signed(gen_size-1 downto 0);
      --y_out : out signed(gen_size-1 downto 0);
      valid : out std_logic
     );      
end basic_goertzel;





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

architecture rtl of basic_goertzel is
	
    --! CORDIC
    --! constants
	constant c_q1 : integer := 2**(gen_size-2);
	constant c_q2 : integer := 2**(gen_size-1);
	constant c_q3 : integer := 2**(gen_size-1) + 2**(gen_size-2);
    -- signals
    signal r_cnt : integer  range 0 to 100;
    type t_cordic_state is (IDLE, LOAD, RUN, DONE );
    signal r_state : t_cordic_state;
    signal r_dir : std_logic;
    type int16_array_t is array(0 to gen_size-1) of signed(gen_size-1 downto 0);
    --! GOERTZEL
    constant c_k : integer := gen_iterations*(gen_tone_period/gen_sampling_period);
    

    type t_goertzel_state is (IDLE, SUM, PROD, RUN, DONE);
    signal r_state : t_goertzel_state;
    signal r_coef : signed(gen_size-1 downto 0);
    signal r_q0 : signed(gen_size-1 downto 0);
    signal r_q1 : signed(gen_size-1 downto 0);
    signal r_q2 : signed(gen_size-1 downto 0);
    signal r_iteration : unsigned(7 downto 0);
    signal r_y_out : signed(gen_size-1 downto 0);



    --! Lookup table
    constant tan_lkp : int16_array_t := (
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
	to_signed(0, gen_size));
 
  begin

  p_cordic : process(rst, clk)  
  begin
    
    if rst = '1' then
        r_iteration <= 0;
        r_state <= IDLE;
        y_out <= to_signed(0, gen_size-1);
        --! Initialite Q values
        r_q1 <= to_signed(0, gen_size-1);
        r_q2 <= to_signed(0, gen_size-1);
        r_q3 <= to_signed(0, gen_size-1);
    elsif rising_edge(clk) then
            case r_state is
                when IDLE =>
                    r_iteration <= 0;
                    r_Z <= to_signed(0, gen_size);
                    r_dir <='0';
                    if sync = '1' then 
                        r_state <= LOAD;
                        r_quadrant <= 0;
                    end if;
                        
                when LOAD =>
					 --! 2480*gain(16) = 4095 ;)
                    r_X <= to_signed(2480, gen_size);
                    r_Y <= to_signed(0, gen_size);
                    
                    --! To shift back to quadrant 1
                    if angle > to_unsigned(c_q3,gen_size) then
                        r_Z  <= signed(angle - to_unsigned(c_q3,gen_size));
                        r_quadrant <= 3;
                    elsif angle > to_unsigned(c_q2,gen_size) then
                        r_Z <= signed(angle - to_unsigned(c_q2,gen_size));
                        r_quadrant <= 2;
                    elsif angle > to_unsigned(c_q1  ,gen_size) then
                        r_Z <= signed(angle - to_unsigned(c_q1,gen_size));
                        r_quadrant <= 1;
                    else
                        r_Z <= signed(angle);
                        r_quadrant <= 0;
                    end if;
                    r_state <= RUN;

                when RUN =>

                    if r_Z < 0 then
                        r_dir <='1';                        
                        r_X <= r_X + shift_right_signed(r_Y, r_Y'length, r_iteration);
                        r_Y <= r_Y - shift_right_signed(r_X, r_X'length, r_iteration);
                        r_Z <= r_Z + signed(tan_lkp(r_iteration));
                    else
                        r_dir <='0';                        
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
                    if r_quadrant = 0 then
                        x_out <= resize(r_X, 16);
                        y_out <= resize(r_Y, 16);
                    elsif r_quadrant = 1 then
                        x_out <= -resize(r_Y, 16);
                        y_out <= resize(r_X, 16); 
                    elsif r_quadrant = 2 then
                        x_out <= -resize(r_X, 16);
                        y_out <= -resize(r_Y, 16);
                    else                        
                        x_out <= resize(r_Y, 16);
                        y_out <= -resize(r_X, 16);
                    end if;

                    if sync = '0' then 
                        r_state <= IDLE;
                    end if;
                    
                when others =>
                    null;
                end case;
    end if;
  end process;

    --! Set valid only when cordic algorithm is done.
    valid <= '1' when r_state = DONE else '0';

end rtl;
