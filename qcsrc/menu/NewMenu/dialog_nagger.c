#ifdef INTERFACE
CLASS(NewMenuNaggerDialog) EXTENDS(NewMenuRootDialog)
    METHOD(NewMenuNaggerDialog, fill, void(entity))
    ATTRIB(NewMenuNaggerDialog, title, string, "Unsupported engine")
    ATTRIB(NewMenuNaggerDialog, color, vector, SKINCOLOR_DIALOG_QUIT)
    ATTRIB(NewMenuNaggerDialog, intendedWidth, float, 0.7)
    ATTRIB(NewMenuNaggerDialog, rows, float, 6)
    ATTRIB(NewMenuNaggerDialog, columns, float, 2)
    ATTRIB(NewMenuNaggerDialog, name, string, "engineNagger")
ENDCLASS(NewMenuNaggerDialog)
#endif

#ifdef IMPLEMENTATION
void fillNewMenuNaggerDialog(entity me) {
    entity e;
    me.TR(me);
        me.TD(me, 1, me.columns, makeNewMenuTextLabel(0.5, "Your engine version is not supported."));
    me.TR(me);
        me.TD(me, 1, me.columns, makeNewMenuTextLabel(0.5, "You may experience crashes, poor performance and bugs."));
    me.TR(me);
        me.TD(me, 1, me.columns, makeNewMenuTextLabel(0.5, "Please visit the following URL to update:"));
    me.TR(me);
        me.TD(me, 1, me.columns, e = makeNewMenuTextLabel(0.5, DPRM_WEBSITE_URL));
        e.colorL = '0.1 1 0.1';
    me.TR(me);
    me.gotoRC(me, me.rows - 1, me.columns * 0.375);
        me.TD(me, 1, me.columns * 0.25, e = makeNewMenuButton("OK", '1 0 0'));
            e.onClick = Dialog_Close;
            e.onClickEntity = me;
}

#endif
