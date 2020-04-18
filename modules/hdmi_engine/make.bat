
ghdl -s hdmi_sync_tb.vhd
ghdl -a hdmi_sync_tb.vhd
ghdl -e hdmi_sync_tb
ghdl -r hdmi_sync_tb --stop-time=50000000ns --vcd=hdmi_sync_tb.vcd

gtkwave hdmi_sync_tb.vcd