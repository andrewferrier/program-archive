/*
	THIS PROGRAM USES ONE CRUCIAL
	FUNCTION WHICH IS INCLUDED IN MY QUICKC LIBS.
	IF YOU DON'T HAVE THIS, YOU'LL HAVE TO FIND A SUITABLE REPLACEMENT.

	SpFormat - Written by and Copyright Andrew Ferrier, Spheroid Software 1998.

	This program uses the Microsoft C Function '_bios_disk', so it
	may not be very portable. I will try to sort out this issue later.
	Apart from this, the program should be ANSI C compatible.

==> To do:
	Fix bootsig bug.

==> Command Line Options:
	+r Verify
	+q Quick (and I mean QUICK) format
	+v Specify Volume Label
	+s Bootable (sort of)
*/

#define VERSION        "1.2"
#define APPNAME        "SpFormat"
#define APPNAME_FILE   "SPFORMAT"
#define DEBUG

#include "sp_stand.c" /* Standard Spheroid Extensions */
#include "asm.h"      /* Spheroid Assembler Helper    */
#include "cmdline.c"  /* Cmdline Parser               */
#include "apps.c"

#include <ctype.h>    /* toupper()                    */
#include <bios.h>     /* _bios_disk()                 */
#include <stdio.h>    /* printf()                     */
#include <string.h>   /* strcpy()                     */
#include <conio.h>    /* kbhit()                      */
#include <assert.h>   /* assert()                     */
#include <stdlib.h>   /* system()                     */

const byte driveNumber = 0;
char  volumeLabel[11]  = "SpFormatted";   /* must be 11 chars + '\0' */

boolean verify, quickFormat, specifyLabel, bootable;

// #define DISK_148
#define DISK_144
// #define DISK_720

#if defined(DISK_144) || defined(DISK_148)
	#define MAX_SECTOR 18
	#define SECTORS_PER_FAT 9
	#define ROOT_DIR_SECTORS 14
	#define ROOT_DIR_ENTRIES 224
	#define MEDIA_DESCRIPTOR_BYTE 0xF0
	#define CLUSTER_SIZE 1
#else
	#define MAX_SECTOR 9
	#define SECTORS_PER_FAT 3
	#define ROOT_DIR_SECTORS 7
	#define ROOT_DIR_ENTRIES 112
	#define MEDIA_DESCRIPTOR_BYTE 0xF9
	#define CLUSTER_SIZE 2
#endif

#if defined(DISK_148)
	#define MAX_TRACK 81
#else
	#define MAX_TRACK 79
#endif

#define MIN_SECTOR 1
#define NUM_SECTORS (MAX_SECTOR - MIN_SECTOR + 1)
#define MIN_HEAD 0
#define MAX_HEAD 1
#define NUM_HEADS (MAX_HEAD - MIN_HEAD + 1)
#define MIN_TRACK 0
#define NUM_TRACKS (MAX_TRACK - MIN_TRACK + 1)

const int SECTSIZE = 512;
const int SECTSIZE_CODE = 2;

const int NUM_FATS = 2;              /* due to bug in DOS, must be 1 or 2 */
#define RETRIES 3                    /* retries for every disk op.        */
#define ROOT_DIR_ENTRY_SIZE 32

typedef struct diskinfo_t diskinfo;  /* Stdio.h really is awful - the
                                        information hiding is so crap! */

typedef byte Head;
typedef byte Sector;
typedef byte Track;

int main(int argc, char *argv[])
{
	boolean formatRaw(void);
	void createStructure(void);
	void setOptions(int argc, char *argv[]);
	void printInfo(void);

	printHeader();
	setOptions(argc, argv);
	printInfo();

	if (specifyLabel)
	{
		char* volTemp;
		// kassert((volTemp = malloc(256 * sizeof(char))) != NULL);

		do printf("Enter the new volume label (11 characters or less): ");
		while (gets(volTemp) == NULL);

		if (strlen(volTemp) > 11) volTemp[11] = '\0';
		strcpy(volumeLabel, volTemp);
		free(volTemp);
	}

	if (!quickFormat)
	{
		printf("Raw Formatting the Diskette...\n");
		if (formatRaw() == FAILED) return FAILED;
		printf("Raw Formatting Done.\n");
	}

	createStructure();
	printf("Format Complete.\n");

	return OK;
}

void setOptions(int argc, char *argv[])
{
	cmdlineParse(argc, argv, false);

	if ((existOption("r") == NEITHER) || (existOption("r") == POSITIVE))
		verify = true;
	else
		verify = false;

	if ((existOption("q") == NEITHER) || (existOption("q") == POSITIVE))
		quickFormat = true;
	else
		quickFormat = false;

	if ((existOption("v") == NEITHER) || (existOption("v") == POSITIVE))
		specifyLabel = true;
	else
		specifyLabel = false;

	if (existOption("s") == NEGATIVE)
		bootable = false;
	else
		bootable = true;

	cmdlineFree();
}

void printInfo(void)
{
	printf("Tracks: %d, Heads: %d, Sectors per Track: %d\n", NUM_TRACKS,
			NUM_HEADS, NUM_SECTORS);
	printf("Sector Size: %d, Root Directory Entries: %d\n", SECTSIZE,
			ROOT_DIR_ENTRIES);

	printf("\n");
	printf("Boot Sector Size             : %d bytes\n", SECTSIZE);
	printf("FAT Size (total of %1d copies) : %d bytes\n",
			NUM_FATS, SECTSIZE * SECTORS_PER_FAT * NUM_FATS);
	printf("Root Directory Size          : %d bytes\n",
			ROOT_DIR_ENTRIES * 32);
	printf("\n");
}


/* This initialises the BIOS for formatting. */

void initDiskBIOS(void)
{
	asm {
		mov ah, 0x18
		mov ch, NUM_TRACKS
		mov cl, NUM_SECTORS
		mov dl, driveNumber
		int 0x13
	}
}

/* This function is effectively a wrapper around _bios_disk */

unsigned disk_io(unsigned service, unsigned drivenum,
        unsigned int absoluteSector, void *buffer)
{
		byte     ah;
        diskinfo dsk;
		byte     tries = 1;

        dsk.drive    = drivenum;
        dsk.nsectors = 1;
        dsk.head     = (absoluteSector /  NUM_SECTORS) % NUM_HEADS;
        dsk.track    =  absoluteSector / (NUM_SECTORS  * NUM_HEADS);
        dsk.sector   = 1 + (absoluteSector % NUM_SECTORS);
        dsk.buffer   = (void far *) buffer;

        while ((ah = HI_BYTE(_bios_disk(service, &dsk))) != 0)
        {
                if (tries > RETRIES)
                {
                        printf("Sorry, too many retries.\n");
                        printf("The diskette is probably broken.\n");
						printf("BIOS Error Code: 0x%-2x\n", ah);
						exit(FAILED);
                }

                tries++;
        }
        return OK;
}

/* This function will do the raw formatting */
boolean formatRaw(void)
{
	typedef struct
		{ byte cylinder; byte head; byte sector; byte sizecode; }
		trackinfo;

	diskinfo  dsk;
	trackinfo ti[NUM_SECTORS];
	Track     track;
	Head      headnum;
	Sector    sector;

	initDiskBIOS();

	dsk.drive  = driveNumber;

	for (track = MIN_TRACK; track <= MAX_TRACK; track++)
	{
		for (headnum = MIN_HEAD; headnum <= MAX_HEAD; headnum++)
		{
			const char* printMessage = "\r%s %d Sectors on Track %d, "
					"Head %d... (press any key to end program)   ";

			for (sector = MIN_SECTOR; sector <= MAX_SECTOR; sector++)
			{
				ti[sector - MIN_SECTOR].cylinder = track;
				ti[sector - MIN_SECTOR].head     = headnum;
				ti[sector - MIN_SECTOR].sector   = sector;
				ti[sector - MIN_SECTOR].sizecode = SECTSIZE_CODE;
			}

			dsk.head  = headnum;
			dsk.track = track;

			printf(printMessage, "Formatting", NUM_SECTORS, track, headnum);

			dsk.buffer = (void far *) &(ti[0]);
			if (HI_BYTE(_bios_disk(_DISK_FORMAT, &dsk)) != 0) return FAILED;

			if (verify)
			{
				printf(printMessage, "Verifying ", NUM_SECTORS, track,
						headnum);

				dsk.nsectors = NUM_SECTORS;
				dsk.sector   = MIN_SECTOR;
				if (HI_BYTE(_bios_disk(_DISK_VERIFY, &dsk)) != 0)
						return FAILED;
			}

			if (kbhit()) return FAILED;
		}
	}

	printf("\n");
	return OK;
}

void createStructure(void)
{
	byte abssector = 0;

	void writeBootsector     (byte* abssector);
	void writeFAT            (byte* abssector);
	void writeRootDirectory  (byte* abssector);

	printf("Creating DOS-Style Diskette Structure...\n");

	printf("Writing Boot Sector... ");
	writeBootsector(&abssector);
	printf("Done.\n");

	printf("Writing FAT... ");
	writeFAT(&abssector);
	printf("Done.\n");

	printf("Writing Root Directory... ");
	writeRootDirectory(&abssector);

	if (bootable)
	{
		char tempCh       = driveNumber + 65;
		char passString[] = "sys  :";

		passString[5] = tempCh;
		system(passString);
	}

	printf("Done.\n");
}

void writeBootsector(byte* abssector)
{
	struct bootsector
	{
		byte jump_instruction[3];
		byte system_id[8];
		Word bytes_per_sector;
		byte sectors_per_cluster;
		Word sectors_in_reserved_area;
		byte num_fats;               /* 9 sectors each * 2 = 18 sectors */
		byte root_dir_entries;
		byte reserved1;
		Word total_sectors;
		byte media_descriptor;
		Word sectors_per_fat;
		Word sectors_per_track;
		Word num_heads;
		DWord num_hidden_sectors;
		DWord total_sectors2;           /* relevant if total_sectors = 0; */
		Word physical_drvnum;
		byte reserved2;
		byte sig_byte;                    /* must be 29h */
		byte serial_num[4];
		byte vol_label[11];
		byte file_system_type[8];         /* FAT12 or FAT16 */
		byte booter[447];
		Word bootsig[2];                  /* 55AAH if bootable */
	} *bs;

	int i;

	// kassert((bs = calloc(sizeof(struct bootsector), sizeof(byte))) != NULL);

	bs->jump_instruction[0] = 0xEB; /* JMP 3E */
	bs->jump_instruction[1] = 0x3C; /* ...... */
	bs->jump_instruction[2] = 0x90; /* NOP    */

	for (i = 0; i < 447; i++) bs->booter[i] = 0;

	/* Copy App Name as Disk Type */
	{
		char systemid[9] = APPNAME_FILE;
		for (i = 0; i < 8; i++) bs->system_id[i] = toupper(systemid[i]);
	}

	bs->bytes_per_sector         = SECTSIZE;
	bs->sectors_per_cluster      = CLUSTER_SIZE;
	bs->sectors_in_reserved_area = 1;
	bs->num_fats                 = NUM_FATS;
	bs->root_dir_entries         = ROOT_DIR_ENTRIES;
	bs->total_sectors            = NUM_HEADS * NUM_SECTORS * NUM_TRACKS;
	bs->media_descriptor         = MEDIA_DESCRIPTOR_BYTE;
	bs->sectors_per_fat          = SECTORS_PER_FAT;
	bs->sectors_per_track        = NUM_SECTORS;
	bs->num_heads                = NUM_HEADS;
	bs->num_hidden_sectors       = 0;
	bs->total_sectors2           = 0;     /* Only needed for 32MB+ */
	bs->physical_drvnum          = 0;
	bs->sig_byte                 = 0x29;

	for (i = 0; i < 4; i++)  bs->serial_num[i] = 0x66;
	for (i = 0; i < 11; i++) bs->vol_label[i]  = toupper(volumeLabel[i]);

	{
			const char fs[9] = "FAT12   ";
			for (i = 0; i < 9; i++) bs->file_system_type[i] = fs[i];
	}

	// GEOFF: THIS LINE IS ESSENTIAL, ALONG WITH OTHER THINGS
	// WHICH I HAVEN'T WRITTEN YET, TO MAKE THE DISK BOOTABLE.
	// BUT I COULDN'T GET IT TO COMPILE, SO I'VE COMMENTED IT OUT.

	//bs->bootsig = bootable ? (0x55AA) : (0);

	disk_io(_DISK_WRITE, driveNumber, (*abssector)++, (void *) bs);

	free(bs);
}

void writeFAT(byte* abssector)
{
	byte* sectors;
	byte  i, j;

	sectors = calloc(SECTSIZE * SECTORS_PER_FAT, sizeof(byte));
	// kassert(sectors != NULL);

	sectors[0] = 0xF0;
	sectors[1] = sectors[2] = 0xFF;

	for (i = 0; i < NUM_FATS; i++)
	{
		for (j = 0; j < SECTORS_PER_FAT; j++)
		{
			byte sectindex = (j == 0) ? 0 : (j * SECTSIZE) - 1;

			disk_io(_DISK_WRITE, driveNumber, (*abssector)++,
					(void *) ((byte *) sectors + sectindex));
		}
	}

	free(sectors);
}

void writeRootDirectory(byte* abssector)
{
	typedef struct
	{
		byte  filename[8];
		byte  extension[3];
		byte  attribute;
		byte  reserved[10];
		Word  time;
		Word  date;
		Word  start_cluster;
		DWord filesize;
	} rootdir;

	rootdir *sectors;
	byte    *sectors_byte;
	Word    i;

	assert(sizeof(rootdir) == ROOT_DIR_ENTRY_SIZE);

	sectors      = calloc(ROOT_DIR_ENTRIES * sizeof(rootdir), sizeof(byte));
	sectors_byte = (byte *) sectors;

	// kassert (sectors != NULL);

	for (i = 0; i < 8; i++)
			sectors[0].filename[i]  = toupper(volumeLabel[i]);
	for (i = 0; i < 3; i++)
			sectors[0].extension[i] = toupper(volumeLabel[i + 8]);

	sectors[0].attribute = 8;  /* Volume Label Attribute */

	for (i = 0; i < ROOT_DIR_SECTORS; i++)
	{
		byte sectindex = (i == 0) ? 0 : (i * SECTSIZE) - 1;

		disk_io(_DISK_WRITE, driveNumber, (*abssector)++,
				(void *) (sectors_byte + sectindex));
	}

	free(sectors);
}

/*

Version History:
	1.2         Various modifications (1/9/1998)
	1.1e.41     ???
*/
