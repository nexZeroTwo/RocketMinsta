#ifdef INTERFACE
CLASS(NewMenuVcallDialog) EXTENDS(NewMenuRootDialog)
	METHOD(NewMenuVcallDialog, fill, void(entity)) // to be overridden by user to fill the dialog with controls
	ATTRIB(NewMenuVcallDialog, title, string, "Call a vote")
	ATTRIB(NewMenuVcallDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(NewMenuVcallDialog, intendedWidth, float, 0.8)
	ATTRIB(NewMenuVcallDialog, rows, float, 16)
	ATTRIB(NewMenuVcallDialog, columns, float, 20)
	ATTRIB(NewMenuVcallDialog, name, string, "VcallMenu")
    ATTRIB(NewMenuVcallDialog, voteList, entity, NULL)
ENDCLASS(NewMenuVcallDialog)
#endif

#ifdef IMPLEMENTATION

void VoteCall_f(entity btn, entity me)
{
    localcmd("cmd vote call ", cvar_string("_menu_vote_string"), "\n");
    btn.onClickEntity.close(btn.onClickEntity);
}

void fillNewMenuVcallDialog(entity me)
{
	entity e, vlist;
	
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuTextLabel(0, "Available votes:"));
	me.TR(me);
        me.TD(me, 13, 20, vlist = makeNewMenuVoteList());
	me.TR(me);
    me.TR(me);
    me.TR(me);
    me.TR(me);
    me.TR(me);
    me.TR(me);
    me.TR(me);
    me.TR(me);
    me.TR(me);
    me.TR(me);
    me.TR(me);
    me.TR(me);
    me.TR(me); // ???
        me.TD(me, 1, 20, e = makeNewMenuInputBox(1, "_menu_vote_string"));
        //e.saveImmediately = 1;
        vlist.textBox = e;
    me.TR(me);
        me.TD(me, 1, 10, e = makeNewMenuButton("Call the vote", '0 0 0'));
            e.onClick = VoteCall_f;
            e.onClickEntity = me;
        me.TD(me, 1, 10, e = makeNewMenuCommandButton("Cancel", '0 0 0', "", 1));
    
    me.voteList = vlist;
}
#endif

/* Click. The c-word is here so you can grep for it :-) */

