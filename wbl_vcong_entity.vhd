--
-- VHDL Entity student.wbl_vcong.arch_name
--
-- Created:
--          by - Yasser Saeid
--          at - 15:22:41 07/16/18
--
-- using Mentor Graphics HDL Designer(TM) 2013.1b (Build 2)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
LIBRARY global;
USE global.global_defs.all;
LIBRARY ahbl_switch;
USE ahbl_switch.utils_ahbl_pkg.all;
USE global.student_ahbl_reg.all;
USE global.student_wbl_reg.all;
USE global.bus_defs.all;
USE global.student_interrupt_uart_reg.all;

ENTITY wbl_vcong IS
END ENTITY wbl_vcong;


ARCHITECTURE wbl_vcong OF Student_uart IS

SIGNAL UART_START : std_logic_vector(31 DOWNTO 0);  

begin

 wbl_slave_write : PROCESS (clk, nres)
   BEGIN
      IF (nres = '0') THEN
        -- Default Reset Values
         
      ELSIF (rising_edge(clk)) THEN
         -- Combined Actions   
         IF (wbl_i.CYC = '1' AND wbl_i.WE = '1') THEN 
            -- Write access
            CASE wbl_i.ADR(STUDENT_INTERRUPT_UART_RANGE) IS
                WHEN ADR_STUDENT_STUDENT_INTERRUPT_UART_STRAT =>
                    UART_START <= wbl_i.DAT;

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
         CASE wbl_i.ADR(STUDENT_INTERRUPT_UART_RANGE) IS
            WHEN ADR_STUDENT_STUDENT_INTERRUPT_UART_STRAT =>
              wbl_o.DAT <= X"0";

            WHEN others =>
              wbl_o.DAT <= X"00DEAD00";
              REPORT "Invalid read access to address " &
                  To_Hex(wbl_i.ADR)
                  SEVERITY WARNING;
          END CASE;
      END IF;
   END PROCESS;
   
end  wbl_vcong;