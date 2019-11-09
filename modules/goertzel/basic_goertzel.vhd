--! Standard IEEE library and packages
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		  	 	   

--! Auxiliary package
--use work.goertzel_common_pkg.all;


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
      gen_block_size : integer := 10; --N
      gen_tone_period : time := 20 ms;
      gen_sampling_period : time := 20 us;
      gen_size : integer := 16
    );
    port( 
      clk : in  std_logic;
      rst : in  std_logic;
      sync : in std_logic;
      x_in : in signed(gen_size-1 downto 0); -- [0=0, 2*16=2*Pi]
      y_out : out signed(gen_size-1 downto 0); -- Magnitude
      valid : out std_logic);      
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
	
    constant c_k : integer := gen_block_size*(gen_tone_period/gen_sampling_period); --! not necessary for now
    constant c_coef : integer := 2; --! not necessary for now

    type t_goertzel_state is (IDLE, ARITHM, LOAD, SUM_MAGN, DONE);
    signal r_state : t_goertzel_state;
    signal r_coef : signed(gen_size-1 downto 0);
    signal r_q0 : signed(gen_size-1 downto 0);
    signal r_q1 : signed(gen_size-1 downto 0);
    signal r_q2 : signed(gen_size-1 downto 0);
    signal r_aux_sum : signed(gen_size-1 downto 0);
    signal r_y_out : signed(gen_size-1 downto 0);
    signal r_iteration : integer range 0 to 255;

  begin

    p_goertzel : process(rst, clk) 
    begin
    
    if rst = '1' then
        r_state <= IDLE;
        r_iteration <= 0;
        y_out <= to_signed(0, gen_size);
        r_y_out <= to_signed(0, gen_size);
        r_q1 <= to_signed(0, gen_size);
        r_q2 <= to_signed(0, gen_size);
        r_q0 <= to_signed(0, gen_size);
        r_aux_sum <= to_signed(0, gen_size);

    elsif rising_edge(clk) then
            case r_state is
                when IDLE =>
                    if sync = '1' then 
                        r_iteration <= 0;
                        r_q1 <= to_signed(0, gen_size);
                        r_q2 <= to_signed(0, gen_size);
                        r_q0 <= to_signed(0, gen_size);
                        r_y_out <= to_signed(0, gen_size);
                        r_aux_sum <= to_signed(0, gen_size);
                        r_state <= LOAD;
                    end if;

                when ARITHM =>
                    r_y_out <= shift_left(r_q1,1);
                    r_aux_sum <= r_q2 + x_in;
                    r_state <= LOAD;

                when LOAD =>
                    r_q0 <= r_y_out + r_aux_sum;
                    r_q1 <= r_q0;
                    r_q2 <= r_q1;
                    if r_iteration < gen_block_size then 
                        r_iteration <= r_iteration + 1;
                        r_state <= ARITHM;
                    else
                        r_state <= SUM_MAGN;
                    end if;

                when SUM_MAGN =>
                    r_y_out <= r_q1 + r_q2;
                    r_state <= DONE;

                when DONE =>
                    if sync = '0' then 
                        y_out <= r_y_out;
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
