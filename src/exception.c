/* -*- mode: c; coding:utf-8 -*- */
/**********************************************************************/
/*  OS kernel sample                                                  */
/*  Copyright 2014 Takeharu KATO                                      */
/*                                                                    */
/*  Exception handler                                                 */
/*                                                                    */
/**********************************************************************/

#include "exception.h"
#include "board.h"
#include "gic_v3.h"

//extern void timer_handler(void);


void common_trap_handler(exception_frame *exc)
{
	//uart_puts("\nException Handler! (");
	//handle_exception(exc);

	if ( ( exc->exc_type & 0xff ) == AARCH64_EXC_SYNC_SPX ) {
		//uart_puts("AARCH64_EXC_SYNC_SPX)\n");
		//handle_exception(exc);
		;
/*
		ti_update_preempt_count(ti, THR_EXCCNT_SHIFT, 1);
		psw_enable_interrupt();
		hal_handle_exception(exc);
		psw_disable_interrupt();
		ti_update_preempt_count(ti, THR_EXCCNT_SHIFT, -1);
*/
	}

	if ( ( exc->exc_type & 0xff ) == AARCH64_EXC_IRQ_SPX) {
		//uart_puts("AARCH64_EXC_IRQ_SPX)\n");
		//irq_handle(exc);
		;
	}
	return;
}