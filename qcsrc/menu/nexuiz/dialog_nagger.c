#ifdef INTERFACE
CLASS(NexuizNaggerDialog) EXTENDS(NexuizRootDialog)
    METHOD(NexuizNaggerDialog, fill, void(entity))
    ATTRIB(NexuizNaggerDialog, title, string, "Unsupported engine")
    ATTRIB(NexuizNaggerDialog, color, vector, SKINCOLOR_DIALOG_QUIT)
    ATTRIB(NexuizNaggerDialog, intendedWidth, float, 0.7)
    ATTRIB(NexuizNaggerDialog, rows, float, 6)
    ATTRIB(NexuizNaggerDialog, columns, float, 2)
    ATTRIB(NexuizNaggerDialog, name, string, "engineNagger")
    ATTRIB(NexuizNaggerDialog, closable, float, FALSE)
    METHOD(NexuizNaggerDialog, close, void(entity))
    METHOD(NexuizNaggerDialog, keyDown, float(entity, float, float, float))
ENDCLASS(NexuizNaggerDialog)
#endif

#ifdef IMPLEMENTATION

void Nagger_Ok(entity button, entity me) {
    if(DPRM_VersionIsSuitable())
        show_engine_nagger = FALSE;
    m_goto(NULL);
}

void closeNexuizNaggerDialog(entity me) {
}

float keyDownNexuizNaggerDialog(entity me, float key, float ascii, float shift)
{
    if(key == K_ESCAPE)
        return TRUE;
    return keyDownDialog(me, key, ascii, shift);
}

void fillNexuizNaggerDialog(entity me) {
    entity e;

    me.TR(me);
        me.TD(me, 1, me.columns, makeNexuizTextLabel(0.5, "Your engine version is not supported."));
    me.TR(me);
        me.TD(me, 1, me.columns, e = makeNexuizTextLabel(0.5, "You will experience crashes, poor performance and bugs."));
        e.colorL = '1 1 0.1';
    me.TR(me);
        me.TD(me, 1, me.columns, makeNexuizTextLabel(0.5, "Please visit the following URL to update:"));
    me.TR(me);
        me.TD(me, 1, me.columns, e = makeNexuizTextLabel(0.5, DPRM_WEBSITE_URL));
        e.colorL = '0.1 1 0.1';
    me.TR(me);
    me.gotoRC(me, me.rows - 1, me.columns * 0.375);
        me.TD(me, 1, me.columns * 0.25, e = makeNexuizButton("OK", '1 0 0'));
            e.onClick = Nagger_Ok;
            e.onClickEntity = me;
}

#endif
