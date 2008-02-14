# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<syserr.h>
include	<imhdr.h>
include	"idb.h"

# IMDELF -- Delete a user field from the image header.  It is an error if the
# named field does not exist.

procedure imdelf (im, key)

pointer	im			# image descriptor
char	key[ARB]		# name of the new parameter

size_t	sz_val
int	off
pointer	rp, sp, keyname
int	idb_kwlookup(), idb_findrecord(), stridxs()
errchk	syserrs

begin
	call smark (sp)
	sz_val = SZ_FNAME
	call salloc (keyname, sz_val, TY_CHAR)

	# FITS format requires that the keyword name be upper case.
	call strcpy (key, Memc[keyname], SZ_FNAME)
	call strupr (Memc[keyname])

	# Cannot delete standard header keywords.
	if (idb_kwlookup (key) > 0)
	    call syserrs (SYS_IDBNODEL, key)

	# Verify that the named user field exists.
	if (idb_findrecord (im, key, rp) <= 0)
	    call syserrs (SYS_IDBDELNXKW, key)
	
	# Delete the field.
	off = stridxs ("\n", Memc[rp])
	if (off > 0)
	    call strcpy (Memc[rp+off], Memc[rp], ARB)
	else
	    Memc[rp] = EOS

	call sfree (sp)
end
