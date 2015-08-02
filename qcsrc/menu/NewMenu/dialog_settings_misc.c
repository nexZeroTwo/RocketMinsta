#ifdef INTERFACE
CLASS(NewMenuMiscSettingsTab) EXTENDS(NewMenuTab)
	METHOD(NewMenuMiscSettingsTab, fill, void(entity))
	ATTRIB(NewMenuMiscSettingsTab, title, string, "Misc")
	ATTRIB(NewMenuMiscSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NewMenuMiscSettingsTab, rows, float, 17)
	ATTRIB(NewMenuMiscSettingsTab, columns, float, 6.5)
ENDCLASS(NewMenuMiscSettingsTab)
entity makeNewMenuMiscSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuMiscSettingsTab()
{
	entity me;
	me = spawnNewMenuMiscSettingsTab();
	me.configureDialog(me);
	return me;
}
void fillNewMenuMiscSettingsTab(entity me)
{
	entity e;
	entity sk;

	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuTextLabel(0, "Menu skins:"));
	me.TR(me);
		me.TD(me, me.rows - 2, 3, sk = makeNewMenuSkinList());
	me.gotoRC(me, me.rows - 2, 0);
		me.TD(me, 1, 3, e = makeNewMenuButton("Apply immediately", '0 0 0'));
			e.onClick = SetSkin_Click;
			e.onClickEntity = sk;

	me.gotoRC(me, 0, 3.5); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "showtime", "Show current time"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "showdate", "Show current date"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "showfps", "Show frames per second"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "cl_showspeed", "Speedometer"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8/3, e = makeNewMenuRadioButton(1, "cl_showspeed_unit", "0", "qu/s (hidden)"));
			setDependent(e, "cl_showspeed", 1, 1);
		me.TD(me, 1, 2.8/3, e = makeNewMenuRadioButton(1, "cl_showspeed_unit", "1", "qu/s"));
			setDependent(e, "cl_showspeed", 1, 1);
		me.TD(me, 1, 2.8/3, e = makeNewMenuRadioButton(1, "cl_showspeed_unit", "2", "m/s"));
			setDependent(e, "cl_showspeed", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8/3, e = makeNewMenuRadioButton(1, "cl_showspeed_unit", "3", "km/h"));
			setDependent(e, "cl_showspeed", 1, 1);
		me.TD(me, 1, 2.8/3, e = makeNewMenuRadioButton(1, "cl_showspeed_unit", "4", "mph"));
			setDependent(e, "cl_showspeed", 1, 1);
		me.TD(me, 1, 2.8/3, e = makeNewMenuRadioButton(1, "cl_showspeed_unit", "5", "knots"));
			setDependent(e, "cl_showspeed", 1, 1);
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "cl_showacceleration", "Show accelerometer"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8/2, e = makeNewMenuTextLabel(0, "Accelerometer scale:"));
			setDependent(e, "cl_showacceleration", 1, 1);
		me.TD(me, 1, 2.8/2, e = makeNewMenuSlider(1, 10, 0.5, "cl_showacceleration_scale"));
			setDependent(e, "cl_showacceleration", 1, 1);
	me.TR(me);
	me.TR(me);
	if(CVAR(menu_advanced) > 0){
	me.TR(me);
		me.TDempty(me, 0.5);
		me.TD(me, 1, 2, e = makeNewMenuButton("Advanced settings...", '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.cvarsDialog;
		me.TDempty(me, 0.5);
	}
	me.gotoRC(me, me.rows - 1, 0);
	if(CVAR(menu_advanced) > 0)
		me.TD(me, 1, me.columns, makeNewMenuCommandButton("Switch to Basic Menu"   , '0 0 0', "set menu_advanced 0; menu_restart; togglemenu", COMMANDBUTTON_APPLY));
	else
		me.TD(me, 1, me.columns, makeNewMenuCommandButton("Switch to Advanced Menu", '0 0 0', "set menu_advanced 1; menu_restart; togglemenu", COMMANDBUTTON_APPLY));
}
#endif
