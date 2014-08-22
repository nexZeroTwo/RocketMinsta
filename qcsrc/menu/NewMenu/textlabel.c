#ifdef INTERFACE
CLASS(NewMenuTextLabel) EXTENDS(Label)
	METHOD(NewMenuTextLabel, configureNewMenuTextLabel, void(entity, float, string))
	METHOD(NewMenuTextLabel, draw, void(entity))
	ATTRIB(NewMenuTextLabel, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NewMenuTextLabel, alpha, float, SKINALPHA_TEXT)
	ATTRIB(NewMenuTextLabel, disabledAlpha, float, SKINALPHA_DISABLED)
ENDCLASS(NewMenuTextLabel)
entity makeNewMenuTextLabel(float theAlign, string theText);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuTextLabel(float theAlign, string theText)
{
	entity me;
	me = spawnNewMenuTextLabel();
	me.configureNewMenuTextLabel(me, theAlign, theText);
	return me;
}
void configureNewMenuTextLabelNewMenuTextLabel(entity me, float theAlign, string theText)
{
	me.configureLabel(me, theText, me.fontSize, theAlign);
}
void drawNewMenuTextLabel(entity me)
{
	drawLabel(me);
}
#endif
