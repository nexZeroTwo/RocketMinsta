#ifdef INTERFACE
CLASS(NewMenuWinnerDialog) EXTENDS(NewMenuDialog)
	METHOD(NewMenuWinnerDialog, fill, void(entity))
	ATTRIB(NewMenuWinnerDialog, title, string, "Winner")
	ATTRIB(NewMenuWinnerDialog, color, vector, SKINCOLOR_DIALOG_SINGLEPLAYER)
	ATTRIB(NewMenuWinnerDialog, intendedWidth, float, 0.32)
	ATTRIB(NewMenuWinnerDialog, rows, float, 12)
	ATTRIB(NewMenuWinnerDialog, columns, float, 3)
ENDCLASS(NewMenuWinnerDialog)
#endif

#ifdef IMPLEMENTATION
void fillNewMenuWinnerDialog(entity me)
{
	entity e;

	me.TR(me);
		me.TD(me, me.rows - 2, me.columns, e = makeNewMenuImage("/gfx/winner", -1));

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeNewMenuButton("OK", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
#endif
