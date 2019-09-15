--
-- VHDL Architecture student.student_interrupt_controller.behavior
--
-- Created:
--          by - Yasser Saeid
--          at - 15:18:34 05/30/18
--
-- using Mentor Graphics HDL Designer(TM) 2013.1b (Build 2)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
LIBRARY global;
USE global.global_defs.all;
USE global.bus_defs.all;
USE global.student_interrupt_controller_reg.all;

LIBRARY student;
USE student.all;

ENTITY student_interrupt_controller IS
  GENERIC(
    how_many_interrupt_inputs: natural
  );
  PORT( 
    wbl_i         : IN     t_wbl_to_slave;
    wbl_o         : OUT    t_wbl_to_master;
    
    clk  : IN     std_logic;
    nres : IN     std_logic;
    fiq_out, irq_out  : OUT    std_logic;
    irq_in: IN std_logic_vector(how_many_interrupt_inputs-1 downto 0)
  );
END student_interrupt_controller;

--
ARCHITECTURE behavior OF student_interrupt_controller IS

  -- Wishbone-Register
  SIGNAL reg_all_en : std_logic;
  
  SIGNAL reg_fiq_mask, reg_irq_mask : std_logic_vector(31 downto 0);
  
  
  SIGNAL all_status, irq_status, fiq_status : std_logic_vector(31 downto 0);
  SIGNAL all_no, irq_no, fiq_no : std_logic_vector(4 downto 0);
  
  SIGNAL irq_in_internal, irq_in_32 : std_logic_vector(31 downto 0);
  
  SIGNAL reg_irq_sim : std_logic_vector(31 downto 0);
  SIGNAL reg_irq_sim_enable : std_logic;
BEGIN
  

  
  irq_in_32(31 downto how_many_interrupt_inputs) <= (others => '0');
  irq_in_32(how_many_interrupt_inputs-1 downto 0) <= irq_in;
  
  irq_in_internal <= irq_in_32 when reg_irq_sim_enable = '0' else reg_irq_sim;
  
  
  fiq_slice: ENTITY student.student_interrupt_controller_one_int
    PORT MAP(
      clk       => clk,
      all_en    => reg_all_en,
      irq_in    => irq_in_internal,

      level_out => fiq_out,
      no        => fiq_no,
      status    => fiq_status,
      mask      => reg_fiq_mask
    );
    
  irq_slice: ENTITY student.student_interrupt_controller_one_int
    PORT MAP(
      clk       => clk,
      all_en    => reg_all_en,
      irq_in    => irq_in_internal,

      level_out => irq_out,
      no        => irq_no,
      status    => irq_status,
      mask      => reg_irq_mask
    );
    
  all_slice: ENTITY student.student_interrupt_controller_one_int
    PORT MAP(
      clk       => clk,
      all_en    => reg_all_en,
      irq_in    => irq_in_internal,

      level_out => open,
      no        => all_no,
      status    => all_status,
      mask      => X"FFFFFFFF"
    );
    
    
   wbl_slave_write : PROCESS (clk, nres)
   BEGIN
      IF (nres = '0') THEN
        -- Default Reset Values
         
        reg_all_en <= '0';
        reg_fiq_mask <= X"00000000";
        reg_irq_mask <= X"00000000";
        reg_irq_sim <= X"00000000";
        reg_irq_sim_enable <= '0';
        
      ELSIF (rising_edge(clk)) THEN
         -- Combined Actions   
         IF (wbl_i.CYC = '1' AND wbl_i.WE = '1') THEN 
            -- Write access
            CASE wbl_i.ADR(STUDENT_INTERRUPT_CONTROLLER_RANGE) IS
                WHEN ADR_STUDENT_INTERRUPT_CONTROLLER_ALL_EN =>
                    reg_all_en <= wbl_i.DAT(0);
                WHEN ADR_STUDENT_INTERRUPT_CONTROLLER_FIQ_MASK =>
                    reg_fiq_mask <= wbl_i.DAT;
                WHEN ADR_STUDENT_INTERRUPT_CONTROLLER_IRQ_MASK =>
                    reg_irq_mask <= wbl_i.DAT;
                WHEN ADR_STUDENT_INTERRUPT_CONTROLLER_IRQ_SIM =>
                    reg_irq_sim <= wbl_i.DAT;
                WHEN ADR_STUDENT_INTERRUPT_CONTROLLER_IRQ_SIM_EN =>
                    reg_irq_sim_enable <= wbl_i.DAT(0);
                WHEN others =>
                    REPORT "Invalid write access to address " &
                        To_Hex(wbl_i.ADR)
                        SEVERITY WARNING;
            END CASE;
         END IF;
      
      END IF;
   END PROCESS;
   
   wbl_slave_read : PROCESS (wbl_i,
    reg_all_en, all_status, all_no, reg_fiq_mask, fiq_status, fiq_no, reg_irq_mask,
    irq_status, irq_no,reg_irq_sim, reg_irq_sim_enable
   ) 

   BEGIN
      -- Default Assignment
      wbl_o <= (DAT=>X"00DEAD00");

      -- Combined Actions
      IF (wbl_i.CYC = '1' AND wbl_i.WE = '1') THEN 
      ELSIF (wbl_i.CYC = '1' AND wbl_i.WE = '0') THEN 
         -- Read access
         CASE wbl_i.ADR(STUDENT_INTERRUPT_CONTROLLER_RANGE) IS
            WHEN ADR_STUDENT_INTERRUPT_CONTROLLER_ALL_EN =>
              wbl_o.DAT <= X"00000000";
              wbl_o.DAT(0) <= reg_all_en;
            WHEN ADR_STUDENT_INTERRUPT_CONTROLLER_ALL_STATUS =>
              wbl_o.DAT <= all_status;
            WHEN ADR_STUDENT_INTERRUPT_CONTROLLER_ALL_NO =>
              wbl_o.DAT <= X"00000000";
              wbl_o.DAT(4 downto 0) <= all_no;
            WHEN ADR_STUDENT_INTERRUPT_CONTROLLER_FIQ_MASK =>
              wbl_o.DAT <= reg_fiq_mask;
            WHEN ADR_STUDENT_INTERRUPT_CONTROLLER_FIQ_STATUS =>
              wbl_o.DAT <= fiq_status;
            WHEN ADR_STUDENT_INTERRUPT_CONTROLLER_FIQ_NO =>
              wbl_o.DAT <= X"00000000";
              wbl_o.DAT(4 downto 0) <= fiq_no;
            WHEN ADR_STUDENT_INTERRUPT_CONTROLLER_IRQ_MASK =>
              wbl_o.DAT <= reg_irq_mask;
            WHEN ADR_STUDENT_INTERRUPT_CONTROLLER_IRQ_STATUS =>
              wbl_o.DAT <= irq_status;
            WHEN ADR_STUDENT_INTERRUPT_CONTROLLER_IRQ_NO =>
              wbl_o.DAT <= X"00000000";
              wbl_o.DAT(4 downto 0) <= irq_no;
            WHEN ADR_STUDENT_INTERRUPT_CONTROLLER_IRQ_SIM =>
              wbl_o.DAT <= reg_irq_sim;
            WHEN ADR_STUDENT_INTERRUPT_CONTROLLER_IRQ_SIM_EN =>
              wbl_o.DAT <= X"00000000";
              wbl_o.DAT(0) <= reg_irq_sim_enable;
            WHEN others =>
              wbl_o.DAT <= X"00DEAD00";
              REPORT "Invalid read access to address " &
                  To_Hex(wbl_i.ADR)
                  SEVERITY WARNING;
          END CASE;
      END IF;
   END PROCESS;
 
END ARCHITECTURE behavior;

