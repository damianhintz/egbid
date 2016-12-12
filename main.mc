#include "main.h"
#include "ui-dlg.h"

/* main entry point */
void main(int argc, char* argv[]) {
    char fileName[MAXFILELENGTH];
    char mdlDir[MAXDIRLENGTH];

    mdlApp_setPath(argv[0]);
    mdlApp_getFileAndMdl(fileName, mdlDir);
    mdlApp_setNumber();
    
    if (SUCCESS != uiDlg_appLoad(argc, argv))
        mdlUtil_dolaczBlad("main", "wystapil blad podczas ladowania aplikacji.");
}