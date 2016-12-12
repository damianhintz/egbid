/* tbdSBM.mc */

#include "tbdSBM.h"
#include "..\Aplikacja\mdlUtil.h"

int plikTbdSBM_inicjuj (PlikTbdSBM* plikP)
{
	if (plikP == NULL)
		return FALSE;
	
	plikP->nTeksty = 0;
	
	return TRUE;
}

int plikTbdSBM_zwolnij (PlikTbdSBM* plikP)
{
	if (plikP == NULL)
		return FALSE;
	
	return TRUE;
}

int plikTbdSBM_dodajTekst (PlikTbdSBM* plikP, char* tekst)
{
	return TRUE;
}

int plikTbdSBM_wczytajTeksty (PlikTbdSBM* plikP, char* sbmName)
{
	FILE* file;
	char wiersz[1024];
	char msg[256];
	
	if (plikP == NULL || sbmName == NULL)
		return FALSE;
	
	if ((file = mdlTextFile_open (sbmName, TEXTFILE_READ)) == NULL)
		return FALSE;
	
	while (NULL != mdlTextFile_getString (wiersz, sizeof wiersz, file, TEXTFILE_DEFAULT))
	{
		char* placeTextP = NULL;
		char placeText[256];
		int i = 0, j = 0;
		char* wierszP = NULL;
		
		//   'Drogowy','lv=24;co=108;lc=0;wt=1;tx=5;active font=3;active txj=cc;place text;PKTK01', line /color=(2,6)
		if (NULL == (placeTextP = strstr (wiersz, ";place text;")))
			continue;
		
		wierszP = placeTextP + strlen (";place text;");
		strcpy (placeText, "");
		
		for (i = 0; i < strlen (wierszP); i++)
		{
			if (wierszP[i] == '\'')
				break;
			
			placeText[j++] = wierszP[i];
		}
		
		placeText[j++] = '\0';
		
		if (plikP->nTeksty >= 256)
			continue;
			
		if (strlen (placeText) + 1 >= 64)
			continue;
			
		strcpy (plikP->aTeksty[plikP->nTeksty++], placeText);
		//mdlUtil_wypiszInfo (placeText);
		//mdlUtil_wypiszInfo (wiersz);
	}
	
	sprintf (msg, "%d wczytane teksty z pliku sbm", plikP->nTeksty);
	mdlUtil_wypiszInfo (msg);
	
	return SUCCESS == mdlTextFile_close (file);
}

int plikTbdSBM_szukajTekstu (PlikTbdSBM* plikP, char* tekst)
{
	int i = 0;
	
	if (plikP == NULL)
		return FALSE;
	
	for (i = 0; i < plikP->nTeksty; i++)
	{
		if (strcmp (plikP->aTeksty[i], tekst) == 0)
			return TRUE;
	}
		
	return FALSE;
}

int plikTbdSBM_szukajPliku (PlikTbdSBM* plikP)
{
	//${MSDIR}\TBD\Data\TBD.SBM
	//char fileName[MAXFILELENGTH];
	char* vPlik = NULL;
	
	/* rozwiniêcie nazwy katalogu docelowego */
	if (NULL == (vPlik = mdlSystem_expandCfgVar ("${MSDIR}\\TBD\\Data\\TBD.SBM")))
		return FALSE;
	
	if (SUCCESS != mdlFile_find (NULL, vPlik, NULL, NULL))
		return FALSE;
	
	mdlUtil_wypiszInfo (vPlik);
	plikTbdSBM_wczytajTeksty (plikP, vPlik);
	
	free (vPlik);
	
	return TRUE;
}
