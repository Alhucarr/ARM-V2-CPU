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

-- Fifo signal

begin

	exec2mem : fifo_72b
	port map (	din()	 => dec_mem_lw,
				
					dout(71)	 => exe_mem_lw,
					dout(70)	 => exe_mem_lb,
					dout(69)	 => exe_mem_sw,
					dout(68)	 => exe_mem_sb,

					dout(67 downto 64) => exe_mem_dest,
					dout(63 downto 32) => exe_mem_data,
					dout(31 downto 0)	 => exe_mem_adr,

					push		 => exe_push,
					pop		 => mem_pop,

					empty		 => exe2mem_empty,
					full		 => exe2mem_full,

					reset_n	 => reset_n,
					ck			 => ck,
					vdd		 => vdd,
					vss		 => vss);

    registers : Reg
    port map(
		wdata1 =>,		 
		wadr1 =>,			 
		wen1 =>,			 
		wdata2 =>,		 
		wadr2 =>,			 
		wen2 =>,			 
		wcry =>,			 
		wzero =>,			 
		wneg =>,			 
		wovr =>,			 
		cspr_wb =>,		 
		reg_rd1 =>,	  
		radr1 =>,			 
		reg_v1 =>,		 
		reg_rd2 =>,		  
		radr2 =>,			 
		reg_v2 =>,		 
		reg_rd3 =>,		  
		radr3 =>,			 
		reg_v3 =>,		 
		reg_cry =>,		 
		reg_zero =>,		 
		reg_neg =>,		 
		reg_cznv =>,		 
		reg_ovr =>,		 
		reg_vv =>,		 
		inval_adr1 =>,	 
		inval1 =>,		 
		inval_adr2 =>,	 
		inval2 =>,		 
		inval_czn =>,	 
		inval_ovr =>,	 
		reg_pc =>,
		reg_pcv =>,		 
		inc_pc =>,		 
		ck =>,				 
		reset_n =>,		 
		vdd =>,			 
		vss =>  );

-- Execution condition

	cond <= '1' when	(if_ir(31 downto 28) = X"0" and zero = '1') or

							(if_ir(31 downto 28) = X"E") else '0';

	condv <= '1'		when if_ir(31 downto 28) = X"E" else
				reg_cznv	when (if_ir(31 downto 28) = X"0" or

				reg_czn and reg_vv;

-- decod instruction type

    regop_t<= '1' when ((if_ir(27 downto 26) = "00") and (not(when if_ir(27 downto 22) = "000000")) and (not(when if_ir(27 downto 23) = "00010"))) else 0;
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

    ldm_i <= '1' when (mtrans_t <= '1' and (if_ir(20))) else '0'
    stm_i <= '1' when (mtrans_t <= '1' and not(if_ir(20))) else '0'

-- decod branch opcode
    
    b_i <= '1' when (branch_t <= '1' and not(if_ir(24))) else '0'
    bl_i <= '1' when (branch_t <= '1' and (if_ir(24))) else '0'

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

process(cond,condv,dec2if_full,dec2if_empty,dec2exe_full,bl_i,b_i,mtrans_t,if2dec_empty)
begin
    case cur_state is
    when Fetch =>
        if dec2if_full = '1' then
            next_state <= Fetch;
        elsif dec2if_empty = '0' then
            next_state <= Run;
        end if;

    when Run =>
        if(if2dec_empty='1' or dec2exe_full=1' or condv ='0') then
            next_state <= Run;
			if(dec2if_full = '0')then
				dec2if_push <= '1';
			end if; 
		elsif(cond = '0')then
			dec2exe_push<='0';
			if(dec2if_full = '0')then
				dec2if_push <= '1';
			end if; 
			next_state <= Run;
		elsif(cond = '1') then
			dec2exe_push<='1';
			if(dec2if_full = '0')then
				dec2if_push <= '1';
			end if; 
			next_state <= Run;
        elsif(bl_i = '1') then
            next_state <= Link;
        elsif(b_i = '1') then
            next_state <= Branch;
        elsif(mtrans_t = '1') then
            next_state <= Mtrans;
        end if;
    
    when Link =>
            next_state <= Branch;
			dec2exe_push <='1';

    when Branch =>
        if(if2dec_empty = '1') then
            next_state <= Branch;
			dec2exe_push <= '0';
			if2dec_pop <= '0';			
        else
            next_state <= Run;
			if(dec2if_full = '0')then
				dec2if_push <= '1';
			end if; 
			dec2exe_push<='1';
			if2dec_pop <= '1';
        end if;

    when Mtrans =>
        if(T1 = '1') then
            next_state <= Mtrans;
        elsif (T2 = '1') then
            next_state <= Run;
			if(dec2if_full = '0')then
				dec2if_push <= '1';
			end if; 
        elsif (T3 = '1') then
            next_state <= Branch;
        end if;
        
    end case;
end process;
end Behavior;