LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY adder_4_tb IS
END;

ARCHITECTURE behav OF adder_4_tb IS
	signal a,b,S : std_logic_vector (3 downto 0);
	signal Cin, Cout : std_logic;
BEGIN
	adder_4: entity work.adder_4
	port map(
	a => a,
	b => b,
	S => S,
	Cin => Cin,
	Cout=> Cout
	);
PROCESS
BEGIN
	a <= "0000";
	b <= "0001";
	Cin <= '1';
	wait for 20 ns;

	a <= "1111";
	b <= "0001";
	Cin <= '0';
	wait for 20 ns;

	wait;
	

END PROCESS;
END behav;	
