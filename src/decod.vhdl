library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Decod is
	port(
	-- Exec  operands
			dec_op1			: out Std_Logic_Vector(31 downto 0); -- first alu input
			dec_op2			: out Std_Logic_Vector(31 downto 0); -- shifter input
			dec_exe_dest	: out Std_Logic_Vector(3 downto 0); -- Rd destination
			dec_exe_wb		: out Std_Logic; -- Rd destination write back
			dec_flag_wb		: out Std_Logic; -- CSPR modifiy

	-- Decod to mem via exec
			dec_mem_data	: out Std_Logic_Vector(31 downto 0); -- data to MEM
			dec_mem_dest	: out Std_Logic_Vector(3 downto 0);
			dec_pre_index 	: out Std_logic;

			dec_mem_lw		: out Std_Logic;
			dec_mem_lb		: out Std_Logic;
			dec_mem_sw		: out Std_Logic;
			dec_mem_sb		: out Std_Logic;

	-- Shifter command
			dec_shift_lsl	: out Std_Logic;
			dec_shift_lsr	: out Std_Logic;
			dec_shift_asr	: out Std_Logic;
			dec_shift_ror	: out Std_Logic;
			dec_shift_rrx	: out Std_Logic;
			dec_shift_val	: out Std_Logic_Vector(4 downto 0);
			dec_cy			: out Std_Logic;

	-- Alu operand selection
			dec_comp_op1	: out Std_Logic;
			dec_comp_op2	: out Std_Logic;
			dec_alu_cy 		: out Std_Logic;

	-- Exec Synchro
			dec2exe_empty	: out Std_Logic;
			exe_pop			: in Std_logic;

	-- Alu command
			dec_alu_add		: out Std_Logic;
			dec_alu_and		: out Std_Logic;
			dec_alu_or		: out Std_Logic;
			dec_alu_xor		: out Std_Logic;

	-- Exe Write Back to reg
			exe_res			: in Std_Logic_Vector(31 downto 0);

			exe_c				: in Std_Logic;
			exe_v				: in Std_Logic;
			exe_n				: in Std_Logic;
			exe_z				: in Std_Logic;

			exe_dest			: in Std_Logic_Vector(3 downto 0); -- Rd destination
			exe_wb			: in Std_Logic; -- Rd destination write back
			exe_flag_wb		: in Std_Logic; -- CSPR modifiy

	-- Ifetch interface
			dec_pc			: out Std_Logic_Vector(31 downto 0) ;
			if_ir				: in Std_Logic_Vector(31 downto 0) ;

	-- Ifetch synchro
			dec2if_empty	: out Std_Logic;
			if_pop			: in Std_Logic;

			if2dec_empty	: in Std_Logic;
			dec_pop			: out Std_Logic;

	-- Mem Write back to reg
			mem_res			: in Std_Logic_Vector(31 downto 0);
			mem_dest			: in Std_Logic_Vector(3 downto 0);
			mem_wb			: in Std_Logic;
			
	-- global interface
			ck					: in Std_Logic;
			reset_n			: in Std_Logic;
			vdd				: in bit;
			vss				: in bit);
end Decod;

----------------------------------------------------------------------

architecture Behavior OF Decod is

component Reg
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
		rdata1		: out Std_Logic_Vector(31 downto 0);
		radr1			: in Std_Logic_Vector(3 downto 0);
		rvalid1		: out Std_Logic;

	-- Read Port 2 32 bits
		rdata2		: out Std_Logic_Vector(31 downto 0);
		radr2			: in Std_Logic_Vector(3 downto 0);
		rvalid2		: out Std_Logic;

	-- Read Port 3 5 bits (for shift)
		rdata3		: out Std_Logic_Vector(31 downto 0);
		radr3			: in Std_Logic_Vector(3 downto 0);
		rvalid3		: out Std_Logic;

	-- read CSPR Port
		cry			: out Std_Logic;
		zero			: out Std_Logic;
		neg			: out Std_Logic;
		ovr			: out Std_Logic;
		
		reg_cznv		: out Std_Logic;
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
		ck					: in Std_Logic;
		reset_n			: in Std_Logic;
		vdd				: in bit;
		vss				: in bit);
end component;

component fifo
	generic(WIDTH: positive);
	port(
		din		: in std_logic_vector(WIDTH-1 downto 0);
		dout		: out std_logic_vector(WIDTH-1 downto 0);

		-- commands
		push		: in std_logic;
		pop		: in std_logic;

		-- flags
		full		: out std_logic;
		empty		: out std_logic;

		reset_n	: in std_logic;
		ck			: in std_logic;
		vdd		: in bit;
		vss		: in bit
	);
end component;

signal cond	: Std_Logic;
signal cond_en	: Std_Logic;

signal regop_t  : Std_Logic;
signal mult_t   : Std_Logic;
signal swap_t   : Std_Logic;
signal trans_t  : Std_Logic;
signal mtrans_t : Std_Logic;
signal branch_t : Std_Logic;

-- regop instructions
signal and_i  : Std_Logic;
signal eor_i  : Std_Logic;
signal sub_i  : Std_Logic;
signal rsb_i  : Std_Logic;
signal add_i  : Std_Logic;
signal adc_i  : Std_Logic;
signal sbc_i  : Std_Logic;
signal rsc_i  : Std_Logic;
signal tst_i  : Std_Logic;
signal teq_i  : Std_Logic;
signal cmp_i  : Std_Logic;
signal cmn_i  : Std_Logic;
signal orr_i  : Std_Logic;
signal mov_i  : Std_Logic;
signal bic_i  : Std_Logic;
signal mvn_i  : Std_Logic;

-- mult instruction
signal mul_i  : Std_Logic;
signal mla_i  : Std_Logic;

-- trans instruction
signal ldr_i  : Std_Logic;
signal str_i  : Std_Logic;
signal ldrb_i : Std_Logic;
signal strb_i : Std_Logic;

-- mtrans instruction
signal ldm_i  : Std_Logic;
signal stm_i  : Std_Logic;

-- branch instruction
signal b_i    : Std_Logic;
signal bl_i   : Std_Logic;

-- Multiple transferts

-- RF read ports

-- Flags
signal cry	: Std_Logic;
signal zero	: Std_Logic;
signal neg	: Std_Logic;
signal ovr	: Std_Logic;

-- DECOD FSM
type state_type is (Fetch, Run, Link, Branch, Mtrans) ;
signal cur_state , next_state : state_type ;
signal T1,T2,T3,T4,T5,T6 : std_logic;

-- Reg signal
signal wdata1,wdata2,wdata3,reg_rd1,reg_rd2,reg_rd3,reg_pc : std_logic_vector (31 downto 0);
signal wen1,wen2,wcry,wzero,wneg,wovr,cspr_wb,reg_v1,reg_v2,reg_v3,reg_cry,reg_zero,reg_neg,reg_cznv,reg_ovr,reg_vv,inval1,inval2,inval_czn,inval_ovr,reg_pcv,inc_pc,reset_n : std_logic;
signal ck : std_logic:='1';
signal wadr1,wadr2,radr1,radr2,radr3,inval_adr1,inval_adr2 : std_logic_vector(3 downto 0);
signal vdd,vss : bit;
signal end_ck : std_logic;
signal end_mt : std_logic;

-- Fifo signal

begin

	exec2mem : fifo_72b
	port map (	
	-- signaux
	din(126 downto 95) => dec2exe_op1,
	din(94 downto 63) => dec2exe_op2,
	din(62 downto 59) => rd,
	din(58) => dec2exe_wb,
	din(57) => dec2exe_fwb,
	din(56 downto 25) => dec2mem_data,
	din(24 downto 21) => dec2mem_dest,
	din(20)  => pre_index,
	
	din(19) =>  dec2mem_lw,
	din(18) =>  dec2mem_lb,
	din(17) =>  dec2mem_sw,
	din(16) =>  dec2mem_sb,
	
	din(15) =>  dec2exe_shift_lsl,
	din(14) =>  dec2exe_shift_lsr,
	din(13) =>  dec2exe_shift_asr,
	din(12) =>  dec2exe_shift_ror,
	din(11) =>  dec2exe_shift_rrx,
	din(10 downto 6) =>  dec2exe_shift_val,
	
	din(5) =>  dec2exe_cy,
	
	din(4) => dec2exe_comp_op1,
	din(3) => dec2exe_comp_op2,     
	din(2) => dec2exe_alu_cy,
	
	din(1 downto 0) => dec2exe_alu_cmd,
	
	-- port
	dout(126 downto 95) => dec_op1,
	dout(94 downto 63) => dec_op2,
	dout(62 downto 59) => dec_exe_dest,
	dout(58) => dec_exe_wb,
	dout(57) => dec_flag_wb,
	dout(56 downto 25) => dec_mem_data,
	dout(24 downto 21) => dec_mem_dest,
	dout(20) => dec_pre_index,
	
	dout(19) => dec_mem_lw,
	dout(18) => dec_mem_lb,
	dout(17) => dec_mem_sw,
	dout(16) => dec_mem_sb,
	
	dout(15) => dec_shift_lsl,
	dout(14) => dec_shift_lsr,
	dout(13) => dec_shift_asr,
	dout(12) => dec_shift_ror,
	dout(11) => dec_shift_rrx,
	dout(10 downto 6) => dec_shift_val,
	dout(5) => dec_cy,
	
	dout(4) => dec_comp_op1,
	dout(3) => dec_comp_op2,
	dout(2) => dec_alu_cy,
	
	dout(1 downto 0) => dec_alu_cmd,
	
	-- ctrl
	push   => dec2exe_push,
	pop    => dec2exe_pop,
  
	full   => dec2exe_full,
	empty  => dec2exe_empty,
  
	-- env
	ck => ck,
	reset_n => reset_n,
	vdd => vdd,
	vss => vss
  );

    registers : Reg
    port map(
		wdata1     => exe_res,
      wadr1      => exe_dest,
      wen1       => exe_wb,

      wdata2     => mem_res,
      wadr2      => mem_dest,
      wen2       => mem_wb,

      wcry       => exe_c,
      wzero      => exe_v,
      wneg       => exe_n,
      wovr       => exe_z,
      cspr_wb    => exe_flag_wb,

      rdata1     => r_data1,
      radr1      => rn,
      rvalid1    => rv1,

      rdata2     => r_data2,
      radr2      => rm,
      rvalid2    => rv2,

      rdata3     => r_data3,
      radr3      => rs,
      rvalid3    => rv3,

      cry        => cry,
      zero       => zero,
      neg        => neg,
      ovr        => ovr,

      reg_cznv   => r_cznv,
      reg_vv     => r_vv,

      inval_adr1 => i_adr1,
      inval1     => inva1,

      inval_adr2 => i_adr2,
      inval2     => inva2,

      inval_czn  => i_czn,
      inval_ovr  => i_v,

      reg_pc     => r_pc,
      reg_pcv    => r_pcv,
      inc_pc     => pc_pp,

      ck         => ck,
      reset_n    => reset_n,
      vdd        => vdd,
      vss        => vss);

-- Execution condition

	cond <= '1' when	(if_ir(31 downto 28) = X"0" and zero = '1') or

							(if_ir(31 downto 28) = X"E") else '0';

	condv <= '1'					when if_ir(31 downto 28) = X"E" else
						reg_cznv	when (if_ir(31 downto 28) = X"0" or 
										(if_ir(31 downto 28) = x"1") or
										(if_ir(31 downto 28) = x"2") or
										(if_ir(31 downto 28) = x"3") or
										(if_ir(31 downto 28) = x"4") or
										(if_ir(31 downto 28) = x"5") or
										(if_ir(31 downto 28) = x"8") or
										(if_ir(31 downto 28) = x"9") else
						r_vv 		when (if_ir(31 downto 28) = x"6") or
           								(if_ir(31 downto 28) = x"7") else
				(reg_cznv and reg_vv) when (if_ir(31 downto 28) = x"A") or
										(if_ir(31 downto 28) = x"B") or
										(if_ir(31 downto 28) = x"C") or
										(if_ir(31 downto 28) = x"D") else '0';

-- decod instruction type

    regop_t<= '1' when ((if_ir(27 downto 26) = "00") and (not(if_ir(27 downto 22) = "000000")) and (not(if_ir(27 downto 23) = "00010"))) else 0;
    mult_t<= '1' when if_ir(27 downto 22) = "000000" else 0;
    swap_t<= '1' when if_ir(27 downto 23) = "00010" else 0;
    trans_t<= '1' when if_ir(27 downto 26) = "01" else 0;
    mtrans_t<= '1' when if_ir(27 downto 25) = "100" else 0;
    branch_t<= '1' when if_ir(27 downto 25) = "101" else 0;

-- decod regop opcode

	and_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"0" else '0';
	eor_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"1" else '0';
	sub_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"2" else '0';
	rsb_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"3" else '0';
	add_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"4" else '0';
	adc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"5" else '0';
	sbc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"6" else '0';
    rsc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"7" else '0';
    tst_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"8" else '0';
    teq_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"9" else '0';
    cmp_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"a" else '0';
    cmn_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"b" else '0';
    orr_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"c" else '0';
    mov_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"d" else '0';
    bic_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"e" else '0';
    mvn_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"f" else '0';

-- decod mult opcode

    mul_i <= '1' when (mult_t <= '1' and not(if_ir(21))) else '0';
    mla_i <= '1' when (mult_t <= '1' and if_ir(21)) else '0';

-- decod trans opcode

    ldr_i  <= '1' when (trans_t <= '1' and not(if_ir(22)) and if_ir(20)) else '0';
    str_i  <= '1' when (trans_t <= '1' and not(if_ir(22)) and not(if_ir(20))) else '0';
    ldrb_i <= '1' when (trans_t <= '1' and (if_ir(22)) and if_ir(20)) else '0';
    strb_i <= '1' when (trans_t <= '1' and (if_ir(22)) and not(if_ir(20))) else '0';

-- decod mtrans opcode

    ldm_i <= '1' when (mtrans_t <= '1' and (if_ir(20))) else '0';
    stm_i <= '1' when (mtrans_t <= '1' and not(if_ir(20))) else '0';

-- decod branch opcode
    
    b_i <= '1' when (branch_t <= '1' and not(if_ir(24))) else '0';
    bl_i <= '1' when (branch_t <= '1' and (if_ir(24))) else '0';

-- MAE Mealy
process(ck)
begin
if(rising_edge(ck))then
    if(reset_n = '0')then
        cur_state <= Fetch;
    else
        cur_state <= next_state;
    end if;
end if;
end process;

process(cond,condv,dec2if_full,dec2if_empty,dec2exe_full,bl_i,b_i,mtrans_t,if2dec_empty,end_mt)
begin
    case cur_state is
    when Fetch =>
        if dec2if_full = '1' then									--
            next_state <= Fetch;
			dec2if_push <= '0';
			if2dec_pop <= '0';
			dec2exe_push<='0';
        elsif dec2if_empty = '0' then								--
            next_state <= Run;
			if(dec2if_full = '0')then
				dec2if_push <= '1';
			end if; 
			if2dec_pop <= '0';
			dec2exe_push<='0';
        end if;

    when Run =>
        if(if2dec_empty='1' or dec2exe_full=1' or condv ='0') then 	-- Si la fifo d'instruction est vide, ou si la fifo vers exec est pleinne, ou si le prédicat est invalide
            next_state <= Run;									   	-- On reste à Run
			if(dec2if_full = '0')then
				dec2if_push <= '1';								   	-- On incrémente PC
			end if;
			if2dec_pop <= '0';
			dec2exe_push<='0';

		elsif(cond = '0')then									   	-- Sinon si le prédicat est faux
			next_state <= Run; 									   	-- On reste à Run			
			if(dec2if_full = '0')then
				dec2if_push <= '1';								   	-- On incrémente PC
			end if;  
			if2dec_pop <= '0';
			dec2exe_push<='0';

		elsif(cond = '1') then									   	-- Sinon si le prédicat est vrai						--
			next_state <= Run; 									   	-- On reste à Run
			if(dec2if_full = '0')then
				dec2if_push <= '1';								   	-- On incrémente PC
			end if; 
			dec2exe_push<='1';									   	-- On éxecute l'instruction
			if2dec_pop <= '0';

        elsif(bl_i = '1') then   								   	-- Si c'est une instruction de branchement avec link
            next_state <= Link;									   	-- On va à Link
			dec2if_push <= '0';
			if2dec_pop <= '0';
			dec2exe_push <='1';									   	-- On éxecute l'instruction

        elsif(b_i = '1') then   								   	-- Si c'est une instruction de branchement sans link							--
            next_state <= Branch;									-- On va à Branch
			dec2if_push <= '0';
			if2dec_pop <= '0';
			dec2exe_push <='1';									   	-- On éxecute l'instruction

        elsif(mtrans_t = '1') then   								-- Si c'est une instruction de transfert mutltiple						--
            next_state <= Mtrans;									-- On va à Mtrans
			dec2if_push <= '0';
			if2dec_pop <= '0';
			dec2exe_push <='0';
        end if;
    
    when Link =>										-- Transition automatique
            next_state <= Branch;
			dec2if_push <= '0';
			if2dec_pop <= '0';
			dec2exe_push <='1';							-- On envoie la valeur de PC pour qu'elle soit stockée dans un autre registre

    when Branch =>
		if(if2dec_empty = '0')						    -- Si fifo d'instructions n'est pas vide, on va traiter ça avec run
			next_state <= Run;
			dec2if_push <= '0';
			dec2exe_push <= '0';
			if2dec_pop <= '0';
        elsif(if2dec_empty = '1' and reg_pcv='1') then  -- Sinon si PC est valide, donc PC a été modifié, on peut effectuer le branchement
            next_state <= Fetch;
			if(dec2if_full = '0')then
				dec2if_push <= '1';
			end if; 
			dec2exe_push<='0';
			if2dec_pop <= '1';			
        else											-- Sinon PC n'a pas été encore modifié, donc on attend que PC soit valide
            next_state <= Branch;
			dec2if_push <= '0';
			dec2exe_push <= '0';
			if2dec_pop <= '0';
        end if;

    when Mtrans =>
        if(end_mt = '0') then -- Si end_mt(transfert non terminé, tous les registres n'ont pas été transférés) alors on refait un transfert
            next_state <= Mtrans;
			dec2if_push <= '0';
			dec2exe_push <= '1'; --transfert
			if2dec_pop <= '0';
        elsif (end_mt = '1' and if_ir(15)='0') then -- Sinon si if_ir(15) (bit indiquant que pc va être transféré) est à 0, alors le transfert multiple ne contient pas de branchement)
            next_state <= Run;
			if(dec2if_full = '0')then
				dec2if_push <= '1';
			end if; 
			dec2exe_push <= '1'; -- Dernier transfert
			if2dec_pop <= '0';
        else										-- Sinon on l'envoie vers Branch pour effectuer le branchement
            next_state <= Branch;
			dec2if_push <= '0';
			dec2exe_push <= '1'; -- Dernier transfert (on envoie la valeur de pc pour la modifier par exec pour le branchement)
			if2dec_pop <= '0';
        end if;
    end case;
end process;



end Behavior;