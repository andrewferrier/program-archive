/*
	Mouse interface class library, written in Borland Turbo C++ 3.0
	Modified by Andrew J Ferrier from other code.
	Copyright Andrew Ferrier, Spheroid Software 1996.
*/

#include "sp_stand.cpp"

#define MOUSE 0x33

class mousea
{

private:
	WORD dx, dy, dbuttons;

public:
	// function declares
	mousea(void) { dx = dy = dbuttons = MAX_WORD; } // Default Constructor

	BOOL get_coords(WORD& x, WORD& y, WORD& buttons);
	void set_coords(WORD x, WORD y);
	void set_limits(WORD minx, WORD miny, WORD maxx, WORD maxy);
};


BOOL mousea::get_coords(WORD& x, WORD& y, WORD& buttons)
{
	WORD ex, ey, ebuttons;

	asm {
		mov ax, 0x03
		int MOUSE
		mov [ex], cx
		mov [ey], dx
		mov [ebuttons], bx
	}

	x = ex;
	y = ey;
	buttons = ebuttons;

	if ((dx != ex) || (dy != ey) || (dbuttons != ebuttons))
	{
		dx = ex;
		dy = ey;
		dbuttons = ebuttons;

		return TRUE;     // i.e. changed
	}
	else
	{
		return FALSE;     // not changed
	}
}

void mousea::set_coords(WORD x, WORD y)
{
	asm {
		mov ax, 0x0004
		mov cx, [x]
		mov dx, [y]
		int MOUSE
	}
}

void mousea::set_limits(WORD minx, WORD miny, WORD maxx, WORD maxy)
{
	asm {
		mov ax, 0x0007
		mov cx, [minx]
		mov dx, [maxx]
		int MOUSE
		mov ax, 0x0008
		mov cx, [miny]
		mov dx, [maxy]
		int MOUSE
	}
}

mousea mouse;

#undef MOUSE
