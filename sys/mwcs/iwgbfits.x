# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	"imwcs.h"

# IW_GBIGFITS -- Get a FITS string valued parameter of arbitrary size.
# Since a FITS string stored as a single parameter is limited to at most
# 69 characters, multiple FITS cards must be used to store longer strings.
# At the time that this routine is called, IW_RFITS has already been called
# to scan the FITS header and build up a list of WCS oriented cards,
# including card types and pointers to the card data.  Our job is merely
# to take these cards in order and concatenate the string values into one
# large string, returning a pointer to the string as the function value.
# The caller must later make a MFREE call to free this buffer.

pointer procedure iw_gbigfits (iw, ctype, axis)

pointer	iw			#I pointer to IMWCS descriptor
int	ctype			#I card type
int	axis			#I axis to which card refers

int	ncards, i, j
pointer	cp, bp, op, rp

begin
	# How much space do we need?
	ncards = 0
	do i = 1, IW_NCARDS(iw) {
	    cp = IW_CARD(iw,i)
	    if (C_AXIS(cp) == axis && C_TYPE(cp) == ctype)
		ncards = ncards + 1
	}

	# Allocate the space.
	call malloc (bp, ncards * MAX_FITSCOLS, TY_CHAR)

	# For successive cards 1, 2, 3, etc...
	op = bp
	do j = 1, ncards {
	    # Find the card.
	    rp = NULL
	    do i = 1, IW_NCARDS(iw) {
		cp = IW_CARD(iw,i)
		if (C_AXIS(cp) != axis)
		    next
		if (C_INDEX(cp) != j)
		    next
		if (C_TYPE(cp) != ctype)
		    next

		rp = C_RP(cp)
		break
	    }

	    # Append to the string buffer.
	    if (rp != NULL) {
		call amovc (Memc[rp+IDB_STARTVALUE+1], Memc[op], MAX_FITSCOLS)
		op = op + MAX_FITSCOLS
	    }
	}

	Memc[op] = EOS
	return (bp)
end
