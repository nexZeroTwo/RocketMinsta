#ifdef INTERFACE
CLASS(NewMenuSliderCheckBox) EXTENDS(CheckBox)
	METHOD(NewMenuSliderCheckBox, configureNewMenuSliderCheckBox, void(entity, float, float, entity, string))
	METHOD(NewMenuSliderCheckBox, setChecked, void(entity, float))
	METHOD(NewMenuSliderCheckBox, draw, void(entity))
	ATTRIB(NewMenuSliderCheckBox, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NewMenuSliderCheckBox, image, string, SKINGFX_CHECKBOX)

	ATTRIB(NewMenuSliderCheckBox, color, vector, SKINCOLOR_CHECKBOX_N)
	ATTRIB(NewMenuSliderCheckBox, colorC, vector, SKINCOLOR_CHECKBOX_C)
	ATTRIB(NewMenuSliderCheckBox, colorF, vector, SKINCOLOR_CHECKBOX_F)
	ATTRIB(NewMenuSliderCheckBox, colorD, vector, SKINCOLOR_CHECKBOX_D)

	ATTRIB(NewMenuSliderCheckBox, alpha, float, SKINALPHA_TEXT)
	ATTRIB(NewMenuSliderCheckBox, disabledAlpha, float, SKINALPHA_DISABLED)

	ATTRIB(NewMenuSliderCheckBox, controlledSlider, entity, NULL)
	ATTRIB(NewMenuSliderCheckBox, offValue, float, -1)
	ATTRIB(NewMenuSliderCheckBox, inverted, float, 0)
	ATTRIB(NewMenuSliderCheckBox, savedValue, float, -1)
ENDCLASS(NewMenuSliderCheckBox)
entity makeNewMenuSliderCheckBox(float, float, entity, string);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuSliderCheckBox(float theOffValue, float isInverted, entity theControlledSlider, string theText)
{
	entity me;
	me = spawnNewMenuSliderCheckBox();
	me.configureNewMenuSliderCheckBox(me, theOffValue, isInverted, theControlledSlider, theText);
	return me;
}
void configureNewMenuSliderCheckBoxNewMenuSliderCheckBox(entity me, float theOffValue, float isInverted, entity theControlledSlider, string theText)
{
	me.offValue = theOffValue;
	me.inverted = isInverted;
	me.checked = (theControlledSlider.value == theOffValue);
	if(theControlledSlider.value == median(theControlledSlider.valueMin, theControlledSlider.value, theControlledSlider.valueMax))
		me.savedValue = theControlledSlider.value;
	else
		me.savedValue = theControlledSlider.valueMin; 
	me.controlledSlider = theControlledSlider;
	me.configureCheckBox(me, theText, me.fontSize, me.image);
	me.tooltip = theControlledSlider.tooltip;
}
void drawNewMenuSliderCheckBox(entity me)
{
	me.checked = ((me.controlledSlider.value == me.offValue) != me.inverted);
	if(me.controlledSlider.value == median(me.controlledSlider.valueMin, me.controlledSlider.value, me.controlledSlider.valueMax))
		me.savedValue = me.controlledSlider.value;
	drawCheckBox(me);
}
void setCheckedNewMenuSliderCheckBox(entity me, float val)
{
	if(me.checked == val)
		return;
	me.checked = val;
	if(val == me.inverted)
		me.controlledSlider.setValue(me.controlledSlider, median(me.controlledSlider.valueMin, me.savedValue, me.controlledSlider.valueMax));
	else
		me.controlledSlider.setValue(me.controlledSlider, me.offValue);
}

#endif
