#include "board.h"
#include "gic_v3.h"
#include "aarch64.h"



/* Exception SVC Test */
void exception_svc(void)
{
/*
Supervisor call to allow application code to call the OS. 
	It generates an exception targeting exception level 1 (EL1).
*/
	asm("svc #0xdead");
}

/* Main */
void exception_svc_test(void)
{
	//uart_puts("exception_svc_test... start\n");
	/* SVC instruction causes a Supervisor Call exception. */ 
	/* vector_table:_curr_el_spx_sync should be called */
	exception_svc();

	// Wait for Interrupt.
	wfi();
	//uart_puts("exception_svc_test... done\n");
}

void core0(void) {
	//exception_svc_test();
	//timer_test();
	;
}
void core1(void)
{
	;
}
void core2(void)
{
	;
}
void core3(void)
{
	;
}


