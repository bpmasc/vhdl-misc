
ghdl -s fib_seq.vhd fib_seq_tb.vhd
ghdl -a fib_seq.vhd fib_seq_tb.vhd
ghdl -e fib_seq_tb
ghdl -r fib_seq_tb --stop-time=50000ns --vcd=fib_seq_tb.vcd

gtkwave fib_seq_tb.vcd