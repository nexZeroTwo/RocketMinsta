#ifdef INTERFACE
CLASS(NewMenuQuitDialog) EXTENDS(NewMenuDialog)
	METHOD(NewMenuQuitDialog, fill, void(entity))
	ATTRIB(NewMenuQuitDialog, title, string, "Quit")
	ATTRIB(NewMenuQuitDialog, color, vector, SKINCOLOR_DIALOG_QUIT)
	ATTRIB(NewMenuQuitDialog, intendedWidth, float, 0.5)
	ATTRIB(NewMenuQuitDialog, rows, float, 3)
	ATTRIB(NewMenuQuitDialog, columns, float, 2)
ENDCLASS(NewMenuQuitDialog)
#endif

#ifdef IMPLEMENTATION
void fillNewMenuQuitDialog(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 1, 2, makeNewMenuTextLabel(0.5, "Are you sure you want to quit?"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuCommandButton("Yes", '1 0 0', "quit", 0));
		me.TD(me, 1, 1, e = makeNewMenuButton("No", '0 1 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
#endif
