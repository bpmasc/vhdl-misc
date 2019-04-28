library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		  	 	   
--pragma translate_off
use std.textio.all;
--pragma translate_on

--library work;
--use work.common_pkg.all;

entity cordic_cos is
    generic (
        internal_res : integer := 16;
        output_res   : integer := 16
      );
    port( 
      clk          : in  std_logic;
      rstn         : in  std_logic;
      start        : in std_logic;
      valid        : out std_logic;
      angle        : in  signed(internal_res-1 downto 0); -- [0=0, 2*16=2*Pi]
      cos          : out signed(output_res-1 downto 0);
      sin          : out signed(output_res-1 downto 0)
      );
      
end cordic_cos;



architecture rtl of cordic_cos is

    -- signals
    signal cnt : integer  range 0 to 100;

    type t_cordic_state is (IDLE, LOAD, RUN, DONE );
    signal state : t_cordic_state;
    signal dir : std_logic;

    subtype uint16_t is unsigned(internal_res-1 downto 0);
    subtype int16_t is signed(internal_res-1 downto 0);
    type uint16_array_t is array(0 to internal_res-1) of uint16_t;
    signal quadrant : integer := 0;
    signal X: signed(internal_res-1 downto 0);
    signal Y: signed(internal_res-1 downto 0);
    signal current_angle: signed(internal_res-1 downto 0);
    signal target_angle: signed(internal_res-1 downto 0);
    signal iteration : integer;

constant tan_lkp : uint16_array_t := (
	to_unsigned(8191, internal_res),
	to_unsigned(4835, internal_res),
	to_unsigned(2555, internal_res),
	to_unsigned(1297, internal_res),
	to_unsigned(651, internal_res),
	to_unsigned(325, internal_res),
	to_unsigned(162, internal_res),
	to_unsigned(81, internal_res),
	to_unsigned(40, internal_res),
	to_unsigned(20, internal_res),
	to_unsigned(10, internal_res),
	to_unsigned(5, internal_res),
	to_unsigned(2, internal_res),
	to_unsigned(1, internal_res),
	to_unsigned(0, internal_res),
	to_unsigned(0, internal_res)
);
 
  begin

  ---------------------------------------------------------------------------
  p_cordic : process(rstn, clk)  
  begin
    
    if rstn='0' then
        iteration <= 0;
        state     <= IDLE;
        valid <= '0';
		X <= to_signed(0, internal_res);
		Y <= to_signed(0, internal_res);
		current_angle 	<= to_signed(0, internal_res);
		target_angle    <= to_signed(0, internal_res);
        cos <= to_signed(0, output_res);
        sin <= to_signed(0, output_res);
        dir <='0';
        quadrant <= 0;
    elsif rising_edge(clk) then
    
                case state is
                    when IDLE =>
                        iteration <= 0;
                        current_angle <= to_signed(0, internal_res);
                        valid    <= '0';
                        dir      <='0';
                        quadrant <= 0;
                        if start = '1' then 
                            state <= LOAD;
                        end if;
                        
                    when LOAD =>
                        if(angle < -16384) then
                            X   <= to_signed(2480, internal_res); -- 2480*gain(16) = 4095 ;)
                            Y   <= to_signed(0, internal_res);
                            target_angle <= angle + 2*16384;
                            quadrant <= 0;
                        elsif(angle < 0) then
                            X   <= to_signed(2480, internal_res); -- 2480*gain(16) = 4095 ;)
                            Y   <= to_signed(0, internal_res);
                            target_angle <= angle + 16384;
                            quadrant <= 1;
                        elsif(angle < 16384) then
                            X   <= to_signed(2480, internal_res); -- 2480*gain(16) = 4095 ;)
                            Y   <= to_signed(0, internal_res);
                            target_angle <= angle ;
                            quadrant <= 2;
                        else
                            X   <= to_signed(2480, internal_res); -- 2480*gain(16) = 4095 ;)
                            Y   <= to_signed(0, internal_res);
                            target_angle <= angle - 16384;
                            quadrant <= 3;        
                        end if;
                        state <= RUN;
                        

                    when RUN =>
                        if current_angle <  target_angle then
                            dir <='1';
                            current_angle <= current_angle + signed(tan_lkp(iteration));
                            X <= X - shift_right(Y, iteration);
                            Y <= Y + shift_right(X, iteration);
                        else
                            dir <='0';
                            current_angle <= current_angle - signed(tan_lkp(iteration));
                            X <= X + shift_right(Y, iteration);
                            Y <= Y - shift_right(X, iteration);
                        end if;
                            
                        if iteration < internal_res-1 then 
                            iteration <= iteration + 1;
                        else
                            state <= DONE;         
                        end if;
                        
                    when DONE =>
                        valid <= '1';
                        if quadrant = 0 then
                            cos <= -resize(X, 16);
                            sin <= -resize(Y, 16);
                        elsif quadrant = 1 then
                            cos <= resize(Y, 16);
                            sin <= -resize(X, 16);
                        elsif quadrant = 2 then
                            cos <=  resize(X, 16);
                            sin <=  resize(Y, 16);
                        else                        
                            cos <= -resize(Y, 16);
                            sin <= resize(X, 16);
                        end if;
                        if start = '0' then 
                            state <= IDLE;
                        end if;
                        
                    when others =>
                    null;
                end case;
    end if;
  end process;
  
  
  -- ---------------------------------------------------------------------------
  -- p_apb : process(rstn, clk)  
  -- variable addr   : integer;
  -- variable apbout : std_logic_vector(31 downto 0);
  -- begin
    
    -- if rstn='0' then
        -- -- APB regs
        -- --ctrl    <= (others=>'0');
        -- apbout  :=  (others=>'0');
		-- send_array <= (others => (others=>'0'));
		-- send_index <= 0;
        -- max_index  <= 0;
		
    -- elsif rising_edge(clk) then
		-- start <= '0';
		
        -- if (apbi.psel(pindex) and apbi.penable) = '1' then
			-- addr := to_integer(unsigned(apbi.paddr(7 downto 2)));
		
            -- if apbi.pwrite = '1' then
                -- case apbi.paddr(7 downto 2) is 
					-- when ADDR_CTRL_MODE  => 
						-- --ctrl_mode <= x"00000000";
				
					-- when ADDR_CTRL_INTERRUPTS  => 
						-- --ctrl_mode <= x"00000000";

					-- when ADDR_SEND_BUFFER_CTRL =>
						-- send_index 	<= 0;
						-- start		<= '1';
						
					-- when ADDR_SEND_BUFFER_CNT =>
							-- max_index <= to_integer( unsigned (apbi.pwdata(7 downto 0)) );
							
					-- when ADDR_SEND_BUFFER  => 
							-- if (send_index <max_index) then  -- ignore out of bounds writes
								-- send_array(send_index) <= apbi.pwdata(7 downto 0);
								-- send_index <= send_index +1 ;
							-- end if;

					-- when others  => 

				-- end case;
            -- else
				-- apbout   	   := x"000000" & receive_array( integer (addr) ) ;
            -- end if;
        -- end if;
    -- end if;
  -- end process;
	
  
  ---------------------------------------------------------------------------
  -- Signal assignments
  ---------------------------------------------------------------------------
  -- apbo.prdata <= apbout;
  -- apbo.pirq  <= (others=>'0');
  -- apbo.pindex  <= pindex;
  --apbo.pconfig <= PCONFIG;
  
  -- boot message

-- pragma translate_off
--    bootmsg : report_version
--      generic map ("Wrapper for PARSPI. interface : pindex = " & tost(pindex));
-- pragma translate_on

end rtl;
