LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY adder_32_tb IS
END;

ARCHITECTURE behav OF adder_32_tb IS
	signal a,b,S : std_logic_vector (31 downto 0);
	signal Cin, Cout : std_logic;
BEGIN
	adder_32: entity work.adder_32
	port map(
	a => a,
	b => b,
	S => S,
	Cin => Cin,
	Cout=> Cout
	);
PROCESS
BEGIN
	a <= (others => '0');
	b <= (others => '1');
	Cin <= '1';
	wait for 20 ns;
	wait;
	

END PROCESS;
END behav;	
