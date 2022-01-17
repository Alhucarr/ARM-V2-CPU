LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity adder_32 is

port (a, b: in  std_logic_vector (31 downto 0);
      Cin : in  std_logic;
      S   : out std_logic_vector (31 downto 0);
      Cout: out std_logic);

end adder_32;

architecture archi_adder_32 of adder_32 is
signal c: std_logic_vector (32 downto 0);

begin
c(0) <= cin;
cout <= c(32);
	Boucle : for i in 0 to 31 generate
		c(i+1) <= (a(i) and (b(i) xor c(i))) or (b(i) and c(i));
		s(i) <= (not(a(i)) and (b(i) xor c(i))) or a(i);
	end generate Boucle;
end archi_adder_32;