#ifdef INTERFACE
CLASS(NewMenuListBox) EXTENDS(ListBox)
	METHOD(NewMenuListBox, configureNewMenuListBox, void(entity))
	ATTRIB(NewMenuListBox, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NewMenuListBox, scrollbarWidth, float, SKINWIDTH_SCROLLBAR)
	ATTRIB(NewMenuListBox, src, string, SKINGFX_SCROLLBAR)
	ATTRIB(NewMenuListBox, tolerance, vector, SKINTOLERANCE_SLIDER)
	ATTRIB(NewMenuListBox, rowsPerItem, float, 1)
	METHOD(NewMenuListBox, resizeNotify, void(entity, vector, vector, vector, vector))
	ATTRIB(NewMenuListBox, color, vector, SKINCOLOR_SCROLLBAR_N)
	ATTRIB(NewMenuListBox, colorF, vector, SKINCOLOR_SCROLLBAR_F)
	ATTRIB(NewMenuListBox, color2, vector, SKINCOLOR_SCROLLBAR_S)
	ATTRIB(NewMenuListBox, colorC, vector, SKINCOLOR_SCROLLBAR_C)
ENDCLASS(NewMenuListBox)
entity makeNewMenuListBox();
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuListBox()
{
	entity me;
	me = spawnNewMenuListBox();
	me.configureNewMenuListBox(me);
	return me;
}
void configureNewMenuListBoxNewMenuListBox(entity me)
{
	me.configureListBox(me, me.scrollbarWidth, 1); // item height gets set up later
}
void resizeNotifyNewMenuListBox(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.itemHeight = me.rowsPerItem * me.fontSize / absSize_y;
	resizeNotifyListBox(me, relOrigin, relSize, absOrigin, absSize);
}
#endif
