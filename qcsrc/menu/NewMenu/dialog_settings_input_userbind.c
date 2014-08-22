#ifdef INTERFACE
CLASS(NewMenuUserbindEditDialog) EXTENDS(NewMenuDialog)
	METHOD(NewMenuUserbindEditDialog, loadUserBind, void(entity, string, string, string))
	METHOD(NewMenuUserbindEditDialog, fill, void(entity))
	ATTRIB(NewMenuUserbindEditDialog, title, string, "User defined key bind")
	ATTRIB(NewMenuUserbindEditDialog, color, vector, SKINCOLOR_DIALOG_USERBIND)
	ATTRIB(NewMenuUserbindEditDialog, intendedWidth, float, 0.7)
	ATTRIB(NewMenuUserbindEditDialog, rows, float, 4)
	ATTRIB(NewMenuUserbindEditDialog, columns, float, 3)
	ATTRIB(NewMenuUserbindEditDialog, keybindBox, entity, NULL)

	ATTRIB(NewMenuUserbindEditDialog, nameBox, entity, NULL)
	ATTRIB(NewMenuUserbindEditDialog, commandPressBox, entity, NULL)
	ATTRIB(NewMenuUserbindEditDialog, commandReleaseBox, entity, NULL)
ENDCLASS(NewMenuUserbindEditDialog)
#endif

#ifdef IMPLEMENTATION
void NewMenuUserbindEditDialog_Save(entity btn, entity me)
{
	me.keybindBox.editUserbind(me.keybindBox, me.nameBox.text, me.commandPressBox.text, me.commandReleaseBox.text);
	Dialog_Close(btn, me);
}

void loadUserBindNewMenuUserbindEditDialog(entity me, string theName, string theCommandPress, string theCommandRelease)
{
	me.nameBox.setText(me.nameBox, theName);
		me.nameBox.keyDown(me.nameBox, K_END, 0, 0);
	me.commandPressBox.setText(me.commandPressBox, theCommandPress);
		me.nameBox.keyDown(me.commandPressBox, K_END, 0, 0);
	me.commandReleaseBox.setText(me.commandReleaseBox, theCommandRelease);
		me.nameBox.keyDown(me.commandReleaseBox, K_END, 0, 0);
}

void fillNewMenuUserbindEditDialog(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Name:"));
		me.TD(me, 1, me.columns - 1, me.nameBox = makeNewMenuInputBox(0, string_null));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Command when pressed:"));
		me.TD(me, 1, me.columns - 1, me.commandPressBox = makeNewMenuInputBox(0, string_null));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Command when released:"));
		me.TD(me, 1, me.columns - 1, me.commandReleaseBox = makeNewMenuInputBox(0, string_null));
	me.TR(me);
		me.TD(me, 1, me.columns / 2, e = makeNewMenuButton("Save", '0 0 0'));
			e.onClick = NewMenuUserbindEditDialog_Save;
			e.onClickEntity = me;
		me.TD(me, 1, me.columns / 2, e = makeNewMenuButton("Cancel", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
#endif
