
ghdl -s mult_common_pkg.vhd mult_x1_x2_x3_y.vhd mult_matrix_3_3_s16.vhd mult_matrix_3_3_s16_tb.vhd
ghdl -a mult_common_pkg.vhd mult_x1_x2_x3_y.vhd mult_matrix_3_3_s16.vhd mult_matrix_3_3_s16_tb.vhd
ghdl -e mult_matrix_3_3_s16_tb
ghdl -r mult_matrix_3_3_s16_tb --stop-time=25000ns --vcd=mult_matrix_3_3_s16_tb.vcd

gtkwave mult_matrix_3_3_s16_tb.vcd