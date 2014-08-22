#ifdef INTERFACE
CLASS(NewMenuCrosshairButton) EXTENDS(RadioButton)
	METHOD(NewMenuCrosshairButton, configureNewMenuCrosshairButton, void(entity, float, float))
	METHOD(NewMenuCrosshairButton, setChecked, void(entity, float))
	METHOD(NewMenuCrosshairButton, draw, void(entity))
	ATTRIB(NewMenuCrosshairButton, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NewMenuCrosshairButton, image, string, SKINGFX_CROSSHAIRBUTTON)

	ATTRIB(NewMenuCrosshairButton, useDownAsChecked, float, 1)
	ATTRIB(NewMenuCrosshairButton, src3, string, string_null)

	ATTRIB(NewMenuCrosshairButton, cvarName, string, string_null)
	ATTRIB(NewMenuCrosshairButton, cvarValueFloat, float, 0)
	METHOD(NewMenuCrosshairButton, loadCvars, void(entity))
	METHOD(NewMenuCrosshairButton, saveCvars, void(entity))
ENDCLASS(NewMenuCrosshairButton)
entity makeNewMenuCrosshairButton(float, float);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuCrosshairButton(float theGroup, float theCrosshair)
{
	entity me;
	me = spawnNewMenuCrosshairButton();
	me.configureNewMenuCrosshairButton(me, theGroup, theCrosshair);
	return me;
}
void configureNewMenuCrosshairButtonNewMenuCrosshairButton(entity me, float theGroup, float theCrosshair)
{
	me.cvarName = "crosshair";
	me.cvarValueFloat = theCrosshair;
	me.loadCvars(me);
	me.configureRadioButton(me, string_null, me.fontSize, me.image, theGroup, 0);
	me.srcMulti = 1;
	me.src3 = strzone(strcat("/gfx/crosshair", ftos(me.cvarValueFloat)));
}
void setCheckedNewMenuCrosshairButton(entity me, float val)
{
	if(val != me.checked)
	{
		me.checked = val;
		me.saveCvars(me);
	}
}
void loadCvarsNewMenuCrosshairButton(entity me)
{
	if not(me.cvarName)
		return;

	me.checked = (cvar(me.cvarName) == me.cvarValueFloat);
}
void saveCvarsNewMenuCrosshairButton(entity me)
{
	if not(me.cvarName)
		return;

	if(me.checked)
		cvar_set(me.cvarName, ftos(me.cvarValueFloat));
	// TODO on an apply button, read _cl_color and execute the color command for it
}
void drawNewMenuCrosshairButton(entity me)
{
	vector sz, rgb;
	float a;

	rgb = eX * cvar("crosshair_color_red") + eY * cvar("crosshair_color_green") + eZ * cvar("crosshair_color_blue");
	a = cvar("crosshair_color_alpha");

	if(!me.checked && !me.focused)
	{
		a *= me.disabledAlpha;
		rgb = '1 1 1';
	}

	drawCheckBox(me);

	sz = draw_PictureSize(me.src3);
	sz = globalToBoxSize(sz, draw_scale);
	sz = sz * cvar("crosshair_size");
	if(sz_x > 0.95)
		sz = sz * (0.95 / sz_x);
	if(sz_y > 0.95)
		sz = sz * (0.95 / sz_y);

	draw_Picture('0.5 0.5 0' - 0.5 * sz, me.src3, sz, rgb, a);
}
#endif
