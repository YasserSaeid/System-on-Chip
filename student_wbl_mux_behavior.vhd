--
-- VHDL Architecture student.student_wbl_mux.behavior
--
-- Created:
--          by - Yasser Saeid
--          at - 15:34:24 05/30/17
--
-- using Mentor Graphics HDL Designer(TM) 2013.1b (Build 2)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
LIBRARY global;
USE global.global_defs.all;
USE global.bus_defs.all;
USE global.wbl_reg.all;
USE global.student_interrupt_controller_reg.all;
USE global.student_lights_reg.all;
USE global.student_interrupt_uart_reg.all;

ENTITY student_wbl_mux IS
   PORT( 
      wbl_i_master         : IN     t_wbl_to_slave;
      wbl_o_master                : OUT    t_wbl_to_master;
      
      
      wbl_i_student_lights, wbl_i_interrupt_controller, wbl_i_vcongen, wbl_i_pixelgen : OUT    t_wbl_to_slave;
      wbl_o_student_lights, wbl_o_interrupt_controller, wbl_o_vcongen, wbl_o_pixelgen : IN     t_wbl_to_master
   );

-- Declarations

END student_wbl_mux ;

--
ARCHITECTURE behavior OF student_wbl_mux IS
  SIGNAL MUX_IN : std_logic_vector(3 downto 0);
  CONSTANT SEL_LIGHTS : std_logic_vector(3 downto 0) := std_logic_vector(BASE_STUDENT_LIGHTS(26 downto 23));
  CONSTANT SEL_INT_CTL : std_logic_vector(3 downto 0) := std_logic_vector(BASE_STUDENT_INTERRUPT_CONTROLLER(26 downto 23));
  CONSTANT SEL_VGA_SYNC : std_logic_vector(3 downto 0) := std_logic_vector(BASE_STUDENT_INTERRUPT_UART(26 downto 23));
BEGIN
  MUX_IN <= std_logic_vector(wbl_i_master.ADR(26 downto 23));
  
  WITH MUX_IN SELECT wbl_o_master <=
    wbl_o_interrupt_controller  WHEN SEL_INT_CTL,
    wbl_o_student_lights         WHEN SEL_LIGHTS,
    wbl_o_vcongen                 WHEN  SEL_VGA_SYNC,
    
    (DAT=>X"B1AB1AB1")          WHEN OTHERS;
  
  wbl_i_student_lights.ADR <= wbl_i_master.ADR;
  wbl_i_student_lights.DAT <= wbl_i_master.DAT;
  wbl_i_student_lights.WE <= wbl_i_master.WE;
  wbl_i_student_lights.CYC <= wbl_i_master.CYC WHEN MUX_IN = SEL_LIGHTS ELSE '0';

  wbl_i_interrupt_controller.ADR <= wbl_i_master.ADR;
  wbl_i_interrupt_controller.DAT <= wbl_i_master.DAT;
  wbl_i_interrupt_controller.WE <= wbl_i_master.WE;
  wbl_i_interrupt_controller.CYC <= wbl_i_master.CYC WHEN MUX_IN = SEL_INT_CTL ELSE '0';

  wbl_i_vcongen.ADR <= wbl_i_master.ADR;
  wbl_i_vcongen.DAT <= wbl_i_master.DAT;
  wbl_i_vcongen.WE <= wbl_i_master.WE;
  wbl_i_vcongen.CYC <= wbl_i_master.CYC WHEN MUX_IN =  SEL_VGA_SYNC  ELSE '0';
  
  wbl_i_pixelgen.ADR <= wbl_i_master.ADR;
  wbl_i_pixelgen.DAT <= wbl_i_master.DAT;
  wbl_i_pixelgen.WE <= wbl_i_master.WE;
  wbl_i_pixelgen.CYC <= '0'; --wbl_i_master.CYC WHEN MUX_IN = SEL_VCONGEN ELSE '0';

END ARCHITECTURE behavior;

