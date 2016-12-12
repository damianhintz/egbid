#include "topoElem.h"
#include "..\Core.h"
#include "..\Aplikacja.h"

/* Interfejs dla topoLpElems */

int topoLpElems_inicjuj(LpTopoLpElems lpElemsP) {
    if (lpElemsP == NULL)
        return FALSE;

    lpElemsP->aElems = NULL;
    lpElemsP->nElems = 0;

    return TRUE;
}

int topoLpElems_zwolnij(LpTopoLpElems lpElemsP) {
    if (lpElemsP == NULL)
        return FALSE;

    if (lpElemsP->aElems != NULL)
        free(lpElemsP->aElems);

    return TRUE;
}

int topoLpElems_dodaj(LpTopoLpElems lpElemsP, LpTopoElem elemP) {
    LpTopoElem* aElemsP = NULL;
    int i = 0;

    if (lpElemsP == NULL || elemP == NULL) {
        mdlUtil_dolaczBlad("topoLpElems_dodaj", "argumenty nie mog¹ byæ NULL");
        return FALSE;
    }

    for (i = 0; i < lpElemsP->nElems; i++) //szukaj stare elementy
    {
        if (lpElemsP->aElems[i] == elemP)
            return FALSE;
    }

    aElemsP = (LpTopoElem*) calloc(lpElemsP->nElems + 1, sizeof (LpTopoElem));

    if (aElemsP == NULL) {
        mdlUtil_dolaczBlad("topoLpElems_dodaj", "za ma³o pamiêci");
        return FALSE;
    }

    for (i = 0; i < lpElemsP->nElems; i++) //skopiuj stare elementy
        aElemsP[i] = lpElemsP->aElems[i];

    aElemsP[lpElemsP->nElems] = elemP; //przypisz ostatni element

    if (lpElemsP->aElems != NULL)
        free(lpElemsP->aElems);

    lpElemsP->aElems = aElemsP;
    lpElemsP->nElems++;

    return TRUE;
}

/* Koniec interfejsu topoLpElems */

/* Interfejs dla topoElem */

int topoElem_inicjuj(TopoElem* elemP) {
    if (elemP == NULL)
        return FALSE;

    elemP->id = -1;
    elemP->mslink = -1;

    elemP->offset = -1;

    elemP->bPunkt = FALSE;

    elemP->nPunkty = 0;
    elemP->aPunkty = NULL;

    elemP->aTekst = NULL;

    elemP->podElemP = NULL;
    elemP->nadElemP = NULL;

    elemP->nPodElem = 0;
    elemP->nNadElem = 0;

    elemP->zakres = NULL;

    elemP->defP = NULL;

    topoLpElems_inicjuj(&elemP->nadElems);
    topoLpElems_inicjuj(&elemP->podElems);

    return TRUE;
}

int topoElem_zwolnij(TopoElem* elemP) {
    if (elemP == NULL)
        return FALSE;

    if (elemP->aPunkty != NULL)
        free(elemP->aPunkty); /* zwolnij pamiêæ zajmowan¹ przez punkty */

    if (elemP->aTekst != NULL)
        free(elemP->aTekst); /* zwolnij pamiêæ zajmowan¹ przez tekst */

    if (elemP->zakres != NULL)
        free(elemP->zakres); /* zwolnij pamiêæ zajmowan¹ przez zakres */

    topoLpElems_zwolnij(&elemP->nadElems);
    topoLpElems_zwolnij(&elemP->podElems);

    return TRUE;
}

int topoElem_ustawTekst(TopoElem* elemP, char* tekst) {
    int nTekst = 0;

    if (elemP == NULL) /* elemP nie mo¿e byæ null */
        return FALSE;

    nTekst = strlen(tekst);

    elemP->aTekst = (char*) calloc(nTekst + 1, sizeof (char));

    if (elemP->aTekst == NULL) /* zabrak³o pamiêci na tekst */
        return FALSE;

    strcpy(elemP->aTekst, tekst);
    elemP->aTekst[nTekst] = '\0';

    return TRUE;
}

int topoElem_pobierzTekst(TopoElem* elemP, char* tekst) {
    if (elemP == NULL) /* elemP nie mo¿e byæ null */
        return FALSE;

    if (tekst == NULL)
        return FALSE;

    if (elemP->aTekst == NULL)
        strcpy(tekst, "");
    else
        strcpy(tekst, elemP->aTekst);

    return TRUE;
}

int topoElem_ustawZakresXY(TopoElem* elemP, double xMin, double yMin, double xMax, double yMax) {
    if (elemP == NULL)
        return FALSE;

    if (elemP->zakres == NULL) {
        elemP->zakres = (TopoZakres*) calloc(1, sizeof (TopoZakres));
        if (elemP->zakres == NULL)
            return FALSE;
    }

    elemP->zakres->xMin = xMin;
    elemP->zakres->yMin = yMin;
    elemP->zakres->xMax = xMax;
    elemP->zakres->yMax = yMax;

    return TRUE;
}

int topoElem_ustawZakres(TopoElem* elemP, TopoZakres* zakresP) {
    return topoElem_ustawZakresXY(elemP, zakresP->xMin, zakresP->yMin, zakresP->xMax, zakresP->yMax);
}

int topoElem_ustawPunktXY(TopoElem* elemP, double x, double y) {
    if (elemP == NULL)
        return FALSE;

    elemP->punkt.x = x;
    elemP->punkt.y = y;
    elemP->punkt.z = 0.0;

    return TRUE;
}

int topoElem_ustawPunkt(TopoElem* elemP, DPoint3d* punkt, double tolZakres) {
    TopoZakres zakres;

    if (punkt == NULL)
        return FALSE;

    /* dla elementów punktowych zdefiniujemy wirtualny zakres wed³ug tolerancji */

    topoZakres_wirtualny(&zakres, punkt, tolZakres);

    topoElem_ustawZakres(elemP, &zakres);

    if (punkt == NULL)
        return FALSE;

    elemP->bPunkt = TRUE;

    return topoElem_ustawPunktXY(elemP, punkt->x, punkt->y);
}

int topoElem_ustawPunkty(TopoElem* elemP, DPoint3d* aPunkty, int nPunkty) {
    int i = 0;
    TopoZakres zakres;
    double xMid, yMid;
    //double fObwod = 0.0, fPole = 0.0;

    if (elemP == NULL)
        return FALSE;

    if (nPunkty < 1 || aPunkty == NULL) /* musi byæ co najmniej jeden element */
        return FALSE;

    elemP->aPunkty = aPunkty;
    elemP->nPunkty = nPunkty;

    zakres.xMin = zakres.xMax = xMid = aPunkty[0].x;
    zakres.yMin = zakres.yMax = yMid = aPunkty[0].y;

    for (i = 1; i < nPunkty; i++)
        topoZakres_aktualizujXY(&zakres, aPunkty[i].x, aPunkty[i].y, aPunkty[i].x, aPunkty[i].y);

    topoElem_ustawZakresXY(elemP, zakres.xMin, zakres.yMin, zakres.xMax, zakres.yMax);

    //topoElem_ustawPunkt (elemP, zakres.xMin + (zakres.xMax - zakres.xMin) / 2.0, zakres.yMin + (zakres.yMax - zakres.yMin) / 2.0);
    topoElem_ustawPunktXY(elemP, zakres.xMin, zakres.yMin);

    if (mdlGeom_obliczCentroid(elemP->aPunkty, elemP->nPunkty, &elemP->punkt)) {
        elemP->bPunkt = mdlGeom_zawieraPunkt(&elemP->punkt, elemP->aPunkty, elemP->nPunkty);
    }

    return TRUE;
}

int topoElem_porownajXY(TopoElem* e1, TopoElem* e2) {
    if (e1->punkt.x < e2->punkt.x)
        return -1;
    else
        if (e1->punkt.x > e2->punkt.x)
        return 1;

    if (e1->punkt.y < e2->punkt.y)
        return -1;
    else
        if (e1->punkt.y > e2->punkt.y)
        return 1;

    return 0;
}

int topoElem_ustawNadElem(TopoElem* elemP, TopoElem* nadP) {
    if (elemP == NULL)
        return FALSE;

    elemP->nadElemP = nadP;

    if (nadP != NULL)
        elemP->nNadElem++;

    return TRUE;
}

int topoElem_ustawPodElem(TopoElem* elemP, TopoElem* podP) {
    if (elemP == NULL)
        return FALSE;

    elemP->podElemP = podP;

    if (podP != NULL)
        elemP->nPodElem++;

    return TRUE;
}

int topoElem_dodajNadElem(TopoElem* elemP, TopoElem* nadElemP) {
    if (elemP == NULL || nadElemP == NULL)
        return FALSE;

    topoElem_ustawNadElem(elemP, nadElemP);

    return topoLpElems_dodaj(&elemP->nadElems, nadElemP);
}

int topoElem_dodajPodElem(TopoElem* elemP, TopoElem* podElemP) {
    if (elemP == NULL || podElemP == NULL)
        return FALSE;

    topoElem_ustawPodElem(elemP, podElemP);

    return topoLpElems_dodaj(&elemP->podElems, podElemP);
}

int topoElem_zawieraPunkt(TopoElem* elemP, TopoElem* punktP) {
    if (elemP == NULL || punktP == NULL)
        return FALSE;

    return mdlGeom_zawieraPunkt(&punktP->punkt, elemP->aPunkty, elemP->nPunkty);
}

/* Koniec interfejsu topoElem */
