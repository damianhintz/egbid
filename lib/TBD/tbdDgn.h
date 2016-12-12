/* tbdDgn.h */

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

#if !defined (H_TBD_DGN)
#define H_TBD_DGN

/* Sekcja DGN - wczytywanie pliku do pamieci */

/* tbdArgument - kazdy obiekt w pliku dgn posiada argumenty wiazace z baza tbd(mdb) */
typedef struct tbdAtrybut
{
	ULong nMslink; 		/* klasa obiektu (klasa moze miec rozne mslink, mslink jest indeksem do tablicy) */
	ULong nId;     		/* identyfikator obiektu */
	//ULong nGml;
	//ULong filePos;
	
} TbdAtrybut, *LpTbdAtrybut;

/* tbdListaAtrybutow - argumenty wczytane z pliku dgn */
typedef struct tbdListaAtrybutow
{
	TbdAtrybut* aAtrybuty;  /* tablica atrybutow */
	int nAtrybutyWybrane;   /* maksymalna liczba atrybutow */
	int nAtrybuty;          /* atrybuty wczytane do pamieci */
	int nObiektyBezAtrybutow;
	
} TbdListaAtrybutow, *LpListaAtrybutow;

int tbdListaAtrybutow_inicjuj (TbdListaAtrybutow* argP);
int tbdListaAtrybutow_zwolnij (TbdListaAtrybutow* argP);
int tbdListaAtrybutow_wczytaj (TbdListaAtrybutow* argP);

int tbdDgn_wczytajAtrybuty (TbdAtrybut* argP, MSElementDescr* edP);
int tbdDgn_wczytajMslinkId (ULong* mslinkP, ULong* idP, ULong* gmlP, MSElementDescr* edP);

int tbdDgn_skanujPlik (int (*tbdDgn_skanujPlikFunc)(MSElementDescr* edP, void* vargP), void* argP);
int tbdDgn_skanujPlikWybierz (MSElementDescr* edP, void* vargP);
int tbdDgn_skanujPlikWczytaj (MSElementDescr* edP, void* vargP);

#endif
