#ifdef INTERFACE
CLASS(NexuizResolutionSlider) EXTENDS(NexuizTextSlider)
	METHOD(NexuizResolutionSlider, configureNexuizResolutionSlider, void(entity))
	METHOD(NexuizResolutionSlider, addResolution, void(entity, float, float))
	METHOD(NexuizResolutionSlider, loadCvars, void(entity))
	METHOD(NexuizResolutionSlider, saveCvars, void(entity))
ENDCLASS(NexuizResolutionSlider)
entity makeNexuizResolutionSlider();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizResolutionSlider()
{
	entity me;
	me = spawnNexuizResolutionSlider();
	me.configureNexuizResolutionSlider(me);
	return me;
}
void addResolutionNexuizResolutionSlider(entity me, float w, float h)
{
    // FIXME (in case you ever want to dynamically instantiate this): THIS IS NEVER FREED
    var res = strzone(strcat(ftos(w), "x", ftos(h)));
	me.addValue(me, res, res);
}
void configureNexuizResolutionSliderNexuizResolutionSlider(entity me)
{
	float i;
	vector r0, r;

    // Note: this cvar is used here for the tooltip only.
    // The slider will control the menu_vid_width/menu_vid_height cvars,
    // and only set vid_width/vid_height when "Apply" is pressed.
	me.configureNexuizTextSlider(me, "vid_width");

	r0 = '0 0 0';
	for(i = 0;; ++i)
	{
		r = getresolution(i);
		if(r_x == 0 && r_y == 0)
			break;
		if(r == r0)
			continue;
		r0 = r;
		if(r_x < 640 || r_y < 400)
			continue;
		me.addResolution(me, r_x, r_y);
	}

	me.configureNexuizTextSliderValues(me);
}
void loadCvarsNexuizResolutionSlider(entity me)
{
    me.setValueFromIdentifier(me, CVAR(vid_width) + "x" + CVAR(vid_height));
}
void saveCvarsNexuizResolutionSlider(entity me)
{
	if(me.value >= 0 || me.value < me.nValues)
	{
        tokenizebyseparator(me.getIdentifier(me), "x");
		cvar_set("menu_vid_width", argv(0));
		cvar_set("menu_vid_height", argv(1));
	}
}
#endif
