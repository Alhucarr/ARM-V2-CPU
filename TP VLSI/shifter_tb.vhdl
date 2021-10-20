LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY shifter_tb IS
END;

ARCHITECTURE behav OF shifter_tb IS
signal shift_lsl : Std_Logic;                    --
signal shift_lsr : Std_Logic;                    -- rempli par "0" == asl
signal shift_asr : Std_Logic;                    -- arithmetic shift right --> pois fort rempli par "1"
signal shift_ror : Std_Logic;                    -- rotate right
signal shift_rrx : Std_Logic;                    -- tatroe right extended by 1 bit
signal shift_val : Std_Logic_Vector(4  downto 0);-- shift value
signal din       : Std_Logic_Vector(31 downto 0);
signal cin       : Std_Logic;
signal dout      : Std_Logic_Vector(31 downto 0);
signal cout      : Std_Logic;
signal vdd,vss : bit;
BEGIN
	shifter: entity work.shifter
	port map(shift_lsl,shift_lsr,shift_asr,shift_ror,shift_rrx,shift_val,din,cin,dout,cout,vdd,vss);
PROCESS
BEGIN

	din <= "00000000000000000000000000000111";
	cin <= '0';
	shift_lsl<='1';
    shift_lsr<='0';
    shift_asr<='0';
    shift_ror<='0';
    shift_rrx<='0';
    shift_val<="00011";

	wait for 10 ns;
    din <= "00000000000000000000000000111000";
	shift_lsl<='0';
    shift_lsr<='1';
    shift_val<="00011";
	wait for 10 ns;
	din <= "00000000000000000000000000111000";
	shift_lsr<='0';
    shift_asr<='1';
    shift_val<="00011";
    wait for 10 ns;
    din <= "00000000000000000000000000000111";
	shift_asr<='0';
    shift_ror<='1';
    shift_val<="00011";
    wait for 10 ns;
    din <= "11000000000000000000000000001110";
	shift_ror<='0';
    shift_rrx<='1';
    shift_val<="00011";
    cin<='1';
    wait for 10 ns;
	wait;
	

END PROCESS;
END behav;	
