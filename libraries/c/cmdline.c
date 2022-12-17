/*
	Spheroid Software Command Line Interpreter.
	Written by Andrew J Ferrier, Spheroid Software.
	Copyright Andrew Ferrier, Spheroid Software 1996.

	This is Microsoft C, but _not_ ANSI C, compatible.

	WARNING: Some Functions, since you pass them char*, ie strings,
	(e.g. existOption) _may_ alter the string that you pass them, in other
	words the equivalent of pass-by-ref. I do not make copies of them,
	because I deem this more problematic than the current problem - if you
	really need your parameter to stay unchanged (unlikely) then pass me
	a copy of it.
*/

#include "sp_stand.c"
#include "cmdline.h"

#include <stdio.h>   /* NULL constant */
#include <string.h>  /* strchr()      */
#include <malloc.h>  /* malloc()      */

typedef struct
{
	char*    text;   /* The text itself                      */
	SignType sign;   /* Is it postive, negative or  netiher? */
} Cmdline;

static Cmdline*   cmdlines      = NULL;
static boolean    caseSensitive = false;
static int        numOpts       = 0;

/* This is the function that does most of the actual work - it parses
   out the command line and stores it into an array. */

void cmdlineParse(int argc, char *argv[], boolean cases)
{
	int i;
	const char* POSITIVECHARS = "/+";
	const char* NEGATIVECHARS = "-";

	caseSensitive    = cases;
	numOpts++;
	cmdlines         = malloc(sizeof(Cmdline) * numOpts);
	cmdlines[0].sign = NEITHER;
	cmdlines[0].text = argv[0];

	for (i = 1; i < argc; i++)
	{
		SignType sign;
		boolean  isOption;

		if      (strchr(POSITIVECHARS, *(argv[i])) != NULL)
		{
			sign     = POSITIVE;
			isOption = true;
		}
		else if (strchr(NEGATIVECHARS, *(argv[i])) != NULL)
		{
			sign     = NEGATIVE;
			isOption = true;
		}
		else
		{
			sign     = NEITHER;
			isOption = false;
		}

		if (!caseSensitive) strlwr(argv[i]); /* Case Sensitive ? */
		if (isOption) argv[i]++;      /* Option character - get rid of it */

		if (strlen(argv[i]) <= 0) continue;

		numOpts++;
		cmdlines = realloc(cmdlines, sizeof(Cmdline) * numOpts);

		cmdlines[numOpts - 1].sign = sign;
		cmdlines[numOpts - 1].text = argv[i];
	}
}

SignType existOption(char* option)
{
	int i;

	if (!caseSensitive) strlwr(option);

	for (i = 0; i < numOpts; i++)
	{
		if ( (strcmp(cmdlines[i].text, option) == 0) &&
				 (cmdlines[i].sign != NEITHER)                      )
		   return cmdlines[i].sign;
	}

	return NOEXIST;
}

char* getArgument(int optPick)
{
	int i;
	int count = -1;

	if (optPick < 0) return NULL;

	for (i = 0; i < numOpts; i++)
	{
		if (cmdlines[i].sign == NEITHER)
		{
			count++;
			if (optPick == count)
			{
				return cmdlines[i].text;
			}
		}
	}

	/* Cannot find this argument - too great! */
	return NULL;
}

/* Free up memory used by 'array' */
void cmdlineFree(void)
{
	free(cmdlines);

	/* the text pointers should be freed anyway because they originally
	   came from main (we hope!) */
}
