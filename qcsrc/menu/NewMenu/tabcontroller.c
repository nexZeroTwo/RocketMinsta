#ifdef INTERFACE
CLASS(NewMenuTabController) EXTENDS(ModalController)
	METHOD(NewMenuTabController, configureNewMenuTabController, void(entity, float))
	METHOD(NewMenuTabController, makeTabButton, entity(entity, string, entity))
	ATTRIB(NewMenuTabController, rows, float, 0)
	ATTRIB(NewMenuTabController, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NewMenuTabController, image, string, SKINGFX_BUTTON)
ENDCLASS(NewMenuTabController)
entity makeNewMenuTabController(float theRows);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuTabController(float theRows)
{
	entity me;
	me = spawnNewMenuTabController();
	me.configureNewMenuTabController(me, theRows);
	return me;
}
void configureNewMenuTabControllerNewMenuTabController(entity me, float theRows)
{
	me.rows = theRows;
}
entity makeTabButtonNewMenuTabController(entity me, string theTitle, entity tab)
{
	entity b;
	if(me.rows != tab.rows)
		error("Tab dialog height mismatch!");
	b = makeNewMenuButton(theTitle, '0 0 0');
		me.addTab(me, tab, b);
	// TODO make this real tab buttons (with color parameters, and different gfx)
	return b;
}
#endif
