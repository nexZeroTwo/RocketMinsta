#ifdef INTERFACE
CLASS(NewMenuVideoSettingsTab) EXTENDS(NewMenuTab)
	METHOD(NewMenuVideoSettingsTab, fill, void(entity))
	ATTRIB(NewMenuVideoSettingsTab, title, string, "Video")
	ATTRIB(NewMenuVideoSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NewMenuVideoSettingsTab, rows, float, 17)
	ATTRIB(NewMenuVideoSettingsTab, columns, float, 6.5)
ENDCLASS(NewMenuVideoSettingsTab)
entity makeNewMenuVideoSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuVideoSettingsTab()
{
	entity me;
	me = spawnNewMenuVideoSettingsTab();
	me.configureDialog(me);
	return me;
}
void fillNewMenuVideoSettingsTab(entity me)
{
	entity e;

	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Resolution:"));
		me.TD(me, 1, 2, e = makeNewMenuResolutionSlider());
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Color depth:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(16, 32, 16, "vid_bitsperpixel"));
	me.TR(me);
		me.TD(me, 1, 1.5, e = makeNewMenuTextLabel(0, "Texture compression"));
		me.TD(me, 1, 0.5, e = makeNewMenuRadioButton(2, "gl_texturecompression", "0", "None"));
		me.TD(me, 1, 0.5, e = makeNewMenuRadioButton(2, "gl_texturecompression", "1", "Fast"));
		me.TD(me, 1, 0.5, e = makeNewMenuRadioButton(2, "gl_texturecompression", "2", "Good"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuCheckBox(0, "vid_fullscreen", "Full screen"));
		me.TD(me, 1, 2, e = makeNewMenuCheckBox(0, "vid_vsync", "Vertical Synchronization"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "r_glsl", "Use OpenGL 2.0 shaders (GLSL)"));
	me.TR(me);
		me.TD(me, 1, 2, e = makeNewMenuCheckBox(0, "r_coronas_occlusionquery", "Use Occlusion Queries"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuTextLabel(0, "Vertex Buffer Objects (VBOs)"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.9, e = makeNewMenuRadioButton(1, "gl_vbo", "0", "Off"));
		me.TD(me, 1, 2.1, e = makeNewMenuRadioButton(1, "gl_vbo", "3", "Vertices, some Tris (compatible)"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.9, e = makeNewMenuRadioButton(1, "gl_vbo", "2", "Vertices"));
		me.TD(me, 1, 2.1, e = makeNewMenuRadioButton(1, "gl_vbo", "1", "Vertices and Triangles"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Depth first:"));
		me.TD(me, 1, 2, e = makeNewMenuTextSlider("r_depthfirst"));
			e.addValue(e, "Disabled", "0");
			e.addValue(e, "World", "1");
			e.addValue(e, "All", "2");
			e.configureNewMenuTextSliderValues(e);
	me.TR(me);
		if(cvar_type("apple_multithreadedgl") & CVAR_TYPEFLAG_ENGINE)
			me.TD(me, 1, 3, e = makeNewMenuCheckBox(1, "apple_multithreadedgl", "Disable multithreaded OpenGL"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "gl_finish", "Wait for GPU to finish each frame"));

	me.gotoRC(me, 0, 3.5); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Brightness:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(0.0, 0.5, 0.02, "v_brightness"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Contrast:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(1.0, 3.0, 0.05, "v_contrast"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Gamma:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(0.5, 2.0, 0.05, "v_gamma"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Contrast boost:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(1.0, 5.0, 0.1, "v_contrastboost"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Saturation:"));
			setDependent(e, "r_glsl", 1, 1);
		me.TD(me, 1, 2, e = makeNewMenuSlider(0.5, 2.0, 0.05, "r_glsl_saturation"));
			setDependent(e, "r_glsl", 1, 1);
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "v_glslgamma", "Use GLSL to handle color control"));
			setDependent(e, "r_glsl", 1, 1);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Ambient:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(0, 20.0, 1.0, "r_ambient"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Intensity:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(0.5, 2.0, 0.05, "r_hdr_scenebrightness"));

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeNewMenuCommandButton("Apply immediately", '0 0 0', "vid_conwidth $menu_vid_conwidth; vid_conheight $menu_vid_conheight; vid_restart", COMMANDBUTTON_APPLY));
}
#endif
