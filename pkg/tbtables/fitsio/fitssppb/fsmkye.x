include "fitsio.h"

procedure fsmkye(ounit,keywrd,rval,decim,comm,status)

# modify a real*4 value header record in E format

int     ounit           # i output file pointer
char    keywrd[SZ_FKEYWORD]     # i keyword name
%       character fkeywr*8
real    rval            # i real*4 value
int     decim           # i number of decimal plac
char    comm[SZ_FCOMMENT]       # i keyword comment
%       character fcomm*48
int     status          # o error status

begin

call f77pak(keywrd,fkeywr,SZ_FKEYWORD)
call f77pak(comm  ,fcomm ,SZ_FCOMMENT)

call ftmkye(ounit,fkeywr,rval,decim,fcomm,status)
end
