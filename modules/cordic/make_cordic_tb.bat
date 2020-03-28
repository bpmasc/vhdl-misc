
ghdl -s cordic_common_pkg.vhd cordic_rot.vhd cordic_rot_tb.vhd
ghdl -a cordic_common_pkg.vhd cordic_rot.vhd cordic_rot_tb.vhd
ghdl -e cordic_rot_tb
ghdl -r cordic_rot_tb --stop-time=50000ns --vcd=cordic_rot_tb.vcd

gtkwave cordic_rot_tb.vcd