#ifdef INTERFACE
CLASS(NewMenuDemoBrowserTab) EXTENDS(NewMenuTab)
	METHOD(NewMenuDemoBrowserTab, fill, void(entity))
	ATTRIB(NewMenuDemoBrowserTab, title, string, "Demo")
	ATTRIB(NewMenuDemoBrowserTab, intendedWidth, float, 0.9)
	ATTRIB(NewMenuDemoBrowserTab, rows, float, 22)
	ATTRIB(NewMenuDemoBrowserTab, columns, float, 6.5)
	ATTRIB(NewMenuDemoBrowserTab, name, string, "DemoBroswer")	
ENDCLASS(NewMenuDemoBrowserTab)
entity makeNewMenuDemoBrowserTab();
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuDemoBrowserTab()
{
	entity me;
	me = spawnNewMenuDemoBrowserTab();
	me.configureDialog(me);
	return me;
}
void fillNewMenuDemoBrowserTab(entity me)
{
	entity e;
	entity btn;
	entity dlist;

	me.TR(me);
		me.TD(me, 1, me.columns, e = makeNewMenuCheckBox(0, "cl_autodemo", "Record demos while playing"));
	me.TR(me);
	dlist = makeNewMenuDemoList();
	me.TR(me);
		me.TD(me, 1, 0.5, e = makeNewMenuTextLabel(0, "Filter:"));
		me.TD(me, 1, 0.5, btn = makeNewMenuButton("Clear", '0 0 0'));
			btn.onClick = InputBox_Clear_Click;
		me.TD(me, 1, me.columns - 1, e = makeNewMenuInputBox(0, string_null));
			e.onChange = DemoList_Filter_Change;
			e.onChangeEntity = dlist;
			btn.onClickEntity = e;
			dlist.controlledTextbox = e;
	me.TR(me);
		me.TD(me, me.rows - 4, me.columns, dlist);
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns / 2, e = makeNewMenuButton("Timedemo", '0 0 0'));
			e.onClick = TimeDemo_Click;
			e.onClickEntity = dlist;
		me.TD(me, 1, me.columns / 2, e = makeNewMenuButton("Play", '0 0 0'));
			e.onClick = StartDemo_Click;
			e.onClickEntity = dlist;
}
#endif
