reg.o : reg.vhdl
	ghdl -a -v reg.vhdl

reg_tb : reg_tb.o
	ghdl -e -v reg_tb

reg_tb.o : reg.o reg_tb.vhdl
	ghdl -a -v reg_tb.vhdl

run : reg_tb
	ghdl -r reg_tb --vcd=reg_tb.vcd;
	gtkwave reg_tb.vcd

clean : 
	rm *.o