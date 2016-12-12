/* tbdOdbc.mc */

#include "tbdOdbc.h"
#include "..\Aplikacja\mdlUtil.h"

int tbdOdbc_inicjuj ()
{
	//char cfgodbc[MAXFILELENGTH];	//poprzednia wartoœæ zmiennej
	//char cfgfile[MAXFILELENGTH];	//nowa wartoœæ zmiennej
	int status = SUCCESS;
	
	//tbdOdbc_zachowajZmiennaFILEDSN (cfgodbc);
	//tbdOdbc_zapiszZmiennaFILEDSN (cfgodbc);
	
	if (SUCCESS != (status = tbdOdbc_createFileDSN ()))
	{
		mdlUtil_dolaczBlad ("dbConnect", "nie mo¿na utworzyæ pliku DSN");
		return FALSE;
	}
	
	if (SUCCESS != (status = mdlDB_changeDatabase (DATABASESERVERID_ODBC, "")))
	{
		mdlUtil_dolaczBlad ("dbConnect", "nie mo¿na zmieniæ bazy danych");
		return FALSE;
	}
	
	if (SUCCESS != (status = mdlDB_activeDatabase ("*")))
	{
		mdlUtil_dolaczBlad ("dbConnect", "nie mo¿na aktywowaæ bazy danych");
		return FALSE;
	}
	
	return TRUE;
}

/*
	tbdOdbc_createSysDSN - utwórz systemowe dsn (wymaga praw administratora)
	return
		SUCCESS
*/
int tbdOdbc_createSysDSN ()
{
	mdlUtil_dolaczBlad ("tbdOdbc_createSysDSN", "brak implementacji");
	return ERROR;
}

/*
	odbc_usrdsnCreate - utwórz user dsn
	return
		SUCCESS
*/
int tbdOdbc_createUserDSN ()
{
	mdlUtil_dolaczBlad ("tbdOdbc_createUserDSN", "brak implementacji");
	return ERROR;
}

/*
	tbdOdbc_createFileDSN - utwórz plikowy dsn
	out
		void
	return
		SUCCESS - sukces gdy uda siê zapisaæ
		ERROR	- b³¹d gdy siê nie uda
*/
int tbdOdbc_createFileDSN ()
{
	FILE* file;
	char buffer[1024];
	char usrdsn[1024];
	
	//char odbcdir[MAXFILELENGTH];
	char dsnname[MAXFILELENGTH];
	char outname[MAXFILELENGTH];
	char mdbname[MAXFILELENGTH];
	char mdbline[MAXFILELENGTH];
	
	char dev[MAXDEVICELENGTH];
	char dir[MAXDIRLENGTH];
	char name[MAXNAMELENGTH];
	char ext[MAXEXTENSIONLENGTH];
	
	int status = SUCCESS;
	
	mdlFile_parseName (tcb->dgnfilenm, dev, dir, name, ext);
	
	if (SUCCESS == mdlSystem_getenv (buffer, "USERPROFILE", sizeof buffer))
	{
		sprintf (usrdsn, "%s\\Moje dokumenty\\%s.dsn", buffer, name);
	}else
		strcpy (usrdsn, "");
		
	sprintf (dsnname, "C:\\Program Files\\Common Files\\ODBC\\Data Sources\\%s.dsn", name);
	
	if (SUCCESS == (status = mdlFile_create (outname, dsnname, NULL, NULL)))
		;
	else
	if (SUCCESS == (status = mdlFile_create (outname, usrdsn, NULL, NULL)))
		;
		
	if (SUCCESS == status)
	{
		file = mdlTextFile_open (outname, TEXTFILE_APPEND);
		
		if (file != NULL)
		{
			mdlTextFile_putString ("[ODBC]", file, TEXTFILE_DEFAULT);
			mdlTextFile_putString ("DRIVER=Driver do Microsoft Access (*.mdb)", file, TEXTFILE_DEFAULT);
			mdlTextFile_putString ("UID=admin", file, TEXTFILE_DEFAULT);
			mdlTextFile_putString ("UserCommitSync=Yes", file, TEXTFILE_DEFAULT);
			mdlTextFile_putString ("Threads=3", file, TEXTFILE_DEFAULT);
			mdlTextFile_putString ("SafeTransactions=0", file, TEXTFILE_DEFAULT);
			mdlTextFile_putString ("PageTimeout=5", file, TEXTFILE_DEFAULT);
			mdlTextFile_putString ("MaxScanRows=8", file, TEXTFILE_DEFAULT);
			mdlTextFile_putString ("MaxBufferSize=2048", file, TEXTFILE_DEFAULT);
			mdlTextFile_putString ("FIL=MS Access", file, TEXTFILE_DEFAULT);
			//mdlTextFile_putString ("DriverId=25", file, TEXTFILE_DEFAULT);
			mdlTextFile_putString ("DefaultDir=C:\\Program Files\\Common Files\\ODBC\\Data Sources", file, TEXTFILE_DEFAULT);
			mdlFile_buildName (mdbname, dev, dir, name, "mdb");
			sprintf (mdbline, "DBQ=%s", mdbname);
			mdlTextFile_putString (mdbline, file, TEXTFILE_DEFAULT);
			
			tbdOdbc_zapiszZmiennaFILEDSN (name);
			
		}else
		{
			mdlUtil_dolaczBlad ("tbdOdbc_createFileDSN", "nie mo¿na otworzyæ pliku dsn");
			status = ERROR;
		}
		
		if(SUCCESS == (status = mdlTextFile_close (file)))
			;
	}
	else
	{
		mdlUtil_dolaczBlad ("tbdOdbc_createFileDSN", "nie mo¿na utworzyæ pliku dsn");
	}
	
	return status;
}

/*
	tbdOdbc_zachowajZmiennaFILEDSN - zachowaj wartoœæ zmiennej MS_ODBCPARAMS w zmiennej pValue
	in
		void
	out
		pValue - wartoœæ zmiennej
	return
		void
*/
void tbdOdbc_zachowajZmiennaFILEDSN (char* pValue)
{
	if(SUCCESS != mdlSystem_getCfgVar (pValue, "MS_ODBCPARAMS", MAXFILELENGTH))
		mdlUtil_dolaczBlad ("tbdOdbc_zachowajZmiennaFILEDSN", "zmienna MS_ODBCPARAMS nie zosta³a zdefiniowana.");
}

/*
	tbdOdbc_zapiszZmiennaFILEDSN - zapisz now¹ wartoœæ pod zmienn¹ MS_ODBCPARAMS
	in
		name - nazwa bazy danych
	out
		void
	return
		void
*/
int tbdOdbc_zapiszZmiennaFILEDSN (char* name)
{
	char pValue[MAXFILELENGTH];
	
	/* inicjowanie funkcji */
	
	sprintf (pValue, "FILEDSN=%s", name);
	
	if (SUCCESS != mdlSystem_defineCfgVar ("MS_ODBCPARAMS", pValue, CFGVAR_LEVEL_USER))
		mdlUtil_dolaczBlad ("tbdOdbc_zapiszZmiennaFILEDSN", "nie uda³o siê zapisaæ zmiennej MS_ODBCPARAMS.");
		
	/* konczenie funkcji */
	
	return TRUE;
}

/*
	odbc_cfgvarRestore - przywróæ wartoœæ zmiennej MS_ODBCPARAMS
	in
		pVariable - przywracana wartoœæ zmiennej
	out
		void
	return
		void
*/
void odbc_restoreCfgVar (char* pVariable)
{
	mdlSystem_defineCfgVar ("MS_ODBCPARAMS", pVariable, CFGVAR_LEVEL_USER);
	//util_fundbgPrint("odbc_cfgvarRestore", "zmienna MS_ODBCPARAMS zosta³a przywrócona.");
}
