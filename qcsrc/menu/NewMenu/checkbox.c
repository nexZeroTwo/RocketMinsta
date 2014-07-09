#ifdef INTERFACE
CLASS(NewMenuCheckBox) EXTENDS(CheckBox)
	METHOD(NewMenuCheckBox, configureNewMenuCheckBox, void(entity, float, float, string, string))
	METHOD(NewMenuCheckBox, setChecked, void(entity, float))
	ATTRIB(NewMenuCheckBox, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NewMenuCheckBox, image, string, SKINGFX_CHECKBOX)
	ATTRIB(NewMenuCheckBox, yesValue, float, 1)
	ATTRIB(NewMenuCheckBox, noValue, float, 0)

	ATTRIB(NewMenuCheckBox, color, vector, SKINCOLOR_CHECKBOX_N)
	ATTRIB(NewMenuCheckBox, colorC, vector, SKINCOLOR_CHECKBOX_C)
	ATTRIB(NewMenuCheckBox, colorF, vector, SKINCOLOR_CHECKBOX_F)
	ATTRIB(NewMenuCheckBox, colorD, vector, SKINCOLOR_CHECKBOX_D)

	ATTRIB(NewMenuCheckBox, cvarName, string, string_null)
	METHOD(NewMenuCheckBox, loadCvars, void(entity))
	METHOD(NewMenuCheckBox, saveCvars, void(entity))

	ATTRIB(NewMenuCheckBox, alpha, float, SKINALPHA_TEXT)
	ATTRIB(NewMenuCheckBox, disabledAlpha, float, SKINALPHA_DISABLED)
ENDCLASS(NewMenuCheckBox)
entity makeNewMenuCheckBox(float, string, string);
entity makeNewMenuCheckBoxEx(float, float, string, string);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuCheckBox(float isInverted, string theCvar, string theText)
{
	float y, n;
	if(isInverted > 1)
	{
		n = isInverted - 1;
		y = -n;
	}
	else if(isInverted < -1)
	{
		n = isInverted + 1;
		y = -n;
	}
	else if(isInverted == 1)
	{
		n = 1;
		y = 0;
	}
	else
	{
		n = 0;
		y = 1;
	}
	return makeNewMenuCheckBoxEx(y, n, theCvar, theText);
}
entity makeNewMenuCheckBoxEx(float theYesValue, float theNoValue, string theCvar, string theText)
{
	entity me;
	me = spawnNewMenuCheckBox();
	me.configureNewMenuCheckBox(me, theYesValue, theNoValue, theCvar, theText);
	return me;
}
void configureNewMenuCheckBoxNewMenuCheckBox(entity me, float theYesValue, float theNoValue, string theCvar, string theText)
{
	me.yesValue = theYesValue;
	me.noValue = theNoValue;
	me.checked = 0;
	if(theCvar)
	{
		me.cvarName = theCvar;
		me.tooltip = getZonedTooltipForIdentifier(theCvar);
		me.loadCvars(me);
	}
	me.configureCheckBox(me, theText, me.fontSize, me.image);
}
void setCheckedNewMenuCheckBox(entity me, float val)
{
	if(val != me.checked)
	{
		me.checked = val;
		me.saveCvars(me);
	}
}
void loadCvarsNewMenuCheckBox(entity me)
{
	float m, d;

	if not(me.cvarName)
		return;

	m = (me.yesValue + me.noValue) * 0.5;
	d = (cvar(me.cvarName) - m) / (me.yesValue - m);
	me.checked = (d > 0);
}
void saveCvarsNewMenuCheckBox(entity me)
{
	if not(me.cvarName)
		return;

	if(me.checked)
		cvar_set(me.cvarName, ftos(me.yesValue));
	else
		cvar_set(me.cvarName, ftos(me.noValue));
}
#endif
