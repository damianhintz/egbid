/* tbdMdb.mc */

#include "tbdMdb.h"
#include "tbdDgn.h"
#include "..\Aplikacja\mdlFile.h"
#include "..\Aplikacja\mdlUtil.h"

/* tbdMdb_aktualizujOpisElementuTBD - aktualizuj tekst elementu z baz¹ danych */
int tbdMdb_aktualizujOpisElementuTBD (MSElementDescr* edP, char* opis)
{
	ULong mslink, id;
	
	if (tbdDgn_wczytajMslinkId (&mslink, &id, NULL, edP))
	{	
		return tbdMdb_zapiszDoBazyTBD (id, mslink, "BBBD_A", "x_uwagi", opis);	
	}else
	{
		mdlUtil_dolaczBlad ("tbdMdb_aktualizujOpisElementuTBD", "element nie ma sygnatury TBD(19)");
		return ERROR;
	}
	
    return SUCCESS;
}

/* tbdMdb_aktualizujZrodloDanychElementuTBD */
int tbdMdb_aktualizujZrodloDanychElementuTBD (char* text, ULong id, ULong mslink, char* tabela)
{
	return tbdMdb_zapiszDoBazyTBD (id, mslink, tabela, "x_zrodlo_danych_g", text);
}

/* tbdMdb_zapiszDoBazyTBD */
int tbdMdb_zapiszDoBazyTBD (ULong id, ULong mslink, char* tabela, char* kolumna, char* wartosc)
{
	char msg[256];
	MS_sqlda colda;
	char tablename[256], query[256], value[256];
	int status = SUCCESS;
	
	sprintf (query, "select tablename from feature where mslink = %d", mslink);
	
	if (SUCCESS == mdlDB_sqlQuery (tablename, query))
	{
		//czy jest kolumna i tabela
		if (SUCCESS == mdlDB_describeColumn (&colda, tablename, kolumna))
		{
			if (strncmp (tablename, tabela, 4) == 0)
			{
				sprintf (query, "select %s from %s where id=%d", kolumna, tablename, id);
				
				if (SUCCESS == (status = mdlDB_sqlQuery (value, query)))
				{
					if (strcmp (value, wartosc) == 0)
					{
						/* wartoœæ nowa jest taka sama jak stara */
						//util_nfoPrint ("bez zmian");
					}else
					{
						if (strcmp (value, "") != 0)
						{
							sprintf (msg, "UWAGA: zmiana %s z '%s' na '%s' dla id %d w %s", kolumna, value, wartosc, id, tablename);
							//ioLog_append (msg);
						}
						
						sprintf (query, "update %s set %s='%s' where id=%d", tablename, kolumna, wartosc, id);
						if (SUCCESS == (status = mdlDB_processSQL (query)))
						{
							//ioLog_append (query);
							/* aktualizacja zapisana w bazie danych */
							
						}else
						{
							sprintf (msg, "b³¹d podczas aktualizacji elementu %d (b³¹d nr %d)", id, status);
							mdlUtil_dolaczBlad ("tbdMdb_zapiszDoBazyTBD", msg);
							mdlUtil_dolaczBlad ("tbdMdb_zapiszDoBazyTBD", query);
						}
					}
				}else
				{
					sprintf (msg, "b³¹d zapisu mslink(%d) (%s)", mslink, query);
					mdlUtil_dolaczBlad ("tbdMdb_zapiszDoBazyTBD", msg);
				}
			}else
			{
				sprintf (msg, "tabela %s <> %s", tablename, tabela);
				mdlUtil_dolaczBlad ("tbdMdb_zapiszDoBazyTBD", msg);
				status = ERROR;
			}
		}else
		{
			sprintf (msg, "brak kolumny %s w tabeli %s", kolumna, tablename);
			mdlUtil_dolaczBlad ("tbdMdb_zapiszDoBazyTBD", msg);
			status = ERROR;
		}
	}else
	{
		sprintf (msg, "brak w bazie elementu z mslink %d", mslink);
		mdlUtil_dolaczBlad ("tbdMdb_zapiszDoBazyTBD", msg);
		status = ERROR;
	}
	
    return status;
}

int tbdMdb_odczytajWartoscBazyTBD (ULong id, ULong mslink, char* tabela, char* kolumna, char* wartosc)
{
	char msg[256];
	MS_sqlda colda;
	char tablename[256], query[256], value[256];
	int status = SUCCESS;
	
	sprintf (query, "select tablename from feature where mslink = %d", mslink);
	
	if (SUCCESS == mdlDB_sqlQuery (tablename, query))
	{
		//czy jest kolumna i tabela
		if (SUCCESS == mdlDB_describeColumn (&colda, tablename, kolumna))
		{
			if (strncmp (tablename, tabela, 4) == 0)
			{
				sprintf (query, "select %s from %s where CInt(id)=%d", kolumna, tablename, id);
				
				if (SUCCESS == (status = mdlDB_sqlQuery (value, query)))
				{
					strcpy (wartosc, value);
				}else
				{
					mdlUtil_dolaczBlad ("tbdMdb_odczytajWartoscBazyTBD", "b³¹d odczytu");
				}
			}else
			{
				sprintf (msg, "tabela %s <> %s", tablename, tabela);
				mdlUtil_dolaczBlad ("tbdMdb_odczytajWartoscBazyTBD", msg);
				status = ERROR;
			}
		}else
		{
			sprintf (msg, "brak kolumny %s w tabeli %s", kolumna, tablename);
			mdlUtil_dolaczBlad ("tbdMdb_odczytajWartoscBazyTBD", msg);
			status = ERROR;
		}
	}else
	{
		sprintf (msg, "brak w bazie tabeli z mslink %d", mslink);
		mdlUtil_dolaczBlad ("tbdMdb_odczytajWartoscBazyTBD", msg);
		status = ERROR;
	}
	
    return status;
}

int tbdMdb_czyJestTabela (ULong mslink, char* tabela)
{
	char msg[256];
	//MS_sqlda colda;
	char tablename[256], query[256];
	int status = FALSE;
	
	sprintf (query, "select tablename from feature where mslink=%d", mslink);
	
	if (SUCCESS == mdlDB_sqlQuery (tablename, query))
	{
		if (strcmp (tablename, tabela) == 0)
		{
			status = TRUE;
		}else
			status = FALSE;
	}else
	{
		sprintf (msg, "brak w bazie tabeli z mslink %d", mslink);
		mdlUtil_dolaczBlad ("tbdMdb_czyJestTabela", msg);
		status = FALSE;
	}
	
    return status;
}

int tbdMdb_szukajKolumnyTabeli (char* tabela, char* kolumna)
{
	MS_sqlda colda;
	
	return SUCCESS == mdlDB_describeColumn (&colda, tabela, kolumna);
}

int tbdMdb_wczytajObiektTBD (ULong id, ULong mslink, char* tabela, char* kolumna, char* wartosc)
{
	char msg[256];
	MS_sqlda colda;
	char query[256];
	int status = TRUE;
	
	if (tabela == NULL)
	{
		mdlUtil_dolaczBlad ("tbdMdb_wczytajObiektTBD", "tabela nie mo¿e byæ NULL");
		return FALSE;
	}
	
	sprintf (query, "select tablename from feature where mslink = %d", mslink);
	
	if (SUCCESS == mdlDB_sqlQuery (tabela, query))
	{
		if (kolumna == NULL || strcmp (kolumna, "") == 0)
		{
			return status = TRUE;
		}
		
		if (wartosc == NULL)
		{
			mdlUtil_dolaczBlad ("tbdMdb_wczytajObiektTBD", "wartosc nie mo¿e byæ NULL");
			return status = TRUE;
		}
		
		if (SUCCESS == mdlDB_describeColumn (&colda, tabela, kolumna))
		{
			/* UWAGA: id mo¿e byæ typu liczba lub string */
			sprintf (query, "select %s from %s where CLng(id)=%d", kolumna, tabela, id);
			
			if (SUCCESS == (status = mdlDB_sqlQuery (wartosc, query)))
			{
				status = TRUE;
			}else
			{
				status = FALSE;
				sprintf (msg, "b³¹d odczytu wartoœci %s(%s=%d)", tabela, kolumna, id);
				mdlUtil_dolaczBlad ("tbdMdb_wczytajObiektTBD", msg);
				mdlUtil_dolaczBlad ("tbdMdb_wczytajObiektTBD", query);
				//ioLog_append (msg);
			}
		}else
		{
			sprintf (msg, "brak kolumny %s w tabeli %s", kolumna, tabela);
			mdlUtil_dolaczBlad ("tbdMdb_wczytajObiektTBD", msg);
			status = FALSE;
		}
	}else
	{
		sprintf (msg, "b³¹d po³¹czenia z baz¹ lub brak tabeli %d(%d)", mslink, id);
		mdlUtil_dolaczBlad ("tbdMdb_wczytajObiektTBD", msg);
		//ioLog_append (msg);
		status = FALSE;
	}
	
    return status;
}

int tbdMdb_wczytajAdres (char* tabela, ULong id, char* adres)
{
	char query[256];
	int bNowySchemat = FALSE;
	
	if (tabela == NULL || adres == NULL)
		return FALSE;
	
	bNowySchemat = (tabela[strlen (tabela)-2] == '_');
	
	//2.02 numer,podnumer,id_miejscowosci,id_ulicy,inform_dodatkowa
	//1.36 numer_adr, id_miejscowosci,id_ulicy,inform_dodatkowa
	
	/* UWAGA: id mo¿e byæ typu liczba lub string */
	if (bNowySchemat)
		sprintf (query, "SELECT numer & podnumer FROM %s WHERE CLng(id)=%ld", tabela, id);
	else
		sprintf (query, "SELECT numer_adr FROM %s WHERE CLng(id)=%ld", tabela, id);
	
	//mdlFile_appendLine (query);
	
	if (SUCCESS != mdlDB_sqlQuery (adres, query))
		return FALSE;
	
    return TRUE;
}

int tbdMdb_wczytajAdresKolumna (char* tabela, ULong id, char* kolumna, char* adres)
{
	char query[256];
	
	if (tabela == NULL || adres == NULL || kolumna == NULL)
		return FALSE;
	
	sprintf (query, "SELECT %s FROM %s WHERE CLng(id)=%ld", kolumna, tabela, id);
	
	//mdlFile_appendLine (query);
	
	if (SUCCESS != mdlDB_sqlQuery (adres, query))
		return FALSE;
	
    return TRUE;
}

int tbdMdb_zapiszAdres (char* tabela, ULong id)
{
	char query[256];
	char egib[256];
	
	if (!tbdMdb_wczytajAdresKolumna (tabela, id, "x_zrodlo_danych_a", egib))
		return FALSE;
	
	mdlFile_appendLine (egib);
	
	sprintf (query, "UPDATE %s SET x_zrodlo_danych_a='EGiB' WHERE id=%d", tabela, id);
	mdlFile_appendLine (query);
	
	if (SUCCESS != mdlDB_processSQL (query))
	{
		mdlFile_appendLine ("FAILED");
		return FALSE;
	}
	
    return TRUE;
}

int tbdMdb_porownajIdentyfikatory (long* aP, long* bP)
{
	if (*aP < *bP)
		return -1;
	else
	if (*aP > *bP)
		return 1;
	else
		return 0;
}

int tbdMdb_szukajIdentyfikatora (long* aIds, long nIds, long nId)
{
	return NULL != bsearch (&nId, aIds, nIds, sizeof (long), tbdMdb_porownajIdentyfikatory);
}

/* tbdMdb_najwiekszyMslink - oblicz najwieksza wartosc mslink w tabeli features */
int tbdMdb_najwiekszyMslink (long* mslinkP)
{
	return tbdMdb_kwerendaWartoscInteger (TBD_QUERY_MAX_MSLINK, mslinkP);
}

int tbdMdb_najmniejszyMslink (long* mslinkP)
{
	return tbdMdb_kwerendaWartoscInteger (TBD_QUERY_MIN_MSLINK, mslinkP);
}

/* tbdMdb_wczytajTabeleFeature - kolekcja nazw tabel (pamiec do zwolnienia) */
int tbdMdb_wczytajTabeleFeature (char*** aTables, int* nTables)
{
	CursorID cursorID;
	MS_sqlda sqlda;
	long n = 0;
	long maxMslink = 0;
	long minMslink = -1;
	
	if (aTables == NULL || nTables == NULL)
	{
		mdlUtil_dolaczBlad ("tbdMdb_queryFetchTables", "NULL");
		return FALSE;
	}
	
	/* wyznaczanie najwiekszej wartosci mslink */
	if (!tbdMdb_najwiekszyMslink (&maxMslink))
	{
		mdlUtil_dolaczBlad ("tbdMdb_queryFetchTables", "MAXMSLINK");
		return FALSE;
	}
	
	/* wyznaczanie najmniejszej wartosci mslink */
	if (!tbdMdb_najmniejszyMslink (&minMslink))
	{
		mdlUtil_dolaczBlad ("tbdMdb_queryFetchTables", "MINMSLINK");
		return FALSE;
	}
	
	/* indeks musi byc wiekszy od zera ale mniejszy od 1024 */
	if (minMslink < 0 || maxMslink > 1024)
	{
		mdlUtil_dolaczBlad ("tbdMdb_queryFetchTables", "MSLINK_RANGE<0,1024>");
		return FALSE;
	}
	
	*nTables = maxMslink + 1;
	/* zakladanie tablicy na nazwy tabel (mslink bedzie indeksem do nazwy w tablicy) */
	*aTables = (char**) calloc (maxMslink+1, sizeof (char*));
	
	/* sprawdzamy czy pamiec zostala przydzielona */
	if (*aTables == NULL)
	{
		tbdMdb_zwolnijTabeleFeature (*aTables, *nTables);
		mdlUtil_dolaczBlad ("tbdMdb_queryFetchTables", "MEMORY");
		return FALSE;
	}
	
	/* inicjowanie tablicy */
	for (n = 0; n < maxMslink + 1; n++)
		(*aTables)[n] = NULL;
	
	if (SUCCESS != mdlDB_openCursorWithID (&cursorID, TBD_QUERY_TABLES))
	{
		tbdMdb_zwolnijTabeleFeature (*aTables, *nTables);
		return FALSE;
	}
	
	//short numColumns;char **name;char **value;short   *type;short   *length;short   *scale;short   *prec;short   *null;

	n = 0;
	while (QUERY_NOT_FINISHED == mdlDB_fetchRowByID (&sqlda, cursorID))
	{
		long mslink;
		//char table[32];
		int len = 0;
		
		if (1 == sscanf (sqlda.value[0], "%ld", &mslink))
		{
			if (mslink >= 0)
			{
				/* obliczamy dlugosc nazwy */
				len = strlen (sqlda.value[1]);
				(*aTables)[mslink] = (char*) calloc (len + 1, sizeof (char));
				
				if ((*aTables)[mslink] != NULL)
				{
					/* skopiowanie nazwy */
					strcpy ((*aTables)[mslink], sqlda.value[1]);
					(*aTables)[mslink][len] = '\0';
				}
			}
		}
	}
	
	if (SUCCESS != mdlDB_closeCursorByID (cursorID))
	{
		tbdMdb_zwolnijTabeleFeature (*aTables, *nTables);
		return FALSE;
	}
	
	mdlDB_freeSQLDADescriptor (&sqlda);
	
    return TRUE;
}

int tbdMdb_zwolnijTabeleFeature (char** aTables, int nTables)
{
	int i = 0;
	
	if (aTables == NULL)
		return FALSE;
	
	for (i = 0; i < nTables; i++)
		if (aTables[i] != NULL)
			free (aTables[i]);
	
	free (aTables);
	
	return TRUE;
}

int tbdMdb_wczytajAdresyTakieSame (int* nAdresyP)
{
	CursorID cursorID;
	MS_sqlda sqlda;
	char id[64], numer[64], podnumer[64], id_ulicy[64], id_miejscowosci[64];
	char idP[64], numerP[64], podnumerP[64], id_ulicyP[64], id_miejscowosciP[64];
	
	*nAdresyP = 0;
	
	//if (SUCCESS != mdlDB_openCursorWithID (&cursorID, TBD_QUERY_ADRESY))
	if (SUCCESS != mdlDB_openCursorWithID (&cursorID, TBD_QUERY_ADRESY_TAKIE_SAME))
	{
		return FALSE;
	}
	
	//short numColumns;char **name;char **value;short   *type;short   *length;short   *scale;short   *prec;short   *null;
	//id,numer,podnumer,id_ulicy,id_miejscowosci
	
	strcpy(id, ""); strcpy(numer, ""); strcpy (podnumer, ""); strcpy (id_ulicy, ""); strcpy (id_miejscowosci, "");
	strcpy(idP, ""); strcpy(numerP, ""); strcpy (podnumerP, ""); strcpy (id_ulicyP, ""); strcpy (id_miejscowosciP, "");
	
	while (QUERY_NOT_FINISHED == mdlDB_fetchRowByID (&sqlda, cursorID))
	{
		strcpy(id, ""); strcpy(numer, ""); strcpy (podnumer, ""); strcpy (id_ulicy, ""); strcpy (id_miejscowosci, "");
			
		strcpy(id, sqlda.value[0]); strcpy(numer, sqlda.value[1]); strcpy (podnumer, sqlda.value[2]); strcpy (id_ulicy, sqlda.value[3]); strcpy (id_miejscowosci, sqlda.value[4]);
		
		if (strcmp (id, idP) != 0 && 
			strcmp (numer, numerP) == 0 && 
			strcmp (podnumer, podnumerP) == 0 && 
			strcmp (id_ulicy, id_ulicyP) == 0 && 
			strcmp (id_miejscowosci, id_miejscowosciP) == 0)
		{
			char msg[256];
			
			sprintf (msg, "ID [%s] == ID [%s]", id, idP);
			mdlUtil_wypiszInfo (msg);
		}
		
		strcpy(idP, id); strcpy(numerP, numer); strcpy (podnumerP, podnumer); strcpy (id_ulicyP, id_ulicy); strcpy (id_miejscowosciP, id_miejscowosci);
		
		(*nAdresyP)++;
	}
	
	if (SUCCESS != mdlDB_closeCursorByID (cursorID))
	{
		return FALSE;
	}
	
	mdlDB_freeSQLDADescriptor (&sqlda);
	
    return TRUE;
}
