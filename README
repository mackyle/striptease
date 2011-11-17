striptease (or "tease" for short) is an enhanced version of strip.  It's
capable of stripping a binary's symbol table of non-text local symbols.
This mode, enabled with the -t switch, is similar to "strip -s", except
-s strips all local symbols including text symbols.  tease -t allows for
useful CrashReporter stacks to be generated on the deployment host.  This
is important in light of the hidden-visibility default (-fvisibility=hidden)
that results in many symbols not being marked as global and therefore being
stripped by an ordinary strip -s.

tease also includes a -no_code_signature option, which strips any
LC_CODE_SIGNATURE load commands from the target file, in much the same way
as the ordinary strip's -no_uuid option.

Finally, tease includes an -a option, which instructs it to regenerate the
symbol table without stripping anything.  tease -a is intended to be used
in conjunction with -no_code_signature (or -no_uuid), to pass over the file
and only strip the relevant Mach-O load commands without removing anything
from the symbol table.

striptease is based on strip.c and other supporting files in Apple's
cctools package.  This version of striptease is based on cctools-809,
corresponding to Xcode Tools 4.2 and Mac OS X 10.7.  It builds properly
under Xcode Tools 2.x on Mac OS X 10.4, as well.  The cctools package is
available from:

http://opensource.apple.com/tarballs/cctools/cctools-809.tar.gz

cctools, and therefore strip, are available under the APSL license:

http://www.opensource.apple.com/apsl/

All files from cctools necessary to build strip are included, unmodified.
This includes strip.c.  Changes to strip.c are made in tease.c.  Many other
files from the cctools package not relevant to strip (or tease) are omitted
from this distribution.  This README and an accompanying Makefile for
build system integration are also included.

Use "make" to build a build/Release/tease executable.

Use "make DEBUG=1" to build a build/Debug/tease debug executable.

Use "make clean" to remove the build directory and built executables.

Note that when building on 10.6 or 10.7, the MacOSX10.5.sdk must be present.
Also note that compile warnings (and link warnings when building on 10.4)
should be ignored -- the cctools-809 sources have some issues.
