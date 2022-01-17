LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- definition de full adder

entity ADDER is
port (a, b, Cin: in std_logic;
      S, Cout: out std_logic);
end ADDER;

architecture archi_adder of ADDER is
signal c : unsigned(1 downto 0);
begin
--	S <= (a xor b) xor Cin ;
--	Cout <= (a and b) or (Cin and (a xor b));
cout <= (a and (b xor cin)) or (b and cin);
s <= (not(a) and (b xor cin)) or a;
end archi_adder;
