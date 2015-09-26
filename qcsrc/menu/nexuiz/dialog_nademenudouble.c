#ifdef INTERFACE
CLASS(NexuizNadeMenuDoubleDialog) EXTENDS(NexuizRootDialog)
    METHOD(NexuizNadeMenuDoubleDialog, fill, void(entity)) // to be overridden by user to fill the dialog with controls
    ATTRIB(NexuizNadeMenuDoubleDialog, title, string, "Nadget Selection")
    ATTRIB(NexuizNadeMenuDoubleDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
    ATTRIB(NexuizNadeMenuDoubleDialog, intendedWidth, float, 0.35)
    ATTRIB(NexuizNadeMenuDoubleDialog, rows, float, 9)
    ATTRIB(NexuizNadeMenuDoubleDialog, columns, float, 2)
    ATTRIB(NexuizNadeMenuDoubleDialog, name, string, "NadeMenuDouble")
    ATTRIB(NexuizNadeMenuDoubleDialog, nadelist, entity, NULL)
    ATTRIB(NexuizNadeMenuDoubleDialog, nadelist2, entity, NULL)
    ATTRIB(NexuizNadeMenuDoubleDialog, acceptBtn, entity, NULL)
    METHOD(NexuizNadeMenuDoubleDialog, selectionUpdated, void(entity))
ENDCLASS(NexuizNadeMenuDoubleDialog)
#endif

#ifdef IMPLEMENTATION

void NadeMenuDouble_Close(entity button, entity me)
{
    localcmd("cmd hg_alwaysask ", ftos(CVAR(_rm_hg_alwaysask)), "; cmd hg_optout ", ftos(CVAR(_rm_hg_optout)), "\n");
    //me.nadelist.applyChanges(me.nadelist);


    localcmd("cmd picknade ", bufstr_get(me.nadelist.nadelist_buf, me.nadelist.selectedItem), " ", bufstr_get(me.nadelist2.nadelist_buf, me.nadelist2.selectedItem), "; cmd join\n");


    me.close(me);
}

void selectionUpdatedNexuizNadeMenuDoubleDialog(entity me) {
    string s1, s2;
    me.acceptBtn.disabled = FALSE;

    s1 = bufstr_get(me.nadelist.nadelist_buf, me.nadelist.selectedItem);
    if(s1 == "random")
        return;

    s2 = bufstr_get(me.nadelist2.nadelist_buf, me.nadelist2.selectedItem);
    if(s2 == "random")
        return;

    if(s1 == s2)
        me.acceptBtn.disabled = TRUE;

}

void fillNexuizNadeMenuDoubleDialog(entity me)
{
    entity e;
    NadeMenu_RegisterCvars();

    string s1 = strzone(strcat("Primary (", firstkeyfor("'+nadget' '+hook' '+button6'"), "):"));
    string s2 = strzone(strcat("Secondary (", firstkeyfor("'+nadget2' '+button9'"), "):"));

    me.TR(me);
        me.TD(me, 1, 1, makeNexuizTextLabel(0, s1));
        me.TD(me, 1, 1, makeNexuizTextLabel(0, s2));
    me.TR(me);
        me.TD(me, me.rows - 2, 1, me.nadelist = e = makeRMNadeList());
            e.notifyentity = me;
        me.TD(me, me.rows - 2, 1, me.nadelist2 = e = makeRMNadeList());
            e.notifyentity = me;
    me.gotoRC(me, me.rows - 3, 0);
    me.TR(me);
        me.TD(me, 1, me.columns, e = makeNexuizCheckBox(0, "_rm_hg_alwaysask", "Ask at each round"));
    //me.TR(me);
    //    me.TD(me, 1, me.columns, e = makeNexuizCheckBox(0, "_rm_hg_optout", "Opt out of bonuses"));
    me.TR(me);
        me.TD(me, 1, me.columns, me.acceptBtn = e = makeNexuizButton("Accept", '0 0 0'));
            e.onClick = NadeMenuDouble_Close;
            e.onClickEntity = me;

    selectionUpdatedNexuizNadeMenuDoubleDialog(me);
}
#endif

/* Click. The c-word is here so you can grep for it :-) */
