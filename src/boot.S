#define ASM_FILE   1


.global vectors

.section  .TT,"ax"
  .align 12

  .global tt_l1_base
tt_l1_base:
  .fill 4096 , 1 , 0

.macro InitMMU

 // Configure SCR_EL3
  // ------------------
  MOV      x0, #1                           // NS=1
  ORR      x0, x0, #(1 << 1)                // IRQ=1         IRQs routed to EL3
  ORR      x0, x0, #(1 << 2)                // FIQ=1         FIQs routed to EL3
  ORR      x0, x0, #(1 << 3)                // EA=1          SError routed to EL3
  ORR      x0, x0, #(1 << 8)                // HCE=1         HVC instructions are enabled
  ORR      x0, x0, #(1 << 10)               // RW=1          Next EL down uses AArch64
  ORR      x0, x0, #(1 << 11)               // ST=1          Secure EL1 can access CNTPS_TVAL_EL1, CNTPS_CTL_EL1 & CNTPS_CVAL_EL1
                                            // SIF=0         Secure state instruction fetches from Non-secure memory are permitted
                                            // SMD=0         SMC instructions are enabled
                                            // TWI=0         EL2, EL1 and EL0 execution of WFI instructions is not trapped to EL3
                                            // TWE=0         EL2, EL1 and EL0 execution of WFE instructions is not trapped to EL3
  MSR      SCR_EL3, x0


  /*
  // Install dummy vector table
  // ---------------------------
  LDR      x0, =vector_table
  MSR      VBAR_EL3, x0
  MSR      VBAR_EL2, x0
  MSR      VBAR_EL1, x0
  */

  DSB      SY
  ISB


  // Set the Base address
  // ---------------------
  LDR      x0, =tt_l1_base                  // Get address of level 1 for TTBR0_EL3
  MSR      TTBR0_EL3, x0                    // Set TTBR0_EL3 (NOTE: There is no TTBR1 at EL3)


  // Set up memory attributes
  // -------------------------
  // This equates to:
  // 0 = b01000100 = Normal, Inner/Outer Non-Cacheable
  // 1 = b11111111 = Normal, Inner/Outer WB/WA/RA
  // 2 = b00000000 = Device-nGnRnE
  MOV      x0, #0x000000000000FF44
  MSR      MAIR_EL3, x0


  // Set up TCR_EL3
  // ---------------
  MOV      x0, #32                          // T0SZ=0b011001 Limits VA space to 32 bits, translation starts @ l1
  ORR      x0, x0, #(0x1 << 8)              // IGRN0=0b01    Walks to TTBR0 are Inner WB/WA
  ORR      x0, x0, #(0x1 << 10)             // OGRN0=0b01    Walks to TTBR0 are Outer WB/WA
  ORR      x0, x0, #(0x3 << 12)             // SH0=0b11      Inner Shareable
                                            // TBI0=0b0      Top byte not ignored
                                            // TG0=0b00      4KB granule
                                            // IPS=0         32-bit PA space
  MSR      TCR_EL3, x0


  // Ensure changes to system register are visible before MMU enabled
  ISB
  

  // Invalidate TLBs
  // ----------------
  TLBI     ALLE3
  DSB      SY
  ISB






  DSB      SY

  // Enable MMU
  // -----------
  MOV      x0, #(1 << 0)                      // M=1 bit       Enable the stage 1 MMU
  ORR      x0, x0, #(1 << 2)                  // C=1 bit       Enable data and unified caches
  ORR      x0, x0, #(1 << 12)                 // I=1           Enable instruction fetches to allocate into unified caches
                                              // A=0           Strict alignment checking disabled
                                              // SA=0          Stack alignment checking disabled
                                              // WXN=0         Write permission does not imply XN
                                              // EE=0          EL3 data accesses are little endian
  MSR      SCTLR_EL3, x0
  ISB

  //
  // MMU is now enabled
  //

  NOP
  NOP
  NOP

.endm


// ***************************************
// SCTLR_EL1, System Control Register (EL1), Page 2654 of AArch64-Reference-Manual.
// ***************************************

#define SCTLR_RESERVED                  (3 << 28) | (3 << 22) | (1 << 20) | (1 << 11)
#define SCTLR_EE_LITTLE_ENDIAN          (0 << 25)
#define SCTLR_EOE_LITTLE_ENDIAN         (0 << 24)
#define SCTLR_I_CACHE_DISABLED          (0 << 12)
#define SCTLR_D_CACHE_DISABLED          (0 << 2)
#define SCTLR_I_CACHE_ENABLED           (1 << 12)
#define SCTLR_D_CACHE_ENABLED           (1 << 2)
#define SCTLR_MMU_DISABLED              (0 << 0)
#define SCTLR_MMU_ENABLED               (1 << 0)

#define SCTLR_VALUE_MMU_DISABLED	( SCTLR_EE_LITTLE_ENDIAN | SCTLR_I_CACHE_ENABLED | SCTLR_D_CACHE_ENABLED | SCTLR_MMU_DISABLED)

// ***************************************
// HCR_EL2, Hypervisor Configuration Register (EL2), Page 2487 of AArch64-Reference-Manual.
// ***************************************

#define HCR_RW	    			(1 << 31)


// mauro: https://developer.arm.com/documentation/102416/0100/EL1--Single-level-table
// FMO e IMO = 1  ??
#define HCR_VALUE			(HCR_RW  )



// ***************************************
// SCR_EL3, Secure Configuration Register (EL3), Page 2648 of AArch64-Reference-Manual.
// ***************************************

#define SCR_RESERVED	    		(3 << 4)
#define SCR_RW				(1 << 10)
#define SCR_NS				(1 << 0)



// mauro: https://developer.arm.com/documentation/102416/0100/EL1--Single-level-table
// << 11)  // ST=1  Secure EL1 can access timers
// << 8)   // HCE=1 HVC instructions are enabled
#define SCR_VALUE	    	    	(SCR_RESERVED | SCR_RW | SCR_NS |  (1 << 8) | (1 << 11))



// ***************************************
// SPSR_EL3, Saved Program Status Register (EL3) Page 389 of AArch64-Reference-Manual.
// ***************************************

#define SPSR_MASK_ALL 			(7 << 6)
#define SPSR_EL1h			(5 << 0)
#define SPSR_VALUE			(SPSR_MASK_ALL | SPSR_EL1h)





.macro WaitALittle
        mov     w0, 50880
        movk    w0, 0x5d, lsl 16
1:
        nop
        subs    w0, w0, #1
        bne     1b
.endm


//0x00111111
//0x00000001
//0x00000001


	.global _start
_start:
	/* check CPU ID = 0x0, or jump to hang */
	mrs x0,mpidr_el1
    mov x1,#0xFF000000
    bic x0,x0,x1
    cbz x0,core_0
    sub x1,x0,#1
    cbz x1,core_1
    sub x1,x0,#2
    cbz x1,core_2
    sub x1,x0,#3
    cbz x1,core_3
    b hang
	
core_0:          
    InitMMU

    ldr x1, =0x00910000 
    mov sp, x1 

    bl core0
    b hang 

core_1:          
    InitMMU

    ldr x1, =0x00910240
    mov sp, x1 

    bl core1
    b hang 

core_2:          
    InitMMU

    ldr x1, =0x00910480 
    mov sp, x1 

    bl core2
    b hang 

core_3:          
    InitMMU
	LDR      x0, =vectors
    MSR      VBAR_EL3, x0
	
    ldr x1, =0x00910720 
    mov sp, x1 

    bl core3
    b hang 

	
	/*
	 * Reset Vector Base Address,
	 */
reset_vector_base:
	/*
		GDB hang if access:
			vbar_el3, vbar_el2
			scr_el3, hcr_el2
	*/
	ldr	x1, = vectors
	msr	vbar_el1, x1





hang:
	nop
    b hang

