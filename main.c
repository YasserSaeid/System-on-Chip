/**
 * main.c: The main program.
 *
 * $Id: main.c 167 2008-01-18 14:28:50Z ziech $
 */
 
/* At this point we include some header files we need. These header files will
 * be treated as if their contents would be directly inserted into this file.
 *
 * Sometimes the order of the #include directives matters, since not all
 * system headers have their dependencies correctly build in. It is good
 * coding style to include the (operating) system headers first, followed by 
 * the required local application headers and finally the header of the C-file
 * itself.
 *
 * The #include statements should always be located at the top of the source
 * file!
 */
/* We have no operating system header here, so we do not include them. */
/* However, we have some local application headers: */
#include <regdef/student_interrupt_controller.h>
#include "base_int_ctrl.h"
#include "base_uart.h"
#include "base_timer.h"
#include "base_aux.h"
#include "softio.h"
#include "test_sim.h"
#include "test.h"
#include <regdef/common.h>
#include <regdef/student_lights.h>
#include "running_light.h"
/* Finally, include the export statements for the current source file: */
#include "main.h"

extern int main(void)
{

unsigned int a,b;
b=100000;
    /* Initialize all components */
   //base_int_ctrl_init();
    base_int_ctrl_init();
    base_uart_init();
    base_timer_init();
    //running_light_init();
    puts("Guten Tag");
   //WRITE_REG_32(ADDR_STUDENT_STUDENT_INTERRUPT_UART_STRAT, 0xff); 
    /* Run testcases if available. */
    
//REG_STUDENT_LIGHTS_PATTERN = 0x18;
test_main();
 puts("UART Start");




    //REG_STUDENT_LIGHTS_PATTERN = 0xfe;

    /* Do the main task here */
    puts("Bye!");
    
  


//WRITE_REG_32(ADDR_STUDENT_STUDENT_INTERRUPT_UART_STRAT, 0xffff);



    
    /* Clean up the system */
    base_uart_finish();
    base_timer_finish();
    
    /* Finally stop the simulation */
    test_sim_stop();
    
    /* Or if we are not simulating, trigger an internal hardware reset: */
    base_aux_reset();
    
    return 0;
}

