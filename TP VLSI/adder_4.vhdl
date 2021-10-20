LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

--definition de full adder 4-bit 

entity adder_4 is

port (a, b: in  std_logic_vector (3 downto 0);
      Cin : in  std_logic;
      S   : out std_logic_vector (3 downto 0);
      Cout: out std_logic);

end adder_4;

architecture archi_adder_4 of adder_4 is

signal c: std_logic_vector (4 downto 0);

component FULLADDER

port (a, b, Cin: in std_logic;
      S, Cout: out std_logic);
end component;

begin
	FA0: entity work.adder
	port map (a(0), b(0), Cin,  S(0), c(1));

	FA1: entity work.adder
	port map (a(1), b(1), c(1), S(1), c(2));

	FA2: entity work.adder
	port map (a(2), b(2), c(2), S(2), c(3));

	FA3: entity work.adder
	port map (a(3), b(3), c(3), S(3), c(4));

	Cout <= c(4);

end archi_adder_4;

