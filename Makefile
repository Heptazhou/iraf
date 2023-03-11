#
#  Makefile for the IRAF source tree.
#
# ---------------------------------------------------------------------------

# Compiler Flags.

RELEASE		= v2.17
export CFLAGS	= -g -Wall -O2 $(CARCH)
export LDFLAGS	= $(CARCH)
export iraf	= $(shell pwd)/
export IRAFARCH	?= $(shell unix/hlib/irafarch.sh -current)


all:: sysgen

# Do a full sysgen.
sysgen: bin
	@echo "Building the IRAF $(RELEASE) ${IRAFARCH} software tree"
	@echo "" ; date ; echo ""
	util/mksysgen
	@echo "" ; date ; echo ""

# Clean the IRAF tree of all binaries.
src pristine::
	util/mksrc

# Clean the IRAF tree of binaries for the currently configured arch.
clean::
	util/mkclean

# Make only the NOAO package.
noao::
	cd noao ; mkpkg -p noao


# ----------------------------------------------------------------------
# architectures
# ----------------------------------------------------------------------
showarch::
	mkpkg arch

bin: ${IRAFARCH}

macosx macintel macos64 linux linux64 freebsd freebsd64 hurd generic::
	util/mkarch $@
