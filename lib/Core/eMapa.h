/* eMapa.h */

#include <string.h>
#include <msdb.fdf>
#include <rdbmslib.fdf>
#include <dlogman.fdf>
#include <mselmdsc.fdf>
#include <msrmatrx.fdf>
#include <mdllib.fdf>
#include <mscell.fdf>
#include <mdl.h>
#include <mselems.h>
#include <userfnc.h>
#include <cmdlist.h>
#include <string.h>
#include <mslinkge.fdf>
#include <msoutput.fdf>
#include <msparse.fdf>
#include <msrsrc.fdf>
#include <mslocate.fdf>
#include <msstate.fdf>
#include <msdefs.h>
#include <msfile.fdf>
#include <dlogitem.h>
#include <cexpr.h>
#include <msmisc.fdf>
#include <mssystem.fdf>
#include <msscan.fdf>
#include <mswindow.fdf>
#include <msdialog.fdf>
#include <mselemen.fdf>
#include <msstring.fdf>
#include <ctype.h>
#include <msview.fdf>
//#include <mswchar.fdf>
#include <msscell.fdf>
#include <mstmatrx.fdf>
#include <msvec.fdf>

#include "..\Aplikacja\def-v8.h"

#if !defined (H_E_MAPA)
#define H_E_MAPA

/* informacja o typie obiektu */

void str_charToInt (char* kod, int* kodInt);
int mdlElem_equKod (MSElement* element, char* kod, char* nazwa);
int mdlElem_equDTM (MSElement* element, int* dtm);

#endif
