#ifdef INTERFACE
CLASS(NewMenuMultiplayerDialog) EXTENDS(NewMenuDialog)
	METHOD(NewMenuMultiplayerDialog, fill, void(entity))
	ATTRIB(NewMenuMultiplayerDialog, title, string, "Multiplayer")
	ATTRIB(NewMenuMultiplayerDialog, color, vector, SKINCOLOR_DIALOG_MULTIPLAYER)
	ATTRIB(NewMenuMultiplayerDialog, intendedWidth, float, 0.96)
	ATTRIB(NewMenuMultiplayerDialog, rows, float, 24)
	ATTRIB(NewMenuMultiplayerDialog, columns, float, 6)
ENDCLASS(NewMenuMultiplayerDialog)
#endif

#ifdef IMPLEMENTATION
void fillNewMenuMultiplayerDialog(entity me)
{
	entity mc, e;
	mc = makeNewMenuTabController(me.rows - 2);
	me.TR(me);
		me.TD(me, 1, 1, e = mc.makeTabButton(mc, "Servers",  makeNewMenuServerListTab()));
		me.TD(me, 1, 1, e = mc.makeTabButton(mc, "Create",  makeNewMenuServerCreateTab()));
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Demos",   makeNewMenuDemoBrowserTab()));
        me.TD(me, 1, 1, mc.makeTabButton(mc, "Music",   makeNewMenuMusicBrowserTab()));
		me.TD(me, 1, 1, e = mc.makeTabButton(mc, "Player Setup",  makeNewMenuPlayerSettingsTab()));
			if(cvar_string("_cl_name") == "Player")
				e.onClick(e, e.onClickEntity); // lol animation

	me.TR(me);
	me.TR(me);
		me.TD(me, me.rows - 2, me.columns, mc);
}
#endif
