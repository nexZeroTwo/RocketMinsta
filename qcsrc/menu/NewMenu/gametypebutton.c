#ifdef INTERFACE
CLASS(NewMenuGametypeButton) EXTENDS(RadioButton)
	METHOD(NewMenuGametypeButton, configureNewMenuGametypeButton, void(entity, float, string, string))
	METHOD(NewMenuGametypeButton, setChecked, void(entity, float))
	ATTRIB(NewMenuGametypeButton, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NewMenuGametypeButton, image, string, SKINGFX_BUTTON_BIG)
	ATTRIB(NewMenuGametypeButton, color, vector, SKINCOLOR_BUTTON_N)
	ATTRIB(NewMenuGametypeButton, colorC, vector, SKINCOLOR_BUTTON_C)
	ATTRIB(NewMenuGametypeButton, colorF, vector, SKINCOLOR_BUTTON_F)
	ATTRIB(NewMenuGametypeButton, colorD, vector, SKINCOLOR_BUTTON_D)
	ATTRIB(NewMenuGametypeButton, srcMulti, float, 1)
	ATTRIB(NewMenuGametypeButton, useDownAsChecked, float, 1)

	ATTRIB(NewMenuGametypeButton, cvarName, string, string_null)
	METHOD(NewMenuGametypeButton, loadCvars, void(entity))
	METHOD(NewMenuGametypeButton, saveCvars, void(entity))

	ATTRIB(NewMenuGametypeButton, alpha, float, SKINALPHA_TEXT)
	ATTRIB(NewMenuGametypeButton, disabledAlpha, float, SKINALPHA_DISABLED)
ENDCLASS(NewMenuGametypeButton)
entity makeNewMenuGametypeButton(float, string, string);
#endif

#ifdef IMPLEMENTATION
void GameTypeButton_Click(entity me, entity other);
entity makeNewMenuGametypeButton(float theGroup, string theCvar, string theText)
{
	entity me;
	me = spawnNewMenuGametypeButton();
	me.configureNewMenuGametypeButton(me, theGroup, theCvar, theText);
	return me;
}
void configureNewMenuGametypeButtonNewMenuGametypeButton(entity me, float theGroup, string theCvar, string theText)
{
	if(theCvar)
	{
		me.cvarName = theCvar;
		me.tooltip = getZonedTooltipForIdentifier(theCvar);
		me.loadCvars(me);
	}
	me.configureRadioButton(me, theText, me.fontSize, me.image, theGroup, 0);
	me.align = 0.5;
	me.onClick = GameTypeButton_Click;
	me.onClickEntity = NULL;
}
void setCheckedNewMenuGametypeButton(entity me, float val)
{
	if(val != me.checked)
	{
		me.checked = val;
		me.saveCvars(me);
	}
}
void loadCvarsNewMenuGametypeButton(entity me)
{
	if not(me.cvarName)
		return;

	me.checked = cvar(me.cvarName);
}
void saveCvarsNewMenuGametypeButton(entity me)
{
	if not(me.cvarName)
		return;

	cvar_set(me.cvarName, ftos(me.checked));
}
void GameTypeButton_Click(entity me, entity other)
{
	RadioButton_Click(me, other);
	me.parent.gameTypeChangeNotify(me.parent);
}
#endif
