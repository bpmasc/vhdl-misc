ghdl -s avalon_mem_pkg.vhd avalon_mem_write_64.vhd avalon_mem_read_32.vhd avalon_mem_tb.vhd
ghdl -a avalon_mem_pkg.vhd avalon_mem_write_64.vhd avalon_mem_read_32.vhd avalon_mem_tb.vhd
ghdl -e avalon_mem_tb
ghdl -r avalon_mem_tb --stop-time=100000ns --vcd=avalon_mem_tb.vcd
gtkwave avalon_mem_tb.vcd