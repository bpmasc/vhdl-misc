--! TODO description
library ieee;
--! TODO description
use ieee.numeric_std.all;
--! TODO description
use ieee.std_logic_1164.all;

package i2c_utils_pkg is  
    

    constant c_i2c_write_mode : std_logic := '1';
    constant c_i2c_read_mode : std_logic := '0';

    constant c_i2c_read_seq_cycles : natural := 4;
    constant c_i2c_write_seq_cycles : natural := 3;

    constant gen_i2c_tbuff : time := 200000 ns; --2000
    constant gen_i2c_tstah : time := 40000 ns; --600

	 
    --! 
    type t_i2c_ctrl is record
        dev_addr : std_logic_vector(6 downto 0);
        iteration : integer;
        r_nw : std_logic;
        base_addr : std_logic_vector(7 downto 0);
        write_data : std_logic_vector(7 downto 0);
        read_data : std_logic_vector(7 downto 0);
    end record t_i2c_ctrl;
    
    --! (addr, value)
    type t_i2c_seq is array (0 to 3) of std_logic_vector(7 downto 0);

    --function function_name (parameters) return type;
    function load_dev_addr(dev_addr : std_logic_vector; mode : std_logic) return std_logic_vector;
    function load_data(data : std_logic_vector) return std_logic_vector;
    function get_seq_cycles(i2c_ch : t_i2c_ctrl) return natural;
    
    function load_seq(i2c_ch : t_i2c_ctrl) return t_i2c_seq;

    --type i2c_ctrl_void is (void);
    --function init(v : i2c_ctrl_void) return t_i2c_ctrl;
    function init(v : std_logic_vector) return t_i2c_ctrl;
    procedure i2c_write_single(signal b_addr : in std_logic_vector; signal data : in std_logic_vector; signal i2c_ch : inout t_i2c_ctrl);
    procedure i2c_read_single(signal b_addr : in std_logic_vector; signal i2c_ch : inout t_i2c_ctrl);
    procedure i2c_store_rec(signal rec : in std_logic_vector; signal i2c_ch : inout t_i2c_ctrl);
    --procedure i2c_(signal ptr : in integer; signal i2c_ch : inout t_i2c_ctrl);

end i2c_utils_pkg;

package body i2c_utils_pkg is
  
  --function function_name (parameters) return type is
  --  declarations
  -- begin
  --   sequential statements
  --end function function_name;
function init(v : std_logic_vector) return t_i2c_ctrl is
    variable r : t_i2c_ctrl;
begin
    r.dev_addr := v;
    r.iteration := 0;
    r.r_nw := '0';
    r.base_addr := (others=>'0');
    r.write_data := (others=>'0');
    r.read_data := (others=>'0');
    return r;
end function;


function load_dev_addr(dev_addr : std_logic_vector; mode : std_logic) return std_logic_vector is
    variable r : std_logic_vector(7 downto 0);
begin
    r(7 downto 1) := dev_addr;
    r(0) := mode;
    return r;
end function;


function load_data(data : std_logic_vector) return std_logic_vector is
    variable r : std_logic_vector(7 downto 0);
begin
    r := data;
    return r;
end function;


function get_seq_cycles(i2c_ch : t_i2c_ctrl) return natural is
    variable r : natural;
begin
    if i2c_ch.r_nw = '0' then
        r := c_i2c_write_seq_cycles;
    else
        r := c_i2c_read_seq_cycles;
    end if;
    return r;
end function;

--! Single write seq
--! start | dev_addr & R_nW ('0') | ack | reg_addr | ack | 
--! write_data | ack | stop

--! Single read seq
--! start | dev_addr & R_nW ('0') | ack | reg_addr | ack | 
--! start | dev_addr & R_nW ('1') | ack | read_data | ack | stop

function load_seq(i2c_ch : t_i2c_ctrl) return t_i2c_seq is
    variable r : t_i2c_seq;
begin
    r(0) := i2c_ch.dev_addr & '0';
    r(1) := i2c_ch.base_addr;
    if i2c_ch.r_nw = '0' then
        r(2) := i2c_ch.write_data;
        r(3) := "00000000";
    else
        r(2) := i2c_ch.dev_addr & '1';
        r(3) := "11111111";
    end if;
    return r;
end function;

procedure i2c_write_single(signal  b_addr : in std_logic_vector; signal  data : in std_logic_vector; signal i2c_ch : inout t_i2c_ctrl) is
begin
    i2c_ch.iteration <= i2c_ch.iteration + 1;
    i2c_ch.r_nw <= '0';
    i2c_ch.base_addr <= b_addr;
    i2c_ch.write_data <= data;
end procedure;

procedure i2c_read_single(signal b_addr : in std_logic_vector; signal i2c_ch : inout t_i2c_ctrl) is
begin
    i2c_ch.iteration <= i2c_ch.iteration + 1;
    i2c_ch.r_nw <= '1';
    i2c_ch.base_addr <= b_addr;
end procedure;


procedure i2c_store_rec(signal rec : in std_logic_vector; signal i2c_ch : inout t_i2c_ctrl) is
begin
    i2c_ch.read_data <= rec;
end procedure;

end i2c_utils_pkg;
