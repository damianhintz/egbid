/* tbdQuery.h */

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

#if !defined (H_TBD_QUERY)
#define H_TBD_QUERY

#define TBD_QUERY_MIN_MSLINK "select min(mslink) from feature"
#define TBD_QUERY_MAX_MSLINK "select max(mslink) from feature"
#define TBD_QUERY_TABLES "select mslink,tablename from feature order by tablename,mslink"
#define TBD_QUERY_ADRESY "select id,numer & '',podnumer & '',id_ulicy & '',id_miejscowosci & '' from arad_p order by numer,podnumer,id_ulicy,id_miejscowosci,id"
#define TBD_QUERY_ADRESY_TAKIE_SAME "SELECT ARAD_P.id, ARAD_P.numer, ARAD_P.podnumer, ARAD_P.id_ulicy, ARAD_P.id_miejscowosci FROM ARAD_P INNER JOIN ARAD_P AS ARAD_P_1 ON (ARAD_P.id <> ARAD_P_1.id) AND (ARAD_P.id_miejscowosci = ARAD_P_1.id_miejscowosci or (ARAD_P.id_miejscowosci is null and  ARAD_P_1.id_miejscowosci is null)) AND (ARAD_P.id_ulicy = ARAD_P_1.id_ulicy) AND (ARAD_P.podnumer = ARAD_P_1.podnumer or (ARAD_P.podnumer is null and  ARAD_P_1.podnumer is null)) AND (ARAD_P.numer = ARAD_P_1.numer)"

int tbdMdb_kwerendaWykonaj (char* query);
int tbdMdb_kwerendaWartoscInteger (char* query, long* countP);
int tbdMdb_kwerendaWartoscString  (char* query, char* name);
int tbdMdb_kwerendaWczytajIdentyfikatory (char* query, char* queryCount, long** aIdsP, long* nIdsP);

typedef struct tbdQuery
{
	char sSqlStart[256];
	
	char* sSql; //kwerenda
	long nSql;  //przydzielona pamiec
	long nLen;  //koniec kwerendy
	int bSql;   //stan kwerendy
	int nMax;	//maksymalna liczba identyfikatorow
	int nIds;
	
} TbdQuery, *LpTbdQuery;

int tbdQuery_inicjuj (TbdQuery* queryP, char* sSqlStart);
int tbdQuery_zwolnij (TbdQuery* queryP);
int tbdQuery_dodajId (TbdQuery* queryP, long id);
int tbdQuery_zakoncz (TbdQuery* queryP);
int tbdQuery_wykonaj (TbdQuery* queryP);

#endif
