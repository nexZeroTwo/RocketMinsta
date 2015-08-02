#ifdef INTERFACE
CLASS(NewMenuCreditsList) EXTENDS(NewMenuListBox)
	METHOD(NewMenuCreditsList, configureNewMenuCreditsList, void(entity))
	ATTRIB(NewMenuCreditsList, rowsPerItem, float, 1)
	METHOD(NewMenuCreditsList, draw, void(entity))
	METHOD(NewMenuCreditsList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(NewMenuCreditsList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(NewMenuCreditsList, keyDown, float(entity, float, float, float))
	METHOD(NewMenuCreditsList, destroy, void(entity))

	ATTRIB(NewMenuCreditsList, realFontSize, vector, '0 0 0')
	ATTRIB(NewMenuCreditsList, realUpperMargin, float, 0)
	ATTRIB(NewMenuCreditsList, bufferIndex, float, 0)
	ATTRIB(NewMenuCreditsList, scrolling, float, 0)
ENDCLASS(NewMenuCreditsList)
entity makeNewMenuCreditsList();
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuCreditsList()
{
	entity me;
	me = spawnNewMenuCreditsList();
	me.configureNewMenuCreditsList(me);
	return me;
}
void configureNewMenuCreditsListNewMenuCreditsList(entity me)
{
	me.configureNewMenuListBox(me);
	// load the file
	me.bufferIndex = buf_load(strcat(CVAR_STR(sys_project_name), "-credits.txt"));
	me.nItems = buf_getsize(me.bufferIndex);
}
void destroyNewMenuCreditsList(entity me)
{
	buf_del(me.bufferIndex);
}
void drawNewMenuCreditsList(entity me)
{
	float i;
	if(me.scrolling)
	{
		me.scrollPos = bound(0, (time - me.scrolling) * me.itemHeight, me.nItems * me.itemHeight - 1);
		i = min(me.selectedItem, floor((me.scrollPos + 1) / me.itemHeight - 1));
		i = max(i, ceil(me.scrollPos / me.itemHeight));
		me.setSelected(me, i);
	}
	drawListBox(me);
}
void resizeNotifyNewMenuCreditsList(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	resizeNotifyNewMenuListBox(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
	me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);
}
void drawListBoxItemNewMenuCreditsList(entity me, float i, vector absSize, float isSelected)
{
	// layout: Ping, Credits name, Map name, NP, TP, MP
	string s;
	float theAlpha;
	vector theColor;

	s = bufstr_get(me.bufferIndex, i);

	if(substring(s, 0, 2) == "**")
	{
		s = substring(s, 2, strlen(s) - 2);
		theColor = SKINCOLOR_CREDITS_TITLE;
		theAlpha = SKINALPHA_CREDITS_TITLE;
	}
	else if(substring(s, 0, 1) == "*")
	{
		s = substring(s, 1, strlen(s) - 1);
		theColor = SKINCOLOR_CREDITS_FUNCTION;
		theAlpha = SKINALPHA_CREDITS_FUNCTION;
	}
	else
	{
		theColor = SKINCOLOR_CREDITS_PERSON;
		theAlpha = SKINALPHA_CREDITS_PERSON;
	}

	draw_CenterText(me.realUpperMargin * eY + 0.5 * eX, s, me.realFontSize, theColor, theAlpha, 0);
}

float keyDownNewMenuCreditsList(entity me, float scan, float ascii, float shift)
{
	float i;
	me.dragScrollTimer = time;
	me.scrolling = 0;

	if(scan == K_PGUP)
		me.scrollPos = max(me.scrollPos - 0.5, 0);
	else if(scan == K_PGDN)
		me.scrollPos = min(me.scrollPos + 0.5, me.nItems * me.itemHeight - 1);
	else if(scan == K_UPARROW)
		me.scrollPos = max(me.scrollPos - me.itemHeight, 0);
	else if(scan == K_DOWNARROW)
		me.scrollPos = min(me.scrollPos + me.itemHeight, me.nItems * me.itemHeight - 1);
	else
		return keyDownListBox(me, scan, ascii, shift);

	i = min(me.selectedItem, floor((me.scrollPos + 1) / me.itemHeight - 1));
	i = max(i, ceil(me.scrollPos / me.itemHeight));
	me.setSelected(me, i);

	return 1;
}
#endif
