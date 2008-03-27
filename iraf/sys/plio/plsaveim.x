# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<syserr.h>
include	<imhdr.h>
include	<imset.h>
include	<mach.h>
include	<plset.h>
include	<plio.h>

# PL_SAVEIM -- Save a mask in a conventional image, i.e., convert a mask to
# an image.

procedure pl_saveim (pl, imname, title, flags)

pointer	pl			#I mask descriptor
char	imname[ARB]		#I image name or section
char	title[ARB]		#I mask "title" string
int	flags			#I bitflags

size_t	sz_val
long	lval
bool	sampling
pointer	im, px, im_pl, bp
size_t	npix
int	naxes, depth, maxdim, mode, i
pointer	locstr, locmem, p_0
long	v_in[PL_MAXDIM], v_out[PL_MAXDIM], vn[PL_MAXDIM]
long	vs_l[PL_MAXDIM], vs_p[PL_MAXDIM]
long	ve_l[PL_MAXDIM], ve_p[PL_MAXDIM]

pointer	immap(), imstatp()
long	clktime(), impnli()
int	imaccess(), strlen()
errchk	immap, syserrs, impnli

begin
	p_0 = 0

	# Open the new output image.
	mode = NEW_IMAGE
	if (and (flags, PL_UPDATE) != 0)
	    if (imaccess (imname, 0) == YES)
		mode = READ_WRITE

	im = immap (imname, mode, p_0)

	# Reload the image header from the "title" string, if any.
	if (strlen(title) > 0) {
	    call zlocva (title, locstr)
	    call zlocva (Memc, locmem)
	    bp = locstr - locmem + 1
	    call im_pmldhdr (im, bp)
	}

	# Initialize a new image to the size of the mask.  If updating an
	# existing image the sizes must match.

	call pl_gsize (pl, naxes, vn, depth)
	maxdim = min (IM_MAXDIM, PL_MAXDIM)
	npix = vn[1]

	if (mode == NEW_IMAGE) {
	    IM_NDIM(im) = naxes
	    IM_PIXTYPE(im) = TY_SHORT
	    if (PL_MAXVAL(pl) > MAX_SHORT) {
		IM_PIXTYPE(im) = TY_INT
	    }
	    sz_val = maxdim
	    call amovl (vn, IM_LEN(im,1), sz_val)
	} else {
	    if (naxes != IM_NDIM(im)) {
		call imunmap (im)
		call syserrs (SYS_IMPLSIZE, imname)
	    }
	    do i = 1, naxes
		if (vn[i] != IM_LEN(im,i)) {
		    call imunmap (im)
		    call syserrs (SYS_IMPLSIZE, imname)
		}
	}

	# If the image is already a mask internally, check whether any
	# subsampling, axis flipping, or axis mapping is in effect.
	# If so we can't use PLIO to copy the mask section.

	im_pl = imstatp (im, IM_PLDES)
	sampling = false

	if (im_pl != NULL) {
	    lval = 1
	    sz_val = maxdim
	    call amovkl (lval, vs_l, sz_val)
	    call amovl (IM_LEN(im,1), ve_l, sz_val)
	    call imaplv (im, vs_l, vs_p, maxdim)
	    call imaplv (im, ve_l, ve_p, maxdim)

	    do i = 1, maxdim {
		vn[i] = ve_l[i] - vs_l[i] + 1
		if (vn[i] != ve_p[i] - vs_p[i] + 1) {
		    sampling = true
		    break
		}
	    }
	}

	# If the source image is already a mask internally and no axis
	# geometry is in effect in the image section (if any), then we can
	# use a PLIO rasterop to efficiently copy the mask subsection.

	if (im_pl != NULL && !sampling) {
	    # Copy a mask subsection (or entire image if no section).
	    call pl_rop (pl, vs_l, im_pl, vs_p, vn, PIX_SRC)
	    call pl_compress (im_pl)

	} else {
	    # Copy image pixels.  Initialize the vector loop indices.
	    lval = 1
	    sz_val = maxdim
	    call amovkl (lval, v_in, sz_val)
	    call amovkl (lval, v_out, sz_val)

	    # Copy the image.
	    while (impnli (im, px, v_out) != EOF) {
		call pl_glpi (pl, v_in, Memi[px], 0, npix, PIX_SRC)
		sz_val = maxdim
		call amovl (v_out, v_in, sz_val)
	    }
	}

	IM_MIN(im) = 0
	IM_MAX(im) = PL_MAXVAL(pl)
	lval = 0
	IM_LIMTIME(im) = clktime(lval)

	call imunmap (im)
end
