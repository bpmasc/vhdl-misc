--! 
--! datashet:
--! https://www.ti.com/lit/ds/symlink/adc124s101.pdf?ts=1598621911944&ref_url=https%253A%252F%252Fwww.google.com%252F
--! ADC124S101 4 Channel, 500 ksps to 1 Msps, 12-Bit A/D Converter
--! 
--! 
--! 
--! 


--! TODO description
library IEEE;
--! TODO description
use IEEE.numeric_std.all;
--! TODO description
use IEEE.std_logic_1164.all;

--library work;
--use work.adv7513_utils_pkg.all;

library spi_3x_master_lib;
use spi_3x_master_lib.spi_3x_utils_pkg.all;

entity spi_3x_master is
    generic( 
        -- Internal clock period
		gen_clk_period : time := 20 ns;
		gen_data_len : integer := 32
		 );
    port( 
        rst : in std_logic;
		clk : in std_logic;
		--! Aux flags
		start : in std_logic;
		valid : out std_logic;
		--! data
		data_in : in std_logic_vector(gen_data_len-1 downto 0);
		data_out : out std_logic_vector(gen_data_len-1 downto 0);
		--! SPI interface
		spi_sclk : out std_logic;
		spi_mosi : out std_logic;
		spi_miso : in std_logic
        );
end;



--! TODO brief
architecture rtl of spi_3x_master is
	--! TODO description
	constant c_t_en : integer := 4;--(c_adc_t_en/gen_clk_period - 1);
	--! TODO description
	constant c_t_sck : integer := 4;--(c_adc_t_sck/gen_clk_period - 1);

    --! TODO description
    type t_main_fsm is (IDLE, SHIFT_DATA, STOP_SCK, DONE);
    --! TODO description
    signal r_main_fsm : t_main_fsm;
	--! TODO description
    type t_sck_fsm is (HIGH, FE, LOW, RE);
    --! TODO description
    signal r_sck_fsm : t_sck_fsm;
	
	--! TODO description
	signal r_sck_cnt : integer;
	--! TODO description
	signal r_spi_ncs : std_logic;
	--! TODO description
	signal r_start_sck : std_logic;
	
	signal r_bit_cnt : integer;
	signal r_seq_cnt : integer;
	signal r_release_sck : std_logic;
	signal r_release_ncs : std_logic;
	signal r_mosi : std_logic_vector(15 downto 0);
	signal r_data_out_a : std_logic_vector(gen_data_len-1 downto 0);
	
	
begin

    --! Main loop
    p_spi_sck : process (rst, clk) 
        begin
            if rst = '1' then
				r_sck_fsm <= HIGH;
				r_sck_cnt <= 0;
				r_release_ncs <= '0';
		    elsif rising_edge(clk) then --! synchronized with hdmi_clk
			    
			    if r_sck_cnt > 0 then
			    	r_sck_cnt <= r_sck_cnt - 1;
			    end if;

				r_release_ncs <= '0';

		    	case(r_sck_fsm) is	
		    		when HIGH =>
		    			if r_start_sck='1'then
		    				r_sck_cnt <= c_t_en - 1;	
		    			end if;

						if r_release_sck ='1' then --and r_sck_cnt = 0 
							r_release_ncs <= '1';
		    				r_sck_cnt <= c_t_en - 1;
						elsif r_sck_cnt = 0 and r_spi_ncs='0' and r_release_sck = '0' then
							r_sck_fsm <= FE;
						end if;

		    		when FE =>
						r_sck_cnt <= c_t_sck - 1;
						r_sck_fsm <= LOW;

		    		when LOW =>
						if r_sck_cnt = 0 then
							r_sck_fsm <= RE;
						end if;

		    		when RE =>
						r_sck_cnt <= c_t_sck - 1;
						r_sck_fsm <= HIGH;

		    		when others =>
		    			r_sck_fsm <= HIGH;
		    	end case ;

			end if;
		end process;

    --! Main loop
    p_main : process (rst, clk) 
        begin
            if rst = '1' then
				r_main_fsm <= IDLE;
				r_spi_ncs <= '1';
				r_start_sck <= '0';
				r_bit_cnt <= 0;
				r_seq_cnt <= 0;
				valid <= '0';
				r_release_sck <= '0';
				spi_mosi <= '0';

		    elsif rising_edge(clk) then --! synchronized with hdmi_clk
		    	--! default value
		    	valid <= '0';
		    	r_start_sck <= '0';
				r_release_sck <= '0';
				r_mosi <= std_logic_vector(shift_left(to_unsigned(r_seq_cnt,16),3));

		    	case(r_main_fsm) is	
		    		when IDLE =>
		    			r_bit_cnt <= 0;
		    			r_seq_cnt <= 0;
						if start='1' then
							r_spi_ncs <= '0';
							r_start_sck <= '1';
							r_main_fsm <= SHIFT_DATA;
						end if;

					when SHIFT_DATA =>
						if r_sck_fsm = RE then
							spi_mosi <= r_mosi(r_bit_cnt);
							--! (4*16)-1
							if r_bit_cnt < 15 then
								r_bit_cnt <= r_bit_cnt + 1;
							else
								r_bit_cnt <= 0;
								if r_seq_cnt < 3 then
									r_seq_cnt <= r_seq_cnt + 1;
								else
									r_release_sck <= '1';
									r_main_fsm <= STOP_SCK;
								end if;
							end if;
						end if;

					when STOP_SCK =>
						if r_release_ncs = '1' then
							r_main_fsm <= DONE;
						end if;

		    		when DONE =>
		    			--! release CS#
		    			r_spi_ncs <= '1';
						if start='0' then
							valid <= '1';
							r_main_fsm <= IDLE;
						end if;
		    		when others =>
		    	
		    	end case ;

			end if;
		end process;

		--! Glue logic
		data_out <= r_data_out_a;
		spi_sclk <= '1' when r_sck_fsm=HIGH or r_sck_fsm=RE else'0';
		
end rtl;
