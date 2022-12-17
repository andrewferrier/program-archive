/*

	Spheroid Software Random Numbers Wrapper Library

	Written by Andrew J Ferrier

*/

#include <stdlib.h> // random

int randomInteger(int lowerlimit, int upperlimit)
{
	return lowerlimit + random(upperlimit - lowerlimit);
}