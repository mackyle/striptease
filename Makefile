# Makefile for striptease project
# Copyright (C) 2011,2012 Kyle J. McKay.  All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
# AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Except as contained in this notice, the name of the author(s) shall not
# be used in advertising or otherwise to promote the sale, use or other
# dealings in this Software without prior written authorization from the
# author(s).

include version.mak

.PHONY : all clean

ifeq ($(DEBUG),)
 DEBUG := 0
endif

export DEBUG

CC = clang
CINC = -Iinclude
XSDK := $(shell xcode-select -print-path 2>/dev/null)
ifeq ($(XSDK),)
 XSDK := /Developer
endif
ifeq (0,$(shell test -d '$(XSDK)/Platforms/MacOSX.platform/Developer/SDKs'; echo $$?))
 XSDK := $(XSDK)/Platforms/MacOSX.platform/Developer/SDKs
else
 ifeq (0,$(shell test -d '$(XSDK)/SDKs'; echo $$?))
  XSDK := $(XSDK)/SDKs
 else
  ifeq ($(DEBUG),0)
   ifneq ($(MAKECMDGOALS),clean)
    $(error Could not find Developer SDKs directory)
   endif
  endif
 endif
endif

OSXNUVER := $(shell uname -r | cut -d. -f1)
OSXNUVERACTUAL := $(shell uname -r | cut -d. -f1)

ifeq (0,$(shell test -d '$(XSDK)/MacOSX10.4u.sdk'; echo $$?))
 OSXNUVER := 8
endif

ifeq ($(DEBUG),0)
 $(shell mkdir -p build/Release/libstuff)
 DD=build/Release/
 COPTS=$(ARCH) -Os
 LDEXTRA=$(ARCH) -Wl,-S -Wl,-x
else
 $(shell mkdir -p build/Debug/libstuff)
 DD=build/Debug/
 COPTS=-O0 -g
 LDEXTRA=-g
endif

ARCH = -arch x86_64 -arch i386

COPTS += -include preinc.h -DCCTOOLSVER=$(CCTOOLSVER)

LDOPTS = -Wl,-no_uuid -Wl,-dead_strip -Wl,-multiply_defined,suppress
LDOPTS += $(LDEXTRA)

all : $(DD)tease

.PHONY : tools tease strip install_name_tool nm

tools : strip install_name_tool nm tease

tease : $(DD)tease

strip : $(DD)strip

install_name_tool : $(DD)install_name_tool

nm : $(DD)nm

LIBSTUFF_SRC := $(wildcard libstuff/*.c)

TEASE_SRC = \
	tease.c \
	$(LIBSTUFF_SRC)

STRIP_SRC = \
	strip.c \
	$(LIBSTUFF_SRC)

INSTALL_NAME_TOOL_SRC = \
	install_name_tool.c \
	$(LIBSTUFF_SRC)

NM_SRC = \
	nm.c \
	$(LIBSTUFF_SRC)

TEASE_OBJS = $(addprefix $(DD),$(TEASE_SRC:.c=.o)) $(DD)version_tease.o

STRIP_OBJS = $(addprefix $(DD),$(STRIP_SRC:.c=.o)) $(DD)version_strip.o

INSTALL_NAME_TOOL_OBJS = $(addprefix $(DD),$(INSTALL_NAME_TOOL_SRC:.c=.o)) \
	$(DD)version_install_name_tool.o

NM_OBJS = $(addprefix $(DD),$(NM_SRC:.c=.o)) $(DD)nm.o

$(DD)%.o : %.c
	$(CC) -Wall -c $(COPTS) $(CINC) -o $@ $<

$(DD)version_tease.o : version.c
	$(CC) -Wall -c $(COPTS) $(CINC) -DPROGRAMNAME=tease -o $@ $<

$(DD)version_strip.o : version.c
	$(CC) -Wall -c $(COPTS) $(CINC) -DPROGRAMNAME=strip -o $@ $<

$(DD)version_install_name_tool.o : version.c
	$(CC) -Wall -c $(COPTS) $(CINC) -DPROGRAMNAME=install_name_tool -o $@ $<

$(DD)version_nm.o : version.c
	$(CC) -Wall -c $(COPTS) $(CINC) -DPROGRAMNAME=nm -o $@ $<

$(DD)tease : $(TEASE_OBJS)
	$(CC) -o $@ $(LDOPTS) $^
ifneq ($(DEBUG),0)
	dsymutil $@
else
	strip $@
	cd '$(@D)' && zip -X -9 '$(@F)-$(CCTOOLSVER).zip' '$(@F)'
endif

$(DD)strip : $(STRIP_OBJS)
	$(CC) -o $@ $(LDOPTS) $^
ifneq ($(DEBUG),0)
	dsymutil $@
else
	strip $@
	cd '$(@D)' && zip -X -9 '$(@F)-$(CCTOOLSVER).zip' '$(@F)'
endif

$(DD)install_name_tool : $(INSTALL_NAME_TOOL_OBJS)
	$(CC) -o $@ $(LDOPTS) $^
ifneq ($(DEBUG),0)
	dsymutil $@
else
	strip $@
	cd '$(@D)' && zip -X -9 '$(@F)-$(CCTOOLSVER).zip' '$(@F)'
endif

$(DD)nm : $(NM_OBJS)
	$(CC) -o $@ $(LDOPTS) $^
ifneq ($(DEBUG),0)
	dsymutil $@
else
	strip $@
	cd '$(@D)' && zip -X -9 '$(@F)-$(CCTOOLSVER).zip' '$(@F)'
endif

clean :
	rm -rf build
