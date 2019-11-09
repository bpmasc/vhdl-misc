# @brief https://pypi.org/project/wavedrom/

import wavedrom

# Simple waveform example
svg = wavedrom.render("""
{ "signal": [
 { "name": "CLK",  "wave": "P.......",                                              "period": 2  },
 { "name": "CMD",  "wave": "x.3x=x4x=x=x=x=x", "data": "RAS NOP CAS NOP NOP NOP NOP", "phase": 0.5 },
 { "name": "ADDR", "wave": "x.=x..=x........", "data": "ROW COL",                     "phase": 0.5 },
 { "name": "DQS",  "wave": "z.......0.....z." },
 { "name": "DQ",   "wave": "z.........z.....", "data": "D0 D1 D2 D3" }
]}""")

svg.saveas("demo1.svg")
