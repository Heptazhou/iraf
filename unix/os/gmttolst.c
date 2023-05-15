/* Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.
 */

#include <sys/types.h>
#include <time.h>

#define	SECONDS_1970_TO_1980	315532800L
static	long get_timezone();

/* GMT_TO_LST -- Convert gmt to local standard time, epoch 1980.
 */
time_t
gmt_to_lst (time_t gmt)
{
	time_t	time_var;
#ifndef MACOSX
	long gmtl = (long)gmt;          /* correct for DST, if in effect */
#endif
	
	/* Subtract seconds westward from GMT */
	time_var = gmt - get_timezone();

#ifndef MACOSX
	/* Mac systems already include the DST offset in the GMT offset */
	if (localtime(&gmtl)->tm_isdst)
	    time_var += 60L * 60L;
#endif

	return (time_var - SECONDS_1970_TO_1980);
}


/* _TIMEZONE -- Get the local timezone, measured in seconds westward
 * from Greenwich, ignoring daylight savings time if in effect.
 */
static long
get_timezone(void)
{
#ifdef CYGWIN
	extern	long _timezone;
	tzset();
	return (_timezone);
#else
#ifdef SYSV
	extern	long timezone;
	tzset();
	return (timezone);
#else
#ifdef MACOSX
	struct tm *tm;
	time_t clock = time(NULL);
	tm = localtime (&clock);
	return (-(tm->tm_gmtoff));
#else
	struct timeb time_info;
	ftime (&time_info);
	return (time_info.timezone * 60);
#endif
#endif
#endif
}
