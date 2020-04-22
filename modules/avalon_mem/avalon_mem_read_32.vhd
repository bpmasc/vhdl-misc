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
    	--data_in : out t_mem_array(2**sel_width - 1 downto 0)(bus_width - 1 downto 0);
    	data_in_0 : out std_logic_vector(31 downto 0);
    	data_in_1 : out std_logic_vector(31 downto 0);
    	data_in_2 : out std_logic_vector(31 downto 0);
    	data_in_3 : out std_logic_vector(31 downto 0);
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
	constant c_address : std_logic_vector(29 downto 0) := std_logic_vector(to_unsigned(1,30)); -- get base addr from pkg
	--!  
	constant c_burstcount : std_logic_vector(7 downto 0) := "00000010";
	--!  
	type t_fsm is (IDLE, READ_DATA, READ_DATA2, READ_DATA3, DONE);
	--!  
	signal r_fsm : t_fsm;

begin

	p_main : process(reset, clk)
	begin
		if reset='1' then
			r_fsm <= IDLE;
			f2h_sdram_read <= '0';
			f2h_sdram_address <= (others=>'0');
			f2h_sdram_burstcount <= (others=>'0');
		elsif rising_edge(clk) then
			case r_fsm is
			 	when IDLE =>
			 		if start = '1' then
			 			f2h_sdram_address <= c_address;
						f2h_sdram_burstcount <= c_burstcount;
						f2h_sdram_read <= '1';
			 			r_fsm <= READ_DATA;
			 		end if;

				when READ_DATA =>
					if f2h_sdram_waitrequest = '0' then
						data_in_0 <= f2h_sdram_readdata;
						r_fsm <= READ_DATA2;
					end if;

				when READ_DATA2 =>
					if f2h_sdram_waitrequest = '0' then
						data_in_1 <= f2h_sdram_readdata;
						r_fsm <= READ_DATA3;
					end if;
				
				when READ_DATA3 =>
					if f2h_sdram_waitrequest = '0' then
						data_in_2 <= f2h_sdram_readdata;
						r_fsm <= DONE;
					end if;

			 	when DONE =>
					if f2h_sdram_waitrequest = '0' then
						data_in_2 <= f2h_sdram_readdata;
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