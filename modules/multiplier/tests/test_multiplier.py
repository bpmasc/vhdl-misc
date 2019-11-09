# Simple tests for an adder module
import cocotb
from cocotb.triggers import Timer
from cocotb.result import TestFailure
from multiplier_model import multiplier_model
import random

@cocotb.test()
def mult_basic_test(dut):
    """Test for 5 + 10"""
    yield Timer(2)
    A = 5
    B = 10
    dut.A = A
    dut.B = B
    yield Timer(2)
    if int(dut.X) != multiplier_model(A, B):
        raise TestFailure(
            "Adder result is incorrect: %s != 15" % str(dut.X))
    else:  # these last two lines are not strictly necessary
        dut._log.info("Ok!")

@cocotb.test()
def mult_randomised_test(dut):
    """Test for adding 2 random numbers multiple times"""
    yield Timer(2)
    for i in range(10):
        A = random.randint(0, 15)
        B = random.randint(0, 15)
        dut.A = A
        dut.B = B
        yield Timer(2)
        if int(dut.X) != multiplier_model(A, B):
            raise TestFailure(
                "Randomised test failed with: %s + %s = %s" %
                (int(dut.A), int(dut.B), int(dut.X)))
        else:  # these last two lines are not strictly necessary
            dut._log.info("Ok!")