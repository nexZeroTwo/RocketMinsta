#ifdef INTERFACE
CLASS(NewMenuRadioButton) EXTENDS(RadioButton)
	METHOD(NewMenuRadioButton, configureNewMenuRadioButton, void(entity, float, string, string, string))
	METHOD(NewMenuRadioButton, draw, void(entity))
	METHOD(NewMenuRadioButton, setChecked, void(entity, float))
	ATTRIB(NewMenuRadioButton, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NewMenuRadioButton, image, string, SKINGFX_RADIOBUTTON)
	ATTRIB(NewMenuRadioButton, color, vector, SKINCOLOR_RADIOBUTTON_N)
	ATTRIB(NewMenuRadioButton, colorC, vector, SKINCOLOR_RADIOBUTTON_C)
	ATTRIB(NewMenuRadioButton, colorF, vector, SKINCOLOR_RADIOBUTTON_F)
	ATTRIB(NewMenuRadioButton, colorD, vector, SKINCOLOR_RADIOBUTTON_D)

	ATTRIB(NewMenuRadioButton, cvarName, string, string_null)
	ATTRIB(NewMenuRadioButton, cvarValue, string, string_null)
	ATTRIB(NewMenuRadioButton, cvarOffValue, string, string_null)
	METHOD(NewMenuRadioButton, loadCvars, void(entity))
	METHOD(NewMenuRadioButton, saveCvars, void(entity))

	ATTRIB(NewMenuRadioButton, alpha, float, SKINALPHA_TEXT)
	ATTRIB(NewMenuRadioButton, disabledAlpha, float, SKINALPHA_DISABLED)
ENDCLASS(NewMenuRadioButton)
entity makeNewMenuRadioButton(float, string, string, string);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuRadioButton(float theGroup, string theCvar, string theValue, string theText)
{
	entity me;
	me = spawnNewMenuRadioButton();
	me.configureNewMenuRadioButton(me, theGroup, theCvar, theValue, theText);
	return me;
}
void configureNewMenuRadioButtonNewMenuRadioButton(entity me, float theGroup, string theCvar, string theValue, string theText)
{
	if(theCvar)
	{
		me.cvarName = theCvar;
		me.cvarValue = theValue;
		me.tooltip = getZonedTooltipForIdentifier(theCvar);
		me.loadCvars(me);
	}
	me.configureRadioButton(me, theText, me.fontSize, me.image, theGroup, 0);
}
void setCheckedNewMenuRadioButton(entity me, float val)
{
	if(val != me.checked)
	{
		me.checked = val;
		me.saveCvars(me);
	}
}
void loadCvarsNewMenuRadioButton(entity me)
{
	if(me.cvarValue)
	{
		if(me.cvarName)
			me.checked = (cvar_string(me.cvarName) == me.cvarValue);
	}
	else
	{
		if(me.cvarName)
		{
			me.checked = !!cvar(me.cvarName);
		}
		else
		{
			// this is difficult
			// this is the "generic" selection... but at this time, not
			// everything is constructed yet.
			// we need to set this later in draw()
			me.checked = 0;
		}
	}
}
void drawNewMenuRadioButton(entity me)
{
	if not(me.cvarValue)
		if not(me.cvarName)
		{
			// this is the "other" option
			// always select this if none other is
			entity e;
			float found;
			found = 0;
			for(e = me.parent.firstChild; e; e = e.nextSibling)
				if(e.group == me.group)
					if(e.checked)
						found = 1;
			if(!found)
				me.setChecked(me, 1);
		}
	drawCheckBox(me);
}
void saveCvarsNewMenuRadioButton(entity me)
{
	if(me.cvarValue)
	{
		if(me.cvarName)
		{
			if(me.checked)
				cvar_set(me.cvarName, me.cvarValue);
			else if(me.cvarOffValue)
				cvar_set(me.cvarName, me.cvarOffValue);
		}
	}
	else
	{
		if(me.cvarName)
		{
			cvar_set(me.cvarName, ftos(me.checked));
		}
	}
}
#endif
