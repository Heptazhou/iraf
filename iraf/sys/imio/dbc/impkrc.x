# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<mach.h>

# IMPKRC -- Put an image header parameter of type real.

procedure impkrc (im, key, rval, comment)

pointer	im			# image descriptor
char	key[ARB]		# parameter to be set
real	rval			# parameter value
char	comment[ARB]		# 
size_t	sz_val
pointer	sp, sval

begin
	call smark (sp)
	sz_val = SZ_FNAME
	call salloc (sval, sz_val, TY_CHAR)

	call sprintf (Memc[sval], SZ_FNAME, "%0.*g")
	    call pargi (NDIGITS_RP)
	    call pargr (rval)
	call impstrc (im, key, Memc[sval], comment)

	call sfree (sp)
end
