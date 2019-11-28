--! TODO description
library IEEE;
--! TODO description
use IEEE.numeric_std.all;
--! TODO description
use IEEE.std_logic_1164.all;


--! TODO brief
entity mult_x1_x2_y is
    generic( 
        N: integer := 16,
        gen_deterministic : boolean := True
    );
    port( 
        clk : in std_logic;
        reset : in std_logic;
        start : in std_logic;
        x1 : in signed(N-1 downto 0);
        x2 : in signed(N-1 downto 0);
        y : in signed(N-1 downto 0);
        z1 : out signed(2*N-1 downto 0);
        z2 : out signed(2*N-1 downto 0);
        valid : out std_logic);
end;

   
--! TODO brief
architecture rtl of mult_x1_x2_y is
    
    --! TODO description
    type t_fsm is (IDLE, MULTIPLY, FLIP, DONE);
    --! TODO description
    signal r_x1 : signed(2*N-1 downto 0);
    --! TODO description
    signal r_x2 : signed(2*N-1 downto 0);
    --! TODO description
    signal r_y : signed(N-1 downto 0);
    --! TODO description
    signal r_z1 : signed(2*N-1 downto 0);
    --! TODO description
    signal r_z2 : signed(2*N-1 downto 0);
    --! TODO description
    signal r_state : t_fsm;
    --! TODO description
    signal r_cnt : integer range 0 to N+1;--    : integer;
    --! TODO description
    signal r_negative_mult: std_logic;

begin
    process (clk, reset) begin
            if reset = '1' then
                r_x1 <= to_signed(0, 2*N);
                r_x2 <= to_signed(0, 2*N);
                r_y <= to_signed(0, N);
                r_z1 <= to_signed(0, 2*N);
                r_z2 <= to_signed(0, 2*N);
                z1 <= to_signed(0, 2*N);
                z2 <= to_signed(0, 2*N);
                r_state <= IDLE;
                r_cnt <= 0;
                r_negative_mult  <= '0';
            elsif rising_edge(clk) then

                case r_state is
                    when IDLE =>
                        r_x1 <= to_signed(0, 2*N);
                        r_x2 <= to_signed(0, 2*N);
                        r_y <= to_signed(0, N);
                        r_z1 <= to_signed(0, 2*N);
                        r_z2 <= to_signed(0, 2*N);
                        z1 <= to_signed(0, 2*N);
                        z2 <= to_signed(0, 2*N);
                        r_cnt <= 0;  
                        if start = '1' then
                            r_x1 <= resize(x1, 32);
                            r_x2 <= resize(x2, 32);
                            if y <0 then
                                r_y <= -y;
                                r_negative_mult <= '1';
                            else
                                r_y <= y;
                                r_negative_mult <= '0';
                            end if;
                            r_state <= MULTIPLY;
                        end if;

                    when MULTIPLY =>
                        r_cnt <= r_cnt + 1;
                        if r_cnt < N then -- can i check if y different than 0 ?? -> and remove cnt at the same time
                            if r_y(0)='1' then
                                r_z1 <= r_z1 + r_x1;
                                r_z2 <= r_z2 + r_x2;
                            end if;
                            r_x1 <= shift_left(r_x1, 1);  -- get bigger  (x2)
                            r_x2 <= shift_left(r_x2, 1);  -- get bigger  (x2)
                            r_y <= shift_right(r_y, 1); -- pick high bits (/2)
                        else
                            r_state <= FLIP;
                        end if;


                    when FLIP =>
                        if r_negative_mult= '1' then
                            z1 <= -r_z1;
                            z2 <= -r_z2;
                        else
                            z1 <= r_z1;
                            z2 <= r_z2;
                        end if;
                        r_state <= DONE;

                    when DONE =>
                        if start = '0' then
                            r_state <= IDLE;
                        end if;

                    when OTHERS =>                        
                        r_state <= IDLE; --! nothing useful
                end case;
            end if;
    end process;

    valid  <= '1' when r_state = DONE else '0';
    
end rtl;