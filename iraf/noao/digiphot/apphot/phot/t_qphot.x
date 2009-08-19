include <fset.h>
include <gset.h>
include <lexnum.h>
include <imhdr.h>
include "../lib/apphot.h"
include "../lib/fitsky.h"

# T_QPHOT -- Procedure to measure magnitudes inside a set of apertures for a
# list of stars in a list of images.

procedure t_qphot ()

pointer	image			# pointer name of the image
pointer	output			# pointer output file name
pointer	coords			# pointer to the coordinate file
pointer	plotfile		# file of plot metacode
pointer	graphics		# graphics display device
pointer	display			# display device
int	cache			# cache input image pixels in memory
int	verbose			# verbose mode	

size_t	sz_val
pointer	sp, outfname, cname, ap, im, gd, mgd, id, str, olist, clist, imlist
int	limlist, lclist, lolist, cl, out, root, stat, pfd, interactive
int	memstat, wcs
long	sid, lid
size_t	req_size, old_size, buf_size
long	l_val

pointer	immap(), gopen(), clpopnu(), imtopenp()
int	imtlen(), imtgetim(), clplen(), clgfil(), btoi(), strncmp(), strlen()
int	fnldir(), apqphot(), open(), clgwrd(), ap_memstat(), sizeof()
bool	clgetb(), streq()
errchk	gopen

include	<nullptr.inc>

begin
	# Allocate temporary space.
	call smark (sp)
	sz_val = SZ_FNAME
	call salloc (image, sz_val, TY_CHAR)
	call salloc (coords, sz_val, TY_CHAR)
	call salloc (output, sz_val, TY_CHAR)
	call salloc (plotfile, sz_val, TY_CHAR)
	call salloc (graphics, sz_val, TY_CHAR)
	call salloc (display, sz_val, TY_CHAR)
	call salloc (outfname, sz_val, TY_CHAR)
	call salloc (cname, sz_val, TY_CHAR)
	call salloc (str, sz_val, TY_CHAR)

	# Set the standard output to flush on newline.
	call fseti (STDOUT, F_FLUSHNL, YES)

	# Get the task parameters.
	imlist = imtopenp ("image")
	limlist = imtlen (imlist)
	clist = clpopnu ("coords")
	lclist = clplen (clist)
	olist = clpopnu ("output")
	lolist = clplen (olist)

	# Check that image and coordinate list lengths match.
	if (limlist < 1 || (lclist > 1 && lclist != limlist)) {
	    call imtclose (imlist)
	    call clpcls (clist)
	    call clpcls (olist)
	    call error (0, "Imcompatible image and coordinate list lengths")
	}

	# Check that image and output list lengths match.
	if (lolist > 1 && lolist != limlist) {
	    call imtclose (imlist)
	    call clpcls (olist)
	    call error (0, "Imcompatible image and output list lengths")
	}

	# Intialize the phot structure.
	call clgstr ("icommands.p_filename", Memc[cname], SZ_FNAME)
	if (Memc[cname] != EOS)
	    interactive = NO
	#else if (lclist == 0)
	    #interactive = YES
	else
	    interactive = btoi (clgetb ("interactive"))
	cache = btoi (clgetb ("cache"))
	verbose = btoi (clgetb ("verbose"))

	# Get the parameters.
	call ap_gqppars (ap)

        # Get the wcs information.
        wcs = clgwrd ("wcsin", Memc[str], SZ_LINE, WCSINSTR)
        if (wcs <= 0) {
            call eprintf (
                "Warning: Setting the input coordinate system to logical\n")
            wcs = WCS_LOGICAL
        }
        call apseti (ap, WCSIN, wcs)
        wcs = clgwrd ("wcsout", Memc[str], SZ_LINE, WCSOUTSTR)
        if (wcs <= 0) {
            call eprintf (
                "Warning: Setting the output coordinate system to logical\n")
            wcs = WCS_LOGICAL
        }
        call apseti (ap, WCSOUT, wcs)

	# Get the graphics and display devices.
	call clgstr ("graphics", Memc[graphics], SZ_FNAME)
	call clgstr ("display", Memc[display], SZ_FNAME)

	# Open the plot files.
	if (interactive == YES) {
	    if (Memc[graphics] == EOS)
		gd = NULL
	    else {
		iferr {
		    gd = gopen (Memc[graphics], APPEND+AW_DEFER, STDGRAPH)
		} then {
		    call eprintf (
		        "Warning: Error opening graphics device.\n")
		    gd = NULL
		}
	    }
	    if (Memc[display] == EOS)
		id = NULL
	    else if (streq (Memc[graphics], Memc[display]))
		id = gd
	    else {
		iferr {
		    id = gopen (Memc[display], APPEND, STDIMAGE)
		} then {
		    call eprintf (
		"Warning: Graphics overlay not available for display device.\n")
		    id = NULL
		}
	    }
	} else {
	    gd = NULL
	    id = NULL
	}

	# Open the plot metacode file.
	call clgstr ("plotfile", Memc[plotfile], SZ_FNAME)
	if (Memc[plotfile] == EOS)
	    pfd = NULL
	else
	    pfd = open (Memc[plotfile], APPEND, BINARY_FILE)
	if (pfd != NULL)
	    mgd = gopen (Memc[graphics], NEW_FILE, pfd)
	else
	    mgd = NULL

	# Begin looping over the image list.
	sid = 1
	while (imtgetim (imlist, Memc[image], SZ_FNAME) != EOF) {

	    # Open the image and store image parameters.
	    im = immap (Memc[image], READ_ONLY, NULLPTR)
	    call apimkeys (ap, im, Memc[image])

	    # Set the image display viewport.
	    if ((id != NULL) && (id != gd))
		call ap_gswv (id, Memc[image], im, 4)

	    # Cache the input image pixels.
            req_size = MEMFUDGE * IM_LEN(im,1) * IM_LEN(im,2) *
                sizeof (IM_PIXTYPE(im))
            memstat = ap_memstat (cache, req_size, old_size)
            if (memstat == YES) {
		l_val = INDEFL
                call ap_pcache (im, l_val, buf_size)
	    }

	    # Open the coordinate file, where coords is assumed to be a simple
	    # text file in which the x and y positions are in columns 1 and 2
	    # respectively and all remaining fields are ignored.

	    if (lclist <= 0) {
		cl = NULL
		call strcpy ("", Memc[outfname], SZ_FNAME)
	    } else {
		stat = clgfil (clist, Memc[coords], SZ_FNAME)
		root = fnldir (Memc[coords], Memc[outfname], SZ_FNAME)
		if (strncmp ("default", Memc[coords+root], 7) == 0 || root ==
		    strlen (Memc[coords])) {
		    call ap_inname (Memc[image], Memc[outfname], "coo",
		        Memc[outfname], SZ_FNAME)
		    lclist = limlist
	            cl = open (Memc[outfname], READ_ONLY, TEXT_FILE)
		} else if (stat != EOF) {
		    call strcpy (Memc[coords], Memc[outfname], SZ_FNAME)
	            cl = open (Memc[outfname], READ_ONLY, TEXT_FILE)
		} else {
		    call apstats (ap, CLNAME, Memc[outfname], SZ_FNAME)
		    l_val = BOF
		    call seek (cl, l_val)
		}
	    }
	    call apsets (ap, CLNAME, Memc[outfname])
	    call apfroot (Memc[outfname], Memc[str], SZ_FNAME)
	    call apsets (ap, CLROOT, Memc[str])

	    # Open the output text file, if output is "default", dir$default or
	    # a directory specification then the extension "mag" is added to the
	    # image name and a suitable version number is appended to the output
	    # name. If output is the null string then no output file is created.

	    if (lolist == 0) {
		out = NULL
		call strcpy ("", Memc[outfname], SZ_FNAME)
	    } else {
	        stat = clgfil (olist, Memc[output], SZ_FNAME)
		root = fnldir (Memc[output], Memc[outfname], SZ_FNAME)
		if (strncmp ("default", Memc[output+root], 7) == 0 || root ==
		    strlen (Memc[output])) {
		    call apoutname (Memc[image], Memc[outfname], "mag",
		        Memc[outfname], SZ_FNAME)
		    out = open (Memc[outfname], NEW_FILE, TEXT_FILE)
		    lolist = limlist
		} else if (stat != EOF) {
		    call strcpy (Memc[output], Memc[outfname], SZ_FNAME)
		    out = open (Memc[outfname], NEW_FILE, TEXT_FILE)
		} else
		    call apstats (ap, OUTNAME, Memc[outfname], SZ_FNAME)
	    }
	    call apsets (ap, OUTNAME, Memc[outfname])

	    # Do aperture photometry.
	    if (interactive == NO) {
	        if (Memc[cname] != EOS)
		    stat = apqphot (ap, im, cl, NULLPTR, mgd, NULLPTR, out, sid, NO,
			cache)
	        else if (cl != NULL) {
		    lid = 1
	            call apbphot (ap, im, cl, NULL, out, sid, lid, gd, mgd, id,
		        verbose)
		    stat = NO
		} else
		    stat = NO
	    } else
		stat = apqphot (ap, im, cl, gd, mgd, id, out, sid, YES, cache)

	    # Cleanup.
	    call imunmap (im)
	    if (cl != NULL) {
		if (lclist > 1)
		    call close (cl)
	    }
	    if (out != NULL && lolist != 1) {
		call close (out)
		if (sid <= 1) {
		    call apstats (ap, OUTNAME, Memc[outfname], SZ_FNAME)
		    call delete (Memc[outfname])
		}
		sid = 1
	    }

	    # Uncache memory.
	    call fixmem (old_size)

	    if (stat == YES)
		break
	}


	# Close the coordinate, sky and output files.
	if (cl != NULL && lclist == 1)
	    call close (cl)
	if (out != NULL && lolist == 1) {
	    call close (out)
	    if (sid <= 1) {
		call apstats (ap, OUTNAME, Memc[outfname], SZ_FNAME)
		call delete (Memc[outfname])
	    }
	}

	# Close up the plot files.
	if (id == gd && id != NULL)
	    call gclose (id)
	else {
	    if (gd != NULL)
	        call gclose (gd)
	    if (id != NULL)
	        call gclose (id)
	}
	if (mgd != NULL)
	    call gclose (mgd)
	if (pfd != NULL)
	    call close (pfd)

	# Free the apphot data structure.
	call appfree (ap)

	# Close the coord, sky and image lists.
	call imtclose (imlist)
	call clpcls (clist)
	call clpcls (olist)

	# Free working space.
	call sfree (sp)
end
