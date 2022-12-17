/*
        Spheroid Software C/C++ Error Handling Library.
        Written by Andrew J Ferrier, Spheroid Software.
        Copyright Andrew Ferrier, Spheroid Software 1996.

        To use this library, merely #include this file in all of your modules.
        This library should be Ansi C compatible.
*/

#if !defined(SP_ERRORC_CALLED)
#define SP_ERRORC_CALLED

#define LIBRARY
#include "sp_stand.c"
#undef LIBRARY

#include <stdio.h>   /* printf */
#include <stdlib.h>  /* exit() */

/* Language Extensions */
#define _assert(exp) { if (!(exp)) { printf("\nAssertion Failed: " #exp "\nFILE %s: LINE %u: Please inform the author.\nThe program will now end.\n", __FILE__, __LINE__); exit(FAILED); } }

#if defined(_WINDOWS)
        #define assert(exp) ;
        #define kassert(exp) ;
#else
        #if defined(DEBUG)
                #define assert(exp) _assert(exp)
                #define kassert(exp) _assert(exp)
        #else
                #define assert(exp) ;
                #define kassert(exp) _assert(exp)
        #endif
#endif

void endprog(int errorcode)
{
        exit(errorcode);
}

#endif
