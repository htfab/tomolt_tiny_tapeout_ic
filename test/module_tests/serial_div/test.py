# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    WIDTH = 10

    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut._log.info("Test serial divider module")

    dut.num.value = 100
    dut.den.value = 10

    dut.load.value = 1
    await ClockCycles(dut.clk, 1)
    dut.load.value = 0
    await ClockCycles(dut.clk, 2*WIDTH)
    quo = dut.quo.value
    rem = dut.rem.value

    assert (rem, quo) == (0, 10)
