--! TODO description
library IEEE;
--! TODO description
use IEEE.numeric_std.all;
--! TODO description
use IEEE.std_logic_1164.all;


--! TODO brief
entity mult_matrix_3_3 is
    generic( 
        N: integer := 16,
        gen_deterministic : boolean := True
    );
    port( 
        clk : in std_logic;
        reset : in std_logic;
        start : in std_logic;
        m_in_1 : in t_matrix_3_3;
        m_in_2 : in t_matrix_3_3;
        m_out : out t_matrix_3_3;
        valid : out std_logic);
end;


   
--! TODO brief
architecture rtl of mult_matrix_3_3 is
    
    --! TODO description
    type t_fsm is (IDLE, MULTIPLY, WAIT_MULT, DONE);
    --! TODO description
    signal r_x1 : signed(2*N-1 downto 0);
    --! TODO description
    signal r_x2 : signed(2*N-1 downto 0);
    --! TODO description
    signal r_x3 : signed(2*N-1 downto 0);
    --! TODO description
    signal r_y : signed(N-1 downto 0);
    --! TODO description 
    signal r_z1_a : signed(2*N-1 downto 0);
    --! TODO description
    signal r_z2_b : signed(2*N-1 downto 0);
    --! TODO description
    signal r_z3_c : signed(2*N-1 downto 0);
    --! TODO description
    signal r_state : t_fsm;
    --! TODO description
    signal r_row_pointer : integer range 0 to 7 := 0;--    : integer;

begin

--          M1        M2       M3
-- step 1
-- o11 = a11*b11 + a12*b21 + a13*b31 
-- o12 = a11*b21 + a12*b22 + a13*b32
-- o13 = a11*b31 + a12*b23 + a13*b33
-- step 2
-- o21 = a21*b11 + a22*b21 + a23*b31 
-- o22 = a21*b21 + a22*b22 + a23*b32
-- o23 = a21*b31 + a22*b23 + a23*b33
-- step 3
-- o31 = a31*b11 + a32*b21 + a33*b31 
-- o32 = a31*b21 + a32*b22 + a33*b32
-- o33 = a31*b31 + a32*b23 + a33*b33


inst_mult_a : entity work.mult_x1_x2_x3_y
    port( 
        clk => clk,
        reset => reset,
        start => r_start_mult_a,
        x1 => r_x1_a,
        x2  => r_x2_a,
        x3  => r_x3_a,
        y  => r_y_a,
        z1  => r_z1_a,
        z2 => r_z2_a,
        z3  => r_z3_a,
        valid => r_valid_a); 

inst_mult_b : entity work.mult_x1_x2_x3_y
    port( 
        clk => clk,
        reset => reset,
        start => r_start_mult_b,
        x1 => r_x1_b,
        x2  => r_x2_b,
        x3  => r_x3_b,
        y  => r_y_b,
        z1  => r_z1_b,
        z2 => r_z2_b,
        z3  => r_z3_b,
        valid => r_valid_b);

inst_mult_a : entity work.mult_x1_x2_x3_y
    port( 
        clk => clk,
        reset => reset,
        start => r_start_mult_c,
        x1 => r_x1_c,
        x2  => r_x2_c,
        x3  => r_x3_c,
        y  => r_y_c,
        z1  => r_z1_c,
        z2 => r_z2_c,
        z3  => r_z3_c,
        valid => r_valid_c);

    process (clk, reset) begin
            if reset = '1' then
                r_x1_a <= to_signed(0, 2*N);
                r_x2_a <= to_signed(0, 2*N);
                r_x3_a <= to_signed(0, 2*N);
                r_y_a <= to_signed(0, N);
                r_z1_a <= to_signed(0, 2*N);
                r_z2_a <= to_signed(0, 2*N);
                r_z3_a <= to_signed(0, 2*N);
                r_x1_b <= to_signed(0, 2*N);
                r_x2_b <= to_signed(0, 2*N);
                r_x3_b <= to_signed(0, 2*N);
                r_y_b <= to_signed(0, N);
                r_z1_b <= to_signed(0, 2*N);
                r_z2_b <= to_signed(0, 2*N);
                r_z3_b <= to_signed(0, 2*N);
                r_x1_c <= to_signed(0, 2*N);
                r_x2_c <= to_signed(0, 2*N);
                r_x3_c <= to_signed(0, 2*N);
                r_y_c <= to_signed(0, N);
                r_z1_c <= to_signed(0, 2*N);
                r_z2_c <= to_signed(0, 2*N);
                r_z3_c <= to_signed(0, 2*N);


                r_start_mult_a <= '0';
                r_start_mult_b <= '0';
                r_start_mult_c <= '0';

                r_row_pointer <= 0;
                m_out <= (others => (others => '0'));
                r_m_out <= (others => (others => '0'));

                r_state <= IDLE;
            elsif rising_edge(clk) then

                case r_state is
                    when IDLE =>

                        r_row_pointer <= 0;

                        if start = '1' then
                            --! load multipliers
                            r_x1_a <= m_in_2[0][0];
                            r_x2_a <= m_in_2[0][1];
                            r_x3_a <= m_in_2[0][2];
                            r_y_a <= m_in_1[r_row_pointer][0];
                            r_x1_b <= m_in_2[1][0];
                            r_x2_b <= m_in_2[1][1];
                            r_x3_b <= m_in_2[1][2];
                            r_y_b <= m_in_1[r_row_pointer][1];
                            r_x1_c <= m_in_2[2][0];
                            r_x2_c <= m_in_2[2][1];
                            r_x3_c <= m_in_2[2][2];
                            r_y_c <= m_in_1[r_row_pointer][2];
                            --! start multipliers
                            r_start_mult_a <= '1';
                            r_start_mult_b <= '1';
                            r_start_mult_c <= '1';

                            r_state <= WAIT_MULT;
                        end if;

                    when WAIT_MULT =>
                        if r_valid_a = '1' and r_valid_b = '1' and r_valid_c = '1' then
                            --! release multipliers
                            r_start_mult_a <= '0';
                            r_start_mult_b <= '0';
                            r_start_mult_c <= '0';
                            --! sum and load output
                            r_m_out[r_row_pointer][0] <= r_z1_a + r_z1_b + r_z1_c;
                            r_m_out[r_row_pointer][1] <= r_z2_a + r_z2_b + r_z2_c;
                            r_m_out[r_row_pointer][2] <= r_z3_a + r_z3_b + r_z3_c;
                            if r_row_pointer < 3 then
                                r_row_pointer <= r_row_pointer + 1;
                                r_state <= MULTIPLY;
                            else
                                r_state <= DONE;
                            end if;
                        end if;


                    when MULTIPLY =>
                        --! start multipliers
                        r_start_mult_a <= '1';
                        r_start_mult_b <= '1';
                        r_start_mult_c <= '1';
                        --! load multipliers
                        r_x1_a <= m_in_2[0][0];
                        r_x2_a <= m_in_2[0][1];
                        r_x3_a <= m_in_2[0][2];
                        r_y_a <= m_in_1[r_row_pointer][0];
                        r_x1_b <= m_in_2[1][0];
                        r_x2_b <= m_in_2[1][1];
                        r_x3_b <= m_in_2[1][2];
                        r_y_b <= m_in_1[r_row_pointer][1];
                        r_x1_c <= m_in_2[2][0];
                        r_x2_c <= m_in_2[2][1];
                        r_x3_c <= m_in_2[2][2];
                        r_y_c <= m_in_1[r_row_pointer][2];
                        r_state <= WAIT_MULT;

                    when DONE =>
                        if start = '0' then
                            r_row_pointer <= 0;
                            m_out <= r_m_out;
                            r_state <= IDLE;
                        end if;

                    when OTHERS =>                        
                        r_state <= IDLE; --! nothing useful
                end case;
            end if;
    end process;

    valid  <= '1' when r_state = DONE else '0';
    
end rtl;