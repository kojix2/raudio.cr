CC ?= gcc
AR ?= ar
RANLIB ?= ranlib
CRYSTAL ?= crystal
# BusyBox make does not define RM.
RM ?= rm

# raudio repository
RAUDIO_REPO ?= https://github.com/raysan5/raudio.git
RAUDIO_BRANCH ?= master
RAUDIO_DIR = raudio

# Build from a generated copy so postinstall can fetch pristine upstream raudio
# sources, then apply our small local compatibility patch without editing them.
BUILD_DIR = build
ORIG_SRC = $(RAUDIO_DIR)/src/raudio.c
PATCHED_SRC = $(BUILD_DIR)/raudio.c
PATCH_SCRIPT = patch_raudio.cr
PATCH_CACHE_DIR = $(BUILD_DIR)/.crystal-cache

# Common flags
CPPFLAGS ?=
CFLAGS   ?=
EXTRA_CPPFLAGS ?=
EXTRA_CFLAGS   ?=

# BusyBox make ignores .DEFAULT_GOAL, so keep all first.
.DEFAULT_GOAL := all

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
		SRC = $(PATCHED_SRC)
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
		SRC = $(PATCHED_SRC)
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
	SRC = $(PATCHED_SRC)
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

all: check-raudio $(EXT_LIB)

# Ensure raudio directory exists and is populated
check-raudio:
	@if [ ! -f "$(RAUDIO_DIR)/src/raudio.c" ]; then \
		if [ -f "../.git" ] || [ -d "../.git" ]; then \
			echo "Initializing raudio submodule..."; \
			cd .. && git submodule update --init --recursive; \
		else \
			echo "raudio source not found. Cloning from $(RAUDIO_REPO)..."; \
			$(RM) -rf $(RAUDIO_DIR); \
			git clone --depth 1 --branch $(RAUDIO_BRANCH) $(RAUDIO_REPO) $(RAUDIO_DIR); \
		fi; \
	fi

# Apply local source adjustments after submodule init/clone and before compile.
patch: check-raudio $(PATCHED_SRC)

$(PATCHED_SRC): check-raudio $(ORIG_SRC) $(PATCH_SCRIPT) Makefile
	@mkdir -p "$(BUILD_DIR)" "$(PATCH_CACHE_DIR)"
	CRYSTAL_CACHE_DIR="$(PATCH_CACHE_DIR)" $(CRYSTAL) run $(PATCH_SCRIPT) -- "$(ORIG_SRC)" "$(PATCHED_SRC)"

# Ensure the library build uses the patched generated source.
$(EXT_LIB): check-raudio patch

raudio.obj raudio.o: check-raudio $(SRC)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(SRC) $(OUTFLAG)


raudio.lib: raudio.obj
	$(LIB_CMD)

libraudio.a: raudio.o
	$(AR_CMD)
	-@$(RANLIB) libraudio.a >/dev/null 2>&1 || true

clean:
	$(RM) -f raudio.o raudio.obj libraudio.a raudio.lib "$(PATCHED_SRC)"
	$(RM) -rf "$(PATCH_CACHE_DIR)"


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

.PHONY: all check-raudio patch clean install uninstall
