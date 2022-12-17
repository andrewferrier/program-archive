/*
	Functions to aid with assembly-language (esp. in-line)
	in C. Written by Andrew J Ferrier of Spheroid Software.

	Copyright Andrew Ferrier, Spheroid Software 1997.
*/

// Stop this being included twice.
#if !defined(SP_ASM_CALLED)
#define SP_ASM_CALLED

#include "sp_stand.c"

#if !defined(__TURBOC__)
         #define asm _asm
#else
         #define _asm asm
#endif

#if !defined(DISALLOW_INTERRUPT_DISABLE)
        #define disable_interrupts asm { pushf } asm { cli }
        #define enable_interrupts  asm { popf  }
#else
        #define disable_interrupts
        #define enable_interrupts
#endif

#endif
