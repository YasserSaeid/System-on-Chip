/**
 * base_int_ctrl.c: Basic interrupt controller driver
 *
 * $Id: base_int_ctrl.c 178 2008-02-06 20:10:12Z ziech $
 */
#include <regdef/common.h>
#include <regdef/int_ctrl.h>
#include <regdef/int_ctrl_bf.h>
#include <regdef/student_interrupt_controller.h>
#include <boot.h>
#include "softio.h"
#include "base_timer.h"
#include "base_int_ctrl.h"

/* Hardwired exception vector addresses */
#define ADDR_VECTOR_RESET    (0x00000020)
#define ADDR_VECTOR_UNDEF    (0x00000024)
#define ADDR_VECTOR_SOFTINT  (0x00000028)
#define ADDR_VECTOR_PABORT   (0x0000002C)
#define ADDR_VECTOR_DABORT   (0x00000030)
#define ADDR_VECTOR_RESERVED (0x00000034)
#define ADDR_VECTOR_IRQ      (0x00000038)
#define ADDR_VECTOR_FIQ      (0x0000003C)

#ifdef BROKEN_INTERRUPTS
extern void broken_irq_glue(void);
extern void broken_fiq_glue(void);
#endif

/** Top-level IRQ handler */
extern void base_int_ctrl_top_irq_handler(void) IRQ_HANDLER;
/** Top-level FIQ handler */
extern void base_int_ctrl_top_fiq_handler(void) FIQ_HANDLER;

static void (*student_fiq_handlers[32])(void),(*student_irq_handlers[32])(void);

void set_irq(int no, void (*handler)(void)) {
	if(no<0 || no>31) {
		puts("illegal set_irq call");
		return;
	}
	puts("set_irq");
	student_irq_handlers[no]=handler;
}

void set_fiq(int no, void (*handler)(void)) {
	if(no<0 || no>31) {
		puts("illegal set_fiq call");
		return;
	}
	student_fiq_handlers[no]=handler;
}

void (*get_irq(int no))(void) {
	if(no<0 || no>31) {
		puts("illegal get_irq call");
		return NULL;
	}
	return student_irq_handlers[no];
}

void (*get_fiq(int no))(void) {
	if(no<0 || no>31) {
		puts("illegal get_irq call");
		return NULL;
	}
	return student_fiq_handlers[no];
}

extern IRQ_HANDLER void base_int_ctrl_top_irq_handler(void)
{
    int_ctrl_status_t status;
    
    status.val = READ_REG_U32(ADDR_STATUS_NIRQ);
    
    if (status.bf.ethernet) {
        puts("Spurious ethernet IRQ!");
    } else if (status.bf.student) {
	get_irq(student_ic_get_irq_no())();
        puts("Spurious student IRQ!");
    } else if (status.bf.timer) {
        base_timer_interrupt();
    } else if (status.bf.uart) {
        puts("Spurious uart IRQ!");
    } else {
        puts("Spurious unknown IRQ!");
    }
}

extern FIQ_HANDLER void base_int_ctrl_top_fiq_handler(void)
{
    int_ctrl_status_t status;
    
    status.val = READ_REG_U32(ADDR_STATUS_NFIQ);
    
    if (status.bf.ethernet) {
        puts("Spurious ethernet FIQ!");
    } else if (status.bf.student) {
	get_fiq(student_ic_get_fiq_no())();
        //puts("Spurious student FIQ!");
    } else if (status.bf.timer) {
        base_timer_interrupt();
    } else if (status.bf.uart) {
        puts("Spurious uart FIQ!");
    } else {
        puts("Spurious unknown FIQ!");
    }
}

void dummy_handler(void) {
	puts("Dummy handler called :]");
}



extern int base_int_ctrl_init(void)
{
    /* Set global interrupt vectors */
#ifdef BROKEN_INTERRUPTS
    WRITE_REG_32(ADDR_VECTOR_IRQ, (int)broken_irq_glue);
    WRITE_REG_32(ADDR_VECTOR_FIQ, (int)broken_fiq_glue);
#else
    WRITE_REG_32(ADDR_VECTOR_IRQ, (int)base_int_ctrl_top_irq_handler);
    WRITE_REG_32(ADDR_VECTOR_FIQ, (int)base_int_ctrl_top_fiq_handler);
#endif

    /* Enable Interrupts 0-3 */
    WRITE_REG_32(ADDR_MAIN_NFIQ_INT_CTRL, 0x0f);
    WRITE_REG_32(ADDR_MAIN_NIRQ_INT_CTRL, 0x0f);

	/* Initialize student FIQ and IRQ jump tables to dummy handler */
	int i;
	for(i=0;i<32;i++) {
		set_fiq(i, dummy_handler);
		set_irq(i, dummy_handler);
	}

    return 0;
}


