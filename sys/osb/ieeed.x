# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<mach.h>

.help IEEE
.nf ------------------------------------------------------------------------
Low level primitives for IEEE to native floating point datatype conversions.
See also the MII package, which provides a higher level interface, and the
IEEE related definitions in <mach.h>.

	         ieepak[rd] (datum)			# scalar conversions
	         ieeupk[rd] (datum)
		ieevpak[rd] (native, ieee, nelem)	# vector conversions
		ieevupk[rd] (ieee, native, nelem)
	     iee[sg]nan[rd] (NaN)			# NaN handling

The first two routines handle scalar conversions, the second two vectors.
The input and output vectors may be the same.  Unfortunately, for portability
reasons, functions cannot be used, so the scalar operators do an in-place
conversion instead, and are a no-op on an unswapped IEEE system.  The routines
iee[sg]nan[rd] set/get the native floating value used to replace NaNs or
overflows occuring when converting IEEE to the native floating format.

The routines in this file are the "portable" versions.  The "portable"
solution it to merely copy the array, swapping the bytes if necessary - this
works on any host that uses the IEEE floating format.  If the local host does
not use IEEE floating, or if a significant efficiency gain can be realized
by programming in assembler or C, a host specific version of this file should
be written, placed in AS, and referenced in the MKPKG special file list.
Note that NaN replacement on input of IEEE data is not supported by the
portable routines, although the iee[sg]nan[rd] routines are included in the
interface.
.endhelp -------------------------------------------------------------------


# IEEVPAK -- Convert an array in the native floating point format into an
# array in IEEE floating format.  The input and output arrays can be the same.

procedure ieevpakd (native, ieee, nelem)

double	native[ARB]		#I input native floating format array
double	ieee[ARB]		#O output IEEE floating format array
int	nelem			#I number of floating point numbers

begin
	if (IEEE_SWAP8 == YES)
	    call bswap8 (native, 1, ieee, 1, nelem * 8)
	else
	    call amovd (native, ieee, nelem)
end


# IEEVUPK -- Convert an array in IEEE floating format into the native
# floating point format.  The input and output arrays can be the same.

procedure ieevupkd (ieee, native, nelem)

double	ieee[ARB]		#I input IEEE floating format array
double	native[ARB]		#O output native floating format array
int	nelem			#I number of floating point numbers

begin
	if (IEEE_SWAP8 == YES)
	    call bswap8 (ieee, 1, native, 1, nelem * 8)
	else
	    call amovd (ieee, native, nelem)
end


# IEEPAK -- Convert a native floating point number into IEEE format.

procedure ieepakd (x)

double	x			#U datum to be converted

begin
	if (IEEE_SWAP8 == YES)
	    call bswap8 (x, 1, x, 1, 8)
end


# IEEUPK -- Convert an IEEE format number into native floating point.

procedure ieeupkd (x)

double	x			#U datum to be converted

begin
	if (IEEE_SWAP8 == YES)
	    call bswap8 (x, 1, x, 1, 8)
end


# IEESNAN -- Set the native floating point value used to replace NaNs and
# overflows when converting IEEE to native [NOTE: this is merely a placeholder
# in this portable version of the interface].

procedure ieesnand (x)

double	x			#I native value which will replace NaN

double	nan
common	/ieenand/ nan

begin
	nan = x
end


# IEEGNAN -- Get the NaN value.

procedure ieegnand (x)

double	x			#O native value which will replace NaN

double	nan
common	/ieenand/ nan

begin
	x = nan
end
