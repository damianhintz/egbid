/* topoLayer.h */

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
#include "topoIndex.h"

#if !defined (H_TOPO_LAYER)
#define H_TOPO_LAYER

/* topoLayer - definicja klasy obiektu */
typedef struct topoLayer
{
	int  nRodzaj;			//obszar,tekst,symbol,none
	char sRodzaj[64];		//obszar,tekst,symbol,none
	char sOpis[64];			//symbol[ADRES]
	char sNazwa[64];		//identyfikator
	
	char sNadrzedny[64];	//identyfikator nadrzêdnego
	int  nNadrzedny;
	char sRelacjaNad[64];	//nazwa relacji do obiektu nadrzêdnego
	
	char sPodrzedny[64];	//identyfikator podrzêdnego
	int  nPodrzedny;
	char sRelacjaPod[64];	//nazwa relacji do obiektu podrzêdnego
	
	char sTabela[64];		//nazwa tabeli TBD (czteroliterowa)
	char sTabTBD[64];		//rzeczywista nazwa tabeli w bazie mdb (w starym schemacie nazwy tabel sa krotsze)
	int bNowySchemat;		//tak (2.02) | nie (1.36) (schemat bazy danych)
	
	int    bBazaTBD;		//TBD
	int    bReferencyjny;	//0 - nie, 1 - tak
	UInt32 nWarstwa;		//numer warstwy
	//UInt32 nKolor;		//kolor
	double tolZakres;		//tolerancja
	
	TopoElems elems;		//kolekcja elementów danej klasy
	int nRozmiar;			//maksymalny rozmiar tablicy
	int nBledy;				//bledy
	
	long* aIds;             //tablica identyfikatorow obiektow wczytanych z bazy danych
	long nIds;              //liczba identyfikatorow
	
	long* aMslinks;         //tablica mslink tej samej klasy
	long nMslinks;          //liczba mslink tej samej klasy
	
} TopoLayer, *LpTopoLayer;

/* Interfejs dla topoLayer */

int topoLayer_inicjuj     (LpTopoLayer defP);
int topoLayer_zwolnij     (LpTopoLayer defP);
int topoLayer_wczytaj     (LpTopoLayer defP, char* wiersz);
int topoLayer_identyczny  (LpTopoLayer opis1P, LpTopoLayer opis2P);
int topoLayer_porownaj    (LpTopoLayer defP, int nRodzaj, int bReferencyjny, int nWarstwa);
int topoLayer_porownajTBD (LpTopoLayer defP, int nRodzaj, int bReferencyjny, int nWarstwa, ULong nMslink);
int topoLayer_ustawRodzaj (LpTopoLayer defP, char* sRodzaj);
int topoLayer_ustawNazwa  (LpTopoLayer defP, char* sNazwa);
int topoLayer_ustawNadrz  (LpTopoLayer defP, char* sNadrz);
int topoLayer_ustawPodrz  (LpTopoLayer defP, char* sPodrz);
int topoLayer_ustawWarstwa      (LpTopoLayer defP, int nWarstwa);
int topoLayer_ustawReferencyjny (LpTopoLayer defP, int bReferencyjny);
int topoLayer_ustawTBD          (LpTopoLayer defP, char* sTBD);
int topoLayer_inicjujElems (LpTopoLayer defP);

//topoLayer_setIndex;
//topoLayer_buildIndex;
//topoLayer_addFeature;
//topoLayer_build (from selection, design file, fence)

/* ========================================================================== */

/* topoLayers - definicje klas obiektów */
typedef struct topoLayers
{
	TopoLayer* aElems;	/* pamiêæ do zwolnienia */
	int nElems;			/* liczba elementów */
	
} TopoLayers, *LpTopoLayers;

/* Interfejs dla topoLayers */

int topoLayers_inicjuj (LpTopoLayers defsP);
int topoLayers_zwolnij (LpTopoLayers defsP);
int topoLayers_dodaj   (LpTopoLayers defsP, LpTopoLayer defP);
int topoLayers_dodajDef (LpTopoLayers defsP, char* def, double tolZakres);
int topoLayers_wczytaj (LpTopoLayers defsP);
int topoLayers_szukajNazwy        (LpTopoLayers defsP, char* sNazwa, LpTopoLayer* defP); /* optymalizacja, wyszukiwanie binarne */
int topoLayers_szukajIdentyczny   (LpTopoLayers defsP, int nRodzaj, int bReferencyjny, int nWarstwa, LpTopoLayer* defP); /* optymalizacja, wyszukiwanie binarne */
int topoLayers_szukajIdentycznyTBD(LpTopoLayers defsP, int nRodzaj, int bReferencyjny, int nWarstwa, long nMslink, LpTopoLayer* defP); /* optymalizacja, wyszukiwanie binarne */
int topoLayers_szukajReferencyjny (LpTopoLayers defsP, int* bReferencyjny); /* optymalizacja, wyszukiwanie binarne */
int topoLayers_szukajTBD          (LpTopoLayers defsP, int* bTBD); /* optymalizacja, wyszukiwanie binarne */
int topoLayers_inicjujElems (LpTopoLayers defsP);
int topoLayers_wypisz       (LpTopoLayers defsP);
int topoLayers_conn         (LpTopoLayers defsP);

/* ========================================================================== */

#endif
