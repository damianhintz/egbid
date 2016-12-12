/* topoOgrodzenie.mc */

#include "topoOgrodzenie.h"
#include "..\Core.h"
#include "..\Aplikacja.h"
#include "..\TBD.h"
//#include "..\mdlCore.h"

/* Interfejs dla topoOgrodzenie */

int topoOgrodzenie_inicjuj(LpTopoOgrodzenie ogrodzenieP) {
    if (ogrodzenieP == NULL)
        return FALSE;

    ogrodzenieP->nSelected = 0;
    ogrodzenieP->aOffsets = NULL;
    ogrodzenieP->aFileNums = NULL;

    return topoLayers_inicjuj(&ogrodzenieP->definicje);
}

/* topoOgrodzenie_zwolnij */
int topoOgrodzenie_zwolnij(LpTopoOgrodzenie ogrodzenieP) {
    if (ogrodzenieP == NULL)
        return FALSE;

    if (ogrodzenieP->aOffsets != NULL)
        free(ogrodzenieP->aOffsets);

    if (ogrodzenieP->aFileNums != NULL)
        free(ogrodzenieP->aFileNums);

    topoLayers_zwolnij(&ogrodzenieP->definicje);

    return TRUE;
}

int topoOgrodzenie_powiazPunktyDoPoligonow(TopoElems* aParentsP, TopoElems* aChildsP) {
    int i = 0, j = 0;

    if (aParentsP == NULL || aChildsP == NULL)
        return FALSE;

    for (i = 0; i < aParentsP->nElems; i++) {
        TopoElem* aParentP = &aParentsP->aElems[i];

        for (j = 0; j < aChildsP->nElems; j++) {
            TopoElem* aChildP = &aChildsP->aElems[j];

            if (mdlGeom_zawieraPunkt(&aChildP->punkt, aParentP->aPunkty, aParentP->nPunkty)) {
                topoElem_ustawNadElem(aChildP, aParentP);
                topoElem_ustawPodElem(aParentP, aChildP);
            }
        }
    }

    return TRUE;
}

int topoOgrodzenie_powiazPoligonyDoPoligonow(TopoElems* aParentsP, TopoElems* aChildsP) {
    int i = 0, j = 0;

    if (aParentsP == NULL || aChildsP == NULL)
        return FALSE;

    for (i = 0; i < aParentsP->nElems; i++) {
        TopoElem* aParentP = &aParentsP->aElems[i];

        for (j = 0; j < aChildsP->nElems; j++) {
            TopoElem* aChildP = &aChildsP->aElems[j];

            if (mdlGeom_przecinajaObszary(aChildP->aPunkty, aChildP->nPunkty, aParentP->aPunkty, aParentP->nPunkty)) {
                topoElem_dodajNadElem(aChildP, aParentP);
            }
        }
    }

    return TRUE;
}

int topoOgrodzenie_load(LpTopoOgrodzenie ogrodzenieP) {
    char msg[256];
    MSElementDescr* edP = NULL;
    int i = 0;
    ULong id, mslink;

    char tekst[256];
    DPoint3d origin;

    int bAllowLocked = FALSE;
    int bAllowTBD = FALSE;

    LpTopoLayers defsP = NULL;

    if (NULL == ogrodzenieP)
        return FALSE;

    /* kolekcja definicji klas */
    defsP = &ogrodzenieP->definicje;

    /* jezeli jakas klasa jest referencyjna to wlaczamy przeszukiwanie plikow referencyjnych dla ogrodzenia */
    topoLayers_szukajReferencyjny(defsP, &bAllowLocked);

    /* jezeli jakas klasa jest TBD to trzeba zaladowac obiekty tej klasy do pamieci */
    topoLayers_szukajTBD(defsP, &bAllowTBD);

    if (bAllowTBD) {
        char querySelect[256];
        char queryCount[256];
        long* ids = NULL;
        long num = 0;

        /* wczytanie tabeli feature */
        mdlUtil_wypiszInfo("Trwa analizowanie tabeli feature...");

        for (i = 0; i < defsP->nElems; i++) {
            TopoLayer* defP = &defsP->aElems[i];

            if (defP->bBazaTBD) {
                sprintf(msg, "Trwa wczytywanie bazy danych %s...", defP->sTabela);
                mdlUtil_wypiszInfo(msg);
                //sprintf (querySelect, "select mslink from feature where left(tablename,4)='%s'", defP->sTabela);
                //sprintf (queryCount, "select count(*) from feature where left(tablename,4)='%s'", defP->sTabela);
                sprintf(querySelect, "select mslink from feature where tablename='%s'", defP->sTabela);
                sprintf(queryCount, "select count(*) from feature where tablename='%s'", defP->sTabela);

                /* obiekt klasy topo moze miec rozne identyfikatory mslink ktore odpowiadaja jednej tabeli w bazie mdb */
                if (tbdMdb_kwerendaWczytajIdentyfikatory(querySelect, queryCount, &ids, &num)) {
                    defP->aMslinks = ids;
                    defP->nMslinks = num;

                    sprintf(msg, "Wczytane identyfikatory mslink %d", num);
                    mdlUtil_wypiszInfo(msg);
                }

                /* odczytywanie rzeczywistej nazwy tabeli */
                //sprintf (querySelect, "select distinct tablename from feature where left(tablename,4)='%s'", defP->sTabela);
                sprintf(querySelect, "select distinct tablename from feature where tablename='%s'", defP->sTabela);
                if (tbdMdb_kwerendaWartoscString(querySelect, defP->sTabTBD)) {
                    sprintf(msg, "Trwa wczytywanie bazy danych %s...", defP->sTabTBD);
                    mdlUtil_wypiszInfo(msg);

                    //ustalamy schemat bazy danych (w nowym schemacie dodano do nazw tabel _X, gdzie X jest zmienne
                    defP->bNowySchemat = (defP->sTabTBD[strlen(defP->sTabTBD) - 2] == '_');

                    /* wczytywanie identyfikatorow obiektow */
                    sprintf(querySelect, "select id from %s", defP->sTabTBD);
                    sprintf(queryCount, "select count(*) from %s", defP->sTabTBD);

                    if (tbdMdb_kwerendaWczytajIdentyfikatory(querySelect, queryCount, &ids, &num)) {
                        defP->aIds = ids;
                        defP->nIds = num;

                        sprintf(msg, "Wczytane identyfikatory id %d", num);
                        mdlUtil_wypiszInfo(msg);
                    }
                } else
                    mdlUtil_wypiszInfo("tbdMdb_queryName: niepoprawne");
            }
        }
    }

    /* inicjowanie ogrodzenia */
    mdlState_startFenceCommand(topoOgrodzenie_loadFunc, NULL, NULL, NULL, 0, 0, FENCE_NO_CLIP);

    mdlLocate_init();

    /* czy przeszukiwac pliki referencyjne */
    if (bAllowLocked)
        mdlLocate_allowLocked();
    else
        mdlLocate_normal();

    /* odznaczenie wybranych obiektow */
    mdlSelect_freeAll();

    mdlUtil_wypiszInfo("Trwa selekcjonowanie elementów...");
    mdlUtil_msgPrint("Trwa selekcjonowanie elementów...");

    /* przetwarzanie elementów w ogrodzeniu */
    if (SUCCESS == mdlFence_process(ogrodzenieP))
        ;

    /* odœwie¿ widok */
    //if (SUCCESS == mdlView_updateSingle (tcb->lstvw)) ;

    /* przetwarzanie wybranych elementów */
    if (SUCCESS != mdlSelect_returnPositions(&ogrodzenieP->aOffsets, &ogrodzenieP->aFileNums, &ogrodzenieP->nSelected)) {
        mdlUtil_wypiszInfo("Uwaga! Brak obiektów spe³niaj¹cych kryteria definicji klas.");
        mdlUtil_wypiszInfo("Pamiêtaj o wybraniu ogrodzenia.");
        return FALSE;
    }

    /* ten fragment jest potrzebny, bez niego program siê wyk³ada */
    mdlFence_clear(FALSE);

    if (!topoLayers_inicjujElems(&ogrodzenieP->definicje)) {
        return FALSE;
    }

    mdlUtil_msgPrint("Trwa wczytywanie elementów...");
    mdlUtil_wypiszInfo("Trwa wczytywanie elementów...");

    for (i = 0; i < ogrodzenieP->nSelected; i++) {
        NumerPlikuDgn modelRefP;
        ULong filePos;
        int nType, nRodzaj = TOPO_ELEM_ID_None, bReferencyjny = FALSE, bTBD = FALSE;
        UInt32 uLevel;
        //UInt32 uWeight, uColor;
        //Int32 nStyle;
        TopoElem elem;
        DPoint3d* aPunkty = NULL;
        int nPunkty = 0;

        if (i % 16 == 0) {
            sprintf(msg, "%d/%d...", i, ogrodzenieP->nSelected);
            mdlUtil_msgPrint(msg);
        }

        modelRefP = ogrodzenieP->aFileNums[i];
        filePos = ogrodzenieP->aOffsets[i];

        if (0 == mdlElmdscr_read(&edP, filePos, modelRefP, 0, NULL)) {
            mdlUtil_dolaczBlad("topoOgrodzenie_load", "nie mo¿na odczytaæ elementu");
            continue;
        }

        //mdlElem_getTypeAndLevel (edP, modelRefP, &nType, &uLevel);
        obiektDgn_wczytajAtrybuty(edP, modelRefP, &nType, &uLevel, NULL, NULL, NULL);
        //mdlElem_getSymbology (edP, &uColor, &uWeight, &nStyle);

        topoElem_inicjuj(&elem);

        if (tbdDgn_wczytajMslinkId(&mslink, &id, NULL, edP)) {
            bTBD = TRUE;
            elem.id = id;
            elem.mslink = mslink;
        }

        elem.offset = filePos;
        elem.filenum = modelRefP;

        aPunkty = NULL;
        nPunkty = 0;

        bReferencyjny = modelRefP != MASTERFILE;
        topoUtil_typNaRodzaj(nType, &nRodzaj);

        elem.defP = NULL;

        if (nRodzaj != TOPO_ELEM_ID_None) {
            LpTopoLayer defP = NULL;

            if (bTBD)
                topoLayers_szukajIdentycznyTBD(&ogrodzenieP->definicje, nRodzaj, bReferencyjny, uLevel, mslink, &defP);
            else
                topoLayers_szukajIdentyczny(&ogrodzenieP->definicje, nRodzaj, bReferencyjny, uLevel, &defP);

            if (defP != NULL) {
                /* element nalezy do klasy defP */
                elem.defP = defP;

                switch (nRodzaj) {
                    case TOPO_ELEM_ID_Linia:
                    {
                        if (NULL != (aPunkty = mdlGeom_pobierzPunktyWszystkie(edP, modelRefP, &nPunkty))) {
                            topoElem_ustawPunkty(&elem, aPunkty, nPunkty);
                            if (!topoElems_dodajElem(&defP->elems, &elem))
                                defP->nBledy++;
                        } else
                            defP->nBledy++;
                    }
                        break;
                    case TOPO_ELEM_ID_Obszar:
                    {
                        if (NULL != (aPunkty = mdlGeom_pobierzPunktyWszystkie(edP, modelRefP, &nPunkty))) {
                            topoElem_ustawPunkty(&elem, aPunkty, nPunkty);
                            if (!topoElems_dodajElem(&defP->elems, &elem))
                                defP->nBledy++;
                        } else
                            defP->nBledy++;
                    }
                        break;
                    case TOPO_ELEM_ID_Tekst:
                    {
                        //if (SUCCESS == mdlElem_getTextAndPoint (edP, tekst, &origin))
                        if (obiektDgn_wczytajTekst(edP, tekst, &origin)) {
                            topoElem_ustawPunkt(&elem, &origin, defP->tolZakres);
                            topoElem_ustawTekst(&elem, tekst);
                            if (!topoElems_dodajElem(&defP->elems, &elem))
                                defP->nBledy++;
                        } else
                            defP->nBledy++;
                    }
                        break;
                    case TOPO_ELEM_ID_Symbol:
                    {
                        if (obiektDgn_wczytajSymbol(edP, tekst, &origin, modelRefP))
                            //if (SUCCESS == mdlElem_getCellAndPoint (edP, tekst, &origin, modelRefP))
                        {
                            if (strcmp(tekst, defP->sOpis) == 0) {
                                topoElem_ustawPunkt(&elem, &origin, defP->tolZakres);
                                if (!topoElems_dodajElem(&defP->elems, &elem))
                                    defP->nBledy++;
                            }
                        } else
                            defP->nBledy++;
                    }
                        break;
                }
            }
        }

        mdlSelect_removeElement(filePos, modelRefP, TRUE);

        mdlElmdscr_freeAll(&edP);
    }

    /* odœwie¿ widok */
    //if (SUCCESS == mdlView_updateSingle (tcb->lstvw)) ;

    topoLayers_conn(&ogrodzenieP->definicje);

    return TRUE;
}

/* topoOgrodzenie_loadFunc - wybieranie elementów */
int topoOgrodzenie_loadFunc(LpTopoOgrodzenie ogrodzenieP) {
    MSElementDescr* edP = NULL;
    NumerPlikuDgn modelRefP;
    ULong filePos;
    int nType, nRodzaj = TOPO_ELEM_ID_None, bReferencyjny = FALSE, bTBD = FALSE;
    UInt32 uLevel;
    ULong id, mslink;

    filePos = mdlElement_getFilePos(FILEPOS_CURRENT, &modelRefP);
    mdlElmdscr_read(&edP, filePos, modelRefP, 0, NULL);

    //mdlElem_getTypeAndLevel (edP, modelRefP, &nType, &uLevel);
    //mdlUtil_wypiszInfo("Wczytaj atrybuty obiektu");
    obiektDgn_wczytajAtrybuty(edP, modelRefP, &nType, &uLevel, NULL, NULL, NULL);
    //mdlElem_getSymbology (edP, &color, &weight, &style);
    //mdlUtil_wypiszInfo("Wczytaj mslink id tbd/bdot");
    bTBD = tbdDgn_wczytajMslinkId(&mslink, &id, NULL, edP);
    //mdlUtil_wypiszInfo("Koniec.");
    bReferencyjny = modelRefP != MASTERFILE;
    topoUtil_typNaRodzaj(nType, &nRodzaj);

    if (nRodzaj != TOPO_ELEM_ID_None) {
        LpTopoLayer defP = NULL;

        if (bTBD)
            topoLayers_szukajIdentycznyTBD(&ogrodzenieP->definicje, nRodzaj, bReferencyjny, uLevel, mslink, &defP);
        else
            topoLayers_szukajIdentyczny(&ogrodzenieP->definicje, nRodzaj, bReferencyjny, uLevel, &defP);

        if (defP != NULL) {
            /* dla symbolu trzeba odczytac jego nazwe */
            if (nRodzaj == TOPO_ELEM_ID_Symbol) {
                char tekst[256];
                DPoint3d origin;

                strcpy(tekst, "");

                //if (SUCCESS == mdlElem_getCellAndPoint (edP, tekst, &origin, modelRefP))
                if (obiektDgn_wczytajSymbol(edP, tekst, &origin, modelRefP)) {
                    if (strcmp(tekst, defP->sOpis) == 0) {
                        if (SUCCESS == mdlSelect_addElement(filePos, modelRefP, &edP->el, TRUE)) {
                            defP->nRozmiar++;
                        }
                    }
                }
            } else {
                if (SUCCESS == mdlSelect_addElement(filePos, modelRefP, &edP->el, TRUE)) {
                    defP->nRozmiar++;
                }
            }
        }
    }

    mdlElmdscr_freeAll(&edP);

    return SUCCESS;
}

/* Koniec interfejsu dla topoOgrodzenie */
