/* topoOgrodzenie.h */

#include <msmisc.fdf>
#include <msregion.fdf>
#include <msscan.fdf>
#include <scanner.h>
#include <mselmdsc.fdf>
#include <msview.fdf>
#include <string.h>
#include <msdarray.fdf>
#include <msselect.fdf>
#include <msstring.fdf>
#include <mdllib.fdf>
#include <msvec.fdf>
#include <math.h>
#include <mslocate.fdf>

#include "..\Aplikacja\def-v8.h"
#include "topoLayer.h"

#if !defined (H_TOPO_OGRODZENIE)
#define H_TOPO_OGRODZENIE

/* topoOgrodzenie */
typedef struct topoOgrodzenie
{
	TopoLayers definicje;		/* kolekcja rodzajów elementów */
	
	ULong* aOffsets;			/* tablica po³o¿enia w pliku, do zwolnienia */
	NumerPlikuDgn* aFileNums;		/* tablica numerów plików, do zwolnienia */
	int nSelected;				/* liczba wybranych elementów */
	
} TopoOgrodzenie, *LpTopoOgrodzenie;

/* Interfejs dla topoOgrodzenie */

int topoOgrodzenie_load (LpTopoOgrodzenie ogrodzenieP);
int topoOgrodzenie_loadFunc (LpTopoOgrodzenie ogrodzenieP);
int topoOgrodzenie_inicjuj (LpTopoOgrodzenie ogrodzenieP);
int topoOgrodzenie_zwolnij (LpTopoOgrodzenie ogrodzenieP);
int topoOgrodzenie_ustawElementy (LpTopoOgrodzenie ogrodzenieP, TopoElems* elemsP, int typ);
int topoOgrodzenie_powiazPoligonyDoPoligonow (TopoElems* aParentsP, TopoElems* aChildsP);
int topoOgrodzenie_powiazPunktyDoPoligonow (TopoElems* aParentsP, TopoElems* aChildsP);

/* ========================================================================== */

#endif
