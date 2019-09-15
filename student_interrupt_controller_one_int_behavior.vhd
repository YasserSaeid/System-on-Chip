--
-- VHDL Architecture board.student_interrupt_controller_one_int.behavior
--
-- Created:
--          by - Yasser Saeid
--          at - 14:53:34 06/06/17
--
-- using Mentor Graphics HDL Designer(TM) 2013.1b (Build 2)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY student_interrupt_controller_one_int IS
  PORT (
    clk : IN std_logic;
    all_en : IN std_logic;
    level_out : OUT std_logic;
    no: OUT std_logic_vector(4 downto 0);
    status: OUT std_logic_vector(31 downto 0);
    irq_in, mask: IN std_logic_vector(31 downto 0)
  );
END ENTITY student_interrupt_controller_one_int;

--
ARCHITECTURE behavior OF student_interrupt_controller_one_int IS
  SIGNAL irq_masked : std_logic_vector(31 downto 0);
  SIGNAL any_masked_irq, any_masked_irq_enabled: std_logic;
BEGIN
  irq_masked <= irq_in and mask;
  
  any_masked_irq <= '0' when irq_masked = X"00000000" else '1';
  
  any_masked_irq_enabled <= all_en and any_masked_irq;
  
  status <= irq_masked;
  
  level_out_ff: PROCESS(clk)
  BEGIN
    IF(clk='1' and clk'event) THEN    
      level_out <= any_masked_irq_enabled;  
    END IF;
  END PROCESS;
  
  prio_enc: PROCESS(irq_masked)
  BEGIN
    no <= "00000";
    FOR i IN 31 downto 0
    LOOP
      IF irq_masked(i) = '1' THEN
        no <= std_logic_vector(to_unsigned(i, 5));
      END IF;
    END LOOP;
  END PROCESS;

END ARCHITECTURE behavior;

