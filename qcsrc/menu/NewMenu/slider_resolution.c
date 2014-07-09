#ifdef INTERFACE
CLASS(NewMenuResolutionSlider) EXTENDS(NewMenuTextSlider)
	METHOD(NewMenuResolutionSlider, configureNewMenuResolutionSlider, void(entity))
	METHOD(NewMenuResolutionSlider, addResolution, void(entity, float, float, float, float))
	METHOD(NewMenuResolutionSlider, loadCvars, void(entity))
	METHOD(NewMenuResolutionSlider, saveCvars, void(entity))
ENDCLASS(NewMenuResolutionSlider)
entity makeNewMenuResolutionSlider();
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuResolutionSlider()
{
	entity me;
	me = spawnNewMenuResolutionSlider();
	me.configureNewMenuResolutionSlider(me);
	return me;
}
void addResolutionNewMenuResolutionSlider(entity me, float w, float h, float cw, float ch)
{
	float f;
	f = max(cw / w, ch / h);
	if(f > 1)
	{
		cw = rint(cw / f);
		ch = rint(ch / f);
	}
	me.addValue(me, strzone(strcat(ftos(w), "x", ftos(h))), strzone(strcat(ftos(w), " ", ftos(h), " ", ftos(cw), " ", ftos(ch))));
	// FIXME (in case you ever want to dynamically instantiate this): THIS IS NEVER FREED
}
void configureNewMenuResolutionSliderNewMenuResolutionSlider(entity me)
{
	float i;
	vector r0, r, c;

	me.configureNewMenuTextSlider(me, "vid_width");

	c = '0 0 0';
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
		c_x = 800;
		c_y = rint(c_x * r_y / r_x);
		if(c_y >= 600)
		{
			me.addResolution(me, r_x, r_y, c_x, c_y);
			continue;
		}
		c_y = 600;
		c_x = rint(c_y * r_x / r_y);
		me.addResolution(me, r_x, r_y, c_x, c_y);
	}

	me.configureNewMenuTextSliderValues(me);
}
void loadCvarsNewMenuResolutionSlider(entity me)
{
	me.setValueFromIdentifier(me, strcat(cvar_string("vid_width"), " ", cvar_string("vid_height"), " ", cvar_string("menu_vid_conwidth"), " ", cvar_string("menu_vid_conheight")));
}
void saveCvarsNewMenuResolutionSlider(entity me)
{
	if(me.value >= 0 || me.value < me.nValues)
	{
		tokenize_console(me.getIdentifier(me));
		cvar_set("vid_width", argv(0));
		cvar_set("vid_height", argv(1));
		cvar_set("menu_vid_conwidth", argv(2));
		cvar_set("menu_vid_conheight", argv(3));
	}
}
#endif
