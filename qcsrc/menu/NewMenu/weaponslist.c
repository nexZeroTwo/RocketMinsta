#ifdef INTERFACE
CLASS(NewMenuWeaponsList) EXTENDS(NewMenuListBox)
	METHOD(NewMenuWeaponsList, configureNewMenuWeaponsList, void(entity))
	METHOD(NewMenuWeaponsList, toString, string(entity))
	ATTRIB(NewMenuWeaponsList, rowsPerItem, float, 1)
	METHOD(NewMenuWeaponsList, draw, void(entity))
	METHOD(NewMenuWeaponsList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(NewMenuWeaponsList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(NewMenuWeaponsList, keyDown, float(entity, float, float, float))
	ATTRIB(NewMenuWeaponsList, realFontSize, vector, '0 0 0')
	ATTRIB(NewMenuWeaponsList, realUpperMargin, float, 0)
	METHOD(NewMenuWeaponsList, mouseDrag, float(entity, vector))
	ATTRIB(NewMenuWeaponsList, scrollbarWidth, float, 0)
ENDCLASS(NewMenuWeaponsList)
entity makeNewMenuWeaponsList();
void WeaponsList_MoveUp_Click(entity btn, entity me);
void WeaponsList_MoveDown_Click(entity box, entity me);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuWeaponsList()
{
	entity me;
	me = spawnNewMenuWeaponsList();
	me.configureNewMenuWeaponsList(me);
	return me;
}
void configureNewMenuWeaponsListNewMenuWeaponsList(entity me)
{
	me.configureNewMenuListBox(me);
}
void drawNewMenuWeaponsList(entity me)
{
	// read in cvar?
	string s, t;
	s = CVAR_STR(cl_weaponpriority);
	t = W_FixWeaponOrder(s, 1);
	if(t != s)
	{
		print("AUTOFIXED\n");
		cvar_set("cl_weaponpriority", t);
	}
	me.nItems = tokenize_console(t);
	drawListBox(me);
}
void WeaponsList_MoveUp_Click(entity box, entity me)
{
	if(me.selectedItem > 0)
	{
		cvar_set("cl_weaponpriority", swapInPriorityList(CVAR_STR(cl_weaponpriority), me.selectedItem - 1, me.selectedItem));
		me.selectedItem -= 1;
	}
}
void WeaponsList_MoveDown_Click(entity box, entity me)
{
	if(me.selectedItem < me.nItems - 1)
	{
		cvar_set("cl_weaponpriority", swapInPriorityList(CVAR_STR(cl_weaponpriority), me.selectedItem, me.selectedItem + 1));
		me.selectedItem += 1;
	}
}
void resizeNotifyNewMenuWeaponsList(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	resizeNotifyNewMenuListBox(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
	me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);
}
float mouseDragNewMenuWeaponsList(entity me, vector pos)
{
	float f, i;
	i = me.selectedItem;
	f = mouseDragListBox(me, pos);
	if(me.selectedItem != i)
		cvar_set("cl_weaponpriority", swapInPriorityList(CVAR_STR(cl_weaponpriority), me.selectedItem, i));
	return f;
}
string toStringNewMenuWeaponsList(entity me)
{
	float n, i;
	string s;
	entity e;
	n = tokenize_console(CVAR_STR(cl_weaponpriority));
	s = "";
	for(i = 0; i < n; ++i)
	{
		e = get_weaponinfo(stof(argv(i)));
		s = strcat(s, e.message, ", ");
	}
	return substring(s, 0, strlen(s) - 2);
}
void drawListBoxItemNewMenuWeaponsList(entity me, float i, vector absSize, float isSelected)
{
	entity e;
	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
	e = get_weaponinfo(stof(argv(i)));
	draw_Text(me.realUpperMargin * eY, e.message, me.realFontSize, '1 1 1', SKINALPHA_TEXT, 0);
}

float keyDownNewMenuWeaponsList(entity me, float scan, float ascii, float shift)
{
	if(ascii == 43) // +
	{
		WeaponsList_MoveUp_Click(NULL, me);
		return 1;
	}
	else if(scan == 45) // -
	{
		WeaponsList_MoveDown_Click(NULL, me);
		return 1;
	}
	else if(keyDownListBox(me, scan, ascii, shift))
		return 1;
	return 0;
}
#endif
