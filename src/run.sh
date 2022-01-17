#!/bin/bash

#ghdl -a -v adder.vhdl
#ghdl -a -v adder_32.vhdl
#ghdl -a -v alu.vhdl
#ghdl -a -v shifter.vhdl
#ghdl -a -v fifo.vhdl

ghdl -a -v adder_32.vhdl
ghdl -a -v adder_32_tb.vhdl
ghdl -e -v adder_32_tb
ghdl -r adder_32_tb --vcd=adder_32_tb.vcd
gtkwave adder_32_tb.vcd

#ghdl -a -v exec_tb.vhdl
#ghdl -e -v exec_tb
#ghdl -r exec_tb --vcd=exec.vcd


