#ifdef INTERFACE
CLASS(NewMenuBigCommandButton) EXTENDS(NewMenuCommandButton)
	METHOD(NewMenuBigCommandButton, configureNewMenuBigCommandButton, void(entity, string, vector, string, float))
	ATTRIB(NewMenuBigCommandButton, image, string, SKINGFX_BUTTON_BIG)
	ATTRIB(NewMenuBigCommandButton, grayImage, string, SKINGFX_BUTTON_BIG_GRAY)
ENDCLASS(NewMenuCommandButton)
entity makeNewMenuBigCommandButton(string theText, vector theColor, string theCommand, float closesMenu);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuBigCommandButton(string theText, vector theColor, string theCommand, float theFlags)
{
	entity me;
	me = spawnNewMenuBigCommandButton();
	me.configureNewMenuBigCommandButton(me, theText, theColor, theCommand, theFlags);
	return me;
}

void configureNewMenuBigCommandButtonNewMenuBigCommandButton(entity me, string theText, vector theColor, string theCommand, float theFlags)
{
	me.configureNewMenuCommandButton(me, theText, theColor, theCommand, theFlags);
}
#endif
