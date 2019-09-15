--
-- VHDL Architecture student.btn_debouncer.btn_debouncer
--
-- Created:
--          by - Yasser Saeid
--          at - 19:26:13 07/04/18
--
-- using Mentor Graphics HDL Designer(TM) 2013.1b (Build 2)



library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity student_btn_debouncer is

 GENERIC(counter_size  :  INTEGER := 19); --counter size (19 bits gives 10.5ms with 50MHz clock)
    
    Port ( clk : in STD_LOGIC;
           btn_right : in STD_LOGIC :=0;
           btn_left : in STD_LOGIC:=0;
           btn_pause : in STD_LOGIC:=0;
           db_btn_right : out STD_LOGIC;
           db_btn_left : out STD_LOGIC;
           db_btn_pause : out STD_LOGIC);
end student_btn_debouncer;

architecture Behavioral of student_btn_debouncer is
    SIGNAL flipflops_0   : STD_LOGIC_VECTOR(1 DOWNTO 0); --input flip flops
    SIGNAL flipflops_1   : STD_LOGIC_VECTOR(1 DOWNTO 0); --input flip flops
    SIGNAL flipflops_2   : STD_LOGIC_VECTOR(1 DOWNTO 0); --input flip flops

    SIGNAL counter_set_0 : STD_LOGIC;                    --sync reset to zero
    SIGNAL counter_set_1 : STD_LOGIC;                    --sync reset to zero
    SIGNAL counter_set_2 : STD_LOGIC;                    --sync reset to zero
    
    SIGNAL counter_out_0 : STD_LOGIC_VECTOR(counter_size DOWNTO 0) := (OTHERS => '0'); --counter output
    SIGNAL counter_out_1 : STD_LOGIC_VECTOR(counter_size DOWNTO 0) := (OTHERS => '0'); --counter output
    SIGNAL counter_out_2 : STD_LOGIC_VECTOR(counter_size DOWNTO 0) := (OTHERS => '0'); --counter output
begin

  counter_set_0 <= flipflops_0(0) xor flipflops_0(1);   --determine when to start/reset counter
  counter_set_1 <= flipflops_1(0) xor flipflops_1(1);   --determine when to start/reset counter
  counter_set_2 <= flipflops_2(0) xor flipflops_2(1);   --determine when to start/reset counter
  
  PROCESS(clk)
  BEGIN
    IF(clk'EVENT and clk = '1') THEN
      flipflops_0(0) <= btn_right;
      flipflops_1(0) <= btn_left;
      flipflops_2(0) <= btn_pause;
      
      flipflops_0(1) <= flipflops_0(0);
      flipflops_1(1) <= flipflops_1(0);
      flipflops_2(1) <= flipflops_2(0);
      
      If(counter_set_0 = '1' OR counter_set_1 = '1' OR counter_set_2 = '1') THEN                  --reset counter because input is changing
        counter_out_0 <= (OTHERS => '0');
        counter_out_1 <= (OTHERS => '0');
        counter_out_2 <= (OTHERS => '0');
      ELSIF(counter_out_0(counter_size) = '0' OR counter_out_1(counter_size) = '0' OR counter_out_2(counter_size) = '0') THEN --stable input time is not yet met
        counter_out_0 <= counter_out_0 + 1;
        counter_out_1 <= counter_out_1 + 1;
        counter_out_2 <= counter_out_2 + 1;
      ELSE                                        --stable input time is met
        db_btn_right <= flipflops_0(1);
        db_btn_left <= flipflops_1(1);
        db_btn_pause <= flipflops_2(1);
      END IF;    
    END IF;
  END PROCESS;

end Behavioral;