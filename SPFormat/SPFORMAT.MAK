PROJ	=SPFORMAT
DEBUG	=1
CC	=qcl
CFLAGS_G	=
CFLAGS_D	=/Od /Gi$(PROJ).mdt /Zi /Zr
CFLAGS_R	=/O /DNDEBUG
CFLAGS	=$(CFLAGS_G) $(CFLAGS_D)
LFLAGS_G	=/NOI
LFLAGS_D	=/INCR /CO
LFLAGS_R	=
LFLAGS	=$(LFLAGS_G) $(LFLAGS_D)
RUNFLAGS	=
OBJS_EXT = 	
LIBS_EXT = 	

all:	$(PROJ).exe

spformat.obj:	spformat.c

$(PROJ).exe:	spformat.obj $(OBJS_EXT)
	echo >NUL @<<$(PROJ).crf
spformat.obj +
$(OBJS_EXT)
$(PROJ).exe

$(LIBS_EXT);
<<
	ilink -a -e "link $(LFLAGS) @$(PROJ).crf" $(PROJ)

run: $(PROJ).exe
	$(PROJ) $(RUNFLAGS)

