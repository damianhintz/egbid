/* selekcjonowanie.mc */

#include "selekcjonowanie.h"
#include "..\Core\obiektDgn.h"
#include "..\Aplikacja\mdlUtil.h"

int plikDgn_selekcjonowanie (int (*plikDgn_selekcjaFunc)(MSElementDescr* edP, void* argP), void* argP)
{
	//char msg[256];
	ULong* offsets;
	NumerPlikuDgn* fileNums;
	int nSelected = 0, i = 0;
	
	mdlSystem_startBusyCursor ();
	
	//odznacz wszystkie obiekty
	mdlSelect_freeAll ();
	
	//zaznacz wszystkie obiekty
	mdlSelect_allElements ();
	
	if (SUCCESS != mdlSelect_returnPositions (&offsets, &fileNums, &nSelected))
		return FALSE;
		
	mdlSelect_freeAll ();
	
	//odznacz wszystkie obiekty ktore maja jakies atrybuty
	for (i = 0; i < nSelected; i++)
	{
		MSElementDescr* edP = NULL;
		NumerPlikuDgn numerPliku = fileNums[i];
		ULong filePos = offsets[i];
		int typObiektu;
		
		if (0 == mdlElmdscr_read (&edP, filePos, numerPliku, 0, NULL))
			continue;
		
		if (!obiektDgn_wczytajAtrybuty (edP, numerPliku, &typObiektu, NULL, NULL, NULL, NULL))
			continue;
		
		plikDgn_selekcjaFunc (edP, argP);
		
		/*
		if (!obiektDgn_jestTekstem (typObiektu))
		{
			//mdlSelect_removeElement (offsets[i], numerPliku, TRUE);
			continue;
		}
		
		//mdlSelect_addElement(filePos, numerPliku, &edP->el, TRUE);
		
		if (!obiektDgn_konwertujTekstNaSymbol (&edPsymbol, edP, "OBSZAR"))
			continue;
		
		//mdlElmdscr_add (edPsymbol);
		*/
		
		mdlElmdscr_freeAll (&edP);
	}
	
	mdlSystem_stopBusyCursor ();
	
	mdlUtil_wypiszInfo ("-KONIEC-");
	
	
	return TRUE;
}

int plikDgn_selekcjaPolicz (MSElementDescr* edP, void* vargP)
{
	PlikDgnSelekcja* argP = (PlikDgnSelekcja*) vargP;
	NumerPlikuDgn numerPliku = MASTERFILE; //skanujemy tylko plik g³ówny
	int typObiektu;
	
	if (obiektDgn_wczytajAtrybuty (edP, numerPliku, &typObiektu, NULL, NULL, NULL, NULL))
	{
		if (obiektDgn_jestTekstem (typObiektu))
			argP->nTeksty++;
		else
		if (obiektDgn_jestSymbolem (typObiektu))
			argP->nSymbole++;
		else
		if (obiektDgn_jestObszarem (typObiektu))
			argP->nObszary++;
		else
			argP->nInneObiekty++;
		
		argP->nObiekty++;
	}
	
	return SUCCESS;
}

int plikDgnSelekcja_inicjuj (PlikDgnSelekcja* argP)
{
	if (argP == NULL)
		return FALSE;
	
	argP->nObiekty = 0;
	argP->nInneObiekty = 0;
	
	argP->nTeksty = 0;
	argP->nSymbole = 0;
	argP->nObszary = 0;
	
	return TRUE;
}

int plikDgnSelekcja_zwolnij (PlikDgnSelekcja* argP)
{
	if (argP == NULL)
		return FALSE;
	
	return TRUE;
}

int plikDgnSelekcja_wczytaj (PlikDgnSelekcja* argP)
{
	//char msg[256];
	
	if (argP == NULL)
		return FALSE;
	
	/* wczytaj atrybuty do pamieci */
	if(!plikDgn_selekcjonowanie (plikDgn_selekcjaPolicz, argP))
	{
		return FALSE;
	}
	
	/* odœwie¿ widok */
	if (SUCCESS == mdlView_updateSingle (tcb->lstvw)) ;
	
	return TRUE;
}

int plikDgnSelekcja_wypisz (PlikDgnSelekcja* argP)
{
	char msg[256];
	
	if (argP == NULL)
		return FALSE;
	
	sprintf (msg, "skanowanie: teksty %d, symbole %d, obszary %d, inne %d", 
		argP->nTeksty, argP->nSymbole, argP->nObszary, argP->nInneObiekty);
	mdlUtil_wypiszInfo (msg);
	
	return TRUE;
}
