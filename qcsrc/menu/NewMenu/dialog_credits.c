#ifdef INTERFACE
CLASS(NewMenuCreditsDialog) EXTENDS(NewMenuDialog)
	METHOD(NewMenuCreditsDialog, fill, void(entity))
	METHOD(NewMenuCreditsDialog, focusEnter, void(entity))
	ATTRIB(NewMenuCreditsDialog, title, string, "License")
	ATTRIB(NewMenuCreditsDialog, color, vector, SKINCOLOR_DIALOG_CREDITS)
	ATTRIB(NewMenuCreditsDialog, intendedWidth, float, SKINWIDTH_CREDITS)
	ATTRIB(NewMenuCreditsDialog, rows, float, SKINROWS_CREDITS)
	ATTRIB(NewMenuCreditsDialog, columns, float, 2)
	ATTRIB(NewMenuCreditsDialog, creditsList, entity, NULL)
ENDCLASS(NewMenuCreditsDialog)
#endif

#ifdef IMPLEMENTATION
void fillNewMenuCreditsDialog(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, me.rows - 1, me.columns, me.creditsList = makeNewMenuCreditsList());
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeNewMenuButton("OK", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
void focusEnterNewMenuCreditsDialog(entity me)
{
	me.creditsList.scrolling = time + 1;
}
#endif
