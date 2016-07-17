#ifdef INTERFACE
CLASS(NexuizMinorNaggerDialog) EXTENDS(NexuizNaggerDialog)
    METHOD(NexuizMinorNaggerDialog, fill, void(entity))
    ATTRIB(NexuizMinorNaggerDialog, title, string, "Engine update available")
    ATTRIB(NexuizMinorNaggerDialog, color, vector, SKINCOLOR_DIALOG_CREDITS)
    ATTRIB(NexuizMinorNaggerDialog, rows, float, 5)
    ATTRIB(NexuizMinorNaggerDialog, columns, float, 2)
ENDCLASS(NexuizMinorNaggerDialog)
#endif

#ifdef IMPLEMENTATION

void fillNexuizMinorNaggerDialog(entity me) {
    entity e;

    me.TR(me);
        me.TD(me, 1, me.columns, makeNexuizTextLabel(0.5, "A recommended engine update is available."));
    me.TR(me);
        me.TD(me, 1, me.columns, makeNexuizTextLabel(0.5, "Please visit the following URL to update:"));
    me.TR(me);
        me.TD(me, 1, me.columns, e = makeNexuizTextLabel(0.5, DPRM_WEBSITE_URL));
        e.colorL = '0.1 1 0.1';
    me.TR(me);
    me.gotoRC(me, me.rows - 1, me.columns * 0.375);
        me.TD(me, 1, me.columns * 0.25, e = makeNexuizButton("OK", '1 1 1'));
            e.onClick = Nagger_Ok;
            e.onClickEntity = me;
}

#endif
