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
#include <msscell.fdf>
#include <mstmatrx.fdf>
#include <msvec.fdf>
#include "..\Aplikacja\def-v8.h"

#if !defined (H_OBIEKT_DGN)
#define H_OBIEKT_DGN

/* informacja o typie obiektu */
int obiektDgn_jestTekstem(int elemType);
int obiektDgn_jestSymbolem(int elemType);
int obiektDgn_jestLinia(int elemType);
int obiektDgn_jestLiniowy(int elemType);
int obiektDgn_jestObszarem(int elemType);
int obiektDgn_jestObszaremPoligonowym(int elemType);
int obiektDgn_jestProsty(int elemType);
int obiektDgn_jestZlozony(int elemType);

/* wczytywanie atrybutów obiektu */
int obiektDgn_wczytajSymbol(MSElementDescr *edP, char* name, DPoint3d* origin, NumerPlikuDgn modelRefP);
int obiektDgn_wczytajTekst(MSElementDescr *edP, char* textP, DPoint3d* originP);
int obiektDgn_wczytajAtrybuty(MSElementDescr *edP, NumerPlikuDgn modelRef, int* typeP, UInt32* levelP, UInt32* colorP, UInt32* weightP, Int32* styleP);
int obiektDgn_wczytajAtrybutySymbolu(MSElementDescr* edP, ULong* levelP, UInt32* colorP, UInt32* weigthP, Int32* styleP);

/* wczytywanie topologii obiektu */
int obiektDgn_wczytajPunktyTekstu(MSElementDescr *edP, DPoint3d* aPunkty, int* nPunktyP);
int obiektDgn_wczytajObszar();
int obiektDgn_wczytajLinie();

/* konwersja i tworzenie obiektu */
int mdlElem_tekst(MSElement* el, DPoint3d* punkt, char* tekst, ULong czcionka, double wysokosc, double rotacja);
int mdlElem_cellLine(MSElementDescr* edP, NumerPlikuDgn modelRefP, MSElementUnion* elLineP, DPoint3d* shape, RotMatrix* matrixP);
int dgnCell_extractEllipse(MSElementDescr* edP, NumerPlikuDgn modelRefP, MSElementUnion* elipsa, double scale, DPoint3d* centerP, int* visible);
int dgnCell_extractRect(MSElementDescr* edP, NumerPlikuDgn modelRefP, MSElementUnion* prostokat, double scale, int* visible);

int obiektDgn_konwertujTekstNaSymbol(MSElementDescr** edPsymbol, MSElementDescr* edPtekst, char* cellName);
int obiektDgn_konwertujSymbolTekstuNaTekst();
int obiektDgn_konwertujSymbolOkreguNaOkrag();
int obiektDgn_konwertujSymbolProstokataNaProstokat();

/* rysowanie obiektu */
int obiektDgn_rysujPunktyNaOknie(DPoint3d* aPunkty, int nPunkty, double vZakres, int bDraw, int dialogId, int X, int W, int Y, int H, int bShow);

#define B_PUNKTY 1
#define B_LINIE 2
#define B_KIERUNEK 4
#define B_CENTROID 8
#define B_POLE 16
#define B_OBWOD 32
#define B_WSPOLRZEDNE 64
#define B_ZAKRES 128

int obiektDgn_rysujPunktyNaWidoku(DPoint3d* aPunkty, int nPunkty, byte bParametry);
int obiektDgn_rysujPunkty();

#endif
