library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

  
entity exec_tb is
end entity;

architecture simu of exec_tb is
  signal de_emp, e_pop, de_wb, d_f_wb, d_pre_index, dm_lw, dm_lb, dm_sw   : Std_Logic := '0';
  signal dm_sb, ds_ll, ds_lr, ds_a, ds_ro, ds_rr, ds_cy, dc_op1     : Std_Logic := '0';
  signal dc_op2, da_cy, e_c, e_v, e_n, e_z, e_wb, e_f_wb, em_lw, em_lb, em_sw   : Std_Logic := '0';
  signal em_sb, em_empty, m_pop, ck, reset                            : Std_Logic := '0';

  signal da_cmd : std_logic_vector(1 downto 0);
  signal de_dest, dm_dest, e_dest, em_dest : std_logic_vector(3 downto 0);
  signal ds_val : Std_Logic_Vector(4 downto 0);
  signal d_op1, d_op2, dm_data, e_res, em_adr, em_data : Std_Logic_Vector(31 downto 0);
  signal vdd, vss : bit;

  -- debug
  signal end_ck : std_logic;
  
  function to_string (vector : in std_logic_vector) return string is
    variable stri, sum : integer := 0;
    variable cpt : integer := 1;
  begin
    case vector(0) is
      when 'U' | 'X' | 'Z' | 'W' | '-' => return "'U'";
      when others => NULL;                                          
    end case;
    
    for i in 0 to vector'length-1 loop
      if vector(stri) = '1' then
        sum := sum + cpt;
      end if;
      cpt := cpt * 2;
      stri := stri+1;
    end loop;
    return "'"&integer'image(sum)&"'";
  end function;
  
begin
  exec : entity work.exec
    port map(de_emp, e_pop, d_op1, d_op2, de_dest, de_wb, d_f_wb, dm_data, dm_dest, d_pre_index,
             dm_lw, dm_lb, dm_sw, dm_sb, ds_ll, ds_lr, ds_a, ds_ro, ds_rr, ds_val, ds_cy,
             dc_op1, dc_op2, da_cy, da_cmd, e_res, e_c, e_v, e_n, e_z, e_dest, e_wb, e_f_wb,
             em_adr, em_data, em_dest, em_lw, em_lb, em_sw, em_sb, em_empty, m_pop, ck, reset, vdd, vss);

  -- CLOCK
  ck <= not ck after 10 ns when end_ck /= '1' else '0';
  
  process
    variable ex_pop, ex_c, ex_v, ex_n, ex_z, ex_wb, ex_f_wb, exm_lw : std_logic;
    variable exm_lb, exm_sw, exm_sb, e2m_emp : std_logic;
    variable ex_dest, exm_dest : std_logic_vector(3 downto 0);
    variable ex_res, exm_adr, exm_data : std_logic_vector(31 downto 0);
  begin
    -- IN
    de_emp      <= '1';
    
    d_op1       <= x"00000001";
    d_op2       <= x"00000001";
    de_dest     <= "0000";
    de_wb       <= '0';
    d_f_wb      <= '0';
    
    dm_data     <= x"00000000";
    dm_dest     <= "0000";
    d_pre_index <= '0';

    dm_lw       <= '1';
    dm_lb       <= '0';
    dm_sw       <= '0';
    dm_sb       <= '0';

    ds_ll       <= '1';
    ds_lr       <= '0';
    ds_a        <= '0';
    ds_ro       <= '0';
    ds_rr       <= '0';
    ds_val      <= "00100";
    ds_cy       <= '0';

    dc_op1      <= '0';
    dc_op2      <= '0';
    da_cy       <= '0';

    da_cmd      <= "00";

    m_pop       <= '0';
    reset       <= '0';
    vdd         <= '0';
    vss         <= '0';
    
    -- OUT
    ex_pop := '0';

    ex_res   := x"00000011";    
    ex_c     := '0';
    ex_v     := '0';
    ex_n     := '0';
    ex_z     := '0';
    ex_dest  := "0000";
    ex_wb    := '0';
    ex_f_wb  := '0';
    
    exm_adr  := x"00000001";
    exm_data := x"00000000";
    exm_dest := "0000";
    exm_lw   := '1';
    exm_lb   := '0';
    exm_sw   := '0';
    exm_sb   := '0';
    e2m_emp  := '1';
    
    wait for 50 ns;
    
    assert ex_pop   = e_pop    report "Erreur exe_pop       - expected : "&std_logic'image(ex_pop)&"  returned : "&std_logic'image(e_pop)     severity note;
    assert ex_res   = e_res    report "Erreur exe_res       - expected : "&to_string(ex_res)&"  returned : "&to_string(e_res)                 severity note;
    assert ex_c     = e_c      report "Erreur exe_c         - expected : "&std_logic'image(ex_c)&"  returned : "&std_logic'image(e_c)         severity note;
    assert ex_v     = e_v      report "Erreur exe_v         - expected : "&std_logic'image(ex_v)&"  returned : "&std_logic'image(e_v)         severity note;
    assert ex_n     = e_n      report "Erreur exe_n         - expected : "&std_logic'image(ex_n)&"  returned : "&std_logic'image(e_n)         severity note;
    assert ex_z     = e_z      report "Erreur exe_z         - expected : "&std_logic'image(ex_z)&"  returned : "&std_logic'image(e_z)         severity note;
    assert ex_dest  = e_dest   report "Erreur exe_dest      - expected : "&to_string(ex_dest)&"  returned : "&to_string(e_dest)               severity note;
    assert ex_wb    = e_wb     report "Erreur exe_wb        - expected : "&std_logic'image(ex_wb)&"  returned : "&std_logic'image(e_wb)       severity note;
    assert ex_f_wb  = e_f_wb   report "Erreur exe_flag_wb   - expected : "&std_logic'image(ex_f_wb)&"  returned : "&std_logic'image(e_f_wb)   severity note;
    assert exm_adr  = em_adr   report "Erreur exe_mem_adr   - expected : "&to_string(exm_adr)&"  returned : "&to_string(em_adr)               severity note;
    assert exm_data = em_data  report "Erreur exe_mem_data  - expected : "&to_string(exm_data)&"  returned : "&to_string(em_data)             severity note;
    assert exm_dest = em_dest  report "Erreur exe_mem_dest  - expected : "&to_string(exm_dest)&"  returned : "&to_string(em_dest)             severity note;
    assert exm_lw   = em_lw    report "Erreur exe_mem_lw    - expected : "&std_logic'image(exm_lw)&"  returned : "&std_logic'image(em_lw)     severity note;
    assert exm_lb   = em_lb    report "Erreur exe_mem_lb    - expected : "&std_logic'image(exm_lb)&"  returned : "&std_logic'image(em_lb)     severity note;
    assert exm_sw   = em_sw    report "Erreur exe_mem_sw    - expected : "&std_logic'image(exm_sw)&"  returned : "&std_logic'image(em_sw)     severity note;
    assert exm_sb   = em_sb    report "Erreur exe_mem_sb    - expected : "&std_logic'image(exm_sb)&"  returned : "&std_logic'image(em_sb)     severity note;
    assert e2m_emp  = em_empty report "Erreur exe2mem_empty - expected : "&std_logic'image(e2m_emp)&"  returned : "&std_logic'image(em_empty) severity note;

    assert false report "end of test 1" severity note;
        -- IN
    de_emp      <= '1';
    
    d_op1       <= x"0000000A";
    d_op2       <= x"00000003";
    de_dest     <= "0000";
    de_wb       <= '0';
    d_f_wb      <= '0';
    
    dm_data     <= x"00000000";
    dm_dest     <= "0000";
    d_pre_index <= '0';

    dm_lw       <= '1';
    dm_lb       <= '0';
    dm_sw       <= '0';
    dm_sb       <= '0';

    ds_ll       <= '1';
    ds_lr       <= '0';
    ds_a        <= '0';
    ds_ro       <= '0';
    ds_rr       <= '0';
    ds_val      <= "00000";
    ds_cy       <= '0';

    dc_op1      <= '0';
    dc_op2      <= '1';
    da_cy       <= '0';

    da_cmd      <= "00";

    m_pop       <= '0';
    reset       <= '0';
    vdd         <= '0';
    vss         <= '0';
    
    -- OUT
    ex_pop := '0';

    ex_res   := x"00000006";    
    ex_c     := '1';
    ex_v     := '1';
    ex_n     := '0';
    ex_z     := '0';
    ex_dest  := "0000";
    ex_wb    := '0';
    ex_f_wb  := '0';
    
    exm_adr  := x"0000000A";
    exm_data := x"00000000";
    exm_dest := "0000";
    exm_lw   := '1';
    exm_lb   := '0';
    exm_sw   := '0';
    exm_sb   := '0';
    e2m_emp  := '1';
    
    wait for 50 ns;
    
    assert ex_pop   = e_pop    report "Erreur exe_pop       - expected : "&std_logic'image(ex_pop)&"  returned : "&std_logic'image(e_pop)     severity note;
    assert ex_res   = e_res    report "Erreur exe_res       - expected : "&to_string(ex_res)&"  returned : "&to_string(e_res)                 severity note;
    assert ex_c     = e_c      report "Erreur exe_c         - expected : "&std_logic'image(ex_c)&"  returned : "&std_logic'image(e_c)         severity note;
    assert ex_v     = e_v      report "Erreur exe_v         - expected : "&std_logic'image(ex_v)&"  returned : "&std_logic'image(e_v)         severity note;
    assert ex_n     = e_n      report "Erreur exe_n         - expected : "&std_logic'image(ex_n)&"  returned : "&std_logic'image(e_n)         severity note;
    assert ex_z     = e_z      report "Erreur exe_z         - expected : "&std_logic'image(ex_z)&"  returned : "&std_logic'image(e_z)         severity note;
    assert ex_dest  = e_dest   report "Erreur exe_dest      - expected : "&to_string(ex_dest)&"  returned : "&to_string(e_dest)               severity note;
    assert ex_wb    = e_wb     report "Erreur exe_wb        - expected : "&std_logic'image(ex_wb)&"  returned : "&std_logic'image(e_wb)       severity note;
    assert ex_f_wb  = e_f_wb   report "Erreur exe_flag_wb   - expected : "&std_logic'image(ex_f_wb)&"  returned : "&std_logic'image(e_f_wb)   severity note;
    assert exm_adr  = em_adr   report "Erreur exe_mem_adr   - expected : "&to_string(exm_adr)&"  returned : "&to_string(em_adr)               severity note;
    assert exm_data = em_data  report "Erreur exe_mem_data  - expected : "&to_string(exm_data)&"  returned : "&to_string(em_data)             severity note;
    assert exm_dest = em_dest  report "Erreur exe_mem_dest  - expected : "&to_string(exm_dest)&"  returned : "&to_string(em_dest)             severity note;
    assert exm_lw   = em_lw    report "Erreur exe_mem_lw    - expected : "&std_logic'image(exm_lw)&"  returned : "&std_logic'image(em_lw)     severity note;
    assert exm_lb   = em_lb    report "Erreur exe_mem_lb    - expected : "&std_logic'image(exm_lb)&"  returned : "&std_logic'image(em_lb)     severity note;
    assert exm_sw   = em_sw    report "Erreur exe_mem_sw    - expected : "&std_logic'image(exm_sw)&"  returned : "&std_logic'image(em_sw)     severity note;
    assert exm_sb   = em_sb    report "Erreur exe_mem_sb    - expected : "&std_logic'image(exm_sb)&"  returned : "&std_logic'image(em_sb)     severity note;
    assert e2m_emp  = em_empty report "Erreur exe2mem_empty - expected : "&std_logic'image(e2m_emp)&"  returned : "&std_logic'image(em_empty) severity note;

    assert false report "end of test 2" severity note;
    end_ck <= '1';
    wait;
  end process;
end simu;