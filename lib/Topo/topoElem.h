/* topoElem.h */

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
#include "topoZakres.h"

#if !defined (H_TOPO_ELEM)
#define H_TOPO_ELEM

#define TOPO_ELEM_ID_None       -1
#define TOPO_ELEM_ID_Obszar     0
#define TOPO_ELEM_ID_Tekst      1
#define TOPO_ELEM_ID_Symbol     2
#define TOPO_ELEM_ID_Linia      3
#define TOPO_ELEM_STRING_None   "none"
#define TOPO_ELEM_STRING_Obszar "obszar"
#define TOPO_ELEM_STRING_Tekst  "tekst"
#define TOPO_ELEM_STRING_Symbol "symbol"
#define TOPO_ELEM_STRING_Linia  "linia"

typedef struct topoElem* LpTopoElem;
typedef struct topoLayer;

/* topoLpElems - */
typedef struct topoLpElems
{
	LpTopoElem* aElems;	//tablica wskaŸników do elementów
	int nElems;			//liczba elementów w tablicy
	
} TopoLpElems, *LpTopoLpElems;

/* Interfejs dla topoLpElems */
int topoLpElems_inicjuj (LpTopoLpElems lpElemsP);
int topoLpElems_zwolnij (LpTopoLpElems lpElemsP);
int topoLpElems_nElems (LpTopoLpElems lpElemsP, int* nElems);
int topoLpElems_aElems (LpTopoLpElems lpElemsP, LpTopoElem* aElems);
int topoLpElems_dodaj (LpTopoLpElems lpElemsP, LpTopoElem elemP);

/* =============================================== */

/* topoElem - element topo tj. dzia³ka, budynek, adres, numer dzia³ki, numer budynku */
typedef struct topoElem
{
	ULong offset;
	
	NumerPlikuDgn filenum;
	
	ULong id;
	ULong mslink;
	
	int bPunkt;			/* je¿eli element jest polygonem, czy jego œrodek ciê¿koœci jest w jego wnêtrzu */
	DPoint3d punkt;		/* œrodek */
	char* aTekst;		/* pamiêæ do zwolnienia */
	
	DPoint3d* aPunkty;	/* pamiêæ do zwolnienia */
	int nPunkty;
	
	TopoZakres* zakres;	/* zakres elementu (niektóre elementy nie maj¹ zakresu tj. numer budynku, numer dzia³ki, adres */
	
	double fPole;
	double fObwod;
	
	struct topoElem* podElemP;
	struct topoElem* nadElemP;
	
	int nNadElem;
	int nPodElem;
	
	TopoLpElems nadElems;		//nadrzêdne elementy
	TopoLpElems podElems;		//podrzêdne elementy
	
	struct topoLayer* defP;	//klasa obiektu
	
} TopoElem, *LpTopoElem;

/* Interfejs dla topoElem */
int topoElem_inicjuj (TopoElem* elemP);
int topoElem_zwolnij (TopoElem* elemP);
int topoElem_ustawTekst (TopoElem* elemP, char* tekst);
int topoElem_pobierzTekst (TopoElem* elemP, char* tekst);
int topoElem_ustawZakresXY (TopoElem* elemP, double xMin, double yMin, double xMax, double yMax);
int topoElem_ustawZakres (TopoElem* elemP, TopoZakres* zakresP);
int topoElem_ustawPunkty (TopoElem* elemP, DPoint3d* aPunkty, int nPunkty);
int topoElem_ustawPunktXY (TopoElem* elemP, double x, double y);
int topoElem_ustawPunkt (TopoElem* elemP, DPoint3d* aPunkt, double tolZakres);
int topoElem_ustawNadElem (TopoElem* elemP, TopoElem* nadP);
int topoElem_ustawPodElem (TopoElem* elemP, TopoElem* podP);
int topoElem_porownajXY (TopoElem* e1, TopoElem* e2);
int topoElem_zawieraPunkt (TopoElem* elemP, TopoElem* punktP);
int topoElem_dodajNadElem (TopoElem* elemP, TopoElem* nadElemP);
int topoElem_dodajPodElem (TopoElem* elemP, TopoElem* podElemP);

/* =========================================================================*/

#endif