/*
		Spheroid Software Standard C Header File

		Written by Andrew J Ferrier.
		Copyright Andrew J Ferrier, Spheroid Software 1997.

		Most of the extensions are compiler directives, typedefs, etc,
		so they do not take up storage if they are not used. The file
		copes with most Borland and Microsoft Compilers, but I wouldn't
		be sure about anything else!

		This file contains standard ANSI C only (except for #pragmas)

		Constants to (possibly) define:

		VERSION         String
		APPNAME         String
		APPNAME_FILE    String
		AUTHOR          String
		COMPANY         String
		COPYRIGHT_YEAR  String
		DEBUG|RELEASE   define
*/

/* Stop this being called twice */
#if !defined(SP_STAND_CALLED)
#define SP_STAND_CALLED

#if !defined(AUTHOR)
		#define AUTHOR "Andrew Ferrier"
#endif

#if !defined(COMPANY)
		#define COMPANY "Spheroid Software"
#endif

#if !defined(COPYRIGHT_YEAR)
		#define COPYRIGHT_YEAR "1997"
#endif

#if !defined(APPNAME)
		#define APPNAME "Test Program"
#endif

#if !defined(APPNAME_FILE)
		#define APPNAME_FILE "TESTPROG"
#endif

#if !defined(VERSION)
		#define VERSION "version 0.00"
#endif

#if !defined(RELEASE)
		#if !defined(DEBUG)
				#define DEBUG
		#endif
#endif

/* Debug - Compiler Dependent */
#if defined(__TCPLUSPLUS__)
	#if defined(DEBUG)
		#pragma option -N            // CheckStack
		#pragma option -v            // Off: Inline
		#pragma option -y            // On: Line Numbers
	#else
		#pragma option -N-           // Borland - Do not check stack
		#pragma option -v-           // On: Inline
		#pragma option -y-           // Off: line numbers
	#endif
#endif

#if !defined(__TCPLUSPLUS__)
				/* Microsoft C Pragmas */
		#pragma loop_opt(on)    // Optimize Loops
		#pragma pack(1)         // Who cares about an 8088? :-)
#else
				/* Borland C++ Pragmas */
		#pragma option -2       // Generate 286 Instructions
		#pragma option -A-      // Use all Turbo C++ extensions.
		#pragma option -b-      // Store enum in byte
		#pragma option -G       // Optimize for Speed over Size
		#pragma option -O       // Optimize Jumps
		#pragma option -rd      // Only allow register storage if declared
		#pragma option -Z       // Optimize mem -> reg storage
		#pragma warn +amb
		#pragma warn +amp
		#pragma warn +asm
		#pragma warn +aus
		#pragma warn +bbf
		#pragma warn +bei
		#pragma warn +big
		#pragma warn +ccc
		#pragma warn -cln       // No: Constant is Long.
		#pragma warn +cpt
		#pragma warn -def       // No: Possible Use of 'x' before definition.
		#pragma warn +dpu
		#pragma warn -dsz
		#pragma warn +dup       // Yes: Redefinition of Macro
		#pragma warn +eas
		#pragma warn +eff
		#pragma warn +ext
		#pragma warn +hid
		#pragma warn +ias
		#pragma warn +ibc
		#pragma warn +ill
		#pragma warn +inl       // Yes: inline something
		#pragma warn +lin
		#pragma warn +lvc
		#pragma warn +mpc
		#pragma warn +mpd
		#pragma warn +ncf
		#pragma warn +nci
		#pragma warn +nod
		#pragma warn +nst
		#pragma warn +obi
		#pragma warn +ofp
		#pragma warn +ore
		#pragma warn +ovl
		#pragma warn +par
		#pragma warn +pia
		#pragma warn +pin
		#pragma warn +pro
		#pragma warn +rch
		#pragma warn +ret
		#pragma warn +rng
		#pragma warn +rpt
		#pragma warn +rvl
		#pragma warn -sig       // No: Conversion may lose significance.
		#pragma warn +stu
		#pragma warn +stv
		#pragma warn +sus
		#pragma warn +ucp
		#pragma warn +use
		#pragma warn +voi
		#pragma warn +zdi

#endif

#define MAX_BYTE      (0xFFU)
#define MIN_BYTE      (0)
#define MAX_WORD      (0xFFFFU)
#define MIN_WORD      (0)
#define MAX_DWORD     (0xFFFFFFFFUL)
#define MIN_DWORD     (0)

typedef char Bit;
#define MAX_BIT (1)
#define MIN_BIT (0)

#define LO_BYTE(x) (x && 0x00FF)
#define HI_BYTE(x) (x >> 8)
#define LO_WORD(x) (x && 0x0000FFFF)
#define HI_WORD(x) (x >> 16)

/* Java Emulation */

typedef unsigned char boolean;
typedef unsigned char byte;

#define true (1)
#define false (0)
#define FAILED false
#define OK true
#define SUCCESS true

/* Not Java Types, not portable beyond x86 */

typedef unsigned int Word;
typedef unsigned long int DWord;

#endif

/*

Version History:
	1.1     Various modifications (1/9/1998)
	1.0     Unknown
*/
