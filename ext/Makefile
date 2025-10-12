CC ?= gcc
AR ?= ar
RANLIB ?= ranlib

# Common flags
CPPFLAGS ?=
CFLAGS   ?=
EXTRA_CPPFLAGS ?=
EXTRA_CFLAGS   ?=

# MSVC -> cl
# MinGW -> gcc
ifeq ($(OS),Windows_NT)
	ifdef MSYSTEM
		CC ?= gcc
	else
		CC = cl
	endif
endif

ifeq ($(OS),Windows_NT)
	ifeq ($(CC),cl)
		EXT_LIB = raudio.lib
		OBJ = raudio.obj
		SRC = raudio/src/raudio.c
		CPPFLAGS += \
			/Iraudio/src \
			/DRAUDIO_STANDALONE \
			/DSUPPORT_MODULE_RAUDIO \
			/DSUPPORT_FILEFORMAT_WAV \
			/DSUPPORT_FILEFORMAT_OGG \
			/DSUPPORT_FILEFORMAT_MP3 \
			/DSUPPORT_FILEFORMAT_FLAC \
			/DSUPPORT_FILEFORMAT_QOA \
			/DSUPPORT_FILEFORMAT_XM \
			/DSUPPORT_FILEFORMAT_MOD
		CFLAGS   += /nologo /c /O2 /Fo$(OBJ)
		CPPFLAGS += $(EXTRA_CPPFLAGS)
		CFLAGS   += $(EXTRA_CFLAGS)
		OUTFLAG =
		LIB_CMD = lib /OUT:raudio.lib raudio.obj
	else
		EXT_LIB = libraudio.a
		OBJ = raudio.o
		SRC = raudio/src/raudio.c
		CPPFLAGS += \
			-Iraudio/src \
			-DRAUDIO_STANDALONE \
			-DSUPPORT_MODULE_RAUDIO \
			-DSUPPORT_FILEFORMAT_WAV \
			-DSUPPORT_FILEFORMAT_OGG \
			-DSUPPORT_FILEFORMAT_MP3 \
			-DSUPPORT_FILEFORMAT_FLAC \
			-DSUPPORT_FILEFORMAT_QOA \
			-DSUPPORT_FILEFORMAT_XM \
			-DSUPPORT_FILEFORMAT_MOD
		CFLAGS   += -c -O2 -fPIC
		CPPFLAGS += $(EXTRA_CPPFLAGS)
		CFLAGS   += $(EXTRA_CFLAGS)
		OUTFLAG = -o $(OBJ)
		AR_CMD = $(AR) rcs libraudio.a raudio.o
	endif
else
	EXT_LIB = libraudio.a
	OBJ = raudio.o
	SRC = raudio/src/raudio.c
	CPPFLAGS += \
		-Iraudio/src \
		-DRAUDIO_STANDALONE \
		-DSUPPORT_MODULE_RAUDIO \
		-DSUPPORT_FILEFORMAT_WAV \
		-DSUPPORT_FILEFORMAT_OGG \
		-DSUPPORT_FILEFORMAT_MP3 \
		-DSUPPORT_FILEFORMAT_FLAC \
		-DSUPPORT_FILEFORMAT_QOA \
		-DSUPPORT_FILEFORMAT_XM \
		-DSUPPORT_FILEFORMAT_MOD
	CFLAGS   += -c -O2 -fPIC
	CPPFLAGS += $(EXTRA_CPPFLAGS)
	CFLAGS   += $(EXTRA_CFLAGS)
	OUTFLAG = -o $(OBJ)
	AR_CMD = $(AR) rcs libraudio.a raudio.o

	# --- auto-add multiarch include for glibc when available (helps non-system clang) ---
	ifeq ($(filter cl,$(CC)),)  # skip for MSVC
	MULTIARCH := $(shell gcc -print-multiarch 2>/dev/null)
	ifneq ($(strip $(MULTIARCH)),)
		CPPFLAGS += -isystem /usr/include/$(MULTIARCH)
	endif
	endif
endif

all: $(EXT_LIB)

raudio.obj raudio.o: $(SRC)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(SRC) $(OUTFLAG)


raudio.lib: raudio.obj
	$(LIB_CMD)

libraudio.a: raudio.o
	$(AR_CMD)
	-@$(RANLIB) libraudio.a >/dev/null 2>&1 || true

clean:
	$(RM) -f raudio.o raudio.obj libraudio.a raudio.lib


# install/uninstall targets
PREFIX ?= /usr/local
DESTDIR ?=
LIBDIR ?= $(PREFIX)/lib

# Command used for installing files
INSTALL ?= install
INSTALL_CMD ?= mkdir -p $(DESTDIR)$(LIBDIR) && \
	$(INSTALL) -m 0644 $(EXT_LIB) $(DESTDIR)$(LIBDIR)/$(EXT_LIB)

install: all
	@$(INSTALL_CMD)

uninstall:
	-@rm -f $(DESTDIR)$(LIBDIR)/$(EXT_LIB)

.PHONY: all clean install uninstall