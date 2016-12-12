#include "topoIndex.h"
#include "..\Aplikacja.h"
#include "..\Core.h"

/* Interfejs dla topoElems */

int topoElems_inicjujN(TopoElems* elemsP, int nRozmiar) {
    char msg[128];

    if (elemsP == NULL) {
        mdlUtil_dolaczBlad("topoElems_inicjujN", "argument nie mo¿e byæ NULL");
        return FALSE;
    }

    elemsP->nElems = 0;
    elemsP->nRozmiar = nRozmiar;
    elemsP->zakres = NULL;
    elemsP->matrixP = NULL;
    elemsP->aElems = NULL;

    if (nRozmiar < 1)
        return TRUE;

    elemsP->aElems = (TopoElem*) calloc(nRozmiar, sizeof (TopoElem));

    if (elemsP->aElems == NULL) {
        sprintf(msg, "(%d,%d) brak pamiêci %ldkB (%d)", nRozmiar, sizeof (int), (sizeof (TopoElem) * nRozmiar) / 1024, mdlErrno);
        mdlUtil_dolaczBlad("topoElems_inicjujN", msg);
        return FALSE;
    }

    return TRUE;
}

int topoElems_inicjuj(TopoElems* elemsP) {
    return topoElems_inicjujN(elemsP, 0);
}

int topoElems_zwolnij(TopoElems* elemsP) {
    int i = 0;

    if (elemsP == NULL)
        return FALSE;

    if (elemsP->aElems != NULL) {
        for (i = 0; i < elemsP->nElems; i++)
            topoElem_zwolnij(&elemsP->aElems[i]);
        free(elemsP->aElems);
    }

    if (elemsP->zakres != NULL) {
        topoZakres_zwolnij(elemsP->zakres);
        free(elemsP->zakres);
    }

    if (elemsP->matrixP != NULL) {
        topoIndexMatrix_zwolnij(elemsP->matrixP);
        free(elemsP->matrixP);
    }

    return TRUE;
}

int topoElems_sortuj(TopoElems* elemsP, int (*topoElem_cmpFunc)(void *, void *)) {
    if (elemsP == NULL)
        return FALSE;

    mdlUtil_quickSort(elemsP->aElems, elemsP->nElems, sizeof (TopoElem), topoElem_cmpFunc);

    return TRUE;
}

int topoElems_sortujXY(TopoElems* elemsP) {
    return topoElems_sortuj(elemsP, topoElem_porownajXY);
}

int topoElems_wypisz(TopoElems* elemsP) {
    char msg[256];
    int i = 0;

    if (elemsP == NULL)
        return FALSE;

    for (i = 0; i < elemsP->nElems; i++) {
        TopoElem* e = &elemsP->aElems[i];

        if (e->zakres != NULL)
            sprintf(msg, "%.0f %.0f %.0f %.0f %.0f %.0f", e->punkt.x, e->punkt.y, e->zakres->xMin, e->zakres->yMin, e->zakres->xMax, e->zakres->yMax);
        else
            sprintf(msg, "%.0f %.0f", e->punkt.x, e->punkt.y);

        mdlUtil_wypiszInfo(msg);
    }

    return TRUE;
}

int topoElems_dodajElem(TopoElems* elemsP, TopoElem* elemP) {
    if (elemsP == NULL || elemP == NULL) {
        mdlUtil_dolaczBlad("topoElems_dodajElem", "argumenty nie mog¹ byæ NULL");
        return FALSE;
    }

    if (elemsP->nRozmiar <= elemsP->nElems) {
        mdlUtil_dolaczBlad("topoElems_dodajElem", "za du¿o elementów w kolekcji");
        return FALSE;
    }

    elemsP->aElems[elemsP->nElems] = *elemP;

    /* Aktualizuj zakres */
    if (elemP->zakres != NULL) {
        if (elemsP->zakres == NULL)
            elemsP->zakres = topoZakres_kopiuj(elemP->zakres);
        else {
            topoZakres_aktualizuj(elemsP->zakres, elemP->zakres);
        }
    }

    elemsP->nElems++;

    return TRUE;
}

int topoElems_inicjujMatrix(TopoElems* elemsP) {
    if (elemsP == NULL) {
        mdlUtil_dolaczBlad("topoElems_inicjujMatrix", "argument nie mo¿e byæ NULL");
        return FALSE;
    }

    if (elemsP->nElems < 1) {
        mdlUtil_dolaczBlad("topoElems_inicjujMatrix", "za ma³o elementów");
        return FALSE;
    }

    if (elemsP->matrixP != NULL) {
        mdlUtil_dolaczBlad("topoElems_inicjujMatrix", "macierz ju¿ zosta³a utworzona");
        return FALSE;
    }

    elemsP->matrixP = (TopoIndexMatrix*) malloc(sizeof (TopoIndexMatrix));

    if (elemsP->matrixP == NULL) {
        mdlUtil_dolaczBlad("topoElems_inicjujMatrix", "za ma³o pamiêci");
        return FALSE;
    }

    if (!topoIndexMatrix_inicjuj(elemsP->matrixP, elemsP))
        return FALSE;

    return topoIndexMatrix_load(elemsP->matrixP, elemsP);
}

/* Koniec interfejsu dla topoElems */

int topoElems_relacjaZawieraniePunktObszar(TopoElems* nadElemsP, TopoElems* podElemsP) {
    int i = 0, j = 0, k = 0, n = 0;
    TopoIndexMatrix* nadMatrixP = NULL;
    TopoIndexMatrix* podMatrixP = NULL;

    if (nadElemsP == NULL || podElemsP == NULL)
        return FALSE;

    nadMatrixP = nadElemsP->matrixP;
    podMatrixP = podElemsP->matrixP;

    if (nadMatrixP == NULL) {
        mdlUtil_dolaczBlad("topoElems_matrixPointInPolygon", "brak macierzy elementów nadrzêdnych");
        return FALSE;
    }

    /* dla wszystkich punktów*/
    for (k = 0; k < podElemsP->nElems; k++) {
        TopoElem* podElemP = &podElemsP->aElems[k];
        int ixMin = -1, jyMin = -1, ixMax = -1, jyMax = -1;

        /* szukaj poligonów w których znajduje siê punkt */

        /* obliczanie indeksów skrajnych komórek w jakich mo¿e byæ element */
        if (!topoMatrix_obliczSkrajneIndeksy(&ixMin, &jyMin, &ixMax, &jyMax, nadElemsP->matrixP, podElemP))
            return FALSE;

        /* macierz kontenerów */
        for (i = ixMin; i <= ixMax; i++) {
            for (j = jyMin; j <= jyMax; j++) {
                TopoElemsBin* binP = NULL;
                int iBin = topoIndexMatrix_pobierzIndeks(nadElemsP->matrixP, i, j);

                binP = &nadElemsP->matrixP->aBins[iBin];

                /* elementy z danego kontenera */
                for (n = 0; n < binP->nElems; n++) {
                    TopoElem* nadElemP = binP->aElems[n];

                    /* szybki test zakresów */
                    if (topoZakres_przecinaja(podElemP->zakres, nadElemP->zakres)) {
                        /* test zakresów to za ma³o mo¿e z³apaæ te¿ inne punkty a nam chodzi o te na koncach linii */
                        if (mdlGeom_zawieraPunkt(&podElemP->punkt, nadElemP->aPunkty, nadElemP->nPunkty)) {
                            topoElem_ustawNadElem(podElemP, nadElemP);
                            topoElem_dodajNadElem(podElemP, nadElemP);

                            topoElem_ustawPodElem(nadElemP, podElemP);
                            topoElem_dodajPodElem(nadElemP, podElemP);
                        }
                    }
                }
            }
        }
    }

    return TRUE;
}

int topoElems_relacjaZawieranieObszarObszar(TopoElems* nadElemsP, TopoElems* podElemsP) {
    //char msg[256];
    int i = 0, j = 0, k = 0, n = 0;
    TopoIndexMatrix* nadMatrixP = NULL;
    TopoIndexMatrix* podMatrixP = NULL;

    if (nadElemsP == NULL || podElemsP == NULL)
        return FALSE;

    nadMatrixP = nadElemsP->matrixP;
    podMatrixP = podElemsP->matrixP;

    if (nadMatrixP == NULL) {
        mdlUtil_dolaczBlad("topoElems_matrixPolygonInPolygon", "brak macierzy elementów nadrzêdnych");
        return FALSE;
    }

    /* dla wszystkich poligonów */
    for (k = 0; k < podElemsP->nElems; k++) {
        TopoElem* podElemP = &podElemsP->aElems[k];
        int ixMin = -1, jyMin = -1, ixMax = -1, jyMax = -1;

        /* szukaj poligonów w których znajduje siê polygon */

        /* obliczanie indeksów skrajnych komórek w jakich mo¿e byæ element */
        if (!topoMatrix_obliczSkrajneIndeksy(&ixMin, &jyMin, &ixMax, &jyMax, nadElemsP->matrixP, podElemP))
            return FALSE;

        /* macierz kontenerów */
        for (i = ixMin; i <= ixMax; i++) {
            for (j = jyMin; j <= jyMax; j++) {
                TopoElemsBin* binP = NULL;
                int iBin = topoIndexMatrix_pobierzIndeks(nadElemsP->matrixP, i, j);

                binP = &nadElemsP->matrixP->aBins[iBin];

                /* elementy z danego kontenera */
                for (n = 0; n < binP->nElems; n++) {
                    TopoElem* nadElemP = binP->aElems[n];

                    /* szybki test zakresów */
                    if (topoZakres_przecinaja(podElemP->zakres, nadElemP->zakres)) {
                        /* test na œrodek geometryczny */

                        if (podElemP->bPunkt) {
                            if (mdlGeom_zawieraPunkt(&podElemP->punkt, nadElemP->aPunkty, nadElemP->nPunkty)) {
                                topoElem_dodajNadElem(podElemP, nadElemP);
                            } else {
                                if (mdlGeom_przecinajaObszary(podElemP->aPunkty, podElemP->nPunkty, nadElemP->aPunkty, nadElemP->nPunkty)) {
                                    topoElem_dodajNadElem(podElemP, nadElemP);
                                }
                            }
                        } else {
                            if (mdlGeom_przecinajaObszary(podElemP->aPunkty, podElemP->nPunkty, nadElemP->aPunkty, nadElemP->nPunkty)) {
                                topoElem_dodajNadElem(podElemP, nadElemP);
                            }
                        }
                    }
                }
            }
        }
    }

    return TRUE;
}

int topoElems_relacjePunktLinia(TopoElems* nadElemsP, TopoElems* podElemsP, double tolZakres) {
    int i = 0, j = 0, k = 0, n = 0;
    TopoIndexMatrix* nadMatrixP = NULL;
    TopoIndexMatrix* podMatrixP = NULL;

    if (nadElemsP == NULL || podElemsP == NULL)
        return FALSE;

    nadMatrixP = nadElemsP->matrixP;
    podMatrixP = podElemsP->matrixP;

    if (nadMatrixP == NULL) {
        mdlUtil_dolaczBlad("topoElems_matrixPointInPolygon", "brak macierzy elementów nadrzêdnych");
        return FALSE;
    }

    /* dla wszystkich punktów*/
    for (k = 0; k < podElemsP->nElems; k++) {
        TopoElem* podElemP = &podElemsP->aElems[k];
        int ixMin = -1, jyMin = -1, ixMax = -1, jyMax = -1;

        /* szukaj poligonów w których znajduje siê punkt */

        /* obliczanie indeksów skrajnych komórek w jakich mo¿e byæ element */
        if (!topoMatrix_obliczSkrajneIndeksy(&ixMin, &jyMin, &ixMax, &jyMax, nadElemsP->matrixP, podElemP))
            return FALSE;

        /* macierz kontenerów */
        for (i = ixMin; i <= ixMax; i++) {
            for (j = jyMin; j <= jyMax; j++) {
                TopoElemsBin* binP = NULL;
                int iBin = topoIndexMatrix_pobierzIndeks(nadElemsP->matrixP, i, j);

                binP = &nadElemsP->matrixP->aBins[iBin];

                /* elementy z danego kontenera */
                for (n = 0; n < binP->nElems; n++) {
                    TopoElem* nadElemP = binP->aElems[n];

                    /* szybki test zakresów */
                    if (topoZakres_przecinaja(podElemP->zakres, nadElemP->zakres)) {
                        /* test zakresów to za ma³o mo¿e z³apaæ te¿ inne punkty a nam chodzi o te na koncach linii */
                        /* test na œrodek geometryczny */
                        //nZakres++;

                        /* czy zakres punktu linii przecina sie z zakresem punktu */
                        if (topoZakres_przecinajaPunkty(podElemP->zakres, nadElemP->aPunkty, nadElemP->nPunkty, tolZakres)) {
                            //topoElem_dodajNadElem (podElemP, nadElemP);
                            topoElem_dodajPodElem(nadElemP, podElemP);
                            //topoElem_ustawNadElem (podElemP, nadElemP);
                            //topoElem_ustawPodElem (nadElemP, podElemP);
                        }
                    }
                }
            }
        }
    }

    return TRUE;
}

int topoElems_relacjePunktPunkt(TopoElems* nadElemsP, TopoElems* podElemsP) {
    int i = 0, j = 0, k = 0, n = 0;
    TopoIndexMatrix* nadMatrixP = NULL;
    TopoIndexMatrix* podMatrixP = NULL;

    if (nadElemsP == NULL || podElemsP == NULL)
        return FALSE;

    nadMatrixP = nadElemsP->matrixP;
    podMatrixP = podElemsP->matrixP;

    if (nadMatrixP == NULL) {
        mdlUtil_dolaczBlad("topoElems_matrixPointInPolygon", "brak macierzy elementów nadrzêdnych");
        return FALSE;
    }

    /* dla wszystkich punktów*/
    for (k = 0; k < podElemsP->nElems; k++) {
        TopoElem* podElemP = &podElemsP->aElems[k];
        int ixMin = -1, jyMin = -1, ixMax = -1, jyMax = -1;

        /* obliczanie indeksów skrajnych komórek w jakich mo¿e byæ element */
        if (!topoMatrix_obliczSkrajneIndeksy(&ixMin, &jyMin, &ixMax, &jyMax, nadElemsP->matrixP, podElemP))
            return FALSE;

        /* macierz kontenerów */
        for (i = ixMin; i <= ixMax; i++) {
            for (j = jyMin; j <= jyMax; j++) {
                TopoElemsBin* binP = NULL;
                int iBin = topoIndexMatrix_pobierzIndeks(nadElemsP->matrixP, i, j);

                binP = &nadElemsP->matrixP->aBins[iBin];

                /* elementy z danego kontenera */
                for (n = 0; n < binP->nElems; n++) {
                    TopoElem* nadElemP = binP->aElems[n];

                    /* szybki test zakresów */
                    if (topoZakres_przecinaja(podElemP->zakres, nadElemP->zakres)) {
                        //topoElem_dodajNadElem (podElemP, nadElemP);
                        topoElem_dodajPodElem(nadElemP, podElemP);
                        //mdlUtil_wypiszInfo ("test");
                        //topoElem_ustawNadElem (podElemP, nadElemP);
                        //topoElem_ustawPodElem (nadElemP, podElemP);
                    }
                }
            }
        }
    }

    return TRUE;
}

/* Interfejs dla topoElemsBin */

int topoElemsBin_inicjuj(LpTopoElemsBin binP) {
    if (binP == NULL)
        return FALSE;

    binP->nElems = 0;
    binP->aElems = NULL;
    binP->nRozmiar = 0;

    return TRUE;
}

int topoElemsBin_zwolnij(LpTopoElemsBin binP) {
    if (binP == NULL)
        return FALSE;

    if (binP->aElems != NULL)
        free(binP->aElems);

    return TRUE;
}

int topoElemsBin_dodaj(LpTopoElemsBin binP) {
    if (binP == NULL)
        return FALSE;

    binP->nRozmiar++;

    return TRUE;
}

int topoElemsBin_dodajElem(LpTopoElemsBin binP, TopoElem* elemP) {
    if (binP == NULL)
        return FALSE;

    if (binP->nRozmiar <= binP->nElems)
        return FALSE;

    binP->aElems[binP->nElems++] = elemP;

    return TRUE;
}


/* Koniec interfejsu dla topoElemsBin */

/* Interfejs dla topoIndexMatrix */

int topoIndexMatrix_inicjuj(LpTopoIndexMatrix matrixP, LpTopoElems elemsP) {
    int i;
    double fX, fY;

    if (matrixP == NULL || elemsP == NULL) {
        mdlUtil_dolaczBlad("topoIndexMatrix_inicjuj", "argumenty nie mog¹ byæ NULL");
        return FALSE;
    }

    matrixP->elemsP = elemsP;

    //do obliczenia macierzy wymagany jest zakres elementów, UWAGA: punkty nie maj¹ zakresu
    if (elemsP->zakres == NULL || elemsP->nElems < 1) {
        mdlUtil_dolaczBlad("topoIndexMatrix_inicjuj", "brak zakresu lub za ma³o elementów");
        return FALSE;
    }

    matrixP->nBok = ((int) sqrt(elemsP->nElems / 2)) + 1;
    matrixP->nBins = matrixP->nBok * matrixP->nBok;

    /* liczba komórek jest ustalana z góry na podstawie liczby elementów */
    matrixP->aBins = (TopoElemsBin*) calloc(matrixP->nBins, sizeof (TopoElemsBin));

    if (matrixP->aBins == NULL) {
        mdlUtil_dolaczBlad("topoIndexMatrix_inicjuj", "za ma³o pamiêci");
        return FALSE;
    }

    //inicjowanie macierzy
    for (i = 0; i < matrixP->nBins; i++) {
        topoElemsBin_inicjuj(&matrixP->aBins[i]);
    }

    fX = (elemsP->zakres->xMax - elemsP->zakres->xMin) / matrixP->nBok;
    fY = (elemsP->zakres->yMax - elemsP->zakres->yMin) / matrixP->nBok;

    if (fX < 0 || fY < 0) //bok nie mo¿e byæ mniejszy lub równy od zera
        return FALSE;

    matrixP->fX = fX;
    matrixP->fY = fY;

    return TRUE;
}

int topoIndexMatrix_pobierzIndeks(LpTopoIndexMatrix matrixP, int i, int j) {
    if (matrixP == NULL)
        return -1;

    return i * matrixP->nBok + j; //wiersz i, kolumna j
}

int topoIndexMatrix_load(LpTopoIndexMatrix matrixP, LpTopoElems elemsP) {
    int i;

    /* zliczanie elementów w kontenerach */
    for (i = 0; i < elemsP->nElems; i++)
        topoIndexMatrix_dodaj(matrixP, &elemsP->aElems[i]);

    /* inicjowanie kontenerów elementami */
    if (!topoIndexMatrix_inicjujElems(matrixP, elemsP))
        return FALSE;

    for (i = 0; i < elemsP->nElems; i++)
        topoIndexMatrix_dodajElem(matrixP, &elemsP->aElems[i]);

    return TRUE;
}

int topoIndexMatrix_wypisz(LpTopoIndexMatrix matrixP) {
    char msg[256], msg2[256];
    int i, j;

    if (matrixP == NULL)
        return FALSE;

    for (i = 0; i < matrixP->nBok; i++) {
        strcpy(msg, "");

        for (j = 0; j < matrixP->nBok; j++) {
            int iBin = topoIndexMatrix_pobierzIndeks(matrixP, i, j); //wiersz i, kolumna j
            TopoElemsBin* binP = NULL;

            binP = &matrixP->aBins[iBin];

            sprintf(msg2, "%3d", binP->nElems);
            strcat(msg, msg2);
        }

        mdlUtil_wypiszInfo(msg);
    }

    return TRUE;
}

int topoIndexMatrix_zwolnij(LpTopoIndexMatrix matrixP) {
    int i = 0;

    if (matrixP == NULL)
        return FALSE;

    if (matrixP->aBins != NULL) {
        for (i = 0; i < matrixP->nBins; i++)
            topoElemsBin_zwolnij(&matrixP->aBins[i]);

        free(matrixP->aBins);
    }

    return TRUE;
}

int topoMatrix_obliczSkrajneIndeksy(int* xMin, int* yMin, int* xMax, int* yMax, LpTopoIndexMatrix matrixP, LpTopoElem elemP) {
    int iMin, jMin, iMax, jMax;
    TopoZakres zakresE;
    TopoZakres* zakresP;

    if (matrixP == NULL || elemP == NULL)
        return FALSE;

    if (elemP->zakres == NULL) {
        topoZakres_inicjuj(&zakresE, elemP->punkt.x, elemP->punkt.y, elemP->punkt.x, elemP->punkt.y);
        zakresP = &zakresE;
    } else
        zakresP = elemP->zakres;

    iMin = (int) ((zakresP->xMin - matrixP->elemsP->zakres->xMin) / matrixP->fX);
    jMin = (int) ((zakresP->yMin - matrixP->elemsP->zakres->yMin) / matrixP->fY);
    iMax = (int) ((zakresP->xMax - matrixP->elemsP->zakres->xMin) / matrixP->fX);
    jMax = (int) ((zakresP->yMax - matrixP->elemsP->zakres->yMin) / matrixP->fY);

    *xMin = topoUtil_obliczMinInt(iMin, iMax);
    *xMax = topoUtil_obliczMaxInt(iMin, iMax);
    *yMin = topoUtil_obliczMinInt(jMin, jMax);
    *yMax = topoUtil_obliczMaxInt(jMin, jMax);

    if (*xMin < 0) *xMin = 0;
    if (*xMax >= matrixP->nBok) *xMax = matrixP->nBok - 1;
    if (*yMin < 0) *yMin = 0;
    if (*yMax >= matrixP->nBok) *yMax = matrixP->nBok - 1;

    return TRUE;
}

int topoIndexMatrix_dodaj(LpTopoIndexMatrix matrixP, LpTopoElem elemP) {
    int i, j;
    int ixMin, jyMin, ixMax, jyMax;

    /* obliczanie indeksów skrajnych komórek w jakich mo¿e byæ element */
    if (!topoMatrix_obliczSkrajneIndeksy(&ixMin, &jyMin, &ixMax, &jyMax, matrixP, elemP))
        return FALSE;

    for (i = ixMin; i <= ixMax; i++) {
        for (j = jyMin; j <= jyMax; j++) {
            TopoElemsBin* binP = NULL;
            int iBin = topoIndexMatrix_pobierzIndeks(matrixP, i, j);

            binP = &matrixP->aBins[iBin];
            topoElemsBin_dodaj(binP);
        }
    }

    return TRUE;
}

int topoIndexMatrix_dodajElem(LpTopoIndexMatrix matrixP, LpTopoElem elemP) {
    int i, j;
    int ixMin, jyMin, ixMax, jyMax;

    /* obliczanie indeksów skrajnych komórek w jakich mo¿e byæ element */
    if (!topoMatrix_obliczSkrajneIndeksy(&ixMin, &jyMin, &ixMax, &jyMax, matrixP, elemP))
        return FALSE;

    for (i = ixMin; i <= ixMax; i++) {
        for (j = jyMin; j <= jyMax; j++) {
            TopoElemsBin* binP = NULL;
            int iBin = topoIndexMatrix_pobierzIndeks(matrixP, i, j);

            binP = &matrixP->aBins[iBin];
            topoElemsBin_dodajElem(binP, elemP);
        }
    }

    return TRUE;
}

int topoIndexMatrix_inicjujElems(LpTopoIndexMatrix matrixP, LpTopoElems elemsP) {
    int i, j, k;

    if (matrixP == NULL || elemsP == NULL)
        return FALSE;

    /* inicjowanie kontenerów elementami */
    for (i = 0; i < matrixP->nBok; i++) {
        for (j = 0; j < matrixP->nBok; j++) {
            TopoElemsBin* binP = NULL;
            int iBin = topoIndexMatrix_pobierzIndeks(matrixP, i, j); //wiersz i, kolumna j

            binP = &matrixP->aBins[iBin];

            /* pojedynczy kontener powinien mieæ minimum jeden element */
            if (binP->nRozmiar < 1)
                continue;

            binP->aElems = (TopoElem**) calloc(binP->nRozmiar, sizeof (TopoElem*));

            if (binP->aElems == NULL) {
                mdlUtil_dolaczBlad("topoIndexMatrix_inicjujElems", "za ma³o pamiêci");
                return FALSE;
            }

            for (k = 0; k < binP->nRozmiar; k++) {
                binP->aElems[k] = NULL; //narazie nie ma ¿adnego indeksu do elementu
            }
        }
    }

    return TRUE;
}

/* Koniec interfejsu dla topoIndexMatrix */

/* Intefejs dla topoUtil */

int topoUtil_typNaRodzaj(int nTyp, int* nRodzajP) {
    int nRodzaj = TOPO_ELEM_ID_None;

    if (nRodzajP == NULL)
        return FALSE;

    switch (nTyp) {
        case SHAPE_ELM:
        case CMPLX_SHAPE_ELM:
        {
            nRodzaj = TOPO_ELEM_ID_Obszar;
        }
            break;
        case TEXT_ELM:
        case TEXT_NODE_ELM:
        {
            nRodzaj = TOPO_ELEM_ID_Tekst;
        }
            break;
        case CELL_HEADER_ELM:
        case SHARED_CELL_ELM:
        {
            nRodzaj = TOPO_ELEM_ID_Symbol;
        }
            break;
        case LINE_ELM:
        case LINE_STRING_ELM:
        case CMPLX_STRING_ELM:
        {
            nRodzaj = TOPO_ELEM_ID_Linia;
        }
            break;
        default:
            nRodzaj = TOPO_ELEM_ID_None;
            break;
    }

    *nRodzajP = nRodzaj;

    return TRUE;
}

/* napis[integer] */
int topoUtil_wczytajInteger(char* sString, char* sNazwa, int* nLiczbaP) {
    int i = 0;

    if (sString == NULL)
        return FALSE;

    for (i = 0; i < strlen(sString); i++) {
        if (sString[i] == '[' || sString[i] == ']')
            sString[i] = ' ';
    }

    return 2 == sscanf(sString, "%s %d", sNazwa, nLiczbaP);
}

/* napis[string] */
int topoUtil_wczytajString(char* sString, char* sNazwa, char* sOpis) {
    int i = 0;

    if (sString == NULL)
        return FALSE;

    for (i = 0; i < strlen(sString); i++) {
        if (sString[i] == '[' || sString[i] == ']')
            sString[i] = ' ';
    }

    return 2 == sscanf(sString, "%s %s", sNazwa, sOpis);
}

int topoLoad_elemBS(TopoElems* elemsP, double value, int left, int right) {
    int mid;

    if (elemsP == NULL)
        return FALSE;

    while (left <= right) {
        mid = left + right / 2;

        if (elemsP->aElems[mid].zakres->xMax == value)
            break;

        if (value < elemsP->aElems[mid].zakres->xMax)
            right = mid - 1;
        else
            left = mid + 1;
    }

    return mid;
}

int topoLoad_elemsBSP(TopoElems* elemsP) {
    return elemsP != NULL;
}

int topoUtil_obliczMinInt(int x1, int x2) {
    return x1 < x2 ? x1 : x2;
}

double topoUtil_obliczMin(double x1, double x2) {
    return x1 < x2 ? x1 : x2;
}

int topoUtil_obliczMaxInt(int x1, int x2) {
    return x1 > x2 ? x1 : x2;
}

double topoUtil_obliczMax(double x1, double x2) {
    return x1 > x2 ? x1 : x2;
}

/* Koniec intefejsu dla topoUtil */
