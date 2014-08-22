#ifdef INTERFACE
CLASS(NewMenuBigButton) EXTENDS(NewMenuButton)
	METHOD(NewMenuBigButton, configureNewMenuBigButton, void(entity, string, vector))
	ATTRIB(NewMenuBigButton, image, string, SKINGFX_BUTTON_BIG)
	ATTRIB(NewMenuBigButton, grayImage, string, SKINGFX_BUTTON_BIG_GRAY)
ENDCLASS(NewMenuButton)
entity makeNewMenuButton(string theText, vector theColor);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuBigButton(string theText, vector theColor)
{
	entity me;
	me = spawnNewMenuBigButton();
	me.configureNewMenuBigButton(me, theText, theColor);
	return me;
}

void configureNewMenuBigButtonNewMenuBigButton(entity me, string theText, vector theColor)
{
	me.configureNewMenuButton(me, theText, theColor);
}
#endif
