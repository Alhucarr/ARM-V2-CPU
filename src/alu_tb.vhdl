LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY alu_tb IS
END;

ARCHITECTURE behav OF alu_tb IS
	signal op1,op2,res : std_logic_vector (31 downto 0);
	signal cin, cout,z,n,v : std_logic;
	signal cmd : std_logic_vector(1 downto 0);
	signal vdd,vss : bit;
BEGIN
	alu: entity work.alu
	port map(op1,op2,cin,cmd,res,cout,z,n,v,vdd,vss);
PROCESS
BEGIN
	op1 <= (others => '0');
	op2 <= (others => '1');
	cin <= '1';
	cmd <= "01";
	wait for 10 ns;

	op1 <= "00000000000000000000000000000111";
	op2 <= "00000000000000000000000000000111";
	cin <= '1';
	cmd <= "01";
	wait for 10 ns;
	op1 <= "00000000000000011111111111111111";
	op2 <= "00000000000000011111111111111111";
	cin <= '1';
	cmd <= "01";
	wait for 10 ns;
	cin <= '0';
	cmd <= "00";
	wait for 10 ns;
	cmd <= "01";
	op1 <= x"00000000";
	op2 <= x"FFFFF000";	
	wait for 10 ns;
	wait;
	

END PROCESS;
END behav;	
