/* tbdMdb.h */

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

#if !defined (H_TBD_MDB)
#define H_TBD_MDB

/* Sekcja MDB - wczytywanie bazy do pamieci */
/* z tabeli feature tworzymy tablice z bezposrednim dostepem do nazwy tabeli i jej klasy */

int tbdMdb_wczytajTabeleFeature (char*** aTables, int* nTables);
int tbdMdb_zwolnijTabeleFeature (char** aTables, int nTables);

int tbdMdb_najwiekszyMslink (long* mslinkP);
int tbdMdb_najmniejszyMslink (long* mslinkP);

int tbdMdb_porownajIdentyfikatory (long* aP, long* bP);
int tbdMdb_szukajIdentyfikatora (long* aIds, long nIds, long nId);
int tbdMdb_szukajKolumnyTabeli (char* tabela, char* kolumna);

int tbdMdb_zapiszDoBazyTBD (ULong id, ULong mslink, char* tabela, char* kolumna, char* wartosc);
int tbdMdb_odczytajWartoscBazyTBD (ULong id, ULong mslink, char* tabela, char* kolumna, char* wartosc);
int tbdMdb_wczytajObiektTBD (ULong id, ULong mslink, char* tabela, char* kolumna, char* wartosc);
int tbdMdb_aktualizujOpisElementuTBD (MSElementDescr* edP, char* opis);
int tbdMdb_aktualizujZrodloDanychElementuTBD (char* text, ULong id, ULong mslink, char* tabela);
int tbdMdb_czyJestTabela (ULong mslink, char* tabela);

int tbdMdb_wczytajAdres (char* tabela, ULong id, char* adres);
int tbdMdb_zapiszAdres (char* tabela, ULong id);
int tbdMdb_wczytajAdresyTakieSame (int* nAdresyP);

#endif
