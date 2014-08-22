#ifdef INTERFACE
CLASS(NewMenuInputSettingsTab) EXTENDS(NewMenuTab)
	METHOD(NewMenuInputSettingsTab, fill, void(entity))
	ATTRIB(NewMenuInputSettingsTab, title, string, "Input")
	ATTRIB(NewMenuInputSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NewMenuInputSettingsTab, rows, float, 17)
	ATTRIB(NewMenuInputSettingsTab, columns, float, 6.5)
ENDCLASS(NewMenuInputSettingsTab)
entity makeNewMenuInputSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuInputSettingsTab()
{
	entity me;
	me = spawnNewMenuInputSettingsTab();
	me.configureDialog(me);
	return me;
}
void fillNewMenuInputSettingsTab(entity me)
{
	entity e;
	entity kb;

	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuTextLabel(0, "Key bindings:"));
	me.TR(me);
		me.TD(me, me.rows - 2, 3, kb = makeNewMenuKeyBinder());
	me.gotoRC(me, me.rows - 1, 0);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuButton("Change key...", '0 0 0'));
			e.onClick = KeyBinder_Bind_Change;
			e.onClickEntity = kb;
			kb.keyGrabButton = e;
		me.TD(me, 1, 1, e = makeNewMenuButton("Edit...", '0 0 0'));
			e.onClick = KeyBinder_Bind_Edit;
			e.onClickEntity = kb;
			kb.userbindEditButton = e;
			kb.userbindEditDialog = main.userbindEditDialog;
			main.userbindEditDialog.keybindBox = kb;
		me.TD(me, 1, 1, e = makeNewMenuButton("Clear", '0 0 0'));
			e.onClick = KeyBinder_Bind_Clear;
			e.onClickEntity = kb;

	me.gotoRC(me, 0, 3.5); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Sensitivity:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(1, 64, 0.2, "sensitivity"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "UI mouse speed:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(0.2, 4.0, 0.1, "menu_mouse_speed"));
	if(cvar("menu_advanced") > 0){
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Look Down:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(-75, -120, 1, "in_pitch_min"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Look Up:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(75, 120, 1, "in_pitch_max"));
	}
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "m_filter", "Mouse filter"));
	if(cvar("menu_advanced") > 0){
		me.TR(me);
			me.TD(me, 1, 2.8, e = makeNewMenuCheckBox(0, "host_sleep", "Minimize input latency"));
	}
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuCheckBox(1.022, "m_pitch", "Invert mouse"));
	// No one uses this, at least no one who enjoys winning.
	if(cvar("menu_advanced") > 0){
		me.TR(me);
		if(cvar_type("joy_enable") & CVAR_TYPEFLAG_ENGINE)
			me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "joy_enable", "Use joystick input"));
		else if(cvar_type("joystick") & CVAR_TYPEFLAG_ENGINE)
			me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "joystick", "Use joystick input"));
	}

	me.TR(me);
		if(cvar_type("vid_dgamouse") & CVAR_TYPEFLAG_ENGINE)
			me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "vid_dgamouse", "Turn off OS mouse acceleration"));
		else if(cvar_type("apple_mouse_noaccel") & CVAR_TYPEFLAG_ENGINE)
			me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "apple_mouse_noaccel", "Turn off OS mouse acceleration"));
	if(cvar("menu_advanced") > 0){
		me.TR(me);
			me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "con_closeontoggleconsole", "\"enter console\" also closes"));
		me.TR(me);
			me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Show binds:"));
			me.TD(me, 1, 2, e = makeNewMenuTextSlider("sbar_showbinds"));
				e.addValue(e, "Actions", "0");
				e.addValue(e, "Bound keys", "1");
				e.addValue(e, "Both", "2");
				e.configureNewMenuTextSliderValues(e);
	}
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuCheckBoxEx(2, 0, "cl_showpressedkeys", "Show pressed keys"));
}
#endif
