/* topoZakres.mc */

#include "topoZakres.h"
#include "..\Aplikacja.h"

/* Interfejs dla topoZakres */
int topoZakres_inicjuj (LpTopoZakres zakresP, double xMin, double yMin, double xMax, double yMax)
{
	if (zakresP == NULL)
		return FALSE;
	
	zakresP->xMin = xMin;
	zakresP->yMin = yMin;
	zakresP->xMax = xMax;
	zakresP->yMax = yMax;
	
	return TRUE;
}

int topoZakres_inicjujZerami (LpTopoZakres zakresP)
{
	if (zakresP == NULL)
		return FALSE;
	
	zakresP->xMin = 0.0;
	zakresP->yMin = 0.0;
	zakresP->xMax = 0.0;
	zakresP->yMax = 0.0;
	
	return TRUE;
}

int topoZakres_zwolnij (LpTopoZakres zakresP)	/* dummy */
{
	return zakresP != NULL;
}

int topoZakres_pobierzMinX (LpTopoZakres zakresP, double* xMin)
{
	if (zakresP == NULL)
		return FALSE;
	
	*xMin = zakresP->xMin;
	
	return TRUE;
}

int topoZakres_pobierzMinY (LpTopoZakres zakresP, double* yMin)
{
	if (zakresP == NULL)
		return FALSE;
	
	*yMin = zakresP->yMin;
	
	return TRUE;
}
	
int topoZakres_pobierzMaxX (LpTopoZakres zakresP, double* xMax)
{
	if (zakresP == NULL)
		return FALSE;
	
	*xMax = zakresP->xMax;
	
	return TRUE;
}

int topoZakres_pobierzMaxY (LpTopoZakres zakresP, double* yMax)
{
	if (zakresP == NULL)
		return FALSE;
		
	*yMax = zakresP->yMax;
	
	return TRUE;
}

int topoZakres_ustawMinX (LpTopoZakres zakresP, double xMin)
{
	if (zakresP == NULL)
		return FALSE;

	zakresP->xMin = xMin;
	
	return TRUE;
}

int topoZakres_ustawMinY (LpTopoZakres zakresP, double yMin)
{
	if (zakresP == NULL)
		return FALSE;

	zakresP->yMin = yMin;
	
	return TRUE;
}

int topoZakres_ustawMaxX (LpTopoZakres zakresP, double xMax)
{
	if (zakresP == NULL)
		return FALSE;

	zakresP->xMax = xMax;
	
	return TRUE;
}

int topoZakres_ustawMaxY (LpTopoZakres zakresP, double yMax)
{
	if (zakresP == NULL)
		return FALSE;

	zakresP->yMax = yMax;
	
	return TRUE;
}

LpTopoZakres topoZakres_kopiuj (LpTopoZakres zakresP)
{
	LpTopoZakres kopiaZakresP = NULL;
	
	if (zakresP == NULL)
		return NULL;
	
	kopiaZakresP = (LpTopoZakres) calloc (1, sizeof (TopoZakres));
	
	if (kopiaZakresP == NULL)
		return NULL;
	
	*kopiaZakresP = *zakresP;
	
	return kopiaZakresP;
}

int topoZakres_aktualizujXY (LpTopoZakres zakresP, double xMin, double yMin, double xMax, double yMax)
{
	if (zakresP == NULL)
		return FALSE;
	
	if (xMin < zakresP->xMin)
		zakresP->xMin = xMin;
	
	if (yMin < zakresP->yMin)
		zakresP->yMin = yMin;
	
	if (xMax > zakresP->xMax)
		zakresP->xMax = xMax;
		
	if (yMax > zakresP->yMax)
		zakresP->yMax = yMax;
		
	return TRUE;
}

int topoZakres_aktualizuj (LpTopoZakres zakresP, LpTopoZakres nowyZakresP)
{
	return topoZakres_aktualizujXY (zakresP, nowyZakresP->xMin, nowyZakresP->yMin, nowyZakresP->xMax, nowyZakresP->yMax);
}

int topoZakres_przecinaja (LpTopoZakres zakres1, LpTopoZakres zakres2)
{
	if (zakres1 == NULL || zakres2 == NULL)
		return FALSE;
	
	if (zakres1->xMax < zakres2->xMin)
		return FALSE;
	
	if (zakres1->xMin > zakres2->xMax)
		return FALSE;
	
	if (zakres1->yMax < zakres2->yMin)
		return FALSE;
	
	if (zakres1->yMin > zakres2->yMax)
		return FALSE;
	
	return TRUE;
}

int topoZakres_wirtualny (LpTopoZakres zakresP, DPoint3d* punktP, double tolerancja)
{
	if (zakresP == NULL || punktP == NULL)
		return FALSE;
	
	zakresP->xMin = punktP->x - tolerancja;
	zakresP->yMin = punktP->y - tolerancja;
	zakresP->xMax = punktP->x + tolerancja;
	zakresP->yMax = punktP->y + tolerancja;
	
	return TRUE;
}

int topoZakres_przecinajaPunkty (LpTopoZakres zakresP, DPoint3d* aPunkty, int nPunkty, double tolZakres)
{
	int i = 0;
	
	if (zakresP == NULL || aPunkty == NULL || nPunkty < 1)
		return FALSE;
	
	for (i = 0; i < nPunkty; i++)
	{
		TopoZakres zakresPunkt;
		
		topoZakres_wirtualny (&zakresPunkt, &aPunkty[i], tolZakres);
		
		if (topoZakres_przecinaja (zakresP, &zakresPunkt))
			return TRUE;
	}
	
	return FALSE;
}

/* Koniec interfejsu topoZakres */
