alu.o : alu.vhdl
	ghdl -a -v alu.vhdl

alu_tb.o :
	ghdl -a -v alu_tb.vhdl

alu_tb : alu.o alu_tb.o 
	ghdl -e -v alu_tb

exec.o : exec.vhdl
	ghdl -a -v exec.vhdl

exec_tb : exec_tb.o
	ghdl -e -v exec_tb

reg.o : reg.vhdl
	ghdl -a -v reg.vhdl

reg_tb : reg_tb.o
	ghdl -e -v reg_tb
	
decod.o : decod.vhdl
	ghdl -a -v decod.vhdl

decod_tb : decod_tb.o
	ghdl -e -v decod_tb

decod_tb.o : decod.o decod_tb.vhdl
	ghdl -a -v decod_tb.vhdl

run : decod_tb
	ghdl -r decod_tb --vcd=decod_tb.vcd;
	gtkwave decod_tb.vcd

clean : 
	rm *.vcd
	rm *.o