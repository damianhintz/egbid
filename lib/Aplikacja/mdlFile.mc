/* mdlFile.mc */

#include "mdlFile.h"
#include "mdlUtil.h"
#include "mdlApp.h"

int mdlFile_putLine (char* wiersz, char* ext, int append, int newline)
{
	FILE* file;
	char logname[MAXFILELENGTH];
	
	char dev[MAXDEVICELENGTH];
	char dir[MAXDIRLENGTH];
	char name[MAXNAMELENGTH];
	char ext2[MAXEXTENSIONLENGTH];
	
	int optionOpen = TEXTFILE_WRITE;
	int optionPut = TEXTFILE_DEFAULT;
	
	if (append) optionOpen = TEXTFILE_APPEND;
	
	if (!newline) optionPut = TEXTFILE_NO_NEWLINE;
	
	mdlFile_parseName (tcb->dgnfilenm, dev, dir, name, ext2);
	mdlFile_buildName (logname, dev, dir, name, ext);
	
	if((file = mdlTextFile_open (logname, optionOpen)) == NULL)
	{
		mdlUtil_dolaczBlad ("mdlFile_putLine", "nie uda³o siê otworzyæ pliku.");
		return FALSE;
	}
	
	mdlTextFile_putString (wiersz, file, optionPut);
	
	if(SUCCESS == mdlTextFile_close (file)) ;
	
	return TRUE;
}

int mdlFile_appendLine (char* line)
{
	return mdlFile_putLine (line, "log", TRUE, TRUE);
}

int mdlFile_appendLineExt (char* line, char* ext)
{
	return mdlFile_putLine (line, ext, TRUE, TRUE);
}

int mdlFile_appendLineExtNoNewLine (char* line, char* ext)
{
	return mdlFile_putLine (line, ext, TRUE, FALSE);
}

int mdlFile_writeLineExt (char* line, char* ext)
{
	return mdlFile_putLine (line, ext, FALSE, TRUE);
}

FILE* mdlFile_logWrite (char* line, FILE* file, int close)
{
	char logname[MAXFILELENGTH];
	
	char dev[MAXDEVICELENGTH];
	char dir[MAXDIRLENGTH];
	char name[MAXNAMELENGTH];
	char ext[MAXEXTENSIONLENGTH];
	
	mdlFile_parseName (tcb->dgnfilenm, dev, dir, name, ext);
	mdlFile_buildName (logname, dev, dir, name, "log");
	
	if (file == NULL)
	{
		if ((file = mdlTextFile_open (logname, TEXTFILE_APPEND)) == NULL)
		{
			mdlUtil_dolaczBlad ("mdlFile_logWrite", "nie uda³o siê otworzyæ pliku.");
			return NULL;
		}
	}
	
	if (EOF == mdlTextFile_putString (line, file, TEXTFILE_DEFAULT))
		return NULL;
	
	//TEXTFILE_NO_NEWLINE
	
	if (close)
	{
		if (SUCCESS == mdlTextFile_close (file))
			return NULL;
	}
	
	return file;
}

int mdlFile_logWriteCSV (char* wiersz)
{
	FILE* file;
	char logname[MAXFILELENGTH];
	
	char dev[MAXDEVICELENGTH];
	char dir[MAXDIRLENGTH];
	char name[MAXNAMELENGTH];
	char ext[MAXEXTENSIONLENGTH];
	
	mdlFile_parseName(tcb->dgnfilenm, dev, dir, name, ext);
	mdlFile_buildName(logname, dev, dir, name, "csv");
	
	if((file = mdlTextFile_open(logname, TEXTFILE_APPEND)) != NULL)
	{
		mdlTextFile_putString(wiersz, file, TEXTFILE_DEFAULT);
		
		if(SUCCESS == mdlTextFile_close(file))
			;
	}else
		mdlUtil_dolaczBlad ("mdlFile_logWriteCSV", "nie uda³o siê otworzyæ pliku.");
	
	return SUCCESS;
}

void file_logPrint (char* line)
{
	FILE* file;
	char logname[MAXFILELENGTH];
	
	char dev[MAXDEVICELENGTH];
	char dir[MAXDIRLENGTH];
	char name[MAXNAMELENGTH];
	char ext[MAXEXTENSIONLENGTH];
	
	mdlFile_parseName(tcb->dgnfilenm, dev, dir, name, ext);
	mdlFile_buildName(logname, dev, dir, name, "log");
	
	if((file = mdlTextFile_open(logname, TEXTFILE_APPEND)) != NULL)
	{
		mdlTextFile_putString(line, file, TEXTFILE_DEFAULT); //TEXTFILE_NO_NEWLINE
		if(SUCCESS == mdlTextFile_close(file))
			;
	}else
		mdlUtil_dolaczBlad ("file_logPrint", "nie uda³o siê otworzyæ pliku.");
	
}

void file_logInit ()
{
	FILE* file;
	char logname[MAXFILELENGTH];
	
	char dev[MAXDEVICELENGTH];
	char dir[MAXDIRLENGTH];
	char name[MAXNAMELENGTH];
	char ext[MAXEXTENSIONLENGTH];
	
	mdlFile_parseName(tcb->dgnfilenm, dev, dir, name, ext);
	mdlFile_buildName(logname, dev, dir, name, "log");
	
	if((file = mdlTextFile_open(logname, TEXTFILE_WRITE)) != NULL)
	{
		if(SUCCESS == mdlTextFile_close(file))
			;
	}else
		mdlUtil_dolaczBlad ("file_logInit", "nie uda³o siê otworzyæ pliku.");
	
}

int mdlFile_wybierzPlik (char* workFileP, char* titleP, char* extP)
{
	int  actionCanceled;
	
	actionCanceled = mdlDialog_fileOpen (workFileP, /* returned file name*/
					0L,     						/* dlogbox rsc file handle */
					0L,     						/* dlogbox resource */
					NULL, 							/* suggested file name P*/
					extP,     						/* File Filter P*/
					NULL,     						/* Default Dir P*/
					titleP);						/* Dialog Title */
	
	if (actionCanceled == FALSE)
		return TRUE;
	else
		return FALSE;
}


/* ioCfg_read - wczytaj plik konfiguracyjny */
/*
int ioCfg_read ()
{
	FILE* file;
	char iniName[MAXFILELENGTH];
	char wiersz[C_MAX_ROW_LENGTH];
	//char* charP = NULL;
	//int i;
	
	if (FALSE == mdlApp_getIniPath (iniName))
	{
		mdlUtil_dolaczBlad ("ioCfg_read", "brak pliku ini");
		return ERROR;
	}
	
	//g_liczbaBudynkowCfg = 0;
	
	if ((file = mdlTextFile_open (iniName, TEXTFILE_READ)) != NULL)
	{
		while (NULL != mdlTextFile_getString (wiersz, C_MAX_ROW_LENGTH, file, TEXTFILE_DEFAULT))
		{
			if (strncmp (wiersz, "#", 1) == 0)
				// pomiñ wiersze zaczynaj¹ce siê od znaku #
				continue;
			else
			if (strncmp (wiersz, "budynek=", strlen ("budynek=")) == 0)
			{
				//sscanf (wiersz, "tolerancja=%f", &g_tolerancja);
				//g_tolerancja = mdlCnv_subUnitsToUors (g_tolerancja);
				
				//g_tolerancja = mdlCnv_masterUnitsToUors (g_tolerancja);
				//sprintf (g_nfomsg, "%.2f", g_tolerancja);
				//util_nfoPrint (g_nfomsg);
			}
		}
		
		if (SUCCESS == mdlTextFile_close (file))
			;
	}else
	{
		mdlUtil_dolaczBlad ("ioCfg_read", "nie uda³o siê otworzyæ pliku.");
		return ERROR;
	}
	
	return SUCCESS;
}

int ioCfg_write()
{
	FILE* file;
	char logname[MAXFILELENGTH];
	
	char dev[MAXDEVICELENGTH];
	char dir[MAXDIRLENGTH];
	char name[MAXNAMELENGTH];
	char ext[MAXEXTENSIONLENGTH];
	
	mdlFile_parseName (tcb->dgnfilenm, dev, dir, name, ext);
	mdlFile_buildName (logname, dev, dir, name, "rtf");
	
	if((file = mdlTextFile_open (logname, TEXTFILE_WRITE)) != NULL)
	{
		
		mdlTextFile_putString ("{\\rtf1 \\ansi \\cpg1250 \\deff0 ", file, TEXTFILE_DEFAULT);
		
		mdlTextFile_putString ("}", file, TEXTFILE_DEFAULT);
		
		if(SUCCESS == mdlTextFile_close (file))
			;
	}else
		mdlUtil_dolaczBlad ("ioCfg_write", "nie uda³o siê otworzyæ pliku.");
	
	return SUCCESS;
}
*/
