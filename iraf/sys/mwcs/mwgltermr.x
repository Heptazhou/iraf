# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<syserr.h>
include	"mwcs.h"

# MW_GLTERMR -- Get the current Lterm, single precision version.

procedure mw_gltermr (mw, ltm, ltv, ndim)

pointer	mw			#I pointer to MWCS descriptor
real	ltm[ndim,ndim]		#O linear transformation matrix
real	ltv[ndim]		#O translation vector
int	ndim			#I dimensionality of system

size_t	sz_val
int	i
errchk	syserrs

begin
	# The dimensionality of the data must match that of the current Lterm.
	if (ndim != MI_NDIM(mw))
	    call syserrs (SYS_MWNDIM, "mw_gltermr")

	# Copy out the data.  Default to a unitary transformation if the
	# Lterm has not been initialized.

	sz_val = ndim*ndim
	if (MI_LTM(mw) == NULL) {
	    call aclrr (ltm, sz_val)
	    do i = 1, ndim
		ltm[i,i] = 1.0
	} else {
	    call achtdr (D(mw,MI_LTM(mw)), ltm, sz_val)
	}

	sz_val = ndim
	if (MI_LTV(mw) == NULL) {
	    call aclrr (ltv, sz_val)
	} else {
	    call achtdr (D(mw,MI_LTV(mw)), ltv, sz_val)
	}
end
