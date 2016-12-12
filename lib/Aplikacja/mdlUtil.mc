/* mdlUtil.mc */

#include "mdlUtil.h"
//#include "mdlStos.h"

//MdlStos g_mdlUtil_stos;

long g_nPamiec;

int mdlUtil_inicjujMsg (MdlUtilMsg* msgP)
{
	if (msgP == NULL)
	{
		mdlDialog_dmsgsPrint ("mdlUtil_inicjujMsg: argument jest NULL");
		return FALSE;
	}
	
	msgP->nType = MDL_UTIL_MSG_None;
	msgP->nCount = 0;
	msgP->sNazwa = NULL;
	msgP->sPomoc = NULL;
	
	return TRUE;
}

int mdlUtil_zwolnijMsg (MdlUtilMsg* msgP)
{
}

int mdlUtil_dolaczBlad (char* nazwa, char* opis)
{
	mdlUtil_wypiszInfo (opis);
	
	return TRUE;
}

int mdlUtil_wypiszInfo (char* text)
{
	mdlDialog_dmsgsPrint (text);
	return TRUE;
}

int mdlUtil_msgPrint (char* msg)
{
	//mdlOutput_message (msg);
	mdlOutput_command (msg);
	//mdlOutput_status  (msg);
	return TRUE;
}

char* mdlUtil_trimRight (char* p, char c)
{
    char* end;
    int len;

    len = strlen(p);
    
    while (*p && len)
    {
        end = p + len-1;
        if (c == *end)
            *end = 0;
        else
            break;
        len = strlen (p);
    }
    return p;
}

void mdlUtil_readInt (char* wiersz, int* value)
{
	int i = 0;
	char* charP;
	char row[1024];
	
	strcpy (row, wiersz);
	charP = strtok (row, "=");
	
	while (charP != NULL)
	{
		if (i++ == 1)
		{
			sscanf (charP, "%d", value);
			break;
		}
		charP = strtok (NULL, "=");
	}
}

void mdlUtil_readString (char* wiersz, char* value)
{
	int i = 0;
	char* charP;
	char row[1024];
	
	strcpy (row, wiersz);
	charP = strtok (row, "=");
	
	while (charP != NULL)
	{
		if (i++ == 1)
		{
			strcpy (value, charP);
			break;
		}
		charP = strtok (NULL, "=");
	}
}

void mdlUtil_readDouble (char* wiersz, double* value)
{
	int i = 0;
	char* charP;
	char row[1024];
	
	strcpy (row, wiersz);
	charP = strtok (row, "=");
	
	while (charP != NULL)
	{
		if (i++ == 1)
		{
			sscanf (charP, "%f", value);
			break;
		}
		charP = strtok (NULL, "=");
	}
}

int mdlUtil_inicjuj ()
{
	return TRUE;
}

int mdlUtil_zwolnij ()
{
	return TRUE;
}
/*
int mdlUtil_enterFunction (char* nazwaFunkcji)
{
	return mdlStos_pushString (&g_mdlUtil_stos, nazwaFunkcji);
}

int mdlUtil_exitFunction ()
{
	return mdlStos_pop ();
}
*/


void* mdlUtil_alokujPamiec (int nNumber, int nSize)
{
	void* memoryP = calloc (nNumber, nSize);
	
	if (memoryP)
		g_nPamiec += nNumber * nSize;
	else
		
	return memoryP;
	
}

void mdlUtil_zwolnijPamiec (void* memoryP)
{
	free (memoryP);
}
