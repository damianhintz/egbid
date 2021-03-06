/* mdlFile.h */

#include <tcb.h>
#include <mdl.h>
#include <mswindow.fdf>
#include <msdialog.fdf>
#include <mssystem.fdf>
#include <mselemen.fdf>
#include <msoutput.fdf>
#include <mslocate.fdf>
#include <string.h>
#include <mselems.h>
#include <userfnc.h>
#include <cmdlist.h>
#include <msdb.fdf>
#include <rdbmslib.fdf>
#include <dlogman.fdf>
#include <mslinkge.fdf>
#include <msparse.fdf>
#include <msrsrc.fdf>
#include <msstate.fdf>
#include <msdefs.h>
#include <msfile.fdf>
#include <dlogitem.h>
#include <cexpr.h>

#include "..\Aplikacja\def-v8.h"

#if !defined (H_MDL_FILE)
#define H_MDL_FILE

#define C_MAX_ROW_LENGTH 4096

int ioCfg_read ();
int ioCfg_write ();

int mdlFile_putLine (char* wiersz, char* ext, int append, int newline);
int mdlFile_appendLine (char* wiersz);
int mdlFile_appendLineExt (char* wiersz, char* ext);
int mdlFile_appendLineExtNoNewLine (char* wiersz, char* ext);
int mdlFile_writeLineExt (char* wiersz, char* ext);

FILE* mdlFile_logWrite (char* line, FILE* file, int close);

int mdlFile_wybierzPlik (char* workFileP, char* titleP, char* extP);

#endif
