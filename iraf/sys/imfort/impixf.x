# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<imhdr.h>
include	"imfort.h"

# IMPIXF -- Called on an open image to return the BFIO file descriptor of the
# pixel file, and all important physical parameters describing where and how
# the pixels are stored.  This information may be used to directly access the
# pixel file, in particularly demanding applications.  Both the BFIO descriptor
# and the (host) pixel file name are returned, with the expectation that the
# caller will either use BFIO to directly access the pixel file, or call BFCLOS
# to close the file, and reopen it under some other i/o package.
#
# NOTE - Use of this interface implies explicit knowledge of the physical
# storage schema, hence programs which use this information may cease to work
# in the future if the image storage format changes, e.g., if an IMFORT
# interface is implemented for some storage format other than OIF.

procedure impixf (im, pixfp, pixfil, pixoff, szline, ier)

pointer	im			# image descriptor
size_t	sz_val
pointer	pixfp			# receives file pointer of pixel file
%	character*(*) pixfil
int	pixoff			# one-indexed char offset to the pixels
int	szline			# nchars used to store each image line
int	ier

pointer	sp, osfn, ip
int	stridxs()
bool	strne()

begin
	call smark (sp)
	sz_val = SZ_PATHNAME
	call salloc (osfn, sz_val, TY_CHAR)

	if (strne (IM_MAGIC(im), "imhdr"))
	    ier = IE_MAGIC
	else {
	    call imf_gpixfname (IM_PIXFILE(im), IM_HDRFILE(im), Memc[osfn],
		SZ_PATHNAME)
	    ip = osfn + stridxs ("!", Memc[osfn])
	    call f77pak (Memc[ip], pixfil, len(pixfil))

	    pixfp  = IM_PIXFP(im)
	    pixoff = IM_PIXOFF(im)
	    szline = IM_LINESIZE(im)
	    ier = OK
	}

	call sfree (sp)
end
