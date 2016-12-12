#include "ui-dlg.h"
#include "main.h"
#include "budynekId.h"

DialogBox* uiDlg_getMainDialog() {
    return mdlDialog_find(C_ID_DLG_Main, NULL);
}

void dialog_mainHook(DialogMessage *dmP) {
    /* ignore any messages being sent to modal dialog hook */
    if (dmP->dialogId != C_ID_DLG_Main)
        return;

    dmP->msgUnderstood = TRUE;

    switch (dmP->messageType) {
        case DIALOG_MESSAGE_CREATE:
            break;
        case DIALOG_MESSAGE_DESTROY:
            mdlDialog_cmdNumberQueue(FALSE, CMD_MDL_UNLOAD, mdlSystem_getCurrTaskID(), TRUE);
            break;
        default:
            dmP->msgUnderstood = FALSE;
            break;
    }
}

void dialog_menuWyjscieHook(DialogItemMessage *dimP) {
    dimP->msgUnderstood = TRUE;

    switch (dimP->messageType) {
        case DITEM_MESSAGE_BUTTON:
            if (dimP->u.button.buttonTrans != BUTTONTRANS_UP)
                break;
            mdlDialog_cmdNumberQueue(FALSE, CMD_MDL_UNLOAD, mdlSystem_getCurrTaskID(), TRUE);
            break;
        default:
            dimP->msgUnderstood = FALSE;
            break;
    }
}

void dialog_aktualizacjaPrzyrHook(DialogItemMessage *dimP) {
    dimP->msgUnderstood = TRUE;

    switch (dimP->messageType) {
        case DITEM_MESSAGE_BUTTON:
        {
            if (dimP->u.button.buttonTrans != BUTTONTRANS_UP)
                break;

            if (ACTIONBUTTON_OK != mdlDialog_openAlert(
                    "Masz zamiar wykonac przyrostowa aktualizacje tabeli identyfikatorow budynkow OT_BUBD_A_EGiB. "
                    "Teksty identyfikatorow z ewidencji podlacz referencyjnie i wybierz ogrodzenie. "
                    "Kontynuowac ?"
                    )) {
                break;
            }

            mdlFile_appendLine("-TBDUTIL_EGBID_START-");
            budynek_aktualizujId("OT_BUBD_A", FALSE);
            mdlFile_appendLine("-TBDUTIL_EGBID_KONIEC-");
        }
            break;
        default:
            dimP->msgUnderstood = FALSE;
            break;
    }
}

void dialog_aktualizacjaPelnaHook(DialogItemMessage *dimP) {
    dimP->msgUnderstood = TRUE;

    switch (dimP->messageType) {
        case DITEM_MESSAGE_BUTTON:
        {
            if (dimP->u.button.buttonTrans != BUTTONTRANS_UP)
                break;

            if (ACTIONBUTTON_OK != mdlDialog_openAlert(
                    "Masz zamiar wykonac pelna aktualizacje tabeli identyfikatorow budynkow OT_BUBD_A_EGiB. "
                    "Teksty identyfikatorow z ewidencji podlacz referencyjnie i wybierz ogrodzenie. "
                    "Uwaga! Zawartosc tabeli identyfikatorow zostanie podczas tego procesu wyczyszczona i zaktualizowana. "
                    "Kontynuowac ?"
                    )) {
                break;
            }

            mdlFile_appendLine("-TBDUTIL_EGBID_START-");
            budynek_aktualizujId("OT_BUBD_A", TRUE);
            mdlFile_appendLine("-TBDUTIL_EGBID_KONIEC-");
        }
            break;
        default:
            dimP->msgUnderstood = FALSE;
            break;
    }
}

/* hooks array */
DialogHookInfo uHooks[] = {
    {C_HK_DLG_Main, dialog_mainHook},
    {C_HK_PDM_Wyjscie, dialog_menuWyjscieHook},
    {C_HK_PDM_ADR_Przyr, dialog_aktualizacjaPrzyrHook},
    {C_HK_PDM_ADR_Pelna, dialog_aktualizacjaPelnaHook},
};

int uiDlg_appLoad(int argc, char* argv[]) {
    char *setP;
    RscFileHandle rscFileH;
    DialogBox *dbP;

    mdlResource_openFile(&rscFileH, NULL, 0);
    setP = mdlCExpression_initializeSet(VISIBILITY_DIALOG_BOX, 0, FALSE);
    //mdlDialog_publishComplexVariable (setP, "basicglobals", "basicGlobals", &basicGlobals);
    mdlDialog_hookPublish(sizeof (uHooks) / sizeof (DialogHookInfo), uHooks);

    if ((dbP = mdlDialog_open(NULL, C_ID_DLG_Main)) == NULL)
        return ERROR;

    return SUCCESS;
}
