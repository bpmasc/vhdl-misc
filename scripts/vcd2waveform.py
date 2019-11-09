import numpy
import argparse
import wavedrom

# compute aguments
#	command example:
#	python vcd2waveform.py filename -s (signals) -r (enable rising edge) -f (enable falling edge) -n (number of cycles)
#	z.B. python goertzel_tb.vcd -s clk cs mosi miso -r -f -n 25

# @doc https://docs.python.org/3/library/argparse.html
def parse_arg():
	# Get the arguments from the command-line except the filename
	# Construct the argument parser
	ap = argparse.ArgumentParser()

	# Add the arguments to the parser
	ap.add_argument('filename', help="filename")
	ap.add_argument("-s", "--signals", required=True, help="signals",nargs='*')
	ap.add_argument("-r", "--rising_edge", required=False, 	nargs='?', default=False, help="enable rising edge")
	ap.add_argument("-f", "--falling_edge", required=False, nargs='?', default=False, help="enable falling edge")
	ap.add_argument("-n", "--n_cycles", type=int, default=20, required=False, help="number of cycles")
	args = vars(ap.parse_args())


	# Calculate the sum
	print("Filename: {}".format(str(args['filename'])))
	print("Enable rising edge: {}".format(str(args['rising_edge'])))
	print("Enable falling edge: {}".format(str(args['falling_edge'])))
	#print("Sum is {}".format(int(args['foperand']) + int(args['soperand'])))



# open file

# parse data

# generate waveform

# Simple waveform example
#svg = wavedrom.render("""
#{ "signal": [
# { "name": "CLK",  "wave": "P.......",                                              "period": 2  },
# { "name": "CMD",  "wave": "x.3x=x4x=x=x=x=x", "data": "RAS NOP CAS NOP NOP NOP NOP", "phase": 0.5 },
# { "name": "ADDR", "wave": "x.=x..=x........", "data": "ROW COL",                     "phase": 0.5 },
# { "name": "DQS",  "wave": "z.......0.....z." },
# { "name": "DQ",   "wave": "z.........z.....", "data": "D0 D1 D2 D3" }
#]}""")
#svg.saveas("demo1.svg")

# convert .svg to .jpeg?
parse_arg()