
from numpy import *

iterations = 16
res = 7
print("iteration arctan degrees(arctan) hex ")
for i in range(0, iterations):
    at = arctan(2.0**(-i))
    print(i, at, degrees(at), round(sqrt(2)*degrees(at)*2**res))#, hex(degrees(at)*2**res))



print("iteration cos degrees(cos) ")
for i in range(0, 2**res):
    at = cos(2.0*pi*(i/2.0**res))
    print(i, at, degrees(at))#, hex(degrees(at)*2**res))

 