/*
	Spheroid Software C/C++ File

	Written by Andrew J Ferrier.
	Copyright Andrew J Ferrier, Spheroid Software 1996.

	Command Line Library - Header File

	See Cmdline.C for more information.
*/

#if !defined(CMDLINE_CALLED)
#define CMDLINE_CALLED

#include "sp_stand.c" /* Spheroid standard C Stuff */

typedef enum
{
	NEITHER = 0,
	POSITIVE = 1,
	NEGATIVE = 2,
	NOEXIST = 3       /* should only be used in functions returning SgnTyp */
}
SignType;

void cmdlineParse(int argc, char *argv[], boolean cases);
SignType existOption(char* option);
char* getArgument(int optPick);
void cmdlineFree(void);

#endif /* entire file */
