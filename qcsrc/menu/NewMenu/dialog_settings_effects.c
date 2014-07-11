#ifdef INTERFACE
CLASS(NewMenuEffectsSettingsTab) EXTENDS(NewMenuTab)
	METHOD(NewMenuEffectsSettingsTab, fill, void(entity))
	ATTRIB(NewMenuEffectsSettingsTab, title, string, "Effects")
	ATTRIB(NewMenuEffectsSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NewMenuEffectsSettingsTab, rows, float, 17)
	ATTRIB(NewMenuEffectsSettingsTab, columns, float, 6.5)
ENDCLASS(NewMenuEffectsSettingsTab)
entity makeNewMenuEffectsSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuEffectsSettingsTab()
{
	entity me;
	me = spawnNewMenuEffectsSettingsTab();
	me.configureDialog(me);
	return me;
}

void fillNewMenuEffectsSettingsTab(entity me)
{
	entity e;
	float n;
	me.TR(me);
	me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Quality preset:"));
	if(cvar("menu_advanced") > 0){
		n = 8; //5 + 2 * !!cvar("developer");
		//if(cvar("developer"))
		me.TD(me, 1, 4 / n, e = makeNewMenuCommandButton("Nasty!", '0 0 0', "exec effects-omg.cfg", 0));
		me.TD(me, 1, 4 / n, e = makeNewMenuCommandButton("Ugly", '0 0 0', "exec effects-ugly.cfg", 0));
		me.TD(me, 1, 4 / n, e = makeNewMenuCommandButton("Low", '0 0 0', "exec effects-low.cfg", 0));
		me.TD(me, 1, 4 / n, e = makeNewMenuCommandButton("Medium", '0 0 0', "exec effects-med.cfg", 0));
		me.TD(me, 1, 4 / n, e = makeNewMenuCommandButton("Normal", '0 0 0', "exec effects-normal.cfg", 0));
		me.TD(me, 1, 4 / n, e = makeNewMenuCommandButton("High", '0 0 0', "exec effects-high.cfg", 0));
		me.TD(me, 1, 4 / n, e = makeNewMenuCommandButton("Ultra", '0 0 0', "exec effects-ultra.cfg", 0));
		me.TD(me, 1, 4 / n, e = makeNewMenuCommandButton("Wow!", '0 0 0', "exec effects-wow.cfg", 0));
	}
	else {
		n = 4;
		me.TD(me, 1, 4 / n, e = makeNewMenuCommandButton("Low", '0 0 0', "exec effects-low.cfg", 0));
		me.TD(me, 1, 4 / n, e = makeNewMenuCommandButton("Normal", '0 0 0', "exec effects-normal.cfg", 0));
		me.TD(me, 1, 4 / n, e = makeNewMenuCommandButton("High", '0 0 0', "exec effects-high.cfg", 0));
		me.TD(me, 1, 4 / n, e = makeNewMenuCommandButton("Wow!", '0 0 0', "exec effects-wow.cfg", 0));
	}

	me.TR(me);
	if(cvar("menu_advanced") > 0){
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Geometry detail:"));
		me.TD(me, 1, 2, e = makeNewMenuTextSlider("r_subdivisions_tolerance"));
#ifdef mini_menu
			e.addValue(e, "HELP ME", "32");
#endif
			e.addValue(e, "Lowest", "16");
			e.addValue(e, "Low", "8");
			e.addValue(e, "Normal", "4");
			e.addValue(e, "Good", "3");
#ifndef mini_menu
			e.addValue(e, "Best", "2");
#endif
			e.addValue(e, "Insane", "1");
			e.configureNewMenuTextSliderValues(e);
	}
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Antialiasing:"));
		me.TD(me, 1, 2, e = makeNewMenuTextSlider("vid_samples"));
			e.addValue(e, "Disabled", "1");
			e.addValue(e, "2x", "2");
			e.addValue(e, "4x", "4");
			e.configureNewMenuTextSliderValues(e);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Texture quality:"));
		me.TD(me, 1, 2, e = makeNewMenuTextSlider("gl_picmip"));
#ifdef mini_menu
				e.addValue(e, "Leet", "1337");
#endif
			e.addValue(e, "Lowest", "4");
			e.addValue(e, "Low", "3");
			e.addValue(e, "Normal", "2");
			e.addValue(e, "Good", "1");
			e.addValue(e, "Best", "0");
			e.configureNewMenuTextSliderValues(e);
	if(cvar("menu_advanced") > 0){
		me.TR(me);
			me.TDempty(me, 0.2);
			me.TD(me, 1, 2.8, e = makeNewMenuCheckBox(1, "r_picmipworld", "Reduce model texture quality only"));
				setDependent(e, "gl_picmip", 0.5, -0.5);
	}
	me.TR(me);
	me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Anisotropy:"));
		me.TD(me, 1, 2, e = makeNewMenuTextSlider("gl_texture_anisotropy"));
			e.addValue(e, "Disabled", "1");
			e.addValue(e, "2x", "2");
			e.addValue(e, "4x", "4");
			e.addValue(e, "8x", "8");
			e.addValue(e, "16x", "16");
			e.configureNewMenuTextSliderValues(e);
	me.TR(me);
	if(cvar("menu_advanced") > 0){
		me.TR(me);
#ifdef mini_menu
			me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "cl_particles", "Enable particles"));
#endif
			me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Particle quality:"));
			me.TD(me, 1, 2, e = makeNewMenuSlider(0.1, 1.0, 0.05, "cl_particles_quality"));
				setDependent(e, "cl_particles", 1, 1);
		me.TR(me);
			me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Particle dist.:"));
			me.TD(me, 1, 2, e = makeNewMenuSlider(500, 2000, 100, "r_drawparticles_drawdistance"));
				setDependent(e, "cl_particles", 1, 1);
		me.TR(me);
		me.TR(me);
			me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "cl_decals", "Decals"));
		me.TR(me);
			me.TDempty(me, 0.2);
			me.TD(me, 1, 0.8, e = makeNewMenuTextLabel(0, "Distance:"));
				setDependent(e, "cl_decals", 1, 1);
			me.TD(me, 1, 2, e = makeNewMenuSlider(200, 500, 20, "r_drawdecals_drawdistance"));
				setDependent(e, "cl_decals", 1, 1);
		me.TR(me);
			me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeNewMenuTextLabel(0, "Time:"));
		setDependent(e, "cl_decals", 1, 1);
		me.TD(me, 1, 2, e = makeNewMenuSlider(1, 20, 1, "cl_decals_time"));
			setDependent(e, "cl_decals", 1, 1);
	}

	me.gotoRC(me, 2, 3.5); me.setFirstColumn(me, me.currentColumn);
	me.TD(me, 1, 2, e = makeNewMenuCheckBox(1, "mod_q3bsp_nolightmaps", "Use lightmaps"));
	if(cvar("menu_advanced") > 0){
		me.TD(me, 1, 1.9, e = makeNewMenuCheckBox(0, "r_glsl_deluxemapping", "Deluxe mapping"));
			setDependentAND(e, "r_glsl", 1, 1, "mod_q3bsp_nolightmaps", 0, 0);
		me.TD(me, 1, 0.7, e = makeNewMenuCheckBox(0, "r_shadow_gloss", "Gloss"));
			setDependentAND3(e, "r_glsl", 1, 1, "r_glsl_deluxemapping", 1, 2, "mod_q3bsp_nolightmaps", 0, 0);
		me.TR(me);
			me.TD(me, 1, 1.5, e = makeNewMenuCheckBox(0, "r_glsl_offsetmapping", "Offset mapping"));
				setDependent(e, "r_glsl", 1, 1);
			me.TD(me, 1, 1.9, e = makeNewMenuCheckBox(0, "r_glsl_offsetmapping_reliefmapping", "Relief mapping"));
				setDependentAND(e, "r_glsl", 1, 1, "r_glsl_offsetmapping", 1, 1);
	}
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuCheckBox(0, "r_water", "Reflections:"));
			setDependent(e, "r_glsl", 1, 1);
		me.TD(me, 1, 2, e = makeNewMenuTextSlider("r_water_resolutionmultiplier"));
			e.addValue(e, "Blurred", "0.25");
			e.addValue(e, "Good", "0.5");
			e.addValue(e, "Sharp", "1");
			e.configureNewMenuTextSliderValues(e);
			setDependentAND(e, "r_glsl", 1, 1, "r_water", 1, 1);
	me.TR(me);
		if(cvar("developer"))
			me.TD(me, 1, 3, e = makeNewMenuCheckBoxEx(3, 0, "r_showsurfaces", "Show surfaces"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuRadioButton(1, string_null, string_null, "No dynamic lighting"));
	/* This is GARBAGE
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuRadioButton(1, "gl_flashblend", string_null, "Flash blend approximation"));
	*/
	me.TR(me);
		me.TD(me, 1, 2, e = makeNewMenuRadioButton(1, "r_shadow_realtime_dlight", string_null, "Realtime dynamic lighting"));
		me.TD(me, 1, 1, e = makeNewMenuCheckBox(0, "r_shadow_realtime_dlight_shadows", "Shadows"));
			setDependent(e, "r_shadow_realtime_dlight", 1, 1);
	me.TR(me);
		me.TD(me, 1, 2, e = makeNewMenuCheckBox(0, "r_shadow_realtime_world", "Realtime world lighting"));
		me.TD(me, 1, 1, e = makeNewMenuCheckBox(0, "r_shadow_realtime_world_shadows", "Shadows"));
			setDependent(e, "r_shadow_realtime_world", 1, 1);
	if(cvar("menu_advanced") > 0){
		me.TR(me);
			me.TDempty(me, 0.2);
			me.TD(me, 1, 2.8, e = makeNewMenuCheckBox(0, "r_shadow_usenormalmap", "Use normal maps"));
				setDependentOR(e, "r_shadow_realtime_dlight", 1, 1, "r_shadow_realtime_world", 1, 1);
		me.TR(me);
			me.TD(me, 1, 1, e = makeNewMenuCheckBox(0, "r_coronas", "Coronas"));
		me.TD(me, 1, 2, e = makeNewMenuCheckBox(0, "r_sky", "Render Sky Box"));
	}
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuCheckBox(0, "r_bloom", "Bloom"));
#ifdef 0
			setDependent(e, "r_hdr", 0, 0);
		me.TD(me, 1, 2, e = makeNewMenuCheckBox(0, "r_hdr", "High Dynamic Range (HDR)"));
#endif
	me.TR(me);
	
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Motion blur:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(0, 1, 0.1, "r_motionblur"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Damage blur:"));
			setDependent(e, "r_motionblur", 0, 1);
		me.TD(me, 1, 2, e = makeNewMenuSlider(0, 1, 0.1, "r_damageblur"));
			setDependent(e, "r_motionblur", 0, 1);
	
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeNewMenuCommandButton("Apply immediately", '0 0 0', "vid_conwidth $menu_vid_conwidth; vid_conheight $menu_vid_conheight; vid_restart", COMMANDBUTTON_APPLY));
}
#endif
