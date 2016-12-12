/* topo.h */

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

#if !defined (H_TOPO_ZAKRES)
#define H_TOPO_ZAKRES

/* topoZakres - zakres elementu lub wielu elementów */
typedef struct topoZakres
{
	double xMin;
	double yMin;
	double xMax;
	double yMax;
	
} TopoZakres, *LpTopoZakres;

/* Interfejs dla topoZakres */
int topoZakres_inicjuj (LpTopoZakres zakresP, double xMin, double yMin, double xMax, double yMax);
int topoZakres_inicjujZerami (LpTopoZakres zakresP);
int topoZakres_zwolnij (LpTopoZakres zakresP);	/* dummy */

int topoZakres_pobierzMinX (LpTopoZakres zakresP, double* xMin);
int topoZakres_pobierzMinY (LpTopoZakres zakresP, double* yMin);
int topoZakres_pobierzMaxX (LpTopoZakres zakresP, double* xMax);
int topoZakres_pobierzMaxY (LpTopoZakres zakresP, double* yMax);

int topoZakres_ustawMinX (LpTopoZakres zakresP, double xMin);
int topoZakres_ustawMinY (LpTopoZakres zakresP, double yMin);
int topoZakres_ustawMaxX (LpTopoZakres zakresP, double xMax);
int topoZakres_ustawMaxY (LpTopoZakres zakresP, double yMax);

LpTopoZakres topoZakres_kopiuj (LpTopoZakres zakresP);
int topoZakres_aktualizujXY (LpTopoZakres zakresP, double xMin, double yMin, double xMax, double yMax);
int topoZakres_aktualizuj (LpTopoZakres zakresP, LpTopoZakres nowyZakresP);
int topoZakres_przecinaja (LpTopoZakres zakres1, LpTopoZakres zakres2);
int topoZakres_przecinaja (LpTopoZakres zakres1, LpTopoZakres zakres2);
int topoZakres_przecinajaPunkty (LpTopoZakres zakresP, DPoint3d* aPunkty, int nPunkty, double tolZakres);
int topoZakres_wirtualny (LpTopoZakres zakresP, DPoint3d* punktP, double tolerancja);

/* =============================================== */

#endif