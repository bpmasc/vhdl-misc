
ghdl -s cordic_common_pkg.vhd srs_tb.vhd
ghdl -a cordic_common_pkg.vhd srs_tb.vhd
ghdl -e srs_tb
ghdl -r srs_tb --stop-time=15000ns --vcd=srs_tb.vcd

gtkwave srs_tb.vcd