#ifdef INTERFACE
CLASS(NewMenuColorButton) EXTENDS(RadioButton)
	METHOD(NewMenuColorButton, configureNewMenuColorButton, void(entity, float, float, float))
	METHOD(NewMenuColorButton, setChecked, void(entity, float))
	METHOD(NewMenuColorButton, draw, void(entity))
	ATTRIB(NewMenuColorButton, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NewMenuColorButton, image, string, SKINGFX_COLORBUTTON)
	ATTRIB(NewMenuColorButton, image2, string, SKINGFX_COLORBUTTON_COLOR)

	ATTRIB(NewMenuColorButton, useDownAsChecked, float, 1)

	ATTRIB(NewMenuColorButton, cvarPart, float, 0)
	ATTRIB(NewMenuColorButton, cvarName, string, string_null)
	ATTRIB(NewMenuColorButton, cvarValueFloat, float, 0)
	METHOD(NewMenuColorButton, loadCvars, void(entity))
	METHOD(NewMenuColorButton, saveCvars, void(entity))
ENDCLASS(NewMenuColorButton)
entity makeNewMenuColorButton(float, float, float);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuColorButton(float theGroup, float theColor, float theValue)
{
	entity me;
	me = spawnNewMenuColorButton();
	me.configureNewMenuColorButton(me, theGroup, theColor, theValue);
	return me;
}
void configureNewMenuColorButtonNewMenuColorButton(entity me, float theGroup, float theColor, float theValue)
{
	me.cvarName = "_cl_color";
	me.cvarValueFloat = theValue;
	me.cvarPart = theColor;
	me.loadCvars(me);
	me.configureRadioButton(me, string_null, me.fontSize, me.image, theGroup, 0);
	me.srcMulti = 1;
	me.src2 = me.image2;
}
void setCheckedNewMenuColorButton(entity me, float val)
{
	if(val != me.checked)
	{
		me.checked = val;
		me.saveCvars(me);
	}
}
void loadCvarsNewMenuColorButton(entity me)
{
	if not(me.cvarName)
		return;

	if(me.cvarPart == 1)
		me.checked = (cvar(me.cvarName) & 240) == me.cvarValueFloat * 16;
	else
		me.checked = (cvar(me.cvarName) & 15) == me.cvarValueFloat;
}
void saveCvarsNewMenuColorButton(entity me)
{
	if not(me.cvarName)
		return;

	if(me.checked)
	{
		if(me.cvarPart == 1)
			cvar_set(me.cvarName, ftos(cvar(me.cvarName) & 15 + me.cvarValueFloat * 16));
		else
			cvar_set(me.cvarName, ftos(cvar(me.cvarName) & 240 + me.cvarValueFloat));
	}
	// TODO on an apply button, read _cl_color and execute the color command for it
}
void drawNewMenuColorButton(entity me)
{
	me.color2 = colormapPaletteColor(me.cvarValueFloat, me.cvarPart);
	drawCheckBox(me);
}
#endif
