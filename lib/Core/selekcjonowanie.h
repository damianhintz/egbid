/* selekcjonowanie.h */

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
#include <scanner.h>
#include <msscan.fdf>
#include <msselect.fdf>
#include <msview.fdf>
#include <mselmdsc.fdf>

#include "..\Aplikacja\def-v8.h"

#if !defined (H_SELEKCJONOWANIE)
#define H_SELEKCJONOWANIE

/* plikDgnSelekcja - skanowanie pliku dgn */
typedef struct plikDgnSelekcja
{
	int nObiekty;
	int nInneObiekty;
	int bSelekcjonowanie;
	
	int bTeksty;
	int nTeksty;
	void* aTeksty;
	
	int bSymbole;
	int nSymbole;
	void* aSymbole;
	
	int bLinie;
	int bLinie;
	void* aLinie;
	
	int bObszary;
	int nObszary;
	void* aObszary;
	
} PlikDgnSelekcja, *LpPlikDgnSelekcja;

int plikDgnSelekcja_inicjuj (PlikDgnSelekcja* argP);
int plikDgnSelekcja_zwolnij (PlikDgnSelekcja* argP);
int plikDgnSelekcja_wczytaj (PlikDgnSelekcja* argP);
int plikDgnSelekcja_wypisz (PlikDgnSelekcja* argP);

int plikDgn_selekcjonowanie (int (*plikDgn_selekcjaFunc)(MSElementDescr* edP, void* vargP), void* argP);
int plikDgn_selekcjaPolicz (MSElementDescr* edP, void* vargP);

#endif
