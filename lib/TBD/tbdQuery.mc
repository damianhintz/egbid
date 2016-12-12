/* tbdQuery.mc */

#include "tbdQuery.h"
#include "..\Aplikacja\mdlFile.h"
#include "..\Aplikacja\mdlUtil.h"

/* Interfejs klasy tbdQuery */

int tbdQuery_inicjuj (TbdQuery* queryP, char* sSqlStart)
{
	if (queryP == NULL)
		return FALSE;
	
	if (queryP->sSql == NULL)
	{
		strcpy (queryP->sSqlStart, sSqlStart);
		
		queryP->nIds = 0;
		queryP->nMax = 1024;
		queryP->nLen = strlen (sSqlStart);
		//zakladam ze identyfikator nie bedzie dluzszy niz 16 znakow
		queryP->nSql = queryP->nLen + queryP->nMax * 16;
		queryP->sSql = (char*) calloc (queryP->nSql, sizeof (char));
		
		if (queryP->sSql == NULL)
			return FALSE;
	}
	
	strcpy (queryP->sSql, sSqlStart);
	
	return TRUE;
}

int tbdQuery_zwolnij (TbdQuery* queryP)
{
	if (queryP == NULL)
		return FALSE;
	
	if (queryP->sSql != NULL)
		free (queryP->sSql);
	
	return TRUE;
}

int tbdQuery_dodajId (TbdQuery* queryP, long id)
{
	char sId[16];
	int nIdLen = 0;
	
	if (queryP == NULL)
		return FALSE;
	
	if (queryP->sSql == NULL)
		return FALSE;
	
	strcpy (sId, "");
	sprintf (sId, "%ld", id);
	
	nIdLen = strlen (sId);
	
	strcpy (queryP->sSql + queryP->nLen++, ",");
	strcpy (queryP->sSql + queryP->nLen, sId);
	
	queryP->nLen += nIdLen;
	queryP->nIds++;
	
	return TRUE;
}

int tbdQuery_zakoncz (TbdQuery* queryP)
{
	if (queryP == NULL)
		return FALSE;
	
	if (queryP->nIds >= queryP->nMax)
	{
		strcpy (queryP->sSql + queryP->nLen++, ")");	
		queryP->sSql[queryP->nLen] = '\0';
		
		return TRUE;
	}
	
	return FALSE;
}

/* Koniec interfejsu klasy tbdQuery */


int tbdMdb_kwerendaWykonaj (char* query)
{
	return SUCCESS == mdlDB_processSQL (query);
}

int tbdMdb_kwerendaWartoscInteger (char* query, long* countP)
{
	char sCount[32];
	long nCount = 0;
	
	strcpy (sCount, "0");
	
	switch (mdlDB_sqlQuery (sCount, query))
	{
		case SUCCESS:
			if (1 != sscanf (sCount, "%ld", &nCount))
				nCount = -1;
		break;
		case NO_ROWS_RETURNED:
			nCount = 0;
		break;
		default:
			nCount = -1;
		break;
	}
	
	if (countP != NULL)
		*countP = nCount;
	
    return nCount > 0;
}

int tbdMdb_kwerendaWartoscString (char* query, char* name)
{
	char sName[32];
	long nCount = 0;
	
	strcpy (sName, "");
	
	switch (mdlDB_sqlQuery (sName, query))
	{
		case SUCCESS:
			nCount = 1;
		break;
		case NO_ROWS_RETURNED:
			nCount = 0;
		break;
		default:
			nCount = -1;
			mdlUtil_dolaczBlad ("tbdMdb_queryName", query);
		break;
	}
	
	if (name != NULL)
		strcpy (name, sName);
	
    return nCount > 0;
}


int tbdMdb_kwerendaWczytajIdentyfikatory (char* query, char* queryCount, long** aIdsP, long* nIdsP)
{
	CursorID cursorID;
	MS_sqlda sqlda;
	long n = 0;
	
	if (query == NULL || queryCount == NULL)
		return FALSE;
		
	if (!tbdMdb_kwerendaWartoscInteger (queryCount, nIdsP))
		return FALSE;

	*aIdsP = (long*) calloc (*nIdsP, sizeof (long));
	
	if (*aIdsP == NULL)
		return FALSE;
	
	if (SUCCESS != mdlDB_openCursorWithID (&cursorID, query))
	{
		free (*aIdsP);
		return FALSE;
	}
	
	//short numColumns;char **name;char **value;short   *type;short   *length;short   *scale;short   *prec;short   *null;
	n = 0;
	while (QUERY_NOT_FINISHED == mdlDB_fetchRowByID (&sqlda, cursorID))
	{
		long id;
		
		if (1 == sscanf (sqlda.value[0], "%ld", &id))
			(*aIdsP)[n++] = id;
	}
	
	if (SUCCESS != mdlDB_closeCursorByID (cursorID))
	{
		free (*aIdsP);
		return FALSE;
	}
	
	mdlDB_freeSQLDADescriptor (&sqlda);
	
	mdlUtil_sortLongs (*aIdsP, *nIdsP, TRUE);
	//mdlUtil_quickSort (ids, count, sizeof (long), funcCompare); 
	//qsort(ids, count, sizeof (long), funcCompare);
	
	return TRUE;
}
