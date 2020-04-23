--! Standard IEEE library and packages
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

--library avalon_mem_lib;
--use avalon_mem_lib.avalon_mem_pkg.all;

library work;
use work.avalon_mem_pkg.all;


--! Reference. https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/manual/mnl_avalon_spec.pdf

--!		Write Bursts
--!		These rules apply when a write burst begins with burstcount greater than one:
--!		A) When a burstcount of <n> is presented at the beginning of the burst, the slave
--!		must accept <n> successive units of writedata to complete the burst.
--!		Arbitration between the master-slave pair remains locked until the burst
--!		completes. This lock guarantees that no other master can execute transactions on
--!		the slave until the write burst completes.
--!		B) The slave must only capture writedata when write asserts. During the burst,
--!		the master can deassert write indicating that writedata is invalid. Deasserting
--!		write does not terminate the burst. The write deassertion delays the burst and
--!		no other master can access the slave, reducing the transfer efficiency.
--!		C) The slave delays a transfer by asserting waitrequest forcing writedata,
--!		write, burstcount, and byteenable to be held constant.
--!		D) The functionality of the byteenable signal is the same for bursting and nonbursting slaves. 
--!		For a 32-bit master burst-writing to a 64-bit slave, starting at
--!		byte address 4, the first write transfer seen by the slave is at its address 0, with
--!		byteenable = 8'b11110000. The byteenables can change for different
--!		words of the burst.
--!		E) The byteenable signals do not all have to be asserted. A burst master writing
--!		partial words can use the byteenable signal to identify the data being written.
--!		F) Writes with byteenable signals being all 0's are simply passed on to the AvalonMM slave as valid transactions.
--!		G) The constantBurstBehavior property specifies the behavior of the burst
--!		signals.
--!			
--!		When constantBurstBehavior is true for a master, the master holds
--!		address and burstcount stable throughout a burst. When true for a slave,
--!		constantBurstBehavior declares that the slave expects address and
--!		burstcount to be held stable throughout a burst.

--!		When constantBurstBehavior is false, the master holds address and
--!		burstcount stable only for the first transaction of a burst. When
--!		constantBurstBehavior is false, the slave samples address and
--!		burstcount only on the first transaction of a burst.


--!		The burstcount signal behaves as follows:
--!		1/ At the start of a burst, burstcount presents the number of sequential transfers
--!		in the burst.
--!		2/ For width <n> of burstcount, the maximum burst length is 2(<n>-1).The
--!		minimum legal burst length is one.

--!		At the start of a burst, the slave sees the address and a burst length value on
--!		burstcount. For a burst with an address of <a> and a burstcount value of <b>,
--!		the slave must perform <b> consecutive transfers starting at address <a>. The burst
--!		completes after the slave receives (write) or returns (read) the <bth> word of data.
--!		
--!		The bursting slave must capture address and burstcount only once for each burst.
--!		The slave logic must infer the address for all but the first transfers in the burst. A
--!		slave can also use the input signal beginbursttransfer, which the interconnect
--!		asserts on the first cycle of each burst.


entity avalon_mem_write_64 is
	generic(
		gen_sdram_burstcount : integer := 4
		);
	port(
    	reset : in std_logic;
    	clk : in std_logic;
    	start : in std_logic;
    	data_in : in t_mem_array(31 downto 0);
    	f2h_sdram_address : out std_logic_vector(28 downto 0);    -- address
    	f2h_sdram_burstcount : out std_logic_vector(7 downto 0); -- burstcount
    	f2h_sdram_waitrequest : in std_logic;                                        -- waitrequest
    	f2h_sdram_writedata : out std_logic_vector(63 downto 0);  -- writedata
    	f2h_sdram_byteenable : out std_logic_vector(7 downto 0); -- byteenable
    	f2h_sdram_write : out std_logic;
    	valid : out std_logic);
end entity;

--! @brief 
architecture rtl of avalon_mem_write_64 is
	--!  
	type t_fsm is (IDLE, WRITE_DATA, DONE);
	--!  
	signal r_fsm : t_fsm;
	--! 
	signal r_cnt : integer;
begin

	p_main : process(reset, clk)
	begin
		if reset='1' then
			r_fsm <= IDLE;
			f2h_sdram_write <= '0';
			f2h_sdram_byteenable <= (others=>'1');
			f2h_sdram_address <= (others=>'0');
			f2h_sdram_burstcount <= (others=>'0');
			f2h_sdram_writedata <= (others=>'0');
			r_cnt <= 0;
		elsif rising_edge(clk) then
			case r_fsm is
			 	when IDLE =>
			 		r_cnt <= 0;
			 		if start = '1' then
			 			f2h_sdram_address <= AVALON_MEM_WRITE_ADDRESS;
						f2h_sdram_burstcount <= std_logic_vector(to_unsigned(AVALON_MEM_BURSTCOUNT,f2h_sdram_burstcount'length));
						f2h_sdram_writedata <= std_logic_vector(resize(unsigned(data_in(0)),f2h_sdram_writedata'length));
						f2h_sdram_write <= '1';
			 			r_cnt <= r_cnt + 1;
			 			r_fsm <= WRITE_DATA;
			 		end if;

				when WRITE_DATA =>
					if f2h_sdram_waitrequest = '0' then
						f2h_sdram_writedata <= std_logic_vector(resize(unsigned(data_in(r_cnt)),f2h_sdram_writedata'length));
						r_cnt <= r_cnt + 1;
						if r_cnt = AVALON_MEM_BURSTCOUNT-2 then
							r_fsm <= DONE;
						end if;
					end if;

			 	when DONE =>
					if f2h_sdram_waitrequest = '0' then
						f2h_sdram_writedata <=  std_logic_vector(resize(unsigned(data_in(r_cnt)),f2h_sdram_writedata'length));
						f2h_sdram_write <= '0';
						r_fsm <= IDLE;
					end if;

			 	when others =>
					r_fsm <= IDLE;
			end case;
		end if;
	end process; --! p_main

	valid <= '1' when r_fsm = DONE else '0';

end rtl;