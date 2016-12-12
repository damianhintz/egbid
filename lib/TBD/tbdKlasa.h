/* tbdKlasa.h */

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

#include "tbdQuery.h"
#include "tbdObiekt.h"

#if !defined (H_TBD_KLASA)
#define H_TBD_KLASA

/* Sekcja MDB - wczytywanie bazy do pamieci */
/* z tabeli feature tworzymy tablice z bezposrednim dostepem do nazwy tabeli i jej klasy */

typedef struct tbdKlasa
{
	char sKlasa[32]; /* nazwa klasy */
	long nKlasa;     /* identyfikator klasy */
	long nObiekty;   /* obiekty danej klasy */
	long nBledy;
	long nUsuniete;
	
	TbdObiekty obiekty; //obiekty w bazie danych mdb
	
} TbdKlasa, *LpTbdKlasa;

int tbdKlasa_inicjuj (TbdKlasa* klasaP);
int tbdKlasa_zwolnij (TbdKlasa* klasaP);
int tbdKlasa_wypisz (TbdKlasa* klasaP);
int tbdKlasa_wczytajBaze (TbdKlasa* klasaP);
int tbdKlasa_szukajId (TbdKlasa* klasaP, long id);
int tbdKlasa_wykrytoBledy (TbdKlasa* klasaP);

typedef struct tbdListaKlas
{
	int* aMslinkId;   /* tablica konwersji mslink na jednoznaczny identyfikator */
	
	TbdKlasa* aKlasy; /* kolekcja klas */
	int nKlasy;       /* liczba klas */
	
	long nBledy;
	long nOstatniBlad;
	
} TbdListaKlas, *LpTbdListaKlas;

int tbdListaKlas_inicjuj (TbdListaKlas* klasyP);
int tbdListaKlas_zwolnij (TbdListaKlas* klasyP);
int tbdListaKlas_wczytaj (TbdListaKlas* listaP, char** aTables, int nTables);
int tbdListaKlas_wczytajBaze (TbdListaKlas* listaP);
int tbdListaKlas_wypisz (TbdListaKlas* listaP);
int tbdListaKlas_dodajObiektMslink (TbdListaKlas* listaP, ULong mslink);
int tbdListaKlas_dodajObiektId (TbdListaKlas* listaP, ULong mslink, ULong id);
int tbdListaKlas_wykrytoBledy (TbdListaKlas* listaP);
int tbdListaKlas_oczyscBaze (TbdListaKlas* listaP);

#endif
