#ifdef INTERFACE
CLASS(NewMenuCvarsDialog) EXTENDS(NewMenuDialog)
	METHOD(NewMenuCvarsDialog, toString, string(entity))
	METHOD(NewMenuCvarsDialog, fill, void(entity))
	METHOD(NewMenuCvarsDialog, showNotify, void(entity))
	ATTRIB(NewMenuCvarsDialog, title, string, "Advanced settings")
	ATTRIB(NewMenuCvarsDialog, color, vector, SKINCOLOR_DIALOG_CVARS)
	ATTRIB(NewMenuCvarsDialog, intendedWidth, float, 0.8)
	ATTRIB(NewMenuCvarsDialog, rows, float, 25)
	ATTRIB(NewMenuCvarsDialog, columns, float, 6)
ENDCLASS(NewMenuCvarsDialog)
#endif

#ifdef IMPLEMENTATION
void showNotifyNewMenuCvarsDialog(entity me)
{
	loadAllCvars(me);
}
string toStringNewMenuCvarsDialog(entity me)
{
	return "XXX";
}
void fillNewMenuCvarsDialog(entity me)
{
	entity e, cvarlist, btn;
	cvarlist = makeNewMenuCvarList();
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Cvar filter:"));
		me.TD(me, 1, 0.5, btn = makeNewMenuButton("Clear", '0 0 0'));
		me.TD(me, 1, me.columns - 1.5, e = makeNewMenuInputBox(0, string_null));
			e.onChange = CvarList_Filter_Change;
			e.onChangeEntity = cvarlist;
			btn.onClick = InputBox_Clear_Click;
			btn.onClickEntity = e;
			cvarlist.controlledTextbox = e; // this COULD also be the Value box, but this leads to accidentally editing stuff
	me.TR(me);
		me.TD(me, me.rows - me.currentRow - 7, me.columns, cvarlist);
	me.gotoRC(me, me.rows - 7, 0);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Setting:"));
		me.TD(me, 1, me.columns - 1, e = makeNewMenuTextLabel(0, string_null));
			cvarlist.cvarNameBox = e;
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Type:"));
		me.TD(me, 1, me.columns - 1, e = makeNewMenuTextLabel(0, string_null));
			cvarlist.cvarTypeBox = e;
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Value:"));
		me.TD(me, 1, me.columns - 2, e = makeNewMenuInputBox(0, string_null));
			cvarlist.cvarValueBox = e;
			e.onChange = CvarList_Value_Change;
			e.onChangeEntity = cvarlist;
		me.TD(me, 1, 1, e = makeNewMenuButton(string_null, SKINCOLOR_CVARLIST_REVERTBUTTON));
			cvarlist.cvarDefaultBox = e;
			e.onClick = CvarList_Revert_Click;
			e.onClickEntity = cvarlist;
			e.allowCut = 1;
			e.marginLeft = e.marginRight = 0.5;
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Description:"));
		me.TD(me, 1, me.columns - 1, e = makeNewMenuTextLabel(0, string_null));
			cvarlist.cvarDescriptionBox = e;
			e.allowWrap = 1;
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeNewMenuButton("OK", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}

#endif
