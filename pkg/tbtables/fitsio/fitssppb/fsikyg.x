include "fitsio.h"

procedure fsikyg(ounit,keywrd,dval,decim,comm,status)

# insert a double precision value to a header record in F format

int     ounit           # i output file pointer
char    keywrd[SZ_FKEYWORD]     # i keyword name
%       character fkeywr*8
double  dval            # i real*8 value
int     decim           # i number of decimal plac
char    comm[SZ_FCOMMENT]       # i keyword comment
%       character fcomm*48
int     status          # o error status

begin

call f77pak(keywrd,fkeywr,SZ_FKEYWORD)
call f77pak(comm  ,fcomm ,SZ_FCOMMENT)

call ftikyg(ounit,fkeywr,dval,decim,fcomm,status)
end
