#ifdef INTERFACE
CLASS(NewMenuPlayerSettingsTab) EXTENDS(NewMenuTab)
	METHOD(NewMenuPlayerSettingsTab, fill, void(entity))
	METHOD(NewMenuPlayerSettingsTab, draw, void(entity))
	ATTRIB(NewMenuPlayerSettingsTab, title, string, "Player Setup")
	ATTRIB(NewMenuPlayerSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NewMenuPlayerSettingsTab, rows, float, 22)
	ATTRIB(NewMenuPlayerSettingsTab, columns, float, 6.5)
	ATTRIB(NewMenuPlayerSettingsTab, playerNameLabel, entity, NULL)
	ATTRIB(NewMenuPlayerSettingsTab, playerNameLabelAlpha, float, 0)
ENDCLASS(NewMenuPlayerSettingsTab)
entity makeNewMenuPlayerSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuPlayerSettingsTab()
{
	entity me;
	me = spawnNewMenuPlayerSettingsTab();
	me.configureDialog(me);
	return me;
}
void drawNewMenuPlayerSettingsTab(entity me)
{
	if(cvar_string("_cl_name") == "Player")
		me.playerNameLabel.alpha = ((mod(time * 2, 2) < 1) ? 1 : 0);
	else
		me.playerNameLabel.alpha = me.playerNameLabelAlpha;
	drawContainer(me);
}
void fillNewMenuPlayerSettingsTab(entity me)
{
	entity e, pms, sl, label, e0, box;
	float i, r, m, n;

	me.TR(me);
		me.TD(me, 1, 0.5, me.playerNameLabel = makeNewMenuTextLabel(0, "Name:"));
			me.playerNameLabelAlpha = me.playerNameLabel.alpha;
		me.TD(me, 1, 2.5, label = makeNewMenuTextLabel(0, string_null));
			label.allowCut = 1;
			label.allowColors = 1;
			label.alpha = 1;
	me.TR(me);
		me.TD(me, 1, 3.0, box = makeNewMenuInputBox(1, "_cl_name"));
			box.forbiddenCharacters = "\r\n\\\"$"; // don't care, isn't getting saved
			box.maxLength = 63;
			label.textEntity = box;
	me.TR(me);
		me.TD(me, 5, 1, e = makeNewMenuColorpicker(box));
		me.TD(me, 5, 2, e = makeNewMenuCharmap(box));
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.gotoRC(me, 8, 0.0);
		pms = makeNewMenuPlayerModelSelector();
		me.TD(me, 1, 0.6, e = makeNewMenuTextLabel(1, "Model:"));
		me.TD(me, 1, 0.3, e = makeNewMenuButton("<<", '0 0 0'));
			e.onClick = PlayerModelSelector_Prev_Click;
			e.onClickEntity = pms;
		me.TD(me, me.rows - me.currentRow - 1, 1.8, pms);
		me.TD(me, 1, 0.3, e = makeNewMenuButton(">>", '0 0 0'));
			e.onClick = PlayerModelSelector_Next_Click;
			e.onClickEntity = pms;
	me.TR(me);
		r = me.currentRow;
		m = me.rows - r - 2;
		n = 16 - !cvar("developer");
		m = m / (n - 1);
		for(i = 0; i < n; ++i)
		{
			me.gotoRC(me, r + i * m, 0.1);
			me.TDNoMargin(me, m, 0.2, e = makeNewMenuColorButton(1, 0, i), '0 1 0');
		}
		for(i = 0; i < n; ++i)
		{
			me.gotoRC(me, r + i * m, 0.4);
			me.TDNoMargin(me, m, 0.2, e = makeNewMenuColorButton(2, 1, i), '0 1 0');
		}

	me.gotoRC(me, 0, 3.5); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Field of View:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(60, 130, 1, "fov"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Damage kick:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(0, 0.5, 0.05, "v_kicktime"));
	me.TR(me);
		sl = makeNewMenuSlider(0.45, 0.75, 0.01, "cl_bobcycle");
		me.TD(me, 1, 1, e = makeNewMenuSliderCheckBox(0, 1, sl, "View bobbing:"));
		me.TD(me, 1, 2, sl);
	
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Zoom Factor:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(2, 16, 0.5, "cl_zoomfactor"));
	me.TR(me);
		sl = makeNewMenuSlider(1, 8, 0.5, "cl_zoomspeed");
		me.TD(me, 1, 1, e = makeNewMenuSliderCheckBox(-1, 1, sl, "Zoom speed:"));
		me.TD(me, 1, 2, sl);
	me.TR(me);
		me.TD(me, 1, 1.5, e = makeNewMenuButton("Weapon settings...", '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.weaponsDialog;
		me.TD(me, 1, 1.5, e0 = makeNewMenuTextLabel(0, string_null));
			e0.textEntity = main.weaponsDialog;
			e0.allowCut = 1;
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 2, e = makeNewMenuCheckBox(0, "crosshair_per_weapon", "Per weapon crosshairs"));
		me.TD(me, 1, 1.3, e = makeNewMenuCheckBox(1, "crosshair_color_override", "& crosshair colors"));
		setDependent(e, "crosshair_per_weapon", 1, 1);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Crosshair:"));
		for(i = 1; i <= 10; ++i) {
			me.TDNoMargin(me, 1, 2 / 10, e = makeNewMenuCrosshairButton(3, i), '1 1 0');
			setDependent(e, "crosshair_per_weapon", 0, 0);
		}
	me.TR(me);
		me.TDempty(me, 1);
		for(i = 11; i <= 20; ++i) {
			me.TDNoMargin(me, 1, 2 / 10, e = makeNewMenuCrosshairButton(3, i), '1 1 0');
			setDependent(e, "crosshair_per_weapon", 0, 0);
		}
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Crosshair Size:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(0.40, 2, 0.05, "crosshair_size"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Crosshair Alpha:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(0, 1, 0.01, "crosshair_color_alpha"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Crosshair Red:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(0, 1, 0.01, "crosshair_color_red"));
		setDependentOR(e, "crosshair_per_weapon", 0, 0, "crosshair_color_override", 1, 1);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Crosshair Green:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(0, 1, 0.01, "crosshair_color_green"));
		setDependentOR(e, "crosshair_per_weapon", 0, 0, "crosshair_color_override", 1, 1);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Crosshair Blue:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(0, 1, 0.01, "crosshair_color_blue"));
		setDependentOR(e, "crosshair_per_weapon", 0, 0, "crosshair_color_override", 1, 1);
	if(cvar("menu_advanced") > 0){
		me.TR(me);
			me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Hit test:"));
			me.TD(me, 1, 2/3, e = makeNewMenuRadioButton(1, "crosshair_hittest", "0",    "None"));
			me.TD(me, 1, 2/3, e = makeNewMenuRadioButton(1, "crosshair_hittest", "1",    "TrueAim"));
			me.TD(me, 1, 2/3, e = makeNewMenuRadioButton(1, "crosshair_hittest", "1.25", "Enemies"));
	}
	me.TR(me);
		me.TDempty(me, 0.4);
		me.TD(me, 1, 2.2, e = makeNewMenuButton("Radar, HUD & Waypoints...", '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.radarDialog;
		me.TDempty(me, 0.5);
	me.TR(me);
	#ifdef ALLOW_FORCEMODELS
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Force Models:"));
		me.TD(me, 1, 2/3, e = makeNewMenuRadioButton(2, string_null, string_null, "None"));
		me.TD(me, 1, 2/3, e = makeNewMenuRadioButton(2, "cl_forceplayermodelsfromNewMenu", string_null, "Custom"));
		me.TD(me, 1, 2/3, e = makeNewMenuRadioButton(2, "cl_forceplayermodels", string_null, "All"));
	#endif
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "cl_gentle", "Disable gore effects"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Gibs:"));
		me.TD(me, 1, 2, e = makeNewMenuTextSlider("cl_nogibs"));
			e.addValue(e, "None", "1");
			e.addValue(e, "Few", "0.75");
			e.addValue(e, "Many", "0.5");
			e.addValue(e, "Lots", "0");
			e.configureNewMenuTextSliderValues(e);
			setDependent(e, "cl_gentle", 0, 0);
	me.TR(me);

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeNewMenuCommandButton("Apply immediately", '0 0 0', "color -1 -1;name \"$_cl_name\";sendcvar cl_weaponpriority;sendcvar cl_zoomfactor;sendcvar cl_zoomspeed;sendcvar cl_autoswitch;sendcvar cl_shownames;sendcvar cl_forceplayermodelsfromNewMenu;sendcvar cl_forceplayermodels", COMMANDBUTTON_APPLY));
}
#endif
