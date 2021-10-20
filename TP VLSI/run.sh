#!/bin/bash

#ghdl -a -v adder.vhdl
#ghdl -a -v adder_32.vhdl
#ghdl -a -v alu.vhdl
#ghdl -a -v alu_tb.vhdl
#ghdl -e -v alu_tb
#ghdl -r alu_tb --vcd=alu.vcd
#gtkwave alu.vcd

ghdl -a -v shifter.vhdl
ghdl -a -v shifter_tb.vhdl
ghdl -e -v shifter_tb
ghdl -r shifter_tb --vcd=shifter.vcd
gtkwave shifter.vcd
