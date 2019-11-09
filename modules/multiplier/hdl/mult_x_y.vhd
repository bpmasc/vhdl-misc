--! TODO description
library IEEE;
--! TODO description
use IEEE.numeric_std.all;
--! TODO description
use IEEE.std_logic_1164.all;


--! TODO brief
entity mult_x_y is
    generic( 
        N: integer := 16
    );
    port( 
        clk : in std_logic;
        reset : in std_logic;
        start : in std_logic;
        x : in signed(N-1 downto 0);
        y : in signed(N-1 downto 0);
        z : out signed(2*N-1 downto 0);
        valid : out std_logic);
end;



--! TODO brief
architecture rtl of mult_x_y is
    
    --! TODO description
    type FSM_t is (IDLE, MULTIPLY, FLIP, DONE);
    --! TODO description
    signal r_x : signed(2*N-1 downto 0);
    --! TODO description
    signal r_y : signed(N-1 downto 0);
    --! TODO description
    signal r_z : signed(2*N-1 downto 0);
    --! TODO description
    signal state : FSM_t;
    --! TODO description
    signal cnt : integer range 0 to N+1;--    : integer;

    signal r_negative_mult: std_logic;
begin
    process (clk, reset) begin
            if reset = '1' then
                r_x <= to_signed(0, 2*N);
                r_y <= to_signed(0, N);
                r_z <= to_signed(0, 2*N);
                z <= to_signed(0, 2*N);
                state <= IDLE;
                cnt <= 0;
                r_negative_mult  <= '0';
            elsif rising_edge(clk) then

                case state is
                    when IDLE =>
                        r_x <= to_signed(0, 2*N);
                        r_y <= to_signed(0, N);
                        r_z <= to_signed(0, 2*N);
                        z <= to_signed(0, 2*N);
                        cnt <= 0;  
                        if start = '1' then
                            r_x <= resize(x, 32);
                            if y <0 then
                                r_y <= -y;
                                r_negative_mult <= '1';
                            else
                                r_y <= y;
                                r_negative_mult <= '0';
                            end if;
                            state <= MULTIPLY;
                        end if;

                    when MULTIPLY =>
                        cnt <= cnt + 1;
                        if cnt < N then -- can i check if y different than 0 ?? -> and remove cnt at the same time
                            if r_y(0)='1' then
                                r_z <= r_z + r_x;
                            end if;
                            r_x <= shift_left(r_x, 1);  -- get bigger  (x2)
                            r_y <= shift_right(r_y, 1); -- pick high bits (/2)
                        else
                            state <= FLIP;
                        end if;


                    when FLIP =>
                        if r_negative_mult= '1' then
                            z <= -r_z;
                        else
                            z <= r_z;
                        end if;
                        state <= DONE;

                    when DONE =>
                        if start = '0' then
                            state <= IDLE;
                        end if;

                    when OTHERS =>                        
                        state <= IDLE; --! nothing useful
                end case;
            end if;
    end process;

    valid  <= '1' when state = DONE else '0';
    
end rtl;