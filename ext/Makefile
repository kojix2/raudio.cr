CC ?= gcc

# MSVC -> cl
# MinGW -> gcc
ifeq ($(OS),Windows_NT)
	ifdef MSYSTEM
		CC ?= gcc
	else
		CC ?= cl
	endif
endif

ifeq ($(OS),Windows_NT)
	ifeq ($(CC),cl)
		EXT_LIB = raudio.lib
		OBJ = raudio.obj
		SRC = raudio/src/raudio.c
		CFLAGS = /nologo /c /Iraudio/src /DRAUDIO_STANDALONE /DSUPPORT_MODULE_RAUDIO /DSUPPORT_FILEFORMAT_WAV /DSUPPORT_FILEFORMAT_OGG /DSUPPORT_FILEFORMAT_MP3 /DSUPPORT_FILEFORMAT_FLAC /DSUPPORT_FILEFORMAT_QOA /Fo$(OBJ)
		OUTFLAG =
		LIB_CMD = lib /OUT:raudio.lib raudio.obj
	else
		EXT_LIB = libraudio.a
		OBJ = raudio.o
		SRC = raudio/src/raudio.c
		CFLAGS = -c -Iraudio/src -DRAUDIO_STANDALONE -DSUPPORT_MODULE_RAUDIO -DSUPPORT_FILEFORMAT_WAV -DSUPPORT_FILEFORMAT_OGG -DSUPPORT_FILEFORMAT_MP3 -DSUPPORT_FILEFORMAT_FLAC -DSUPPORT_FILEFORMAT_QOA
		OUTFLAG = -o $(OBJ)
		AR_CMD = ar rcs libraudio.a raudio.o
	endif
else
	EXT_LIB = libraudio.a
	OBJ = raudio.o
	SRC = raudio/src/raudio.c
	CFLAGS = -c -Iraudio/src -DRAUDIO_STANDALONE -DSUPPORT_MODULE_RAUDIO -DSUPPORT_FILEFORMAT_WAV -DSUPPORT_FILEFORMAT_OGG -DSUPPORT_FILEFORMAT_MP3 -DSUPPORT_FILEFORMAT_FLAC -DSUPPORT_FILEFORMAT_QOA
	OUTFLAG = -o $(OBJ)
	AR_CMD = ar rcs libraudio.a raudio.o
endif

all: $(EXT_LIB)

raudio.obj raudio.o: $(SRC)
	$(CC) $(CFLAGS) $(SRC) $(OUTFLAG)

raudio.lib: raudio.obj
	$(LIB_CMD)

libraudio.a: raudio.o
	$(AR_CMD)

clean:
	rm -f raudio.o raudio.obj libraudio.a raudio.lib

# install/uninstall targets
PREFIX ?= /usr/local
DESTDIR ?=
LIBDIR ?= $(PREFIX)/lib

# Command used for installing files; kept simple for non-interactive postinstall
INSTALL_CMD ?= mkdir -p $(DESTDIR)$(LIBDIR) && cp -f $(EXT_LIB) $(DESTDIR)$(LIBDIR)/$(EXT_LIB)

install: all
	@$(INSTALL_CMD)

uninstall:
	-@rm -f $(DESTDIR)$(LIBDIR)/$(EXT_LIB)

.PHONY: all clean install uninstall