#ifdef INTERFACE
CLASS(NexuizNadeMenuDialog) EXTENDS(NexuizRootDialog)
	METHOD(NexuizNadeMenuDialog, fill, void(entity)) // to be overridden by user to fill the dialog with controls
	ATTRIB(NexuizNadeMenuDialog, title, string, "Choose Grenade Mode")
	ATTRIB(NexuizNadeMenuDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(NexuizNadeMenuDialog, intendedWidth, float, 0.2)
	ATTRIB(NexuizNadeMenuDialog, rows, float, 7)
	ATTRIB(NexuizNadeMenuDialog, columns, float, 10)
	ATTRIB(NexuizNadeMenuDialog, name, string, "NadeMenu")
	ATTRIB(NexuizNadeMenuDialog, nadelist, entity, NULL)
ENDCLASS(NexuizNadeMenuDialog)
#endif

#ifdef IMPLEMENTATION

void NadeMenu_Close(entity button, entity me)
{
    me.nadelist.applyChanges(me.nadelist);
	me.close(me);
}

void fillNexuizNadeMenuDialog(entity me)
{
	entity e;
	me.TR(me);
        me.TD(me, me.rows - 2, me.columns, me.nadelist = e = makeRMNadeList());
    me.gotoRC(me, me.rows - 2, 0);
        me.TD(me, 2, me.columns, e = makeNexuizButton("Accept", '0 0 0'));
			e.onClick = NadeMenu_Close;
			e.onClickEntity = me;
}
#endif

/* Click. The c-word is here so you can grep for it :-) */
