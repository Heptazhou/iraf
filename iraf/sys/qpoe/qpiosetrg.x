# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	"qpio.h"

# QPIO_SETRANGE -- Set the range in X and Y within which events will be
# extracted by qpio_getevents.  This defines the "bounding box" for i/o
# and "rewinds" the getevent i/o pointer.

procedure qpio_setrange (io, vs, ve, ndim)

pointer	io			#I QPIO descriptor
long	vs[ARB]			#I start vector (lower left corner)
long	ve[ARB]			#I end vector (upper right corner)
int	ndim			#I vector length (ndim=2 at present)

size_t	sz_val
int	i
long	vlim[NDIM]

begin
	vlim[1] = IO_NCOLS(io)
	vlim[2] = IO_NLINES(io)

	if (ndim <= 0) {
	    sz_val = NDIM
	    call amovl (IO_VSDEF(io,1), IO_VS(io,1), sz_val)
	    call amovl (IO_VEDEF(io,1), IO_VE(io,1), sz_val)
	} else {
	    do i = 1, ndim {
		IO_VS(io,i) = max(1, min(vlim[i], vs[i]))
		IO_VE(io,i) = max(1, min(vlim[i], ve[i]))
	    }
	}

	IO_ACTIVE(io) = NO
end
