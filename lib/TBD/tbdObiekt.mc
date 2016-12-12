/* tbdObiekt.mc */

#include "tbdObiekt.h"
#include "tbdMdb.h"
#include "..\Aplikacja\mdlFile.h"
#include "..\Aplikacja\mdlUtil.h"

/* Interfejs klasy tbdObiekty */

int tbdObiekt_porownaj (TbdObiekt* aP, TbdObiekt* bP)
{
	if (aP->nId < bP->nId)
		return -1;
	else
	if (aP->nId > bP->nId)
		return 1;
	else
		return 0;
}

int tbdObiekty_inicjuj (TbdObiekty* obiektyP)
{
	if (obiektyP == NULL)
		return FALSE;
	
	obiektyP->nObiekty = 0;
	obiektyP->aObiekty = NULL;
	obiektyP->nObiektyDgn = 0;
	
	return TRUE;
}

int tbdObiekty_zwolnij (TbdObiekty* obiektyP)
{
	if (obiektyP == NULL)
		return FALSE;
	
	if (obiektyP->aObiekty)
		free (obiektyP->aObiekty);
	
	return TRUE;
}

int tbdObiekty_wczytaj (TbdObiekty* obiektyP, char* query, char* queryCount)
{
	CursorID cursorID;
	MS_sqlda sqlda;
	long n = 0;
	TbdObiekt* aObiekty;
	long nObiekty;
	
	if (obiektyP == NULL)
		return FALSE;
	
	if (query == NULL || queryCount == NULL)
		return FALSE;
		
	if (!tbdMdb_kwerendaWartoscInteger (queryCount, &nObiekty))
		return FALSE;

	aObiekty = (TbdObiekt*) calloc (nObiekty, sizeof (TbdObiekt));
	
	if (aObiekty == NULL)
		return FALSE;
	
	if (SUCCESS != mdlDB_openCursorWithID (&cursorID, query))
	{
		free (aObiekty);
		return FALSE;
	}
	
	//short numColumns;char **name;char **value;short   *type;short   *length;short   *scale;short   *prec;short   *null;
	n = 0;
	while (QUERY_NOT_FINISHED == mdlDB_fetchRowByID (&sqlda, cursorID))
	{
		long id;
		
		if (1 == sscanf (sqlda.value[0], "%ld", &id))
		{
			aObiekty[n].nId = id;
			aObiekty[n].bId = FALSE;
			n++;
		}
	}
	
	if (SUCCESS != mdlDB_closeCursorByID (cursorID))
	{
		free (aObiekty);
		return FALSE;
	}
	
	mdlDB_freeSQLDADescriptor (&sqlda);
	
	//mdlUtil_sortLongs (aIds, nIds, TRUE);
	mdlUtil_quickSort (aObiekty, nObiekty, sizeof (TbdObiekt), tbdObiekt_porownaj); 
	//qsort(ids, count, sizeof (long), funcCompare);
	
	obiektyP->nObiekty = nObiekty;
	obiektyP->aObiekty = aObiekty;
	
	return TRUE;
}

int tbdObiekty_szukaj (TbdObiekty* obiektyP, long nId, TbdObiekt** obiektP)
{
	if (obiektyP == NULL)
		return FALSE;
	
	if (obiektP == NULL)
		return NULL != bsearch (&nId, obiektyP->aObiekty, obiektyP->nObiekty, sizeof (TbdObiekt), tbdObiekt_porownaj);
	else
		return NULL != (*obiektP = bsearch (&nId, obiektyP->aObiekty, obiektyP->nObiekty, sizeof (TbdObiekt), tbdObiekt_porownaj));
}

/* Koniec interfejsu klasy tbdObiekty */
