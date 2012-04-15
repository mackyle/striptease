# Makefile for striptease project
# Copyright (C) 2011 Kyle J. McKay.  All rights reserved.
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

.PHONY : all clean

ifeq ($(DEBUG),)
  DEBUG := 0
endif

export DEBUG

CC = gcc-4.0
CINC = -Iinclude
XSDK := $(shell xcode-select -print-path 2>/dev/null)/SDKs
ifeq ($(XSDK),/SDKs)
XSDK := /Developer/SDKs
endif

OSXNUVER := $(shell uname -r | cut -d. -f1)

ifeq ($(DEBUG),0)
  $(shell mkdir -p build/Release/libstuff)
  DD=build/Release/
  COPTS=-Os
else
  $(shell mkdir -p build/Debug/libstuff)
  DD=build/Debug/
  COPTS=-O0 -g
  LDEXTRA=-g
endif

COPTS += -mmacosx-version-min=10.4
ifeq ($(OSXNUVER),8)
COPTS += -isysroot$(XSDK)/MacOSX10.4u.sdk
else
COPTS += -isysroot$(XSDK)/MacOSX10.5.sdk
endif
COPTS += -include preinc.h
ifneq ($(OSXNUVER),8)
COPTS += -arch x86_64
endif
COPTS += -arch i386 -arch ppc

LDOPTS = -Wl,-no_uuid
LDOPTS += -mmacosx-version-min=10.4
ifneq ($(OSXNUVER),8)
LDOPTS += -Xarch_x86_64 -mmacosx-version-min=10.5
endif
# The 10.4u SDK can be used, but do not require it except on 10.4.x
ifeq ($(OSXNUVER),8)
LDOPTS += -isysroot$(XSDK)/MacOSX10.4u.sdk
else
LDOPTS += -isysroot$(XSDK)/MacOSX10.5.sdk
endif
ifneq ($(OSXNUVER),8)
LDOPTS += -arch x86_64
endif
LDOPTS += -arch i386 -arch ppc
LDOPTS += $(LDEXTRA)

all : $(DD)tease

.PHONY : tease strip

tease : $(DD)tease

strip : $(DD)strip

LIBSTUFF_SRC := $(wildcard libstuff/*.c)

TEASE_SRC = \
	tease.c \
	version.c \
	$(LIBSTUFF_SRC)

STRIP_SRC = \
	strip.c \
	version.c \
	$(LIBSTUFF_SRC)

TEASE_OBJS = $(addprefix $(DD),$(TEASE_SRC:.c=.o))

STRIP_OBJS = $(addprefix $(DD),$(STRIP_SRC:.c=.o))

$(DD)%.o : %.c
	$(CC) -Wall -c $(COPTS) $(CINC) -o $@ $<

$(DD)tease : $(TEASE_OBJS)
	$(CC) -o $@ $(LDOPTS) $^
ifneq ($(DEBUG),0)
	dsymutil $@
endif

$(DD)strip : $(STRIP_OBJS)
	$(CC) -o $@ $(LDOPTS) $^
ifneq ($(DEBUG),0)
	dsymutil $@
endif

clean :
	rm -rf build
