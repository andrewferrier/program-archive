/*
	Huffman Encoding Routine
*/

#define APPNAME "Huffman Encode"
#define VERSION "v1.0"
#define DEBUG

#include "sp_stand.cpp"
#include "apps.c"
#include <stdio.h> // NULL
// #include <malloc.h>
#include <iostream.h> // cout
#include <fstream.h> // ifstream, ofstream
#include <conio.h> // kbhit()

// Bugs:
// What about when only one type of char. in input file?
// 10, 13 only recognised as 10.

typedef unsigned long int OccurenceCount;
typedef unsigned int TreeListIndex;
enum Stat { NONE, CHAR, FULL_CHAR, NODE, FULL_NODE };

class HuffmanTreeListItem
{

private:
	OccurenceCount count; // no. of times this char or summed node occurs
	Stat status;          // node, character, nothing, or a FULL_CHAR
	Byte charRepresent;   // character this MAY represent

	// Only used when part of a tree
	TreeListIndex leftItem, rightItem;

public:
	HuffmanTreeListItem()
		{ status = NONE; count = 0; leftItem = rightItem = 0;
		  charRepresent = 0; }
	void hit(void) { count++; }

	OccurenceCount getCount(void) { return count; }
	Stat           getStatus(void) { return status; }
	TreeListIndex  getLeft(void) { return leftItem; }
	TreeListIndex  getRight(void) { return rightItem; }

	void set(Stat st) { status = st; }
	void set(Stat st, unsigned char cr)
		{ status = st; charRepresent = cr; }
	void set(Stat st, OccurenceCount c, TreeListIndex leftI, TreeListIndex rightI)
		{ status = st; count = c; leftItem = leftI; rightItem = rightI; }

	void invertStatus(void);
};

void HuffmanTreeListItem::invertStatus(void)
{
	if (status == CHAR) status = FULL_CHAR;
	if (status == NODE) status = FULL_NODE;
}

const TreeListIndex HTL_COUNT = 513;

class HuffmanTreeList
{

private:
	HuffmanTreeListItem HTL[HTL_COUNT];

public:
	HuffmanTreeList(void);
	void hit(Byte addChar) { HTL[addChar].hit(); }
	void convertToTree(void);

#if defined(DEBUG)
	void dump(int min, int max);
#endif

};

HuffmanTreeList::HuffmanTreeList(void)
{
	int i;
	for (i = 0; i < 256; i++)
		HTL[i].set(CHAR, (unsigned char) i);
}

void HuffmanTreeList::convertToTree(void)
{
	const signed int NOTHING_FOUND = -1;
	TreeListIndex newest = 0;
	int i;

	// This pair of lines may be unecessary.
	for (i = 0; i < HTL_COUNT; i++)
		if (HTL[i].getCount() <= 0) HTL[i].set(NONE);

	while (TRUE)
	{
		signed int min1 = NOTHING_FOUND, min2 = NOTHING_FOUND;
		int countValid;

		countValid = 0;
		for (i = 0; i < HTL_COUNT; i++)
		{
			if (!((HTL[i].getStatus() == CHAR) ||
			      (HTL[i].getStatus() == NODE)))
				continue;

			if (HTL[i].getCount() <= 0) continue;

			countValid++;

			if      (min1 == NOTHING_FOUND) min1 = i;
			else if	(min2 == NOTHING_FOUND) min2 = i;
			else if	(HTL[min1].getCount() > HTL[i].getCount()) min1 = i;
			else if (HTL[min2].getCount() > HTL[i].getCount()) min2 = i;
		}

		if (countValid <= 1) break;

		while (HTL[newest].getStatus() != NONE) newest++;

		HTL[newest].set(NODE, HTL[min1].getCount() +
			HTL[min2].getCount(), min1, min2);

		HTL[min1].invertStatus(); HTL[min2].invertStatus();
	}
}

#if defined(DEBUG)
void HuffmanTreeList::dump(int min, int max)
{
	// Dump table out for debugging
	Boolean latched = TRUE;
	cout << "Dumping table..." << endl;
	for (TreeListIndex i = min; i < max; i++)
	{
		cout << "Character " << i << " : " << ((i < 32 || i > 255) ? ' ' : char(i)) <<
			" : Status : " << int(HTL[i].getStatus()) <<
			" : Count: " << HTL[i].getCount() <<
			" : Left : " << HTL[i].getLeft() <<
			"["  << int(HTL[HTL[i].getLeft()].getStatus()) << "]" <<
			" : Right : " << HTL[i].getRight() <<
			"["  << int(HTL[HTL[i].getRight()].getStatus()) << "]" << endl;
		if ((i % 20 == 0) && latched) { while (!kbhit()); if(getch() == 'c') latched = FALSE; }
	}
	cout << endl;
}
#endif

int main(int argc, char* argv[])
{
	// Create instances of main objects
	HuffmanTreeList HTL;

	printHeader();

	if (argc != 3) { cerr << "Wrong no. of arguments"; return FAILED; }

	ifstream from(argv[1], ios::in | ios::nocreate);
	if (!from) { cerr << "Open of file " << argv[1] << " Failed"; return FAILED; }
	ofstream to(argv[2], ios::out);
	if (!to) { cerr << "OFStream Open Failed"; return FAILED; }

	unsigned char c;
	while (from.get(c))
		HTL.hit(c);

	if (!from.eof() || to.bad())
	{
		cout << "File I/O Failed";
		return FAILED;
	}

#if defined(DEBUG)
//	HTL.dump(32, 128);
#endif

	HTL.convertToTree();

#if defined(DEBUG)
	HTL.dump(0, HTL_COUNT);
#endif

	cout << "File I/O complete. Press any key to end...";
	while (!kbhit());
	return OK;
}