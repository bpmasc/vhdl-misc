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
      gen_block_size : integer := 205;
      gen_tone_period : time := 20 ms;
      gen_sampling_period : time := 20 us;
      gen_size : integer := 16
    );
    port( 
      clk : in  std_logic;
      rst : in  std_logic;
      sync : in std_logic;
      x_in : in signed(gen_size-1 downto 0); -- [0=0, 2*16=2*Pi]
      --sample_real : out signed(gen_size-1 downto 0);
      --sample_imag : out signed(gen_size-1 downto 0);
      --sample_magnitude : out signed(gen_size-1 downto 0);
      square_mag : out signed(gen_size-1 downto 0);
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
    type t_cordic_state is (IDLE, LOAD, RUN, DONE );
    signal r_state : t_cordic_state;
    signal r_dir : std_logic;
    type int16_array_t is array(0 to gen_size-1) of signed(gen_size-1 downto 0);
    --! GOERTZEL
    constant c_k : integer := gen_iterations*(gen_tone_period/gen_sampling_period);
    signal c_coef : intewger := 12345; --! Pre-compute the coeff. Alternatively use CORDIC

    type t_goertzel_state is (IDLE, SUM, PROD, RUN, DONE);
    signal r_state : t_goertzel_state;
    signal r_coef : signed(gen_size-1 downto 0);
    signal r_q0 : signed(gen_size-1 downto 0);
    signal r_q1 : signed(gen_size-1 downto 0);
    signal r_q2 : signed(gen_size-1 downto 0);
    signal r_iteration : unsigned(7 downto 0);
    signal r_y_out : signed(gen_size-1 downto 0);
    --! CORDIC SQRT

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
        r_q0 <= to_signed(0, gen_size-1);
        r_q1 <= to_signed(0, gen_size-1);
        r_q2 <= to_signed(0, gen_size-1);

    elsif rising_edge(clk) then
            case r_state is
                when IDLE =>
                    --! Initialite Q values
                    r_q0 <= to_signed(0, gen_size-1);
                    r_q1 <= to_signed(0, gen_size-1);
                    r_q2 <= to_signed(0, gen_size-1);
                    r_iteration <= 0;
                    if sync = '1' then 
                        r_state <= LOAD;
                    end if;
                        
                when SAMPLE =>
                    loop_comp : for i in 0 to gen_block_size-1 loop
                        r_q0 <= r_coef*r_q1 - r_q2 + x_in;
                        r_q1 <= r_q0;
                        r_q2 <= r_q1;
                    end loop loop_comp;
                    r_state <= COMPUTE;

                when COMPUTE =>
                    sample_real <= 
                    sample_magnitude  <= 
                    sample_imag  <= 
                    r_state <= DONE;

                when DONE =>

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
