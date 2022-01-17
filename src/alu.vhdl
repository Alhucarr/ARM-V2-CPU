LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity alu is

port ( 	 op1  : in  Std_Logic_Vector(31 downto 0);
         op2  : in  Std_Logic_Vector(31 downto 0);
         cin  : in  Std_Logic;
         cmd  : in  Std_Logic_Vector(1 downto 0);
         res  : out Std_Logic_Vector(31 downto 0);
         cout : out Std_Logic;
         z    : out Std_Logic;
         n    : out Std_Logic;
         v    : out Std_Logic;
         vdd  : in  bit;
         vss  : in  bit );
end alu;

architecture archi_alu of alu is
signal a,b,s,s_a : std_logic_vector(31 downto 0);
signal c: std_logic_vector (32 downto 0);
begin

c(0) <= cin;
a <= op1;
b <= op2;
res<=s;
cout <= c(32);

c(32 downto 1) <= (a(31 downto 0) and (b(31 downto 0) xor c(31 downto 0))) or (b(31 downto 0) and c(31 downto 0));
s_a(31 downto 0) <= (not(a(31 downto 0)) and (b(31 downto 0) xor c(31 downto 0))) or a(31 downto 0);

s <= a and b when cmd = "01" else s_a when cmd = "00" else a or b when cmd = "10" else a xor b when cmd = "11" else x"00000000";
z <= '1' when s = x"00000000" else '0';
v <= '1' when c(32) = '1' else '0';
n <= '1' when s(31)='1' else '0';
end archi_alu;

