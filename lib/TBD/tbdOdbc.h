/* tbdOdbc.h */

#include <mdl.h>
#include <mselems.h>
#include <userfnc.h>
#include <cmdlist.h>
#include <string.h>
#include <msdb.fdf>
#include <rdbmslib.fdf>
#include <dlogman.fdf>
#include <mssystem.fdf>
#include <mslinkge.fdf>
#include <msoutput.fdf>
#include <msparse.fdf>
#include <mselemen.fdf>
#include <msrsrc.fdf>
#include <mslocate.fdf>
#include <msstate.fdf>
#include <msdefs.h>
#include <msfile.fdf>
#include <dlogitem.h>
#include <cexpr.h>

#if !defined (H_TBD_ODBC)
#define H_TBD_ODBC

int tbdOdbc_inicjuj ();
int tbdOdbc_zwolnij ();

int tbdOdbc_createSysDSN ();
int tbdOdbc_createUserDSN ();
int tbdOdbc_createFileDSN ();

void tbdOdbc_zachowajZmiennaFILEDSN (char* pValue);
int tbdOdbc_zapiszZmiennaFILEDSN (char* name);
void odbc_restoreCfgVar (char* pVariable);

#endif
