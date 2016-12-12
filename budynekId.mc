#include "budynekId.h"
#include "main.h"

const char* _egib = "EGiB_lokalnyId";

int budynek_dodajId(ULong id, ULong mslink, char* wartosc, int pelna) {
    char msg[256];
    char tablename[256], query[256], value[256];

    //weryfikacja mslink
    sprintf(query, "select tablename from feature where mslink = %d", mslink);

    if (SUCCESS != mdlDB_sqlQuery(tablename, query)) {
        sprintf(msg, "uwaga: brak w bazie tabeli z mslink %d", mslink);
        mdlUtil_dolaczBlad("budynek_dodajId", msg);
        return FALSE;
    }

    //weryfikacja nazwy tabeli
    if (strcmp(tablename, "OT_BUBD_A") != 0) {
        sprintf(msg, "uwaga: nazwa tabeli niezgodna %s <> OT_BUBD_A", tablename);
        mdlUtil_dolaczBlad("budynek_dodajId", msg);
        return FALSE;
    }

    //weryfikacja zrodla danych
    sprintf(query, "SELECT id FROM %s WHERE id=%d AND x_zrodloDanychG='EGiB'", tablename, id);

    if (SUCCESS != mdlDB_sqlQuery(value, query)) {
        sprintf(msg, "info: pominieto budynek nie EGiB (%d, '%s')", id, wartosc);
        mdlFile_appendLine(msg);
        return FALSE;
    }

    //sprawdzenie czy dane id i wartosc juz istnieje
    sprintf(query, "SELECT id, %s FROM OT_BUBD_A_EGiB WHERE id=%d AND EGiB='%s'",
            _egib, id, wartosc);

    if (SUCCESS == mdlDB_sqlQuery(value, query)) {
        if (pelna) {
            sprintf(msg, "uwaga: pominieto powtorzony wpis (%d, %s)", id, wartosc);
            mdlUtil_wypiszInfo(msg);
        } else {
            sprintf(msg, "info: pominieto juz istniejacy wpis (%d, %s)", id, wartosc);
        }
        mdlFile_appendLine(msg);

        return FALSE;
    }

    //aktualizacja tabeli, dodanie id budynku
    sprintf(query, "INSERT INTO OT_BUBD_A_EGiB (id, poz, %s) VALUES (%ld, 1, '%s')",
            _egib, id, wartosc);

    if (SUCCESS != mdlDB_processSQL(query)) {
        sprintf(msg, "uwaga: nie dodano id budynku %d", id);
        mdlUtil_dolaczBlad("budynek_dodajId", msg);
        mdlFile_appendLine(msg);
        mdlFile_appendLine(query);
        return FALSE;
    }

    return TRUE;
}

int budynek_aktualizujDefinicje(LpTopoLayers defsP, int pelna) {
    char msg[256];
    TopoLayer* budynekDef = NULL, *idDef = NULL;
    TopoElems* budynekElemsP = NULL, *idElemsP = NULL;
    int i = 0, j = 0;
    int n0 = 0, n1 = 0, n2 = 0, n3 = 0;
    int nL = 0, nW = 0, nT = 0, nP = 0;

    if (defsP == NULL) {
        mdlUtil_wypiszInfo("uwaga: brak listy definicji (NULL)");
        return FALSE;
    }

    if (!topoLayers_szukajNazwy(defsP, "budynek", &budynekDef)) {
        mdlUtil_wypiszInfo("uwaga: brak definicji klasy budynku");
        return FALSE;
    }

    budynekElemsP = &budynekDef->elems;

    if (pelna) {
        mdlUtil_wypiszInfo("oczyszczanie tabeli id budynkow...");
        if (SUCCESS != mdlDB_processSQL("DELETE * FROM OT_BUBD_A_EGiB")) {
            sprintf(msg, "budynek_purgeId: uwaga! nie mozna wykonac kwerendy %s lub tabela jest pusta", "DELETE * FROM OT_BUBD_A_EGiB");
            mdlUtil_wypiszInfo(msg);
        }
    }

    mdlUtil_wypiszInfo("aktualizacja id budynkow (tylko x_zrodloDanychG='EGiB')...");
    for (i = 0; i < budynekElemsP->nElems; i++) {
        //budynek
        TopoElem* budynekElemP = &budynekElemsP->aElems[i];
        //teksty powiazane z budynek
        TopoLpElems* tekstyElemsP = &budynekElemP->podElems;

        ULong mslink = budynekElemP->mslink;
        ULong id = budynekElemP->id;

        nL++; //liczba budynkow

        //aktualizacja/zapis identyfikatorow budynku
        for (j = 0; j < tekstyElemsP->nElems; j++) {
            TopoElem* tekstElemP = tekstyElemsP->aElems[j];
            char* tekstId = tekstElemP->aTekst;

            if (budynek_dodajId(id, mslink, tekstId, pelna)) {
                nW++; //liczba zapisanych identyfikatorow
            } else
                nP++;
        }

        //aktualizacja statystyk identyfikatorow
        switch (tekstyElemsP->nElems) {
            case 0: n0++;
                break;
            case 1: n1++;
                break;
            case 2: n2++;
                break;
            default: n3++;
                break;
        }
    }

    sprintf(msg, "statystyka relacji:\n R0=%d R1=%d R2=%d R2+=%d NR=%d", n0, n1, n2, n3, nL);
    mdlUtil_wypiszInfo(msg);

    if (n0 > 0)
        mdlUtil_wypiszInfo("uwaga: znaleziono budynki bez id");

    if (n2 > 0)
        mdlUtil_wypiszInfo("uwaga: znaleziono budynki z dwoma id");

    if (n3 > 0)
        mdlUtil_wypiszInfo("uwaga: znaleziono budynki z wiecej niz 2 id");

    sprintf(msg, "%d id zaktualizowanych, %d id pominietych", nW, nP);
    mdlUtil_wypiszInfo(msg);

    //wyszukiwanie tekstow poza budynkiem
    if (!topoLayers_szukajNazwy(defsP, "identyfikator", &idDef)) {
        mdlUtil_wypiszInfo("uwaga: brak definicji klasy identyfikatorow");
        return FALSE;
    }

    idElemsP = &idDef->elems;
    mdlUtil_wypiszInfo("wyszukiwanie identyfikatorow poza budynkiem...");
    n0 = n1 = n2 = n3 = nT = 0;

    for (i = 0; i < idElemsP->nElems; i++) {

        TopoElem* idElemP = &idElemsP->aElems[i];
        //budynki powiazane z identyfikatorem
        TopoLpElems* budynkiElemsP = &idElemP->nadElems;
        char* idTekst = idElemP->aTekst;

        nT++;

        //aktualizacja statystyk id
        switch (budynkiElemsP->nElems) {
            case 0: n0++;
                sprintf(msg, "info: wolny identyfikator <%s>", idTekst);
                mdlFile_appendLine(msg);
                break;
            default: n1++;
                break;
        }
    }

    if (n0 > 0) {
        sprintf(msg, "uwaga: znaleziono %d/%d wolne identyfikatory", n0, nT);
        mdlUtil_wypiszInfo(msg);
    }

    return TRUE;
}

int budynek_aktualizujId(char* tabela, int pelna) {
    TopoOgrodzenie g_ogrodzenie;
    char defBudynek[256];

    if (!tbdOdbc_inicjuj())
        return FALSE;

    topoOgrodzenie_inicjuj(&g_ogrodzenie);

    sprintf(defBudynek, "def obszar budynek brak[0] brak[0] 0 0 topo[%s]", tabela);
    //mdlUtil_wypiszInfo(defBudynek);

    if (!topoLayers_dodajDef(&g_ogrodzenie.definicje, defBudynek, 0.1))
        return FALSE;

    if (!topoLayers_dodajDef(&g_ogrodzenie.definicje, "def tekst identyfikator budynek[zawieranie] brak[0] 1 0 dgn", 0.1))
        return FALSE;

    if (topoOgrodzenie_load(&g_ogrodzenie)) {
        topoLayers_wypisz(&g_ogrodzenie.definicje);

        if (!budynek_aktualizujDefinicje(&g_ogrodzenie.definicje, pelna)) {
            mdlUtil_wypiszInfo("--ANULOWANO--");
        }
    } else {
        mdlUtil_wypiszInfo("--ANULOWANO--");
    }

    topoOgrodzenie_zwolnij(&g_ogrodzenie);

    mdlUtil_wypiszInfo("-KONIEC-");

    return TRUE;
}
