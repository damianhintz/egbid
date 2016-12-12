#include "topoLayer.h"
#include "..\Core.h"
#include "..\Aplikacja.h"
#include "..\TBD.h"

/* Intefejs dla topoLayer */

int topoLayer_inicjuj(LpTopoLayer defP) {
    if (defP == NULL)
        return FALSE;

    defP->nRodzaj = TOPO_ELEM_ID_None;
    strcpy(defP->sRodzaj, "");
    strcpy(defP->sOpis, "");
    strcpy(defP->sNazwa, "");

    strcpy(defP->sNadrzedny, "");
    defP->nNadrzedny = 0;
    strcpy(defP->sRelacjaNad, "");

    strcpy(defP->sPodrzedny, "");
    defP->nPodrzedny = 0;
    strcpy(defP->sRelacjaPod, "");

    strcpy(defP->sTabela, "");
    strcpy(defP->sTabTBD, "");

    defP->bBazaTBD = FALSE;
    defP->bReferencyjny = FALSE;
    defP->nWarstwa = 0;
    defP->tolZakres = mdlCnv_masterUnitsToUors(0.001);

    topoElems_inicjuj(&defP->elems);
    defP->nRozmiar = 0;
    defP->nBledy = 0;

    defP->aIds = NULL;
    defP->nIds = 0;
    defP->aMslinks = NULL;
    defP->nMslinks = 0;

    return TRUE;
}

int topoLayer_zwolnij(LpTopoLayer defP) {
    if (defP == NULL)
        return FALSE;

    if (defP->aIds != NULL)
        free(defP->aIds);

    if (defP->aMslinks != NULL)
        free(defP->aMslinks);

    return topoElems_zwolnij(&defP->elems);
}

int topoLayer_ustawRodzaj(LpTopoLayer defP, char* sRodzaj) {
    if (defP == NULL || sRodzaj == NULL)
        return FALSE;

    if (strcmp(sRodzaj, TOPO_ELEM_STRING_Obszar) == 0) {
        strcpy(defP->sRodzaj, sRodzaj);
        defP->nRodzaj = TOPO_ELEM_ID_Obszar;
    } else
        if (strcmp(sRodzaj, TOPO_ELEM_STRING_Tekst) == 0) {
        strcpy(defP->sRodzaj, sRodzaj);
        defP->nRodzaj = TOPO_ELEM_ID_Tekst;
    } else
        if (strcmp(sRodzaj, TOPO_ELEM_STRING_Linia) == 0) {
        strcpy(defP->sRodzaj, sRodzaj);
        defP->nRodzaj = TOPO_ELEM_ID_Linia;
    } else
        if (strncmp(sRodzaj, TOPO_ELEM_STRING_Symbol, 6) == 0) {
        if (topoUtil_wczytajString(sRodzaj, defP->sRodzaj, defP->sOpis))
            defP->nRodzaj = TOPO_ELEM_ID_Symbol;
        else
            defP->nRodzaj = TOPO_ELEM_ID_None;
    } else {
        defP->nRodzaj = TOPO_ELEM_ID_None;
    }

    return defP->nRodzaj != TOPO_ELEM_ID_None;
}

int topoLayer_ustawNazwa(LpTopoLayer defP, char* sNazwa) {
    if (defP == NULL || sNazwa == NULL || strlen(sNazwa) == 0)
        return FALSE;

    strcpy(defP->sNazwa, sNazwa);

    return TRUE;
}

/* nazwa[liczba] */
int topoLayer_ustawNadrz(LpTopoLayer defP, char* sNazwa) {
    if (defP == NULL || sNazwa == NULL || strlen(sNazwa) == 0)
        return FALSE;

    //return topoUtil_wczytajInteger (sNazwa, defP->sNadrzedny, &defP->nNadrzedny);
    return topoUtil_wczytajString(sNazwa, defP->sNadrzedny, defP->sRelacjaNad);
}

/* nazwa[liczba] */
int topoLayer_ustawPodrz(LpTopoLayer defP, char* sNazwa) {
    if (defP == NULL || sNazwa == NULL || strlen(sNazwa) == 0)
        return FALSE;

    return topoUtil_wczytajInteger(sNazwa, defP->sPodrzedny, &defP->nPodrzedny);
}

int topoLayer_ustawWarstwa(LpTopoLayer defP, int nWarstwa) {
    if (defP == NULL)
        return FALSE;

    defP->nWarstwa = nWarstwa;

    return TRUE;
}

int topoLayer_ustawReferencyjny(LpTopoLayer defP, int bReferencyjny) {
    if (defP == NULL)
        return FALSE;

    defP->bReferencyjny = bReferencyjny;

    return TRUE;
}

int topoLayer_ustawTBD(LpTopoLayer defP, char* sTBD) {
    char topo[32];
    char tab[32];

    if (defP == NULL || sTBD == NULL)
        return FALSE;

    if (topoUtil_wczytajString(sTBD, topo, tab)) {
        if (strcmp(topo, "topo") == 0) {
            strcpy(defP->sTabela, tab);
            defP->bBazaTBD = TRUE;
        }
    }

    return TRUE;
}

int topoLayer_identyczny(LpTopoLayer opis1P, LpTopoLayer opis2P) {
    if (opis1P == NULL || opis2P == NULL)
        return FALSE;

    return opis1P->nRodzaj == opis2P->nRodzaj && opis1P->bReferencyjny == opis2P->bReferencyjny && opis1P->nWarstwa == opis2P->nWarstwa;
}

int topoLayer_porownaj(LpTopoLayer defP, int nRodzaj, int bReferencyjny, int nWarstwa) {
    if (defP == NULL)
        return FALSE;

    if (defP->nWarstwa == 0)
        nWarstwa = 0;

    return defP->nRodzaj == nRodzaj && defP->bReferencyjny == bReferencyjny && defP->nWarstwa == nWarstwa;
}

int topoLayer_porownajTBD(LpTopoLayer defP, int nRodzaj, int bReferencyjny, int nWarstwa, ULong nMslink) {
    int i = 0;
    int bTBD = FALSE;

    if (defP == NULL)
        return FALSE;

    for (i = 0; i < defP->nMslinks; i++) {
        if (defP->aMslinks[i] == nMslink) {
            bTBD = TRUE;
            break;
        }
    }

    if (defP->nWarstwa == 0)
        nWarstwa = 0;

    //Dla obiektow TBD warstwa nie ma znaczenia
    if (defP->bBazaTBD)
        return defP->nRodzaj == nRodzaj && defP->bReferencyjny == bReferencyjny && bTBD;
    else
        return defP->nRodzaj == nRodzaj && defP->bReferencyjny == bReferencyjny && defP->nWarstwa == nWarstwa && bTBD;
}

int topoLayer_inicjujElems(LpTopoLayer defP) {
    if (defP == NULL)
        return FALSE;

    return topoElems_inicjujN(&defP->elems, defP->nRozmiar);
}

/* topoLayer_wczytaj - wczytanie definicji klasy */
int topoLayer_wczytaj(LpTopoLayer defP, char* wiersz) {
    char rodzaj[256], nazwa[256], nadrz[256], podrz[256], ref, lev, topo[256];

    if (defP == NULL)
        return FALSE;

    //topoLayer_inicjuj (defP);

    if (7 != sscanf(wiersz, "def %s %s %s %s %d %d %s", rodzaj, nazwa, nadrz, podrz, &ref, &lev, topo)) {
        mdlUtil_wypiszInfo("topoLayer_wczytaj: napis definicji bledny");
        return FALSE;
    }

    topoLayer_ustawRodzaj(defP, rodzaj);
    topoLayer_ustawNazwa(defP, nazwa);
    topoLayer_ustawNadrz(defP, nadrz);
    topoLayer_ustawPodrz(defP, podrz);
    topoLayer_ustawWarstwa(defP, lev);
    topoLayer_ustawReferencyjny(defP, ref);
    topoLayer_ustawTBD(defP, topo);

    return TRUE;
}

/* Koniec interfejsu dla topoLayer */

/* Interfejs dla topoLayers */

int topoLayers_inicjuj(LpTopoLayers defsP) {
    if (defsP == NULL)
        return FALSE;

    defsP->aElems = NULL;
    defsP->nElems = 0;

    return TRUE;
}

int topoLayers_zwolnij(LpTopoLayers defsP) {
    if (defsP == NULL)
        return FALSE;

    if (defsP->aElems != NULL) {
        int i = 0;
        for (i = 0; i < defsP->nElems; i++)
            topoLayer_zwolnij(&defsP->aElems[i]);

        free(defsP->aElems);
    }

    return TRUE;
}

/* topoLayers_dodaj - dodanie definicji klasy */
int topoLayers_dodaj(LpTopoLayers defsP, LpTopoLayer defP) {
    TopoLayer* aElems = NULL;
    int i = 0;

    if (defsP == NULL || defP == NULL)
        return FALSE;

    aElems = (TopoLayer*) calloc(defsP->nElems + 1, sizeof (TopoLayer));

    if (aElems == NULL) {
        mdlUtil_dolaczBlad("topoLayers_dodaj", "za ma³o pamiêci");
        return FALSE;
    }

    for (i = 0; i < defsP->nElems; i++) //skopiuj stare elementy
        aElems[i] = defsP->aElems[i];

    aElems[defsP->nElems] = *defP; //przypisz ostatni element

    if (defsP->aElems != NULL)
        free(defsP->aElems);

    defsP->aElems = aElems;
    defsP->nElems++;

    return TRUE;
}

int topoLayers_dodajDef(LpTopoLayers defsP, char* def, double tolZakres) {
    TopoLayer opis;

    if (defsP == NULL || def == NULL)
        return FALSE;

    topoLayer_inicjuj(&opis);
    opis.tolZakres = mdlCnv_masterUnitsToUors(tolZakres);

    if (!topoLayer_wczytaj(&opis, def))
        return FALSE;

    if (!topoLayers_dodaj(defsP, &opis))
        return FALSE;

    return TRUE;
}

/* topoLayers_wczytaj - wczytanie definicji klas z pliku ini */
int topoLayers_wczytaj(LpTopoLayers defsP) {
    FILE* file;
    char ininame[MAXFILELENGTH];

    if (defsP == NULL)
        return FALSE;

    strcpy(ininame, "");
    mdlApp_getIniPath(ininame);

    if ((file = mdlTextFile_open(ininame, TEXTFILE_READ)) != NULL) {
        char row[1024];

        strcpy(row, "");

        while (NULL != mdlTextFile_getString(row, 1024, file, TEXTFILE_DEFAULT)) {
            if (strlen(row) == 0)
                /* pomiñ puste wiersze */
                continue;
            else
                if (row[0] == '#' || row[0] == ';')
                /* pomiñ wiersze zaczynaj¹ce siê od znaku # lub ; */
                continue;
            else {
                char cmd[256];

                strcpy(cmd, "");
                sscanf(row, "%s", cmd);

                if (strcmp(cmd, "def") == 0) {
                    TopoLayer opis;

                    topoLayer_inicjuj(&opis);

                    if (topoLayer_wczytaj(&opis, row)) {
                        if (TRUE != topoLayers_dodaj(defsP, &opis)) {
                            //sprintf (g_nfomsg, "%s %s %s %s", opis.sRodzaj, opis.sNazwa, opis.sOpis, opis.sNadrzedny);
                            //mdlUtil_wypiszInfo (g_nfomsg);
                        }
                    }
                } else
                    ;
            }
        }

        if (SUCCESS == mdlTextFile_close(file))
            ;
    } else {
        mdlUtil_dolaczBlad("topoLayers_wczytaj", "brak pliku konfiguracyjnego");
        return FALSE;
    }

    return TRUE;
}

/* topoLayers_szukajNazwy - szukaj definicji klasy wed³ug jej nazwy */
int topoLayers_szukajNazwy(LpTopoLayers defsP, char* sNazwa, LpTopoLayer* defP) {
    int i = 0;

    if (defsP == NULL)
        return FALSE;

    for (i = 0; i < defsP->nElems; i++) {
        if (strcmp(defsP->aElems[i].sNazwa, sNazwa) == 0) {
            *defP = &defsP->aElems[i];
            return TRUE;
        }
    }

    return FALSE;
}

int topoLayers_inicjujElems(LpTopoLayers defsP) {
    int i = 0;

    if (defsP == NULL)
        return FALSE;

    for (i = 0; i < defsP->nElems; i++) {
        if (!topoLayer_inicjujElems(&defsP->aElems[i]))
            return FALSE;
    }

    return TRUE;
}

/* topoLayers_szukajReferencyjny - szukaj klasy z pliku referencyjnego */
int topoLayers_szukajReferencyjny(LpTopoLayers defsP, int* bReferencyjny) {
    int i = 0;

    if (defsP == NULL || bReferencyjny == NULL)
        return FALSE;

    *bReferencyjny = FALSE;

    for (i = 0; i < defsP->nElems; i++) {
        if (defsP->aElems[i].bReferencyjny) {
            *bReferencyjny = TRUE;
            break;
        }
    }

    return TRUE;
}

/* topoLayers_szukajTBD - szukaj klasy TBD */
int topoLayers_szukajTBD(LpTopoLayers defsP, int* bTBD) {
    int i = 0;

    if (defsP == NULL || bTBD == NULL)
        return FALSE;

    *bTBD = FALSE;

    for (i = 0; i < defsP->nElems; i++) {
        if (defsP->aElems[i].bBazaTBD) {
            *bTBD = TRUE;
            break;
        }
    }

    return TRUE;
}

/* topoLayers_szukajIdentyczny - szukaj definicji klasy o podanych atrybutach */
int topoLayers_szukajIdentyczny(LpTopoLayers defsP, int nRodzaj, int bReferencyjny, int nWarstwa, LpTopoLayer* defP) {
    int i = 0;

    if (defsP == NULL)
        return FALSE;

    for (i = 0; i < defsP->nElems; i++) {
        if (topoLayer_porownaj(&defsP->aElems[i], nRodzaj, bReferencyjny, nWarstwa)) {
            *defP = &defsP->aElems[i];
            return TRUE;
        }
    }

    return FALSE;
}

/* topoLayers_szukajIdentycznyTBD - szukaj definicji klasy o podanych atrybutach */
int topoLayers_szukajIdentycznyTBD(LpTopoLayers defsP, int nRodzaj, int bReferencyjny, int nWarstwa, ULong nMslink, LpTopoLayer* defP) {
    int i = 0;

    if (defsP == NULL)
        return FALSE;

    for (i = 0; i < defsP->nElems; i++) {
        if (topoLayer_porownajTBD(&defsP->aElems[i], nRodzaj, bReferencyjny, nWarstwa, nMslink)) {
            *defP = &defsP->aElems[i];
            return TRUE;
        }
    }

    return FALSE;
}

int topoLayers_wypisz(LpTopoLayers defsP) {
    char msg[256];
    int i = 0;

    if (defsP == NULL)
        return FALSE;

    for (i = 0; i < defsP->nElems; i++) {
        TopoLayer* defP = &defsP->aElems[i];
        int nElems = 0; //, nRozmiar = defP->nRozmiar;
        char topo[64];

        sprintf(topo, "topo[%s]", defP->sTabTBD);
        nElems = defP->elems.nElems;

        sprintf(msg, "definicja: [%s(%s) %s %s L%d N%d]", defP->sRodzaj, defP->sNazwa, defP->bReferencyjny ? "ref" : "mtr", defP->bBazaTBD ? topo : "dgn", defP->nWarstwa, nElems);
        mdlUtil_wypiszInfo(msg);
    }

    return TRUE;
}

int topoLayers_conn(LpTopoLayers defsP) {
    char msg[256];
    int i = 0;

    if (defsP == NULL)
        return FALSE;

    mdlUtil_wypiszInfo("Trwa inicjowanie macierzy...");

    for (i = 0; i < defsP->nElems; i++) {
        TopoLayer* defP = &defsP->aElems[i];

        /* powinien byc co najmniej jeden elemenent danej klasy */
        if (defP->elems.nElems < 1)
            continue;

        if (!topoElems_inicjujMatrix(&defP->elems))
            ;
    }

    mdlUtil_wypiszInfo("Trwa budowanie relacji...");

    //dla kazdej definicji ktora zawiera relacje do obiektu nadrzednego
    for (i = 0; i < defsP->nElems; i++) {
        TopoLayer* defP = &defsP->aElems[i];

        TopoLayer* nadDefP = NULL; //definicja klasy nadrzednej
        //TopoLayer* podDefP = NULL; //definicja klasy podrzednej
        char relacja[64];

        if (defP->elems.nElems < 1) //pomijamy klasy bez obiektow
            continue;

        if (strcmp(defP->sRelacjaNad, "zawieranie") == 0) {
            strcpy(relacja, "zawiera w");
        } else
            if (strcmp(defP->sRelacjaNad, "przecinanie") == 0) {
            strcpy(relacja, "przecina z");
        } else
            if (strcmp(defP->sRelacjaNad, "zgodny") == 0) {
            strcpy(relacja, "zgodny z");
        } else
            if (strcmp(defP->sRelacjaNad, "") == 0) {
            //brak relacji do klasy nadrzednej
            continue;
        } else {
            //nierozpoznana nazwa relacji
            continue;
        }

        sprintf(msg, "\t%s %s %s", defP->sNazwa, relacja, defP->sNadrzedny);
        mdlUtil_wypiszInfo(msg);

        //szukaj definicji klasy nadrzednej
        topoLayers_szukajNazwy(defsP, defP->sNadrzedny, &nadDefP);
        //topoLayers_szukajNazwy (defsP, defP->sPodrzedny, &podDefP);

        if (nadDefP) {
            if (nadDefP->elems.nElems > 0) {
                //if (defP->nRodzaj == TOPO_ELEM_ID_Obszar && nadDefP->nRodzaj == TOPO_ELEM_ID_Obszar)
                if (nadDefP->nRodzaj == TOPO_ELEM_ID_Tekst) {
                    topoElems_relacjePunktPunkt(&nadDefP->elems, &defP->elems);
                } else
                    if (nadDefP->nRodzaj == TOPO_ELEM_ID_Obszar) {
                    topoElems_relacjaZawieraniePunktObszar(&nadDefP->elems, &defP->elems);
                } else
                    mdlUtil_wypiszInfo("\tbrak implementacji relacji");
            }
        } else
            mdlUtil_dolaczBlad("topoLayers_relacje", "brak definicji klasy nadrzêdnej");
        /*
        if (podDefP && podDefP->elems.nElems > 0)
        {
                if (defP->nRodzaj == TOPO_ELEM_ID_Obszar && podDefP->nRodzaj == TOPO_ELEM_ID_Tekst)
                {
                        sprintf (msg, "\t%s -> %s", defP->sNazwa, podDefP->sNazwa);
                        mdlUtil_wypiszInfo (msg);
                        topoElems_matrixPointInPolygon (&defP->elems, &podDefP->elems);
                }
        }
         */
    }

    return TRUE;
}

/* Koniec interfejsu dla topoLayers */
