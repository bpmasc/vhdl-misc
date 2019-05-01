
from numpy import *

iterations = 16
res = 8
print "iteration arctan degrees(arctan) hex "
for i in range(0, iterations):
    at = arctan(2.0**(-i))
    print i, at, degrees(at), round(degrees(at)*2**res), hex(degrees(at)*2**res)

