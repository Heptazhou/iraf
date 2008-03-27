# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<plio.h>

# PL_GETPLANE -- Get the 2-Dim plane to be referenced in calls to the pl_box,
# pl_circle, etc. geometric region masking operators.

procedure pl_getplane (pl, v)

pointer	pl			#I mask descriptor
long	v[ARB]			#O vector defining plane

size_t	sz_val

begin
	sz_val = PL_MAXDIM
	call amovl (PL_PLANE(pl,1), v, sz_val)
end
