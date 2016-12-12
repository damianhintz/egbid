/* tbdObiekt.h */

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
#include <msmisc.fdf>

#if !defined (H_TBD_OBIEKT)
#define H_TBD_OBIEKT

typedef struct tbdObiekt
{
	long nId; 	//identyfikator rekordu
	int bId;  	//czy jest w dgn
} TbdObiekt, *LpTbdObiekt;

int tbdObiekt_porownaj (TbdObiekt* aP, TbdObiekt* bP);

typedef struct tbdObiekty
{
	TbdObiekt* aObiekty;
	long nObiekty;
	long nObiektyDgn;
	
} TbdObiekty, *LpTbdObiekty;

int tbdObiekty_inicjuj (TbdObiekty* obiektyP);
int tbdObiekty_zwolnij (TbdObiekty* obiektyP);
int tbdObiekty_wczytaj (TbdObiekty* obiektyP, char* query, char* queryCount);
int tbdObiekty_szukaj (TbdObiekty* obiektyP, long nId, TbdObiekt** obiektP);

#endif
