# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<gset.h>
include	<mach.h>
include	<imhdr.h>

# T_PROW -- Plot an image row.

procedure t_prow ()

pointer	image
pointer	im, sp, x_vec, y_vec
int	row, ncols, nlines
real	zmin, zmax
int	clgeti()
pointer	immap()

begin
	call smark (sp)
	call salloc (image, SZ_FNAME, TY_CHAR)

	# Open image and graphics stream.
	call clgstr ("image", Memc[image], SZ_FNAME)

	im = immap (Memc[image], READ_ONLY, 0)
	ncols  = IM_LEN(im,1)
	nlines = IM_LEN(im,2)

	call clputi ("row.p_maximum", nlines)
	row = clgeti ("row")
	if (row < 1 || row > nlines) {
	    call imunmap (im)
	    call error (2, "line index references outside image")
	}

	# Get the requested row from the image.
	call malloc (x_vec, ncols, TY_REAL)
	call malloc (y_vec, ncols, TY_REAL)
	call plt_grows (im, row, row, Memr[x_vec], Memr[y_vec], zmin, zmax)

	# Now draw the vector to the screen.
	call pr_draw_vector (Memc[image], Memr[x_vec], Memr[y_vec], ncols,
	    zmin, zmax, row, row, false)
       
        # Free resources.
	call mfree (x_vec, TY_REAL)
	call mfree (y_vec, TY_REAL)

	call imunmap (im)
	call sfree (sp)
end
