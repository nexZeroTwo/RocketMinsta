#ifdef INTERFACE
CLASS(NewMenuTextSlider) EXTENDS(TextSlider)
	METHOD(NewMenuTextSlider, configureNewMenuTextSlider, void(entity, string))
	METHOD(NewMenuTextSlider, setValue, void(entity, float))
	METHOD(NewMenuTextSlider, configureNewMenuTextSliderValues, void(entity))
	ATTRIB(NewMenuTextSlider, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NewMenuTextSlider, valueSpace, float, SKINWIDTH_SLIDERTEXT)
	ATTRIB(NewMenuTextSlider, image, string, SKINGFX_SLIDER)
	ATTRIB(NewMenuSlider, tolerance, vector, SKINTOLERANCE_SLIDER)
	ATTRIB(NewMenuTextSlider, align, float, 0.5)
	ATTRIB(NewMenuSlider, color, vector, SKINCOLOR_SLIDER_N)
	ATTRIB(NewMenuSlider, colorC, vector, SKINCOLOR_SLIDER_C)
	ATTRIB(NewMenuSlider, colorF, vector, SKINCOLOR_SLIDER_F)
	ATTRIB(NewMenuSlider, colorD, vector, SKINCOLOR_SLIDER_D)
	ATTRIB(NewMenuSlider, color2, vector, SKINCOLOR_SLIDER_S)

	ATTRIB(NewMenuTextSlider, cvarName, string, string_null)
	METHOD(NewMenuTextSlider, loadCvars, void(entity))
	METHOD(NewMenuTextSlider, saveCvars, void(entity))

	ATTRIB(NewMenuTextSlider, alpha, float, SKINALPHA_TEXT)
	ATTRIB(NewMenuTextSlider, disabledAlpha, float, SKINALPHA_DISABLED)
ENDCLASS(NewMenuTextSlider)
entity makeNewMenuTextSlider(string); // note: you still need to call addValue and configureNewMenuTextSliderValues!
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuTextSlider(string theCvar)
{
	entity me;
	me = spawnNewMenuTextSlider();
	me.configureNewMenuTextSlider(me, theCvar);
	return me;
}
void configureNewMenuTextSliderNewMenuTextSlider(entity me, string theCvar)
{
	me.configureSliderVisuals(me, me.fontSize, me.align, me.valueSpace, me.image);
	if(theCvar)
	{
		me.cvarName = theCvar;
		me.tooltip = getZonedTooltipForIdentifier(theCvar);
		// don't load it yet
	}
}
void setValueNewMenuTextSlider(entity me, float val)
{
	if(val != me.value)
	{
		me.value = val;
		me.saveCvars(me);
	}
}
void loadCvarsNewMenuTextSlider(entity me)
{
	if not(me.cvarName)
		return;

	me.setValueFromIdentifier(me, cvar_string(me.cvarName));
}
void saveCvarsNewMenuTextSlider(entity me)
{
	if not(me.cvarName)
		return;

	if(me.value >= 0 && me.value < me.nValues)
		cvar_set(me.cvarName, me.getIdentifier(me));
}
void configureNewMenuTextSliderValuesNewMenuTextSlider(entity me)
{
	me.configureTextSliderValues(me, string_null);
	me.loadCvars(me);
}
#endif
