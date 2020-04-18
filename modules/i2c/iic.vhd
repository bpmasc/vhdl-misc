--! TODO description
library IEEE;
--! TODO description
use IEEE.numeric_std.all;
--! TODO description
use IEEE.std_logic_1164.all;

library i2c_lib;
use i2c_lib.i2c_utils_pkg.all;

-- do records and respective functions for i2c packets. zB packet addr, data. (load packet, ...)
-- two pre-defined LUTs. addr_lut and data_lut

-- aftet writing to addrs should i read to mske sure thst it is properly configured??
-- 1) read firmw revision of e chip ()
-- 2) write register map
-- 3) read register map??
-- 4) release hdmi buffer

-- @brief notes from datasheet (Pg. 37/46 of Hardware Users Guide)
--      + Data received ot transmitted on the SDA line must be stable for the duration of the positive-going SCL pulse (rising-edge)
--      + Data on SDA changes only when SCL is low.
--      + Start sequence: high-to-low (falling-edge) transition on SDA while SCL is high.
--      + Stop sequence: low-to-high (rising edge) of SDA while SCL is high -> resets base address
---     ADDR[6:0] RnW ACK -> standard I2C packet






-- If the ADV7513 does not acknowledge the master device during a write sequence, the SDA remains high so the master
-- can generate a stop signal. If the master device does not acknowledge the ADV7513 during a read sequence, the
-- ADV7513 interprets this as end of data. The SDA remains high, so the master can generate a stop signal.

--There are six components to serial bus operation:
-- Start signal
-- Slave address byte
-- Base register address byte
-- Data byte to read or write
-- Stop signal
-- Acknowledge (Ack)

--The start signal is a high-to-low transition on SDA while SCL is high. 

--! Single write seq
--! start | dev_addr & R_nW ('0') | ack | reg_addr | ack | 
--! write_data | ack | stop

--! Single read seq
--! start | dev_addr & R_nW ('0') | ack | reg_addr | ack | 
--! start | dev_addr & R_nW ('1') | ack | read_data | ack | stop

--! TODO brief
entity iic_master is
    generic( 
        gen_clk_period : time := 20 ns;
        gen_dev_addr : std_logic_vector := "1110011" --get reql addr
    );
    port( 
        -- clock and reset declaration
        clk : in std_logic;
        reset : in std_logic;
        -- i2c control
        i2c_user_ctrl : inout t_i2c_ctrl;
        ready : out std_logic;
        -- I2C interface signals
        scl : out std_logic;
        sda_i : in std_logic;
        sda_o : out std_logic);
end;

--! TODO brief
architecture rtl of iic_master is

    constant c_tbuff : integer := gen_i2c_tbuff / gen_clk_period;
    constant c_stah : integer := gen_i2c_tstah / gen_clk_period;
    constant c_tpause : integer := (10*gen_i2c_tstah) / gen_clk_period;

    --! TODO description
    type t_i2c_main_fsm is (INIT, IDLE, START, START_0, START_1, STREAM_DATA_FE,STREAM_DATA_RE,PAUSE_2,BASE_ADDR_FE,BASE_ADDR_RE,PAUSE_1,SLAVE_ADDR_FE,SLAVE_ADDR_RE,STOP_0,STOP,DONE);
    --! TODO description
    signal r_state : t_i2c_main_fsm;
    --! 
    type t_i2c_clock_engine is (FALLING, RISING);
    --!
    signal r_state_scl : t_i2c_clock_engine;
    signal r_cnt_scl : integer;
    signal r_cnt : integer;
    signal r_en_scl : std_logic;
    signal r_sync_T0 : std_logic;
    signal r_bit_counter : natural;
    signal r_cnt_data : natural;
    signal r_iteration : integer;
    signal r_i2c_seq : t_i2c_seq;
    signal r_received_data : std_logic_vector(7 downto 0);
    signal r_bit_cnt : integer;
	 signal r_byte_cnt : integer;
	 
begin

    process (clk, reset)
        begin
            if reset = '1' then
                r_state <= INIT;
                sda_o <= '1';
                r_cnt <= (100*c_tbuff)-1;
                ready <= '0';
                r_bit_cnt <= 0;
                r_i2c_seq <= (others=>(others=>'0'));
					 scl <= '1';
					 r_iteration <= 0;
					 ready <= '0';
					 r_byte_cnt <= 0;
	
            elsif rising_edge(clk) then

                if r_cnt_scl < c_stah then
                    r_cnt_scl <= r_cnt_scl + 1;
                else
                    r_cnt_scl <= 0;
                end if;


                if r_cnt > 0 then
                    r_cnt <= r_cnt - 1;
                end if;

                --! default values
                ready <= '0';

                case r_state is
                    when INIT =>
								--! wait 200 ms after poweer-up, 
								if r_cnt = 0 then
									ready <= '1';
									r_state <= IDLE;
								end if;
								
						  when IDLE =>
                        if i2c_user_ctrl.iteration = r_iteration + 1 then --! got new cmd. read or write?
                            r_iteration <= i2c_user_ctrl.iteration;
                            r_cnt <= c_tbuff/4-1; --! use a different time
                            r_i2c_seq <= load_seq(i2c_user_ctrl);
                            scl <= '1';
									 sda_o <= '1';                            
                            r_bit_cnt <= 0;
									 r_byte_cnt <= 0;
									 r_state <= START_0;
                        end if;
						
                    when START_0 =>
                        if r_cnt = 0 then
                            scl <= '1';
                            r_cnt <= (c_stah/4) - 1;
                            r_state <= START_1;
                        end if;

                    when START_1 =>
                        if r_cnt = 0 then
                            scl <= '1';
									 sda_o <= '0';
                            r_cnt <= (c_stah/4) - 1;
                            r_state <= START;
                        end if;								
								
                    when START =>
                        if r_cnt = 0 then
                            scl <= '0';
                            r_cnt <= (c_stah/2) - 1;
                            r_state <= SLAVE_ADDR_RE;
                        end if;								
								
                    when SLAVE_ADDR_RE =>
                        if r_cnt = (c_stah/4) - 1 then
                            --! update SDA
									 sda_o <= r_i2c_seq(r_byte_cnt)(7-r_bit_cnt);
                            --r_bit_cnt <= r_bit_cnt + 1;
                        elsif r_cnt = 0 then
                            r_cnt <= (c_stah/2) - 1;
                            r_state <= SLAVE_ADDR_FE;
									 scl <= '1';
                        end if;

                    when SLAVE_ADDR_FE =>
                        if r_cnt = 0 then
                            scl <= '0';
                            if r_bit_cnt < 8 then 
                                r_bit_cnt <= r_bit_cnt + 1;
										  r_cnt <= (c_stah/2) - 1;
                                r_state <= SLAVE_ADDR_RE;
                            else
                                r_cnt <= c_tpause - 1;
                                r_bit_cnt <= 0;
                                r_state <= PAUSE_1;
                            end if;
                        end if;

                    when PAUSE_1 =>
                        if r_cnt = 0 then
									 r_byte_cnt <= r_byte_cnt + 1;
									 r_cnt <= (c_stah/2) - 1;
                            r_state <= BASE_ADDR_RE;
                        end if;

                    when BASE_ADDR_RE =>
                        if r_cnt = (c_stah/4) - 1 then
                            --! update SDA
                            sda_o <= r_i2c_seq(r_byte_cnt)(7-r_bit_cnt);
                            --r_bit_cnt <= r_bit_cnt + 1;
                        elsif r_cnt = 0 then
                            r_cnt <= (c_stah/2) - 1;
                            r_state <= BASE_ADDR_FE;
                            scl <= '1';
                        end if;

                    when BASE_ADDR_FE =>
                        if r_cnt = 0 then
                            scl <= '0';
                            if r_bit_cnt < 8 then 
                                r_bit_cnt <= r_bit_cnt + 1;
										  r_cnt <= (c_stah/2) - 1;
                                r_state <= BASE_ADDR_RE;
                            else
                                r_bit_cnt <= 0;
                                r_cnt <= c_tpause - 1;
                                r_state <= PAUSE_2;
                            end if;
                        end if;

                    when PAUSE_2 =>
                        if r_cnt = 0 then
									 r_byte_cnt <= r_byte_cnt + 1;
									 r_cnt <= (c_stah/2) - 1;
									 if i2c_user_ctrl.r_nw = '1' then
										if r_byte_cnt < 2  then
											scl <= '0';
											sda_o <= '1';
											r_state <= START_0;
										else
											sda_o <= '0';
											scl <= '0';
											r_state <= STOP_0;
										end if;
									 else
										r_state <= STREAM_DATA_RE;
									 end if;
                        end if;
            
                    when STREAM_DATA_RE =>
                        if r_cnt = (c_stah/4) - 1 then
                            --! update SDA
                            sda_o <= r_i2c_seq(r_byte_cnt)(7-r_bit_cnt);
                           -- r_bit_cnt <= r_bit_cnt + 1;
                        elsif r_cnt = 0 then
                            r_cnt <= (c_stah/2) - 1;
                            r_state <= STREAM_DATA_FE;
                            scl <= '1';
									 if r_bit_cnt = 9 then
										sda_o <= '0';
									 end if;
                        end if;

                    when STREAM_DATA_FE =>
                        if r_cnt = 0 then
                            scl <= '0';
                            if r_bit_cnt < 8 then 
                                r_bit_cnt <= r_bit_cnt + 1;
										  r_cnt <= (c_stah/2) - 1;
                                r_state <= STREAM_DATA_RE;
                            else
                                r_bit_cnt <= 0;
                                r_cnt <= (c_stah/2) - 1;
										  scl <= '0';
										  sda_o <= '0';
                                r_state <= STOP_0;
                            end if;
                        end if;

								
							when STOP_0 =>
								if r_cnt=0 then
									sda_o <= '0';
									scl <= '1';
									r_cnt <= (c_stah/2) - 1;
									r_state <= STOP;
								end if;
								
                    when STOP =>
								if r_cnt=0 then
									sda_o <= '1';
									r_cnt <= (4*c_tpause) - 1;
									r_state <= DONE;
								end if;

								
						  when DONE =>	
								if r_cnt=0 then
									ready <= '1';
									sda_o <= '1';
									r_state <= IDLE;
								end if;
								
                    when OTHERS =>                        
                        r_state <= IDLE; --! does nothing

                end case;
            end if;
    end process;
    
end rtl;