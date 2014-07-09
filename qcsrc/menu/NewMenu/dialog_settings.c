#ifdef INTERFACE
CLASS(NewMenuSettingsDialog) EXTENDS(NewMenuDialog)
	METHOD(NewMenuSettingsDialog, fill, void(entity))
	ATTRIB(NewMenuSettingsDialog, title, string, "Settings")
	ATTRIB(NewMenuSettingsDialog, color, vector, SKINCOLOR_DIALOG_SETTINGS)
	ATTRIB(NewMenuSettingsDialog, intendedWidth, float, 0.96)
	ATTRIB(NewMenuSettingsDialog, rows, float, 19)
	ATTRIB(NewMenuSettingsDialog, columns, float, 6)
ENDCLASS(NewMenuSettingsDialog)
#endif

#ifdef IMPLEMENTATION
void fillNewMenuSettingsDialog(entity me)
{
	entity mc;
	mc = makeNewMenuTabController(me.rows - 2);
	me.TR(me);
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Input",   makeNewMenuInputSettingsTab()));
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Video",   makeNewMenuVideoSettingsTab()));
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Effects", makeNewMenuEffectsSettingsTab()));
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Audio",   makeNewMenuAudioSettingsTab()));
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Network", makeNewMenuNetworkSettingsTab()));
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Misc",    makeNewMenuMiscSettingsTab()));
	me.TR(me);
	me.TR(me);
		me.TD(me, me.rows - 2, me.columns, mc);
}
#endif
