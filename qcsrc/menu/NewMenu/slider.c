#ifdef INTERFACE
CLASS(NewMenuSlider) EXTENDS(Slider)
	METHOD(NewMenuSlider, configureNewMenuSlider, void(entity, float, float, float, string))
	METHOD(NewMenuSlider, setValue, void(entity, float))
	ATTRIB(NewMenuSlider, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NewMenuSlider, valueSpace, float, SKINWIDTH_SLIDERTEXT)
	ATTRIB(NewMenuSlider, image, string, SKINGFX_SLIDER)
	ATTRIB(NewMenuSlider, tolerance, vector, SKINTOLERANCE_SLIDER)
	ATTRIB(NewMenuSlider, align, float, 0.5)
	ATTRIB(NewMenuSlider, color, vector, SKINCOLOR_SLIDER_N)
	ATTRIB(NewMenuSlider, colorC, vector, SKINCOLOR_SLIDER_C)
	ATTRIB(NewMenuSlider, colorF, vector, SKINCOLOR_SLIDER_F)
	ATTRIB(NewMenuSlider, colorD, vector, SKINCOLOR_SLIDER_D)
	ATTRIB(NewMenuSlider, color2, vector, SKINCOLOR_SLIDER_S)

	ATTRIB(NewMenuSlider, cvarName, string, string_null)
	METHOD(NewMenuSlider, loadCvars, void(entity))
	METHOD(NewMenuSlider, saveCvars, void(entity))

	ATTRIB(NewMenuSlider, alpha, float, SKINALPHA_TEXT)
	ATTRIB(NewMenuSlider, disabledAlpha, float, SKINALPHA_DISABLED)
ENDCLASS(NewMenuSlider)
entity makeNewMenuSlider(float, float, float, string);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuSlider(float theValueMin, float theValueMax, float theValueStep, string theCvar)
{
	entity me;
	me = spawnNewMenuSlider();
	me.configureNewMenuSlider(me, theValueMin, theValueMax, theValueStep, theCvar);
	return me;
}
void configureNewMenuSliderNewMenuSlider(entity me, float theValueMin, float theValueMax, float theValueStep, string theCvar)
{
	float v, vk, vp;
	v = theValueMin;
	vk = theValueStep;
	vp = theValueStep * 10;
	while(fabs(vp) < fabs(theValueMax - theValueMin) / 40)
		vp *= 10;
	me.configureSliderVisuals(me, me.fontSize, me.align, me.valueSpace, me.image);
	me.configureSliderValues(me, theValueMin, v, theValueMax, theValueStep, vk, vp);
	if(theCvar)
	{
		me.cvarName = theCvar;
		me.loadCvars(me);
		if(tooltipdb >= 0)
			me.tooltip = getZonedTooltipForIdentifier(theCvar);
	}
}
void setValueNewMenuSlider(entity me, float val)
{
	if(val != me.value)
	{
		me.value = val;
		me.saveCvars(me);
	}
}
void loadCvarsNewMenuSlider(entity me)
{
	if not(me.cvarName)
		return;

	me.value = cvar(me.cvarName);
}
void saveCvarsNewMenuSlider(entity me)
{
	if not(me.cvarName)
		return;

	cvar_set(me.cvarName, ftos(me.value));
}
#endif
