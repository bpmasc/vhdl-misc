ghdl -s adc124s_utils_pkg.vhd adc124s.vhd adc124s_tb.vhd
ghdl -a adc124s_utils_pkg.vhd adc124s.vhd adc124s_tb.vhd
ghdl -e adc124s_tb
ghdl -r adc124s_tb --stop-time=80000ns --vcd=adc124s_tb.vcd
gtkwave adc124s_tb.vcd