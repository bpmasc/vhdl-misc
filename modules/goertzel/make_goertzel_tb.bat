
ghdl -s basic_goertzel.vhd goertzel_tb.vhd
ghdl -a basic_goertzel.vhd goertzel_tb.vhd
ghdl -e goertzel_tb
ghdl -r goertzel_tb --stop-time=25000ns --vcd=goertzel_tb.vcd

gtkwave goertzel_tb.vcd