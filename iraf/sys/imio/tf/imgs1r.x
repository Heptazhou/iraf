# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<imhdr.h>

# IMGS1? -- Get a section from an apparently one dimensional image.

pointer procedure imgs1r (im, x1, x2)

pointer	im
long	x1, x2
pointer	imggsr(), imgl1r()

begin
	if (x1 == 1 && x2 == IM_LEN(im,1))
	    return (imgl1r (im))
	else
	    return (imggsr (im, x1, x2, 1))
end
