#import numpy
import argparse
import wavedrom
import re
import pandas as pd
import IPython

# compute aguments
#	command example:
#	python vcd2waveform.py filename -s (signals) -r (enable rising edge) -f (enable falling edge) -n (number of cycles)
#	z.B. python goertzel_tb.vcd -s clk cs mosi miso -r -f -n 25

# https://wavedrom.com/tutorial.html

MAX_N_CYCLES = 30
STD_N_CYCLES = 20
MAX_N_SIGNALS = 8
VCD_NEW_ITERATION = "#"
VCD_DATATYPE_LOGIC = 0
VCD_DATATYPE_VECTOR = 1

class signal_wd():
	name = ""
	symbol = ""
	data = []
	flip = 0
	datatype = VCD_DATATYPE_LOGIC

	def __init__(self, name):
		self.name = name
		self.symbol = ""
		self.data = []
		self.flip = 0
		self.datatype = VCD_DATATYPE_LOGIC

	def add_symbol(self, symbol):
		if symbol == '$':
			self.symbol = r'\$'
		else:
			self.symbol = symbol		

	def append_data(self, data):
		self.data.append(data)
		self.flip = 1

	def reset_flip(self):
		self.flip = 0


	def translate_data(self,data_val):
		if data_val == '.' or data_val == '0' or data_val == '1':
			return str(data_val)
		elif data_val == 'u' or data_val == 'X':
			return 'x'
		else:
			return '='

	def return_wave_string(self):
		s = '"'
		for i, data in enumerate(self.data):
			if i < len(self.data)-1:
				s = s + self.translate_data(data)
			else:
				s = s + self.translate_data(data) + '"'
		return s

	def bin_str2hex(self, data_in, index):
		try:
			s = str(hex(int(data_in.split('b')[1].strip(),2)))
		except:
			self.data[index] = 'u'
			s =""
		return s

	def return_data_string(self):
		s = '"'
		for i, data in enumerate(self.data):
			if data == '.':
				if i == len(self.data)-1:
					s = s + '"'
				pass
			else:
				if i < len(self.data)-1:
					s = s + self.bin_str2hex(str(data),i) + " "
				else:
					s = s + self.bin_str2hex(str(data),i) + '"'
		return s

	def set_datatype(self, datatype):
		self.datatype = datatype

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

	def gen_dict(self):
		dict = {}
		for signals in self.signals:
			raw = r'(?P<data>.*)'+signals.symbol+r'\n'
			dict[signals.name] = re.compile(raw)
		return dict

	def add_symbols(self, obj_match):
		for signal in self.signals:
			if signal.name == obj_match.group('name').split('[')[0]:
				signal.add_symbol(obj_match.group('symbol'))
				if obj_match.group('size')=='1':
					signal.set_datatype(VCD_DATATYPE_LOGIC)
				else:
					signal.set_datatype(VCD_DATATYPE_VECTOR)

	def add_data(self, name, obj_match):
		for signal in self.signals:
			if signal.name == name:
				signal.append_data(obj_match.group('data'))

	def check_flips(self):
		for signal in self.signals:
			if signal.flip == 0:
				signal.append_data('.')
			# after checking if flipped, reset
			signal.reset_flip()


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
	#ap.add_argument("-h", "--hscale", type=int, default=3, required=False, help="horizontal scale")
	args = vars(ap.parse_args())
	waveform_obj.load_args(args['signals'], str(args['filename']), args['rising_edge'], args['falling_edge'], args['n_cycles'])


# parse data
# @doc https://www.vipinajayakumar.com/parsing-text-with-python/
# set up regular expressions
# use https://regexper.com to visualise these if required
# https://stackoverflow.com/questions/5357460/python-regex-matching-a-parenthesis-within-parenthesis
def _parse_line(line):
	vcd_dict = {
		#'var_vector': re.compile(r'var reg (?P<size>.*) (?P<symbol>.*) (?P<name>.*)\[(.*)\] \$end\n'),
		'var': re.compile(r'var reg (?P<size>.*) (?P<symbol>.*) (?P<name>.*) \$end\n'),
		'scope': re.compile(r'scope(.*)end\n'),
		'endvar': re.compile(r'enddefinitions(.*)end\n')
	}
	for key, rx in vcd_dict.items():
		match = rx.search(line)
		if match:
			return key, match
    # if there are no matches
	return None, None

# open file
def file_handler(waveform_obj):
	with open(waveform_obj.get_filename(), 'r') as file:
		iterations = -1
		# load available signals and respective symbols
		line = file.readline()
		while line:
			key, match = _parse_line(line)
			if key == 'var':
				print("key: " + str(key))
				print("match: " + str(match.group('symbol') + " " +str(match.group('name'))))
				waveform_obj.add_symbols(match)
			if key == 'var_vector':
				print("Found vector!!!")
			elif key == 'endvar' or key == 'scope':
				break
			line = file.readline()
		
		# generate dictionary for desired signals (with symbbols)
		while line:
			key, match = _parse_line(line)
			if key == 'endvar':
				break
			line = file.readline()

		dic = waveform_obj.gen_dict()

		line = file.readline()
		while line:
			#print line_data[0]
			if line[0] == '#':
				iterations=iterations+1
				if iterations > 0:
					waveform_obj.check_flips()
					if iterations > waveform_obj.n_cycles-1:
						break
				#pass
			else:
				for key, rx in dic.items():
					match = rx.search(line)
					if match:
						waveform_obj.add_data(key, match)
			line = file.readline()


# @brief generate waveform
# Simple waveform example
#svg = wavedrom.render("""{ "signal": ["""+
# """{ "name": "CLK",  "wave": "P.......",                                              "period": 2  },"""+
# """{ "name": "CMD",  "wave": "x.3x=x4x=x=x=x=x", "data": "RAS NOP CAS NOP NOP NOP NOP", "phase": 0.5 },"""+
# """{ "name": "ADDR", "wave": "x.=x..=x........", "data": "ROW COL",                     "phase": 0.5 },"""+
# """{ "name": "DQS",  "wave": "z.......0.....z." },"""+
# """{ "name": "DQ",   "wave": "z.........z.....", "data": "D0 D1 D2 D3" }"""+
#"""]}""")
def gen_wavedrom_render(waveform_obj):

	render_str = """{ "signal": ["""
	for i, signals in enumerate(w_obj.signals):
		if signals.datatype == VCD_DATATYPE_LOGIC:
			str_wave=signals.return_wave_string()
			if i < len(w_obj.signals)-1:
				render_str = render_str + """{ "name":""" +'"'+signals.name+"""" ,  "wave":"""+str_wave+"""},"""
			else:
				render_str = render_str + """{ "name":""" +'"'+signals.name+"""" ,  "wave":"""+str_wave+"""}]}"""
		else:
			str_data=signals.return_data_string()
			str_wave=signals.return_wave_string()
			if i < len(w_obj.signals)-1:
				render_str = render_str + """{ "name":""" +'"'+signals.name+"""" ,  "wave":"""+str_wave+""",  "data":"""+str_data+"""},"""
			else:
				render_str = render_str + """{ "name":""" +'"'+signals.name+"""" ,  "wave":"""+str_wave+""",  "data":"""+str_data+"""}]}"""
		#print(signals.name+" "+signals.symbol+" "+str(signals.data))	

	print(render_str)
	# generate .svg file
	svg = wavedrom.render(render_str)
	# try to save file
	try:
		svg_filename = waveform_obj.filename.split('.')[0] +"_waveform.svg"
		svg.saveas(svg_filename)
		print("File succefully generated as "+svg_filename)
	except:
		print("Failed to generate file.")
	
	#return svg

if __name__=="__main__":
	w_obj = waveform_obj()
	parse_arg(w_obj)
	file_handler(w_obj)
	gen_wavedrom_render(w_obj)
	# convert .svg to .jpeg?

