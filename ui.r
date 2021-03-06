#include <rscdefs.h>
#include <cmdclass.h>
#include <dlogbox.h>
#include <dlogids.h>
#include <keys.h>

#include "ui-txt.h"

DialogBoxRsc C_ID_DLG_Main =
{
	DIALOGATTR_AUTOUNLOADAPP,
	C_UI_DLG_W, C_UI_DLG_H,
	NOHELP, MHELP, C_HK_DLG_Main, NOPARENTID,
	C_TX_DLG_Main,
	{
		{{0, 0, 0, 0}, MenuBar, C_ID_MNB_Main,	ON, 0, "", ""},
	}
};

DItem_MenuBarRsc C_ID_MNB_Main =
{
	NOHOOK, NOARG,
	{
		{ PulldownMenu, C_ID_PDM_Plik },
	}
};

DItem_PulldownMenuRsc C_ID_PDM_Plik =
{
	NOHELP, OHELPTASKIDCMD,
	C_HK_PDM_Plik,
	ON, C_TX_PDM_Plik,
	{
		{C_TX_PDM_ADR_Pelna, 'F'|VBIT_CTRL, ON, NOMARK, 0, 0,
		    NOHELP, OHELPTASKIDCMD,
		    C_HK_PDM_ADR_Pelna, NOHOOK,
		    NOCMD, OTASKID, ""},
		{C_TX_PDM_ADR_Przyr, 'I'|VBIT_CTRL, ON, NOMARK, 0, 0,
		    NOHELP, OHELPTASKIDCMD,
		    C_HK_PDM_ADR_Przyr, NOHOOK,
		    NOCMD, OTASKID, ""},
		{C_TX_PDM_Wyjscie, 'X'|VBIT_CTRL, ON, NOMARK, 0, 0,
		    NOHELP, OHELPTASKIDCMD,
		    C_HK_PDM_Wyjscie, NOHOOK,
		    NOCMD, OTASKID, ""},
	}
};
