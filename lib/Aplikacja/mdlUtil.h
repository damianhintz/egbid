/* mdlUtil.h */

#include <msdialog.fdf>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <msoutput.fdf>

#if !defined (H_MDL_UTIL)
#define H_MDL_UTIL

#define C_MAX_LEN_MSG 512

#define MDL_UTIL_MSG_None -1
#define MDL_UTIL_MSG_Info 0
#define MDL_UTIL_MSG_Warning 1
#define MDL_UTIL_MSG_Error 2

typedef struct _mdlUtilMsg
{
	int nType;    /* typ komunikatu */
	int nCount;   /* liczba komunikatow */
	char* sNazwa; /* kod komunikatu (moze byc NULL) */
	char* sPomoc; /* szczegolowy opis komunikatu */
} MdlUtilMsg;

int mdlUtil_inicjujMsg (MdlUtilMsg* msgP);
int mdlUtil_zwolnijMsg (MdlUtilMsg* msgP);

#define N_MDL_UTIL 128

typedef struct _mdlUtilKomunikaty
{
	int nElems;
	MdlUtilMsg aElems[N_MDL_UTIL];
	
} MdlUtilKomunikaty;

int mdlUtil_inicjuj ();
int mdlUtil_zwolnij ();

int mdlUtil_dolaczInfo (char* nazwa, char* opis);
int mdlUtil_dolaczOstrzezenie (char* nazwa, char* opis);
int mdlUtil_dolaczBlad (char* nazwa, char* opis);

int mdlUtil_wypiszInfo (char* text);
int mdlUtil_msgPrint (char* msg);

int mdlUtil_wypiszBledy ();

int mdlUtil_inicjujPostep ();
int mdlUtil_zwolnijPostep ();
int mdlUtil_pokazPostep ();

char* mdlUtil_trimRight (char* p, char c);
void mdlUtil_readDouble (char* wiersz, double* value);
void mdlUtil_readInt (char* wiersz, int* value);
void mdlUtil_readString (char* wiersz, char* value);

//int mdlUtil_enterFunc (char* nazwaFunkcji);
//int mdlUtil_exitFunc ();

void* mdlUtil_alokujPamiec (int nNumber, int nSize);
void mdlUtil_zwolnijPamiec (void* memoryP);

#endif
