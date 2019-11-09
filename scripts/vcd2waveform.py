import numpy
import argparse
import wavedrom
import re
import pandas as pd
# compute aguments
#	command example:
#	python vcd2waveform.py filename -s (signals) -r (enable rising edge) -f (enable falling edge) -n (number of cycles)
#	z.B. python goertzel_tb.vcd -s clk cs mosi miso -r -f -n 25

MAX_N_CYCLES = 30
STD_N_CYCLES = 20

MAX_N_SIGNALS = 8

VCD_SIGNAL_DECLARATION = "$var"
VCD_SIGNAL_DECLARATION_END = "$end"
VCD_END_DEFINITIONS = "$enddefinitions"
VCD_NEW_ITERATION = "#"

class signal_wd():
	name = ""
	symbol = ""
	data = []
	
	def __init__(self, name):
		self.name = name
		self.symbol = ""
		self.data = []

# https://docs.python.org/3/tutorial/classes.html
class waveform_obj():
	signals = []
	filename = ""
	rising_edge = False
	falling_edge = False
	n_cycles = 20

	# init
	def __init__(self):
		self.signals = []
		self.filename = ""
		self.rising_edge = False
		self.falling_edge = False
		self.n_cycles = 20
	
	def load_args(self, signals, filename, rising_edge, falling_edge, num_cycles):		
		self.load_signals(signals)
		self.filename = filename
		self.load_rising_edge(rising_edge)
		self.load_falling_edge(falling_edge)
		self.check_n_cycles(num_cycles)

	def check_n_cycles(self,n_cycles):
		if n_cycles > MAX_N_CYCLES:
			self.n_cycles = MAX_N_CYCLES
		elif n_cycles == None or n_cycles < 1:
			self.n_cycles = STD_N_CYCLES
		else:
			self.n_cycles = n_cycles
	
	def load_signals(self,signals_arg):
		for name in signals_arg:
			self.signals.append(signal_wd(name))

	def get_filename(self):
		return self.filename
	
	def load_rising_edge(self, re):
		if re == False:
			self.rising_edge = False
		else:
			self.rising_edge = True
	
	def load_falling_edge(self, fe):
		if fe == False:
			self.falling_edge = False
		else:
			self.falling_edge = True

# @doc https://docs.python.org/3/library/argparse.html
def parse_arg(waveform_obj):
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

	waveform_obj.load_args(args['signals'], str(args['filename']), args['rising_edge'], args['falling_edge'], args['n_cycles'])

# open file
def file_handler(waveform_obj):
	with open(waveform_obj.get_filename()) as file:
		file_contents = file.read()
		print(file_contents)

# parse data
# @doc https://www.vipinajayakumar.com/parsing-text-with-python/





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

if __name__=="__main__":
	w_obj = waveform_obj()
	# convert .svg to .jpeg?
	parse_arg(w_obj)
	file_handler(w_obj)
