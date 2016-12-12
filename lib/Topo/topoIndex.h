/* topoIndex.h */

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
#include "topoElem.h"

#if !defined (H_TOPO_INDEX)
#define H_TOPO_INDEX

//topoIndex_addFeature
//topoIndex_removeFeature
//topoIndex_queryFeatures (from range, from feature)

typedef struct topoIndexMatrix;

/* topoElems - tablica elementów topo */
typedef struct topoElems
{
	TopoElem* aElems;	/* pamiêæ do zwolnienia */
	int nElems;			/* */
	int nRozmiar;		/* */
	
	TopoZakres* zakres;	/* pamiêæ do zwolnienia */
	
	struct topoIndexMatrix* matrixP; /* pamiêæ do zwolnienia */
	
} TopoElems, *LpTopoElems;

/* Interfejs dla topoElems */
int topoElems_inicjuj (TopoElems* elemsP);
int topoElems_inicjujN (TopoElems* elemsP, int nRozmiar);
int topoElems_zwolnij (TopoElems* elemsP);
int topoElems_sortuj (TopoElems* elemsP, int (*topoElem_cmpFunc)(void *, void *));
int topoElems_sortujXY (TopoElems* elemsP);
int topoElems_wypisz (TopoElems* elemsP);
int topoElems_dodajElem (TopoElems* elemsP, TopoElem* elemP);
int topoElems_inicjujMatrix (TopoElems* elemsP);
int topoElems_relacjaZawieraniePunktObszar (TopoElems* nadElemsP, TopoElems* podElemsP);
int topoElems_relacjaZawieranieObszarObszar (TopoElems* nadElemsP, TopoElems* podElemsP);
int topoElems_relacjePunktLinia (TopoElems* nadElemsP, TopoElems* podElemsP, double tolZakres);
int topoElems_relacjePunktPunkt (TopoElems* nadElemsP, TopoElems* podElemsP);

/* ======================================================================== */

/* topoElemsBin - kontener na elementy */
typedef struct topoElemsBin
{
	TopoElem** aElems;	/* tablica wskaŸników */
	int nElems;			// aktualny rozmiar
	int nRozmiar;		// maksymalny rozmiar
	
} TopoElemsBin, *LpTopoElemsBin;

int topoElemsBin_inicjuj (LpTopoElemsBin binP);
int topoElemsBin_zwolnij (LpTopoElemsBin binP);
int topoElemsBin_dodaj (LpTopoElemsBin binP);
int topoElemsBin_dodajElem (LpTopoElemsBin binP, TopoElem* elemP);

/* topoIndexMatrix - macierz kontenerów na elementy (optymalizacja) */
typedef struct topoIndexMatrix
{
	TopoElemsBin* aBins;	//macierz kontenerów, pamiêæ do zwolnienia
	int nBins;
	
	int nBok;			//liczba kontenerów na jednym boku
	//int nBin;			//rozmiar macierzy (nBok*nBok)
	
	double fX, fY;		//d³ugoœæ i szerokoœæ jednego kontenera
	
	TopoElems* elemsP;	/* */
	
} TopoIndexMatrix, *LpTopoIndexMatrix;

int topoIndexMatrix_inicjuj (LpTopoIndexMatrix matrixP, LpTopoElems elemsP);
int topoIndexMatrix_zwolnij (LpTopoIndexMatrix matrixP);
int topoIndexMatrix_wypisz  (LpTopoIndexMatrix matrixP);
int topoIndexMatrix_load    (LpTopoIndexMatrix matrixP, LpTopoElems elemsP);
int topoIndexMatrix_dodaj   (LpTopoIndexMatrix matrixP, LpTopoElem elemP);
int topoIndexMatrix_dodajElem (LpTopoIndexMatrix matrixP, LpTopoElem elemP);
int topoIndexMatrix_inicjujElems    (LpTopoIndexMatrix matrixP, LpTopoElems elemsP);
int topoIndexMatrix_pobierzIndeks   (LpTopoIndexMatrix matrixP, int i, int j);
int topoMatrix_obliczSkrajneIndeksy (int* xMin, int* yMin, int* xMax, int* yMax, LpTopoIndexMatrix matrixP, LpTopoElem elemP);

/* ========================================================================== */

/* Interfejs dla topoLoad i topoUtil */

int topoUtil_obliczMinInt (int x1, int x2);
double topoUtil_obliczMin (double x1, double x2);
int topoUtil_obliczMaxInt (int x1, int x2);
double topoUtil_obliczMax (double x1, double x2);

int topoUtil_wczytajInteger (char* sString, char* sNazwa, int* nLiczbaP);	/* string[int] */
int topoUtil_wczytajString (char* sString, char* sNazwa, char* sOpis);		/* string[int] */
int topoUtil_typNaRodzaj (int nTyp, int* nRodzajP);

int topoLoad_elemsBS (TopoElems* elemsP, double value, int left, int right);
int topoLoad_elemsBSP (TopoElems* elemsP);

/* ========================================================================== */

#endif
