# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<imhdr.h>
include	<imio.h>

# IMPL1? -- Put a line to an apparently one dimensional image.  If there
# is only one input buffer, no image section, we are not referencing out of
# bounds, and no datatype conversion needs to be performed, directly access
# the pixels to reduce the overhead per line.

pointer procedure impl1s (im)

pointer	im			# image header pointer

int	fd
size_t	nchars
long	offset, lval
pointer	bp, impgss(), fwritep()
errchk	imopsf

begin
	repeat {
	    if (IM_FAST(im) == YES && IM_PIXTYPE(im) == TY_SHORT) {
		fd = IM_PFD(im)
		if (fd == NULL) {
		    call imopsf (im)
		    next
		}
		offset = IM_PIXOFF(im)
		nchars = IM_PHYSLEN(im,1) * SZ_SHORT
		ifnoerr (bp = (fwritep (fd, offset, nchars) - 1) / SZ_SHORT + 1)
		    return (bp)
	    }
	    lval = 1
	    return (impgss (im, lval, IM_LEN(im,1), 1))
	}
end
