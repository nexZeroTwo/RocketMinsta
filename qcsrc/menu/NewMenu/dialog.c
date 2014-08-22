#ifdef INTERFACE
CLASS(NewMenuDialog) EXTENDS(Dialog)
	// still to be customized by user
	/*
	ATTRIB(NewMenuDialog, closable, float, 1)
	ATTRIB(NewMenuDialog, title, string, "Form1") // ;)
	ATTRIB(NewMenuDialog, color, vector, '1 0.5 1')
	ATTRIB(NewMenuDialog, intendedWidth, float, 0)
	ATTRIB(NewMenuDialog, rows, float, 3)
	ATTRIB(NewMenuDialog, columns, float, 2)
	*/
	ATTRIB(NewMenuDialog, marginTop, float, SKINMARGIN_TOP) // pixels
	ATTRIB(NewMenuDialog, marginBottom, float, SKINMARGIN_BOTTOM) // pixels
	ATTRIB(NewMenuDialog, marginLeft, float, SKINMARGIN_LEFT) // pixels
	ATTRIB(NewMenuDialog, marginRight, float, SKINMARGIN_RIGHT) // pixels
	ATTRIB(NewMenuDialog, columnSpacing, float, SKINMARGIN_COLUMNS) // pixels
	ATTRIB(NewMenuDialog, rowSpacing, float, SKINMARGIN_ROWS) // pixels
	ATTRIB(NewMenuDialog, rowHeight, float, SKINFONTSIZE_NORMAL * SKINHEIGHT_NORMAL) // pixels
	ATTRIB(NewMenuDialog, titleHeight, float, SKINFONTSIZE_TITLE * SKINHEIGHT_TITLE) // pixels
	ATTRIB(NewMenuDialog, titleFontSize, float, SKINFONTSIZE_TITLE) // pixels

	ATTRIB(NewMenuDialog, backgroundImage, string, SKINGFX_DIALOGBORDER)
	ATTRIB(NewMenuDialog, borderLines, float, SKINHEIGHT_DIALOGBORDER)
	ATTRIB(NewMenuDialog, closeButtonImage, string, SKINGFX_CLOSEBUTTON)
	ATTRIB(NewMenuDialog, zoomedOutTitleBarPosition, float, SKINHEIGHT_ZOOMEDTITLE * 0.5 - 0.5)
	ATTRIB(NewMenuDialog, zoomedOutTitleBar, float, SKINHEIGHT_ZOOMEDTITLE != 0)

	ATTRIB(NewMenuDialog, alpha, float, SKINALPHA_TEXT)

	METHOD(NewMenuDialog, configureDialog, void(entity))
ENDCLASS(NewMenuDialog)
entity currentDialog;
#endif

#ifdef IMPLEMENTATION
void configureDialogNewMenuDialog(entity me)
{
	currentDialog = me;
	configureDialogDialog(me);
	me.tooltip = getZonedTooltipForIdentifier(me.classname);
}
#endif
