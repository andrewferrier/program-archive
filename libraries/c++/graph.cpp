/*

	Spheroid Software Graphics Routines,

	Written by Andrew J Ferrier.

	Copyright Andrew Ferrier, Spheroid Software 1997.

	Classes:

	gp_screenmode	- Screen mode class
	gp_main      	- Main graphics routines
	gp_retrace   	- Check for Horizontal and Vertical Retrace
	gp_text         - Text mode functions
	gp_screen	    - Virtual Screen Functions

*/

#if !defined(SP_GRAPH_CALLED)		// Stop it being called twice.
#define SP_GRAPH_CALLED             // ................

// Includes
#include <alloc.h>                  // Memory allocation - farmalloc etc.
#include <dos.h>                    // MK_FP
#include <mem.h>                    // _fmemcpy()

#include "sp_stand.cpp"             // Spheroid Standard Stuff
#include "sp_asm.cpp"               // Spheroid Assembler Handling.

// Constants
#define VGA_BASE 0xA000             // Hex Base of VGA mem.
#define SCREEN 0x10                 // Screen Interrupt
#define SCREEN_SIZE (64000)         // Size of VGA memory in bytes (mode 13h)

// Macros for use during programming
#define MAX_X 		((*cur_screenmode).maxx())
#define MAX_Y 		((*cur_screenmode).maxy())
#define MIN_X 		((*cur_screenmode).minx())
#define MIN_Y       ((*cur_screenmode).miny())
#define CENTRE_X    ((*cur_screenmode).centrex())
#define CENTRE_Y    ((*cur_screenmode).centrey())
#define MIN_PAL     ((*cur_screenmode).maxpal())
#define MAX_PAL     ((*cur_screenmode).minpal())
#define MIN_PAL_VAL ((*cur_screenmode).maxpalval())
#define MAX_PAL_VAL ((*cur_screenmode).minpalval())
#define WIDTH_X     ((*cur_screenmode).maxx() + 1)
#define HEIGHT_Y    ((*cur_screenmode).maxy() + 1)

typedef void far *GP_MEM;

const GP_MEM VGA_POINTER = MK_FP(VGA_BASE, 0x0000);

// Typedefs
typedef BYTE VIDEO_MODE;            // Define types for various video +
typedef BYTE ATTRIBUTE;             // graphics related things.
typedef BYTE COLOUR;                // ................

// *********************** CLASS DECLARATIONS *******************************

class gp_screenmode
{

private:

	VIDEO_MODE biosmode; // The number to call it when talking to the BIOS

	BOOL graphics : 1;   // TRUE if it's a graphics mode
	BOOL working  : 1;   // is an operative mode, not just a * or the like
	BOOL current  : 1;   // Is this the current mode?

	WORD       min_x,    min_y;
	WORD       max_x,    max_y;
	WORD	   centre_x, centre_y;

	ATTRIBUTE  min_pal;
	ATTRIBUTE  max_pal;    // Max Number of palette entries
	COLOUR     min_pal_val;
	COLOUR     max_pal_val;

public:

	// Constructors
	gp_screenmode(void) {working = FALSE; current = FALSE;}

	gp_screenmode(VIDEO_MODE mode, WORD mx_x, WORD mx_y, BOOL truegp,
		 ATTRIBUTE paln);

	// Find out about this class
	BOOL iscurrent(void)         {return current;}
	WORD miny(void)              {return min_y;}
	WORD minx(void)              {return min_x;}
	WORD maxx(void)              {return max_x;}
	WORD maxy(void)              {return max_y;}
	WORD centrex(void)           {return centre_x;}
	WORD centrey(void)           {return centre_y;}
	ATTRIBUTE minpal(void)       {return min_pal;}
	ATTRIBUTE maxpal(void)       {return max_pal;}
	COLOUR minpalval(void)       {return min_pal_val;}
	COLOUR maxpalval(void)       {return max_pal_val;}

	// Actually Initiates this mode
	void set(void);

};

class gp_main
{

public:

	// Main Functions
	void set_palette(ATTRIBUTE attr, COLOUR red, COLOUR green, COLOUR blue);
	void get_palette(ATTRIBUTE attr, COLOUR& red, COLOUR& green, COLOUR& blue);
	void put_pixel(WORD x, WORD y, ATTRIBUTE attr, GP_MEM where = VGA_POINTER);
	// ATTRIBUTE get_pixel(WORD x, WORD y);
	void line(WORD x1, WORD y1, WORD x2, WORD y2, ATTRIBUTE attr);
	void box(WORD x1, WORD y1, WORD x2, WORD y2, ATTRIBUTE attr);
	void clear_screen(void);

};

class gp_retrace
{

public:
	void wait_vretrace(void);
	void wait_hretrace(void);

};

class gp_text
{

public:
	void set_cursor(BYTE row, BYTE column);
	void get_cursor(BYTE& row, BYTE& column);

};

/* class gp_screen
{

private:
	MEMORY screen; // Far pointer to memory.

public:
	gp_screen(void)  {screen = farcalloc(SCREEN_SIZE, 1);}
	~gp_screen(void) {farfree(screen);}

	void writeout(void) {_fmemcpy(VGA_POINTER, screen, SCREEN_SIZE);}

}; */

// ******************** SCREEN MODES ***************************************

gp_screenmode vga_256colours(13, 320, 200, TRUE,  16);
gp_screenmode vga_hires     (12, 640, 480, TRUE,  16);
gp_screenmode vga_text      (3,  0,   0,   FALSE, 16);

gp_screenmode *cur_screenmode;

// ******************** 'GP_SCREENMODE' CLASS ******************************

gp_screenmode::gp_screenmode(VIDEO_MODE mode, WORD mx_x, WORD mx_y, BOOL truegp, ATTRIBUTE paln)
{
	graphics = truegp;

	if (graphics)
	{
		// It's a graphics mode
		max_x    = mx_x - 1;
		max_y    = mx_y - 1;
		centre_x = max_x << 1;
		centre_y = max_y << 1;
	}
	else
	{
		// It's a text mode
		max_x = max_y = centre_x = centre_y = 0;
	}

	biosmode    = mode;

	min_x       = min_y = 0;
	min_pal     = 0;
	max_pal     = paln - 1;

	min_pal_val = 0;
	max_pal_val = 63;

	working     = TRUE;
	current     = FALSE;
}

// Start this mode
void gp_screenmode::set(void)
{
	VIDEO_MODE mode = biosmode;  // Otherwise inline asm. does not like it

	if (working)
	{
		asm {
			xor ah, ah           // Function to change screen-mode.
			mov al, mode
			int SCREEN
		}

		cur_screenmode = this;   // Set pointer to point to this screenmode
		current = TRUE;
	}
}

// ******************** 'GP_MAIN' CLASS ***********************************

void gp_main::set_palette(ATTRIBUTE attr, COLOUR red, COLOUR green, COLOUR blue)
{
	asm {
		mov dx, 0x3c8
		mov al, attr
		out dx, al
		inc dx
		mov al, red
		out dx, al
		mov al, green
		out dx, al
		mov al, blue
		out dx, al
	}
}

void gp_main::get_palette(ATTRIBUTE attr, COLOUR& red, COLOUR& green, COLOUR& blue)
{
	BYTE rr, gg, bb;

	asm {
		mov dx, 0x3c7
		mov al, attr
		out dx, al
		add dx, 2
		in al, dx
		mov rr, al
		in al, dx
		mov gg, al
		in al, dx
		mov bb, al
	}

	red = rr; green = gg; blue = bb;
}

#pragma argsused

void gp_main::put_pixel(WORD x, WORD y, ATTRIBUTE attr, GP_MEM where)
{
//	GP_MEM whereattr;

  //	whereattr = (GP_MEM) &attr;


	where = (((void far *) where) + (y * WIDTH_X) + x);

	printf("\n %p \n", where);

	// assert(where == MK_FP(VGA_BASE, (y * WIDTH_X) + x));

	// _fmemcpy(where, whereattr, 1);
}


/* ATTRIBUTE gp_main::get_pixel(WORD x, WORD y)
{
	register ATTRIBUTE attr;

	if (vga_256colours.iscurrent())
	{
		asm {
			mov ax, VGA_BASE           // Load the Base Address in
			mov es, ax                 // And Put it as the extra seg.
			mov bx, [x]                // Load X into BX
			mov dx, [y]                // Load Y into DX
			mov di, bx                 // Put BX(X) into the pointer
			mov bx, dx                 // Move DX(Y) into BX now BX=Y, DX=Y
			mov dh, dl                 // * DX by 256
			xor dl, dl                 // ...
			mov cl, 6                  // * BX by 64 - Note: 256 + 64 = 320
			shl bx, cl                 // ...
			add dx, bx                 // Add BX to DX
			add di, dx                 // Add DX (320 * Y) to the pointer
			mov al, es:[di]            // Grab the attr.
			mov [attr], al             // ...
		}
	}
	else
	{
		asm {
			mov ah, 0x0d
			mov dx, [y]
			mov cx, [x]
			xor bh,bh            // page
			int SCREEN
			mov [attr], al
		}
	}

	return attr;
}  */

void gp_main::line(WORD x1, WORD y1, WORD x2, WORD y2, BYTE attr)
{
	register int i;

	int deltax, deltay, numpixels,
		d, dinc1,  dinc2,
		x, xinc1,  xinc2 = 1,
		y, yinc1,  yinc2 = 1;

	// Calculate deltax and deltay for initialisation
	deltax = x2 - x1;
	deltay = y2 - y1;
	deltax = deltax < 0 ? -deltax : deltax;
	deltay = deltay < 0 ? -deltay : deltay;

	if (deltax >= deltay)               // Wider than high
	{
		// x is independent variable
		numpixels = deltax + 1;
		d = (deltay << 1) - deltax;
		dinc1 = deltay << 1;
		dinc2 = (deltay - deltax) << 1;
		xinc1 = 1;
		yinc1 = 0;
	}
	else                                // Higher than wide
	{
		// y is independent variable
		numpixels = deltay + 1;
		d = (deltax << 1) - deltay;
		dinc1 = deltax << 1;
		dinc2 = (deltax - deltay) << 1;
		xinc1 = 0;
		yinc1 = 1;
	}

	// Make sure x and y move in the right directions
	if (x1 > x2)
	{
		xinc1 = - xinc1;
		xinc2 = - xinc2;
	}
	if (y1 > y2)
	{
		yinc1 = - yinc1;
		yinc2 = - yinc2;
	}

	// Start drawing at <x1, y1>
	x = x1;
	y = y1;

	// Draw the pixels
	for (i = 1 ; i <= numpixels ; i++)
	{
		put_pixel(x, y, attr, VGA_POINTER);
		if (d < 0)
		{
			d += dinc1; x += xinc1; y += yinc1;
		}
		else
		{
			d += dinc2; x += xinc2; y += yinc2;
		}
	}
}

void gp_main::box(WORD x1, WORD y1, WORD x2, WORD y2, ATTRIBUTE attr)
{
	register WORD i;
			 WORD j;

	if (x2 < x1) swap(x1, x2);
	if (y2 < y1) swap(y1, y2);

	for (i = x1 ; i <= x2 ; i++)
	{
		for (j = y1 ; j <= y2 ; j++)
		{
			put_pixel(i, j, attr, VGA_POINTER);
		}
	}
}

void gp_main::clear_screen(void)
{
	if (vga_256colours.iscurrent())
	{
		asm {
			cld                // Make sure we travel the right way
			mov cx, 0x7D00     // Since we are storing words, /2 64000
			mov ax, VGA_BASE
			mov es, ax
			xor di, di         // Offset
			xor ax, ax         // Byte to store
			rep stosw
		}
	}
	else
	{
		box(MIN_X, MIN_Y, MAX_X, MAX_Y, 0);
	}
}

// ********************* 'GP_RETRACE' CLASS ********************************

void gp_retrace::wait_vretrace(void)
{
	asm mov dx, 0x3da      // Load the port
l1:
	asm in al, dx
	asm	and al, 0x8
	asm	jnz l1             // Continue Looping While Bit 4 = 0 (i.e. in
						   // retrace)
l2:
	asm	in al, dx
	asm	and al, 0x8
	asm	jz l2              // Continue looping while bit 4 = 1 (i.e not
						   // in retrace)
}

// For comments, see above func.

void gp_retrace::wait_hretrace(void)
{
	asm	mov dx, 0x3
l3:
	asm	in al, dx
	asm	and al, 0x1
	asm	jnz l3
l4:
	asm	in al, dx
	asm	and al, 0x1
	asm	jz l4
}

// ************************ 'GP_TEXT' CLASS ********************************

void gp_text::set_cursor(BYTE row, BYTE column = 0)
{
	asm {
		mov dh, [row]
		mov dl, [column]
		xor bh, bh       // page
		mov ah, 0x02
		int SCREEN
	}
}

void gp_text::get_cursor(BYTE& row, BYTE& column)
{
	BYTE row2, column2;

	asm {
		xor bh, bh       // page
		mov ah, 0x03
		int SCREEN
		mov row2, dh
		mov column2, dl
	}

	row = row2;
	column = column2;
}

#endif // Exclude whole file.