/* tbdDgn.mc */

#include "tbdDgn.h"
#include "..\Aplikacja\mdlFile.h"
#include "..\Aplikacja\mdlUtil.h"

/* tbdDgn_wczytajAtrybuty - id(obiekt) oraz mslink(klasa) */
int tbdDgn_wczytajAtrybuty(TbdAtrybut* argP, MSElementDescr* edP) {
    if (argP == NULL)
        return FALSE;

    return tbdDgn_wczytajMslinkId(&argP->nMslink, &argP->nId, NULL, edP);
}

/* tbdDgn_wczytajMslinkId - odczytaj atrybuty dodatkowe elementu */
int tbdDgn_wczytajMslinkId(ULong* mslinkP, ULong* idP, ULong* gmlP, MSElementDescr* edP) {
    ULong words[6]; //Zwiêkszy³em rozmiar tablicy z 4 do 6, bo nowy bdot zapisujê teraz wiêcej danych dodatkowych

    if (edP == NULL)
        return FALSE;

    if (mdlLinkage_extractUsingDescr(words, edP, 19, 0, NULL, NULL, NULL, FALSE) == NULL)
        return FALSE;

    if (mslinkP != NULL)
        *mslinkP = words[1];

    if (idP != NULL)
        *idP = words[2];

    if (gmlP != NULL)
        *gmlP = words[3];

    return TRUE;
}

int tbdDgn_skanujPlik(int (*tbdDgn_skanujPlikFunc)(MSElementDescr* edP, void* argP), void* argP) {
    //char msg[256];
    ULong scanBuf[256];
    int scanSize, status;
#if MSVERSION >= 0x790
    ULong eofBlock;
#else
    int eofBlock, eofByte;
#endif

    Scanlist scanList;
    //short  	    word2, word3, word4;
    //ExtendedAttrBuf extAttrBuf;

    if (tbdDgn_skanujPlikFunc == NULL)
        return FALSE;

    mdlScan_initScanlist(&scanList);
    mdlScan_noRangeCheck(&scanList);

    //scanList.extendedType = FILEPOS | EXTATTR | ITERATEFUNC;
    scanList.extendedType = FILEPOS | ITERATEFUNC;

    /*
    scanList.extAttrBuf = &extAttrBuf;
    memset (&extAttrBuf, 0, sizeof (ExtendedAttrBuf));
    word2 = 0x0013;
    word3 = 0x000B;
    word4 = 0x0000;
    extAttrBuf.numWords = 2;
	
    extAttrBuf.extAttData[0] = 0x1000;
    extAttrBuf.extAttData[2] = 0x1000;
    extAttrBuf.extAttData[1] = 0xffff;
    extAttrBuf.extAttData[3] = word2;
		
    #if defined (BIG_ENDIAN)
            mdlCnv_swapWord(&word2);
            extAttrBuf.extAttData[0] = 0x0010;
            extAttrBuf.extAttData[2] = 0x0010;
            extAttrBuf.extAttData[1] = 0xffff;
            extAttrBuf.extAttData[3] = word2;
    #endif
     */

    /* 0 - MASTERFILE, 1, 2,... - pliki referencyjne */
    mdlScan_initialize(0, &scanList);

    scanSize = sizeof (scanBuf) / sizeof (short);

    mdlSystem_startBusyCursor();

    /* odznaczenie wybranych obiektow */
    mdlSelect_freeAll();


#if MSVERSION >= 0x790
    status = mdlScan_extended(scanBuf, &scanSize, &eofBlock, tbdDgn_skanujPlikFunc, argP);
#else
    status = mdlScan_extended(scanBuf, &scanSize, &eofBlock, &eofByte, tbdDgn_skanujPlikFunc, argP);
#endif

    mdlSystem_stopBusyCursor();

    return TRUE;
}

int tbdDgn_skanujPlikWybierz(MSElementDescr* edP, void* vargP) {
    TbdListaAtrybutow* argP = (TbdListaAtrybutow*) vargP;
    ULong filePos;
    MSElement* elP = NULL;
    NumerPlikuDgn modelRefP;

#if MSVERSION >= 0x790
    elP = NULL;
    filePos = mdlElmdscr_getFilePos(edP);
    modelRefP = mdlModelRef_getActive();
#else
    elP = &edP->el;
    filePos = mdlElement_getFilePos(FILEPOS_CURRENT, NULL);
    modelRefP = MASTERFILE;
#endif

    if (tbdDgn_wczytajMslinkId(NULL, NULL, NULL, edP)) {
        if (SUCCESS == mdlSelect_addElement(filePos, modelRefP, elP, TRUE)) {
            argP->nAtrybutyWybrane++;
        }
    } else {
        argP->nObiektyBezAtrybutow++;
    }

    return SUCCESS;
}

int tbdDgn_skanujPlikWczytaj(MSElementDescr* edP, void* vargP) {
    TbdListaAtrybutow* argP = (TbdListaAtrybutow*) vargP;
    int nAtrybuty = argP->nAtrybuty;

    if (tbdDgn_wczytajMslinkId(&argP->aAtrybuty[nAtrybuty].nMslink, &argP->aAtrybuty[nAtrybuty].nId, NULL, edP)) {
        argP->nAtrybuty++;
    }

    return SUCCESS;
}

/* Interfejs klasy tbdListaAtrybutow */

int tbdListaAtrybutow_inicjuj(TbdListaAtrybutow* argP) {
    if (argP == NULL)
        return FALSE;

    argP->aAtrybuty = NULL;
    argP->nAtrybuty = 0;
    argP->nAtrybutyWybrane = 0;
    argP->nObiektyBezAtrybutow = 0;

    return TRUE;
}

int tbdListaAtrybutow_zwolnij(TbdListaAtrybutow* argP) {
    if (argP == NULL)
        return FALSE;

    if (argP->aAtrybuty != NULL)
        free(argP->aAtrybuty);

    return TRUE;
}

/* tbdListaAtrybutow_wczytaj - wczytanie do pamieci listy obiektow tbd (mslink,id) z pliku dgn */
int tbdListaAtrybutow_wczytaj(TbdListaAtrybutow* argP) {
    char msg[256];
    ULong* aOffsets; /* tablica po³o¿enia w pliku, do zwolnienia */
    NumerPlikuDgn* aFileNums; /* tablica numerów plików, do zwolnienia */
    int nSelected; /* liczba wybranych elementów */
    //int i = 0;

    if (argP == NULL)
        return FALSE;

    /* selekcjonowanie obiektow */
    if (!tbdDgn_skanujPlik(tbdDgn_skanujPlikWybierz, argP))
        return FALSE;

    if (SUCCESS != mdlSelect_returnPositions(&aOffsets, &aFileNums, &nSelected)) {
        mdlUtil_wypiszInfo("tbdutil-purge: brak obiektów tbd.");
        return FALSE;
    }

    /* zwolnij pamiec */
    free(aOffsets);
    free(aFileNums);

    /* przydziel pamiec na atrybuty */
    argP->nAtrybuty = 0;
    argP->nAtrybutyWybrane = nSelected;
    argP->aAtrybuty = (TbdAtrybut*) calloc(nSelected, sizeof (TbdAtrybut));

    if (argP->aAtrybuty == NULL)
        return FALSE;

    /* wczytaj atrybuty do pamieci */
    if (!tbdDgn_skanujPlik(tbdDgn_skanujPlikWczytaj, argP)) {
        free(argP->aAtrybuty);
        return FALSE;
    }

    /* odœwie¿ widok */
    if (SUCCESS == mdlView_updateSingle(tcb->lstvw));

    sprintf(msg, "tbdutil-purge: znalezione %ld obiekty, wczytane %ld obiekty.", nSelected, argP->nAtrybuty);
    mdlUtil_msgPrint(msg);
    mdlUtil_wypiszInfo(msg);

    return TRUE;
}

/* Koniec definicji interfejsu klasy tbdListaAtrybutow */
