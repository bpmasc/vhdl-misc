library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		  	 	   

entity cordic_cos is
    generic (
        gen_internal_res : integer := 16;
        gen_output_res   : integer := 16
	);
    port( 
      clk : in  std_logic;
      rst : in  std_logic;
      start : in std_logic;
      angle : in  unsigned(gen_internal_res-1 downto 0); -- [0=0, 2*16=2*Pi]
      valid : out std_logic;
      cos : out signed(output_res-1 downto 0);
      sin : out signed(output_res-1 downto 0)
     );      
end cordic_cos;



architecture rtl of cordic_cos is
	--! constants
	constant c_q1 : integer := 2**(gen_internal_res-2);
	constant c_q2 : integer := 2**(gen_internal_res-1);
	constant c_q3 : integer := 2**(gen_internal_res-1) + 2**(gen_internal_res-2);
    -- signals
    signal r_cnt : integer  range 0 to 100;
    type t_cordic_state is (IDLE, LOAD, RUN, DONE );
    signal r_state : t_cordic_state;
    signal r_dir : std_logic;
    type uint16_array_t is array(0 to gen_internal_res-1) of unsigned(gen_internal_res-1 downto 0);
    signal r_quadrant : integer := 0;
    signal r_X: signed(gen_internal_res-1 downto 0);
    signal r_Y: signed(gen_internal_res-1 downto 0);
    signal r_Z: signed(gen_internal_res-1 downto 0);
    signal r_iteration : integer;

constant tan_lkp : uint16_array_t := (
	to_unsigned(8191, gen_internal_res),
	to_unsigned(4835, gen_internal_res),
	to_unsigned(2555, gen_internal_res),
	to_unsigned(1297, gen_internal_res),
	to_unsigned(651, gen_internal_res),
	to_unsigned(325, gen_internal_res),
	to_unsigned(162, gen_internal_res),
	to_unsigned(81, gen_internal_res),
	to_unsigned(40, gen_internal_res),
	to_unsigned(20, gen_internal_res),
	to_unsigned(10, gen_internal_res),
	to_unsigned(5, gen_internal_res),
	to_unsigned(2, gen_internal_res),
	to_unsigned(1, gen_internal_res),
	to_unsigned(0, gen_internal_res),
	to_unsigned(0, gen_internal_res)
);
 
  begin

  p_cordic : process(rstn, clk)  
  begin
    
    if rst = '1' then
        r_iteration <= 0;
        r_state     <= IDLE;
        r_valid <= '0';
		r_X <= to_signed(0, gen_internal_res);
		r_Y <= to_signed(0, gen_internal_res);
		r_Z <= to_signed(0, gen_internal_res);
        r_dir <='0';
        r_quadrant <= 0;
        cos <= to_signed(0, gen_output_res);
        sin <= to_signed(0, gen_output_res);

    elsif rising_edge(clk) then
			valid    <= '0';
    
            case state is
                when IDLE =>
                    r_iteration <= 0;
                    r_Z <= to_signed(0, gen_internal_res);
                    r_dir <='0';
                    r_quadrant <= 0;
                    if start = '1' then 
                        r_state <= LOAD;
                    end if;
                        
                when LOAD =>
                    X <= to_signed(2480, gen_internal_res); -- 2480*gain(16) = 4095 ;)
                    Y <= to_signed(0, gen_internal_res);
                    --! To shift back to quadrant 1
                    if(angle > to_unsigned(c_q3,gen_internal_res)) then
                        r_Z  <= angle - to_unsigned(c_q3,gen_internal_res);
                        r_quadrant <= 3;
                    elsif(angle > to_unsigned(c_q2,gen_internal_res)) then
                        r_Z <= angle - to_unsigned(c_q3,gen_internal_res);
                        r_quadrant <= 2;
                    elsif(angle > to_unsigned(c_q1  ,gen_internal_res)) then
                        r_Z <= angle - to_unsigned(c_q3,gen_internal_res);
                        r_quadrant <= 1;
                    else
                        r_Z <= angle;
                        r_quadrant <= 0m;        
                    end if;
                    r_state <= RUN;
                        

                when RUN =>
                    if r_Z < = then
                        r_dir <='1';                        
                        r_X <= r_X - shift_right(r_Y, iteration);
                        r_Y <= r_Y + shift_right(r_X, iteration);
                        r_Z <= r_Z + signed(tan_lkp(iteration));
                    else
                        r_dir <='0';                        
                        r_X <= r_X + shift_right(r_Y, iteration);
                        r_Y <= r_Y - shift_right(r_X, iteration);
                        r_Z <= r_Z - signed(tan_lkp(iteration));
                    end if;
                        
                    if r_iteration < gen_internal_res-1 then 
                        r_iteration <= r_iteration + 1;
                    else
                        state <= DONE;         
                    end if;
                    
                when DONE =>
                    valid <= '1';
                    if r_quadrant = 0 then
                        cos <= -resize(r_X, 16);
                        sin <= -resize(r_Y, 16);
                    elsif r_quadrant = 1 then
                        cos <= resize(r_Y, 16);
                        sin <= -resize(r_X, 16);
                    elsif r_quadrant = 2 then
                        cos <=  resize(r_X, 16);
                        sin <=  resize(r_Y, 16);
                    else                        
                        cos <= -resize(r_Y, 16);
                        sin <= resize(r_X, 16);
                    end if;
                    if start = '0' then 
                        r_state <= IDLE;
                    end if;
                    
                when others =>
                    null;
                end case;
    end if;
  end process;

end rtl;
