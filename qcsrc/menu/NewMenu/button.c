#ifdef INTERFACE
CLASS(NewMenuButton) EXTENDS(Button)
	METHOD(NewMenuButton, configureNewMenuButton, void(entity, string, vector))
	ATTRIB(NewMenuButton, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NewMenuButton, image, string, SKINGFX_BUTTON)
	ATTRIB(NewMenuButton, grayImage, string, SKINGFX_BUTTON_GRAY)
	ATTRIB(NewMenuButton, color, vector, SKINCOLOR_BUTTON_N)
	ATTRIB(NewMenuButton, colorC, vector, SKINCOLOR_BUTTON_C)
	ATTRIB(NewMenuButton, colorF, vector, SKINCOLOR_BUTTON_F)
	ATTRIB(NewMenuButton, colorD, vector, SKINCOLOR_BUTTON_D)
	ATTRIB(NewMenuButton, alpha, float, SKINALPHA_TEXT)
	ATTRIB(NewMenuButton, disabledAlpha, float, SKINALPHA_DISABLED)
ENDCLASS(NewMenuButton)
entity makeNewMenuButton(string theText, vector theColor);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuButton(string theText, vector theColor)
{
	entity me;
	me = spawnNewMenuButton();
	me.configureNewMenuButton(me, theText, theColor);
	return me;
}

void configureNewMenuButtonNewMenuButton(entity me, string theText, vector theColor)
{
	if(theColor == '0 0 0')
	{
		me.configureButton(me, theText, me.fontSize, me.image);
	}
	else
	{
		me.configureButton(me, theText, me.fontSize, me.grayImage);
		me.color = theColor;
		me.colorC = theColor;
		me.colorF = theColor;
	}
	me.tooltip = getZonedTooltipForIdentifier(strcat(currentDialog.classname, "/", me.text));
}
#endif
