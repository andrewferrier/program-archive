/*
	Spheroid Software Applications C Include File.
	Defines Various Functions to aid in consistency amongst SS apps.

	Written by and Copyright Andrew J Ferrier, Spheroid Software 1998.

	This file is not part of Sp_Stand.C because I wouldn't want to
	include	actual code unecessarily.

	This file contains only ANSI standard C.

	Last Modified: 13/2/98
*/

#include "sp_stand.c"
#include <stdio.h>

void printHeader(void)
{
	#if defined(DEBUG)
		printf("\n\nWarning: DEBUG Version\n");
	#endif

	printf("\n%s version %s, compiled at %s, on %s.\n",
		APPNAME, VERSION, __TIME__, __DATE__);
	printf("Written by and Copyright %s, %s %s.\n", AUTHOR, COMPANY,
		COPYRIGHT_YEAR);
	printf(" e-mail: %s\n web:    %s\n", EMAIL, WEBPAGE);
	printf("\n");
}
