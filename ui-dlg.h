#include <msdialog.fdf>
#include <mswindow.fdf>

#if !defined (H_UI_DIALOG)
#define H_UI_DIALOG

#include "ui-txt.h"

DialogBox* uiDlg_getMainDialog ();
int uiDlg_appLoad (int argc, char* argv[]);

void dialog_menuWyjscieHook (DialogItemMessage *dimP);

#endif
