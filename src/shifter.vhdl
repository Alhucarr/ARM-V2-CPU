LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
 
entity Shifter is
   port(
     shift_lsl : in  Std_Logic;                    --
     shift_lsr : in  Std_Logic;                    -- rempli par "0" == asl
     shift_asr : in  Std_Logic;                    -- arithmetic shift right --> pois fort rempli par "1"
     shift_ror : in  Std_Logic;                    -- rotate right
     shift_rrx : in  Std_Logic;                    -- tatroe right extended by 1 bit
     shift_val : in  Std_Logic_Vector(4  downto 0);-- shift value
     din       : in  Std_Logic_Vector(31 downto 0);
     cin       : in  Std_Logic;
     dout      : out Std_Logic_Vector(31 downto 0);
     cout      : out Std_Logic;
    
     -- global interface
     vdd       : in  bit;
     vss       : in  bit
     );
end Shifter;
 
architecture archi_shifter of shifter IS
begin
process(shift_lsl,shift_lsr,shift_asr,shift_ror,shift_rrx,shift_val,din,cin)
variable din_s : std_logic_vector(31 downto 0):= x"00000000";
variable val : integer range 0 to 31 := 0;
begin
  val := to_integer(unsigned(shift_val));
  din_s := din;

    if shift_lsl = '1' then
        for i in 0 to val-1 loop
            din_s := din_s(30 downto 0)&'0';
        end loop;
        cout <= '0';
  
    elsif shift_lsr= '1' then
  
        for i in 31-val to 30 loop
            din_s := '0'&din_s(31 downto 1);
        end loop;
        cout <= '0';
   
    elsif shift_asr = '1' then
  
        for i in 31-val to 30 loop
            din_s := '1'&din_s(31 downto 1);
        end loop;
        cout <= '0';
  
    elsif shift_ror = '1' then
        for i in 31-val to 30 loop
            din_s := din_s(0)&din_s(31 downto 1);
        end loop;
        cout <= '0';
  
    elsif shift_rrx = '1' then
          din_s := cin&din_s(31 downto 1);
          cout <= din_s(0);
    end if;

dout <= din_s;
end process;
end archi_shifter;
 
 

