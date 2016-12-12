#include "eMapa.h"
#include "..\Aplikacja\mdlUtil.h"

/* str_charToInt */
void str_charToInt(char* kod, int* kodInt) {
    int i;
    for (i = 0; i < strlen(kod); i++) {
        kodInt[i * 2] = (int) kod[i];
        kodInt[i * 2 + 1] = 0;
    }
}

/* mdlElem_equKod */
int mdlElem_equKod(MSElement* element, char* kod, char* nazwa) {
    int length;
    short buffer[2048];
    char* bufferChar;

    char napis[1024];
    char nap[1024];
    int napisIndeks;
    int napIndeks;

    int kodInt[256];
    int nazwaInt[256];
    int kodJest, nazwaJest;
    int i, j, kodLen, nazwaLen;

    str_charToInt(kod, kodInt);
    str_charToInt(nazwa, nazwaInt);

    strcpy(napis, "napis>");
    bufferChar = (char*) buffer;

    kodJest = FALSE;
    nazwaJest = FALSE;
    napisIndeks = 6;
    napIndeks = 0;

    mdlElement_extractAttributes(&length, buffer, element); //zawsze sukces

    if (length > 0) {
        int kodJ, nazwaJ;

        kodLen = strlen(kod) * 2;
        nazwaLen = strlen(nazwa) * 2;

        for (i = 4; i < length * 2; i++) {
            if (isalnum(bufferChar[i]))
                //if (isalpha (bufferChar[i]))
                napis[napisIndeks++] = bufferChar[i];

            if (kodJest == FALSE) {
                /* najpierw szukamy kodu, potem nazwy */
                kodJ = FALSE;
                for (j = 0; j < kodLen && i + j < length * 2; j++) {
                    if (kodInt[j] != (int) bufferChar[i + j]) {
                        kodJ = FALSE;
                        break;
                    } else {
                        nap[napIndeks++] = bufferChar[i + j];
                        kodJ = TRUE;
                    }
                }
                kodJest = kodJ;
            } else {
                /* dopóki nie znajdziemy kodu to nie ma sensu szukaæ nazwy */
                nazwaJ = FALSE;
                for (j = 0; j < nazwaLen && i + j < length * 2; j++) {
                    if (nazwaInt[j] != (int) bufferChar[i + j]) {
                        nazwaJ = FALSE;
                        break;
                    } else {
                        nazwaJ = TRUE;
                        nap[napIndeks++] = bufferChar[i + j];
                    }
                }
                nazwaJest = nazwaJ;
            }

            if (nazwaJest)
                break;
        }
    }

    return kodJest && nazwaJest;

}

/* mdlElem_equDTM */
int mdlElem_equDTM(MSElement* element, int* dtm) {
    int length;
    short buffer[2048];
    char* bufferChar;

    char kod[256];
    int kodInt[256];

    int kodJest;
    int i, j, kodLen;

    strcpy(kod, "DTM");

    str_charToInt(kod, kodInt);

    bufferChar = (char*) buffer;

    kodJest = FALSE;

    mdlElement_extractAttributes(&length, buffer, element); //zawsze sukces

    if (length > 0) {
        int kodJ;

        kodLen = strlen(kod) * 2;

        for (i = 4; i < length * 2; i++) {
            kodJ = FALSE;
            for (j = 0; j < kodLen && i + j < length * 2; j++) {
                if (kodInt[j] != (int) bufferChar[i + j]) {
                    kodJ = FALSE;
                    break;
                } else {
                    kodJ = TRUE;
                }
            }
            kodJest = kodJ;

            if (kodJest)
                break;
        }
    }

    return *dtm = kodJest;
}
