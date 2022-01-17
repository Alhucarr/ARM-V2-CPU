library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg is
	port(
	-- Write Port 1 prioritaire
		wdata1		: in Std_Logic_Vector(31 downto 0);
		wadr1			: in Std_Logic_Vector(3 downto 0);
		wen1			: in Std_Logic;

	-- Write Port 2 non prioritaire
		wdata2		: in Std_Logic_Vector(31 downto 0);
		wadr2			: in Std_Logic_Vector(3 downto 0);
		wen2			: in Std_Logic;

	-- Write CSPR Port
		wcry			: in Std_Logic;
		wzero			: in Std_Logic;
		wneg			: in Std_Logic;
		wovr			: in Std_Logic;
		cspr_wb		: in Std_Logic;
		
	-- Read Port 1 32 bits
		reg_rd1		: out Std_Logic_Vector(31 downto 0);
		radr1			: in Std_Logic_Vector(3 downto 0);
		reg_v1		: out Std_Logic;

	-- Read Port 2 32 bits
		reg_rd2		: out Std_Logic_Vector(31 downto 0);
		radr2			: in Std_Logic_Vector(3 downto 0);
		reg_v2		: out Std_Logic;

	-- Read Port 3 32 bits
		reg_rd3		: out Std_Logic_Vector(31 downto 0);
		radr3			: in Std_Logic_Vector(3 downto 0);
		reg_v3		: out Std_Logic;

	-- read CSPR Port
		reg_cry		: out Std_Logic;
		reg_zero		: out Std_Logic;
		reg_neg		: out Std_Logic;
		reg_cznv		: out Std_Logic;
		reg_ovr		: out Std_Logic;
		reg_vv		: out Std_Logic;
		
	-- Invalidate Port 
		inval_adr1	: in Std_Logic_Vector(3 downto 0);
		inval1		: in Std_Logic;

		inval_adr2	: in Std_Logic_Vector(3 downto 0);
		inval2		: in Std_Logic;

		inval_czn	: in Std_Logic;
		inval_ovr	: in Std_Logic;

	-- PC
		reg_pc		: out Std_Logic_Vector(31 downto 0);
		reg_pcv		: out Std_Logic;
		inc_pc		: in Std_Logic;
	
	-- global interface
		ck				: in Std_Logic;
		reset_n		: in Std_Logic;
		vdd			: in bit;
		vss			: in bit);
end Reg;

architecture Behavior OF Reg is
type regs is array (0 to 15) of std_logic_vector(31 downto 0);
signal validite_registre : std_logic_vector(15 downto 0);
signal registres : regs;
signal flags : std_logic_vector(0 to 3);
begin
process (ck)
begin
-- Activité sur front d'horloge montant
if rising_edge(ck) then
	-----------------------------------------------------
	-- 						Reset					   --
	-----------------------------------------------------

    if reset_n = '0' then
        registres(15) <= x"0000";
		validite_registre <= x"ffff";
    else
		-------------------------------------------------
		-- 				Incrémentation PC			   --
		-------------------------------------------------

        if inc_pc = '1' then
            registres(15) <= std_logic_vector(unsigned(registres(15)) + 4);
			validite_registre(15)<= '1';
        end if;
		--------------------------------------------------
		-- 					Ecriture					--
		--------------------------------------------------
		
		-- Validité
		if inval1 = '1' then
			validite_registre(to_integer(unsigned(inval_adr1))) <= not(inval1);
		end if;
		if inval2 = '1' then
			validite_registre(to_integer(unsigned(inval_adr2))) <= not(inval2);
		end if;

		-- EXEC
		if ((wen1 = '1') and (not(validite_registre(to_integer(unsigned(wadr1)))='0'))) then
			registres(to_integer(unsigned(wadr1))) <= wdata1;
			validite_registre(to_integer(unsigned(wadr1))) <= '1';
		end if;
		-- MEM
		if ((wen2 = '1') and ((not(wadr1 = wadr2) and (not(validite_registre(to_integer(unsigned(wadr2)))='0'))) or (wen1 = '0'))) then
			registres(to_integer(unsigned(wadr2))) <= wdata2;
			validite_registre(to_integer(unsigned(wadr2))) <= '1';
		end if;

		------------------------------------------------------
		--					Lecture 						--
		------------------------------------------------------

		reg_rd1 <= registres(to_integer(unsigned(radr1)));
		reg_v1 <= validite_registre(to_integer(unsigned(radr1)));
		reg_rd2 <= registres(to_integer(unsigned(radr2)));
		reg_v2 <= validite_registre(to_integer(unsigned(radr2)));
		reg_rd3 <= registres(to_integer(unsigned(radr3)));
		reg_v3 <= validite_registre(to_integer(unsigned(radr3)));

		------------------------------------------------------
		--  				Gestion FLAGS			    	--
		------------------------------------------------------
		
		if cspr_wb = '1' then
			if inval_czn ='1' then
			reg_cry <= wcry;
			reg_zero <= wzero;
			reg_neg <= wneg;
			reg_cznv <= inval_czn;
			end if;
			if inval_ovr = '1' then
			reg_ovr <= wovr;
			reg_vv <= inval_ovr;
			end if;
		end if;

	end if;
end if;
end process ;

reg_pc<=registres(15);
reg_pcv<=validite_registre(15);

end Behavior;