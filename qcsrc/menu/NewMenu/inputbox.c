#ifdef INTERFACE
CLASS(NewMenuInputBox) EXTENDS(InputBox)
	METHOD(NewMenuInputBox, configureNewMenuInputBox, void(entity, float, string))
	METHOD(NewMenuInputBox, focusLeave, void(entity))
	METHOD(NewMenuInputBox, setText, void(entity, string))
	ATTRIB(NewMenuInputBox, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NewMenuInputBox, image, string, SKINGFX_INPUTBOX)
	ATTRIB(NewMenuInputBox, onChange, void(entity, entity), SUB_Null)
	ATTRIB(NewMenuInputBox, onChangeEntity, entity, NULL)
	ATTRIB(NewMenuInputBox, onEnter, void(entity, entity), SUB_Null)
	ATTRIB(NewMenuInputBox, onEnterEntity, entity, NULL)
	ATTRIB(NewMenuInputBox, marginLeft, float, SKINMARGIN_INPUTBOX_CHARS)
	ATTRIB(NewMenuInputBox, marginRight, float, SKINMARGIN_INPUTBOX_CHARS)
	ATTRIB(NewMenuInputBox, color, vector, SKINCOLOR_INPUTBOX_N)
	ATTRIB(NewMenuInputBox, colorF, vector, SKINCOLOR_INPUTBOX_F)

	ATTRIB(NewMenuInputBox, alpha, float, SKINALPHA_TEXT)

	ATTRIB(NewMenuInputBox, cvarName, string, string_null)
	METHOD(NewMenuInputBox, loadCvars, void(entity))
	METHOD(NewMenuInputBox, saveCvars, void(entity))
	METHOD(NewMenuInputBox, keyDown, float(entity, float, float, float))
ENDCLASS(NewMenuInputBox)
entity makeNewMenuInputBox(float, string);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuInputBox(float doEditColorCodes, string theCvar)
{
	entity me;
	me = spawnNewMenuInputBox();
	me.configureNewMenuInputBox(me, doEditColorCodes, theCvar);
	return me;
}
void configureNewMenuInputBoxNewMenuInputBox(entity me, float doEditColorCodes, string theCvar)
{
	me.configureInputBox(me, "", 0, me.fontSize, me.image);
	me.editColorCodes = doEditColorCodes;
	if(theCvar)
	{
		me.cvarName = theCvar;
		me.tooltip = getZonedTooltipForIdentifier(theCvar);
		me.loadCvars(me);
	}
	me.cursorPos = strlen(me.text);
}
void focusLeaveNewMenuInputBox(entity me)
{
	me.saveCvars(me);
}
void setTextNewMenuInputBox(entity me, string new)
{
	if(me.text != new)
	{
		setTextInputBox(me, new);
		me.onChange(me, me.onChangeEntity);
	}
	else
		setTextInputBox(me, new);
}
void loadCvarsNewMenuInputBox(entity me)
{
	if not(me.cvarName)
		return;
	setTextInputBox(me, cvar_string(me.cvarName));
}
void saveCvarsNewMenuInputBox(entity me)
{
	if not(me.cvarName)
		return;
	cvar_set(me.cvarName, me.text);
}
float keyDownNewMenuInputBox(entity me, float key, float ascii, float shift)
{
	float r;
	r = 0;
	if(key == K_ENTER)
	{
		if(me.cvarName)
		{
			me.saveCvars(me);
			r = 1;
		}
		me.onEnter(me, me.onEnterEntity);
	}
	if(keyDownInputBox(me, key, ascii, shift))
		r = 1;
	return r;
}
#endif
