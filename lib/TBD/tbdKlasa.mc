/* tbdKlasa.mc */

#include "tbdKlasa.h"
#include "tbdMdb.h"
#include "..\Aplikacja\mdlFile.h"
#include "..\Aplikacja\mdlUtil.h"

/* Interfejs klasy tbdKlasa */

int tbdKlasa_inicjuj (TbdKlasa* klasaP)
{
	if (klasaP == NULL)
		return FALSE;

	klasaP->nUsuniete = 0;
	klasaP->nBledy = 0;	
	klasaP->nObiekty = 0;
	klasaP->nKlasa = -1;
	strcpy (klasaP->sKlasa, "");
	
	return tbdObiekty_inicjuj (&klasaP->obiekty);
}

int tbdKlasa_zwolnij (TbdKlasa* klasaP)
{
	if (klasaP == NULL)
		return FALSE;
	
	tbdObiekty_zwolnij (&klasaP->obiekty);
	
	return TRUE;
}

int tbdKlasa_wykrytoBledy (TbdKlasa* klasaP)
{
	return klasaP->nBledy > 0;
}

int tbdKlasa_wypisz (TbdKlasa* klasaP)
{
	char msg[128];
	
	if (klasaP == NULL)
		return FALSE;
	
	sprintf (msg, "klasa: %s (%d) obiekty w pliku dgn %ld, usuniete %ld z %ld", 
		klasaP->sKlasa, klasaP->nKlasa, klasaP->nObiekty, klasaP->nUsuniete, klasaP->obiekty.nObiekty);
	
	mdlUtil_wypiszInfo (msg);
	
	return TRUE;
}

/* tbdKlasa_wczytajBaze - wczytanie identyfikatorow obiektow z bazy danych */
int tbdKlasa_wczytajBaze (TbdKlasa* klasaP)
{
	char msg[256];
	char querySelect[256];
	char queryCount[256];
	
	if (klasaP == NULL)
		return FALSE;
	
	/* wczytywanie identyfikatorow z tabeli */
	sprintf (querySelect, "select id from %s", klasaP->sKlasa);
	sprintf (queryCount, "select count(*) from %s", klasaP->sKlasa);
	
	if (tbdObiekty_wczytaj (&klasaP->obiekty, querySelect, queryCount))
	{
		sprintf (msg, " obiekty klasy %s w bazie %ld, ", klasaP->sKlasa, klasaP->obiekty.nObiekty);
		mdlUtil_wypiszInfo (msg);
	}else
	{
		klasaP->nBledy++;
		mdlUtil_wypiszInfo (" wczytaj obiekty z bazy [FAILURE]");
	}
		
	return !tbdKlasa_wykrytoBledy (klasaP);
}

/* tbdKlasa_oczyscBaze - usuwanie obiektow z bazy danych */
int tbdKlasa_oczyscBaze (TbdKlasa* klasaP)
{
	char sId[16], purged[32], msg[256], sql[4096], ids[4096];
	int i = 0, nId = 0, nLen = 0, nIdLen = 0;
	TbdObiekty* obiektyP;
	
	if (klasaP == NULL)
		return FALSE;
	
	obiektyP = &klasaP->obiekty;
	
	/* inicjowanie kwerendy sql */
	strcpy (ids, "-1");
	nLen = strlen (ids);
	sprintf (purged, "%s_PURGED", klasaP->sKlasa);
	sprintf (msg, "%s: %d OBIEKTY", klasaP->sKlasa, klasaP->nObiekty);
	mdlFile_appendLine (msg);
	
	/* kolekcja obiektow w bazie danych */
	for (i = 0;i < obiektyP->nObiekty; i++)
	{
		TbdObiekt* obiektP = &obiektyP->aObiekty[i];
		
		/* sprawdzamy czy obiekt wystepuje w pliku dgn */
		if (obiektP->bId == FALSE)
		{
			strcpy (sId, "");
			sprintf (sId, "%ld", obiektP->nId);
			
			nIdLen = strlen (sId);
			
			strcpy (ids + nLen++, ",");
			strcpy (ids + nLen, sId);
			
			nLen += nIdLen;
			nId++;
		}
		
		/* na sam koniec lub po znalezieniu 512 obiektow ktorych nie ma w pliku dgn, wykonujemy kwerende usuwajaca je z bazy */
		if (nId > 128 || obiektyP->nObiekty-1 == i)
		{
			/* sprawdzamy czy zostal znaleziony jakis obiekt */
			if (nId > 0)
			{
				/* wstawiamy na koniec nawias */
				//strcpy (sql + nLen++, ")");
				
				if (tbdMdb_szukajKolumnyTabeli (purged, "id"))
					sprintf (sql, "#INSERT INTO %s SELECT * FROM %s WHERE id IN (%s)", purged, klasaP->sKlasa, ids);
				else
					sprintf (sql, "#SELECT * INTO %s FROM %s WHERE id IN (%s)", purged, klasaP->sKlasa, ids);
				
				mdlFile_appendLine ("ARCHIWIZOWANIE USUNIÊTYCH OBIEKTÓW ZOSTA£O WY£¥CZONE");
				mdlFile_appendLine (sql);
				
				/* archiwizowanie starych obiektow */
				//if (tbdMdb_kwerendaWykonaj (sql))
				if (TRUE)
				{
					sprintf (sql, "DELETE * FROM %s WHERE id IN (%s)", klasaP->sKlasa, ids);
					
					/* zapisujemy informacje do pliku i wykonujemy kwerende */
					mdlFile_appendLine (sql);
					if (tbdMdb_kwerendaWykonaj (sql))
						klasaP->nUsuniete += nId;
					else
						mdlFile_appendLine ("FAILED");
						
				}else
				{
					mdlFile_appendLine (sql);
					mdlFile_appendLine ("FAILED");
				}
				
				sprintf (msg, "%ld", i);
				mdlUtil_msgPrint (msg);
			}
			
			/* inicjowanie kwerendy sql */
			strcpy (ids, "-1");
			nLen = strlen (ids);
			nId = 0;
		}
	}
	
	return TRUE;
}

int tbdKlasa_szukajId (TbdKlasa* klasaP, long id)
{
	if (klasaP == NULL)
		return FALSE;
	
	return tbdObiekty_szukaj (&klasaP->obiekty, id, NULL);
}

/* Koniec interfejsu tbdKlasa */

/* Interfejs klasy tbdListaKlas */

int tbdListaKlas_inicjuj (TbdListaKlas* listaP)
{
	if (listaP == NULL)
		return FALSE;
	
	listaP->aMslinkId = NULL;
	listaP->aKlasy = NULL;
	listaP->nKlasy = 0;
	listaP->nBledy = 0;
	
	return TRUE;
}

int tbdListaKlas_zwolnij (TbdListaKlas* listaP)
{
	if (listaP == NULL)
		return FALSE;
	
	if (listaP->aMslinkId != NULL)
		free (listaP->aMslinkId);
	
	if (listaP->aKlasy != NULL)
	{
		int i = 0;
		for (i = 0; i < listaP->nKlasy; i++)
		{
			tbdKlasa_zwolnij (&listaP->aKlasy[i]);
		}
		
		free (listaP->aKlasy);
	}
	
	return TRUE;
}

/* tbdListaKlas_wczytaj */
int tbdListaKlas_wczytaj (TbdListaKlas* listaP, char** aTables, int nTables)
{
	TbdKlasa* aKlasy = NULL;
	int nKlasy = nTables;
	int iMslink = 0;
	int nKlasa = 0;
	int i = 0;
	
	int* aMslinkId = (int*) calloc (nTables, sizeof (int)); //mslink zostanie zamieniony na jednoznaczny identyfikator
	
	/* przydzielamy pamiec na tablice indeksow (kazdej tablicy przypiszemy jednoznaczny identyfikator) */
	
	if (aMslinkId == NULL)
		return FALSE;
	
	for (iMslink = 0; iMslink < nTables; iMslink++)
	{
		int jMslink = 0;
		
		aMslinkId[iMslink] = -1;
		
		/* pomijamy puste nazwy */
		if (aTables[iMslink] == NULL)
			continue;
		
		/* sprawdzamy czy wczesniej juz taka nazwa nie wystapila */
		for (jMslink = 0; jMslink < iMslink; jMslink++)
		{
			/* pomijamy puste nazwy */
			if (aTables[jMslink] == NULL)
				continue;
			
			if (strcmp (aTables[iMslink], aTables[jMslink]) == 0)
			{
				//jezeli taka nazwa juz sie powtorzyla to dostaje juz przydzielony identyfikator
				aMslinkId[iMslink] = aMslinkId[jMslink];
				jMslink = -1;
				break;
			}
		}
		
		/* sprawdzamy czy nazwa sie powtorzyla */
		if (jMslink >= 0)
		{
			//takiej jeszcze nie bylo
			aMslinkId[iMslink] = nKlasa++;
		}
	}
	
	/* przydzielamy pamiec na klasy */
	nKlasy = nKlasa;
	aKlasy = (TbdKlasa*) calloc (nKlasy, sizeof (TbdKlasa));
	
	if (aKlasy == NULL)
		return FALSE;
	
	/* inicjowanie klas identyfikatorami mslinkow */
	for (i = 0; i < nKlasy; i++)
	{
		tbdKlasa_inicjuj (&aKlasy[i]);
	}
	
	for (iMslink = 0; iMslink < nTables; iMslink++)
	{
		nKlasa = aMslinkId[iMslink];
		
		if (nKlasa < 0)
			continue;
		
		aKlasy[nKlasa].nKlasa = nKlasa;
		strcpy (aKlasy[nKlasa].sKlasa, aTables[iMslink]);
	}
	
	listaP->aMslinkId = aMslinkId;
	listaP->aKlasy = aKlasy;
	listaP->nKlasy = nKlasy;
	
	return TRUE;
}

/* tbdListaKlas_oczyscBaze */
int tbdListaKlas_oczyscBaze (TbdListaKlas* listaP)
{
	int i = 0;
	
	if (listaP == NULL)
		return FALSE;
	
	mdlFile_appendLine ("--TBDPURGE_START--");
		
	for (i = 0; i < listaP->nKlasy; i++)
	{
		TbdKlasa* klasaP = &listaP->aKlasy[i];
		
		if (klasaP->nObiekty > 0)
		{
			tbdKlasa_oczyscBaze (klasaP);
			tbdKlasa_wypisz (klasaP);
		}
	}
	
	mdlFile_appendLine ("--TBDPURGE_KONIEC--");
	
	return TRUE;
}

/* tbdListaKlas_wczytajBaze */
int tbdListaKlas_wczytajBaze (TbdListaKlas* listaP)
{
	int i = 0;
	
	if (listaP == NULL)
		return FALSE;
	
	for (i = 0; i < listaP->nKlasy; i++)
	{
		TbdKlasa* klasaP = &listaP->aKlasy[i];
		
		if (klasaP->nObiekty > 0)
		{
			/* wczytanie identyfikatorow obiektow z bazy danych mdb */
			if (!tbdKlasa_wczytajBaze (klasaP))
				listaP->nBledy++;
		}	
	}
		
	return !tbdListaKlas_wykrytoBledy (listaP);
}

int tbdListaKlas_wypisz (TbdListaKlas* listaP)
{
	char msg[256];
	int i = 0;
	long nObiekty = 0;
	int nKlasy = 0;
	
	if (listaP == NULL)
		return FALSE;
	
	for (i = 0; i < listaP->nKlasy; i++)
	{
		TbdKlasa* klasaP = &listaP->aKlasy[i];
		
		if (klasaP->nObiekty > 0)
		{
			nObiekty += klasaP->nObiekty;
			nKlasy++;
			
			tbdKlasa_wypisz (klasaP);
		}	
	}
	
	sprintf (msg, "tbdutil-purge: wczytane klasy %ld(%d), sklasyfikowane obiekty %ld(%ld)", listaP->nKlasy, nKlasy, nObiekty, listaP->nBledy);
	mdlUtil_wypiszInfo (msg);
		
	return TRUE;
}

/* tbdListaKlas_dodajObiektMslink */
int tbdListaKlas_dodajObiektMslink (TbdListaKlas* listaP, ULong mslink)
{
	int nKlasa = -1;
	
	if (listaP == NULL)
		return FALSE;
	
	nKlasa = listaP->aMslinkId[mslink];
	
	if (nKlasa < 0)
	{
		listaP->nBledy++;
		listaP->nOstatniBlad = mslink;
		return FALSE;
	}
	
	if (nKlasa < listaP->nKlasy)
		listaP->aKlasy[nKlasa].nObiekty++;
	else
		return FALSE;
	
	return TRUE;
}

/* tbdListaKlas_dodajObiektId - klasyfikowanie obiektu */
int tbdListaKlas_dodajObiektId (TbdListaKlas* listaP, ULong mslink, ULong id)
{
	//char sId[16];
	//int nIdLen = 0;
	int nKlasa = -1;
	TbdKlasa* klasaP = NULL;
	TbdObiekt* obiektP = NULL;
	
	if (listaP == NULL)
		return FALSE;
	
	nKlasa = listaP->aMslinkId[mslink];
	
	if (nKlasa < 0)
	{
		listaP->nBledy++;
		listaP->nOstatniBlad = mslink;
		return FALSE;
	}
	
	klasaP = &listaP->aKlasy[nKlasa];
	
	/* ustal czy obiekt z pliku dgn jest w bazie danych */
	if (tbdObiekty_szukaj (&klasaP->obiekty, id, &obiektP))
	{
		obiektP->bId = TRUE;
		klasaP->obiekty.nObiektyDgn++;
	}else
		klasaP->nBledy++;
	
	return TRUE;
}

int tbdListaKlas_wykrytoBledy (TbdListaKlas* listaP)
{
	return listaP->nBledy > 0;
}

/* Koniec interfejsu klasy tbdListaKlas */
