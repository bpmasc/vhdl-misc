--! Standard IEEE library and packages
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

--library avalon_mem_lib;
--use avalon_mem_lib.avalon_mem_pkg.all;

library work;
use work.avalon_mem_pkg.all;


--! Reference. https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/manual/mnl_avalon_spec.pdf
entity avalon_mem_read_32 is
	generic(
		gen_sdram_burstcount : integer := 4
		);
	port(
    	reset : in std_logic;
    	clk : in std_logic;
    	start : in std_logic;
    	data_out : out t_mem_array(31 downto 0);
		f2h_sdram_address : out std_logic_vector(29 downto 0) := (others => 'X'); -- address
		f2h_sdram_burstcount : out std_logic_vector(7 downto 0)  := (others => 'X'); -- burstcount
		f2h_sdram_waitrequest : in std_logic;                                        -- waitrequest
		f2h_sdram_readdata : in std_logic_vector(31 downto 0);                    -- readdata
		f2h_sdram_readdatavalid : in std_logic;                                        -- readdatavalid
		f2h_sdram_read : out std_logic;
    	valid : out std_logic);
end entity;

--! @brief 
architecture rtl of avalon_mem_read_32 is

	--!  
	type t_fsm is (IDLE, READ_DATA, DONE);
	--!  
	signal r_fsm : t_fsm;
	--!
	signal r_cnt : integer;
begin
 
	--assert data_out'length-1 < AVALON_MEM_BURSTCOUNT report "Stack overflow" severity error;
	
	p_main : process(reset, clk)
	begin
		if reset='1' then
			r_fsm <= IDLE;
			f2h_sdram_read <= '0';
			r_cnt <= 0;
			f2h_sdram_address <= (others=>'0');
			f2h_sdram_burstcount <= (others=>'0');
			data_out <= (others=>(others=>'0'));
		elsif rising_edge(clk) then
			case r_fsm is
			 	when IDLE =>
			 		r_cnt <= 0;
			 		if start = '1' then
			 			f2h_sdram_address <= AVALON_MEM_READ_ADDRESS;
						f2h_sdram_burstcount <= std_logic_vector(to_unsigned(AVALON_MEM_BURSTCOUNT,f2h_sdram_burstcount'length));
						f2h_sdram_read <= '1';
			 			r_cnt <= r_cnt + 1;
			 			r_fsm <= READ_DATA;
			 		end if;

				when READ_DATA =>
					if f2h_sdram_waitrequest = '0' then
						r_cnt <= r_cnt + 1;
						data_out(r_cnt) <= f2h_sdram_readdata;
						if r_cnt = AVALON_MEM_BURSTCOUNT-2 then 
							r_fsm <= DONE;
						end if;
					end if;

			 	when DONE =>
					if f2h_sdram_waitrequest = '0' then
						data_out(r_cnt) <= f2h_sdram_readdata;
						r_fsm <= IDLE;
						f2h_sdram_read <= '0';
					end if;

			 	when others =>
					r_fsm <= IDLE;
			end case;
		end if;
	end process; --! p_main

	valid <= '1' when r_fsm = DONE else '0';

end rtl;