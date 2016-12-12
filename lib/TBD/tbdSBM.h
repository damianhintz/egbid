/* tbdSBM.h */

#include <mdl.h>
#include <mselems.h>
#include <userfnc.h>
#include <cmdlist.h>
#include <string.h>
#include <msdb.fdf>
#include <rdbmslib.fdf>
#include <dlogman.fdf>
#include <mssystem.fdf>
#include <mslinkge.fdf>
#include <msoutput.fdf>
#include <msparse.fdf>
#include <mselemen.fdf>
#include <msrsrc.fdf>
#include <mslocate.fdf>
#include <msstate.fdf>
#include <msdefs.h>
#include <msfile.fdf>
#include <dlogitem.h>
#include <cexpr.h>
#include <msmisc.fdf>
#include <scanner.h>
#include <msscan.fdf>
#include <msselect.fdf>
#include <msview.fdf>
#include <msinput.fdf>

#if !defined (H_TBD_SBM)
#define H_TBD_SBM

//${MSDIR}\TBD\Data\TBD.SBM
typedef struct plikTbdSBM
{
	char aTeksty[256][64];
	int nTeksty;
	
} PlikTbdSBM, *LpPlikTbdSBM;

int plikTbdSBM_inicjuj (PlikTbdSBM* plikP);
int plikTbdSBM_zwolnij (PlikTbdSBM* plikP);
int plikTbdSBM_szukajPliku (PlikTbdSBM* plikP);
int plikTbdSBM_dodajTekst (PlikTbdSBM* plikP, char* tekst);
int plikTbdSBM_wczytajTeksty (PlikTbdSBM* plikP, char* sbmName);
int plikTbdSBM_szukajTekstu (PlikTbdSBM* plikP, char* tekst);

#endif
