LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY reg_tb IS
END;

ARCHITECTURE behav OF reg_tb IS
	signal wdata1,wdata2,wdata3,reg_rd1,reg_rd2,reg_rd3,reg_pc : std_logic_vector (31 downto 0);
	signal wen1,wen2,wcry,wzero,wneg,wovr,cspr_wb,reg_v1,reg_v2,reg_v3,reg_cry,reg_zero,reg_neg,reg_cznv,reg_ovr,reg_vv,inval1,inval2,inval_czn,inval_ovr,reg_pcv,inc_pc,reset_n : std_logic;
	signal ck : std_logic:='1';
	signal wadr1,wadr2,radr1,radr2,radr3,inval_adr1,inval_adr2 : std_logic_vector(3 downto 0);
	signal vdd,vss : bit;
	signal end_ck : std_logic;
BEGIN
	reg: entity work.reg
	port map(
		wdata1,		 
		wadr1,			 
		wen1,			 
		wdata2,		 
		wadr2,			 
		wen2,			 
		wcry,			 
		wzero,			 
		wneg,			 
		wovr,			 
		cspr_wb,		 
		reg_rd1,	  
		radr1,			 
		reg_v1,		 
		reg_rd2,		  
		radr2,			 
		reg_v2,		 
		reg_rd3,		  
		radr3,			 
		reg_v3,		 
		reg_cry,		 
		reg_zero,		 
		reg_neg,		 
		reg_cznv,		 
		reg_ovr,		 
		reg_vv,		 
		inval_adr1,	 
		inval1,		 
		inval_adr2,	 
		inval2,		 
		inval_czn,	 
		inval_ovr,	 
		reg_pc,
		reg_pcv,		 
		inc_pc,		 
		ck,				 
		reset_n,		 
		vdd,			 
		vss);

	-- CLOCK
	ck <= not ck after 200 ns when end_ck /= '1' else '0';

PROCESS
BEGIN
	wdata1 <= "00000000000000000000000000000111";
    wadr1 <= "0011"; 
    wen1 <= '1';
    wdata2 <= "00000000000000000000000000000011";
    wadr2 <= "0011"; 
    wen2 <= '1';
	wait for 800 ns;

    radr1 <= "0011"; 
    radr2 <= "0010";
    wdata2 <= "00000000000000000000000000000011";
    wadr2 <= "0010"; 
    wen2 <= '1';

	wait for 400 ns;
	wait for 1200 ns;
	end_ck <= '1';
	wait;
	

END PROCESS;


END behav;	
