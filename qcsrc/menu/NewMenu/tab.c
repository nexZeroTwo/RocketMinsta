#ifdef INTERFACE
CLASS(NewMenuTab) EXTENDS(Tab)
	// still to be customized by user
	/*
	ATTRIB(NewMenuTab, intendedWidth, float, 0)
	ATTRIB(NewMenuTab, rows, float, 3)
	ATTRIB(NewMenuTab, columns, float, 2)
	*/
	METHOD(NewMenuTab, showNotify, void(entity))

	ATTRIB(NewMenuTab, marginTop, float, 0) // pixels
	ATTRIB(NewMenuTab, marginBottom, float, 0) // pixels
	ATTRIB(NewMenuTab, marginLeft, float, 0) // pixels
	ATTRIB(NewMenuTab, marginRight, float, 0) // pixels
	ATTRIB(NewMenuTab, columnSpacing, float, SKINMARGIN_COLUMNS) // pixels
	ATTRIB(NewMenuTab, rowSpacing, float, SKINMARGIN_ROWS) // pixels
	ATTRIB(NewMenuTab, rowHeight, float, SKINFONTSIZE_NORMAL * SKINHEIGHT_NORMAL) // pixels
	ATTRIB(NewMenuTab, titleHeight, float, SKINFONTSIZE_TITLE * SKINHEIGHT_TITLE) // pixels

	ATTRIB(NewMenuTab, backgroundImage, string, string_null)
ENDCLASS(NewMenuTab)
#endif

#ifdef IMPLEMENTATION
void showNotifyNewMenuTab(entity me)
{
	loadAllCvars(me);
	showNotifyContainer(me);
}
#endif
