library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hdmi_sync_tb is
end; 

architecture rtl of hdmi_sync_tb is
  
    --! clk
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';
    --! hdmi sync signals
    signal start : std_logic;

    --! Horizontal timmings
    constant c_h_ap : integer := 1920;  --! Active pixels
    constant c_h_fp : integer := 88;    --! Front porch
    constant c_h_sw : integer := 44;    --! Sync width
    constant c_h_bp : integer := 148;   --!  Back porch
    constant c_h_bt : integer := c_h_fp + c_h_sw + c_h_bp; --! Blanking total
    constant c_h_tp : integer := c_h_ap + c_h_bt; --! Total pixels
    constant c_h_pol : std_logic := '1'; --! Polarity. 1- Positive, 0-negative
    --! Vertical timmings
    constant c_v_ap : integer := 1080;  --! Active pixels
    constant c_v_fp : integer := 4;    --! Front porch
    constant c_v_sw : integer := 5;    --! Sync width
    constant c_v_bp : integer := 36;   --!  Back porch
    constant c_v_bt : integer := c_v_fp + c_v_sw + c_v_bp; --! Blanking total
    constant c_v_tp : integer := c_v_ap + c_v_bt; --! Total pixels
    constant c_v_pol : std_logic := '1'; --! Polarity. 1- Positive, 0-negative

        -- Video data input in RGB or YCbCr format.
        signal d :  std_logic_vector(23 downto 0);
        -- DE and sync signals. Embedded...  -> configure registers at startup accordingly
        signal vsync :  std_logic;      --! Vertical sync input
        signal hsync :  std_logic;      --! Horizontal sync input
        --clk_out : out std_logic;    --! Video clock input
        signal de : std_logic;         --! Data Enable signal for digital video
        signal valid : std_logic;
        signal r_cnt_1 : integer;
        signal r_cnt_2 : integer;
begin
	 


    --! Main loop
    p_main : process (clk, rst) 
	 		variable v_h_cnt : integer := 0;
			variable v_v_cnt : integer := 0;
        begin
            if rst = '1' then
                v_v_cnt := 0;
					 v_h_cnt := 0;
					 de <= '1';
					 hsync <= not c_h_pol;
					 vsync <= not c_v_pol;
					 r_cnt_1 <= 0;
					 r_cnt_2 <= 0;
		      elsif rising_edge(clk) then --! synchronized with hdmi_clk
				
					if v_h_cnt=c_h_tp-1 then 
						if v_v_cnt < c_v_tp-1 then
							v_v_cnt := v_v_cnt + 1;
						else
							v_v_cnt := 0;
						end if;
					end if;
					
					if v_h_cnt < c_h_tp-1 then
						v_h_cnt := v_h_cnt + 1;
					else
						v_h_cnt := 0;
					end if;
					

					r_cnt_1 <= v_h_cnt;
					r_cnt_2 <= v_v_cnt;

					if ((v_h_cnt < c_h_ap+c_h_fp) or (v_h_cnt > c_h_ap+c_h_fp+c_h_sw)) then
						hsync <= not c_h_pol;
					else
						hsync <= c_h_pol;
					end if;
					
					if ((v_v_cnt < c_v_ap+c_v_fp) or (v_v_cnt > c_v_ap+c_v_fp+c_v_sw)) then
						vsync <= not c_v_pol;
					else
						vsync <= c_v_pol;
					end if;
					
					if (v_h_cnt <= c_h_ap and v_v_cnt <= c_v_ap) then
						de <= '1';
					else
						de <= '0';
					end if;
					
				end if;
		end process;

	--============================================
	p_rst: process
	begin
	  rst <= '1';
	  wait for 50 ns;
	  rst <= '0';  
	  wait;
	end process;

	--============================================
	p_clock: process
	begin
	  wait for 10 ns;
	  clk <= not clk;
	end process;

	--============================================
	
	p_stimulus : process
	begin
	    -- 0
	    --wait until rst='0';
	    start <= '0';
	    wait until clk='1' and rst='0';
	    start <= '1';
	    wait;
	end process;

end rtl;
