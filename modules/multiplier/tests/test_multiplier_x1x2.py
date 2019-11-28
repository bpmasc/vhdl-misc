# Simple tests for an adder module
import cocotb
from cocotb.triggers import Timer
from cocotb.result import TestFailure
from multiplier_model import multiplier_model
import random
import numpy as np
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, ReadOnly, FallingEdge

def gen_sin(d=0):
    t = np.linspace(-np.pi, np.pi, 500)
    return  np.sin(t)

def translate_res(val, N = 32):
    if int(val) >= 2**(N-1):
        return -2**N+int(val)
    else:
        return int(val)

# generate reset
@cocotb.coroutine
def reset_dut(dut, duration):
    dut.reset <= 1
    yield Timer(duration, units='ns')
    dut.reset <= 0

# generate clock
@cocotb.coroutine
def clock_dut(dut, en = False):
    while en == True:
        dut.clk = 0
        yield Timer(10, units='ns')
        dut.clk = 1
        yield Timer(10, units='ns')

@cocotb.test()
def mult_basic_test(dut):
    """Test basic multiplication"""
    
    A = 5
    B = 10
    # initialize dut inputs
    dut.start = 0
    dut.x1 = 0
    dut.y = 0
    
    # sequentially do reset
    yield reset_dut(dut, 200)
    dut._log.debug("After reset")

    # Fork parallel clock thread
    cocotb.fork(Clock(dut.clk, 10, units='ns').start())

    for val in gen_sin():
        dut.start = 1
        dut.x1 = 1
        dut.y = int(2**15 * val)
        
        #yield RisingEdge(dut.clk)
        #yield FallingEdge(dut.clk)
        yield Timer(20, units='ns')
        dut.start = 0

        yield RisingEdge(dut.valid)

        if multiplier_model(1, int(2**15 * val)) != translate_res(dut.z1) :
        #if int(dut.z) != multiplier_model(A, B):
            raise TestFailure("For val = "+ str(val) +"Multiplier result is incorrect: "+str(multiplier_model(1, int(2**15 * val)))+" != " + str(translate_res(dut.z)))
        else:  # these last two lines are not strictly necessary
            dut._log.info("Ok! For val = "+ str(val) +"Multiplier result is correct: "+str(multiplier_model(1, int(2**15 * val)))+" = " + str(translate_res(dut.z)))
        
        yield FallingEdge(dut.valid)        
        

    # stop clock
    #clock_dut(False)

@cocotb.test()
def mult_randomised_test(dut):
    """Test for multiplying 2 random numbers several times"""
    yield Timer(2)

    # initialize dut inputs
    dut.start = 0
    dut.x1 = 0
    dut.x2 = 0
    dut.y = 0

    # sequentially do reset
    yield reset_dut(dut, 200)
    dut._log.debug("After reset")

    for i in range(10):
        A1 = random.randint(0, 2**15)
        A2 = random.randint(0, 2**15)
        B = random.randint(0, 2**15)
        dut.x1 = A1
        dut.x2 = A2
        dut.y = B
        yield Timer(2)
        if A1*B !=translate_res(dut.z1):
        #if int(dut.z) != multiplier_model(A, B):
            raise TestFailure("Randomised test failed with: %s * %s = %s" %(int(dut.x), int(dut.y), int(dut.z1)))
        elif A2*B != translate_res(dut.z2):
        #if int(dut.z) != multiplier_model(A, B):
            raise TestFailure("Randomised test failed with: %s * %s = %s" %(int(dut.x), int(dut.y), int(dut.z2)))
        else:  # these last two lines are not strictly necessary
            dut._log.info("Ok!")