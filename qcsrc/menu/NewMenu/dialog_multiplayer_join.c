#ifdef INTERFACE
CLASS(NewMenuServerListTab) EXTENDS(NewMenuTab)
	METHOD(NewMenuServerListTab, fill, void(entity))
	ATTRIB(NewMenuServerListTab, title, string, "Join")
	ATTRIB(NewMenuServerListTab, intendedWidth, float, 0.9)
	ATTRIB(NewMenuServerListTab, rows, float, 22)
	ATTRIB(NewMenuServerListTab, columns, float, 6.5)
ENDCLASS(NewMenuServerListTab)
entity makeNewMenuServerListTab();
#endif

#ifdef IMPLEMENTATION

entity makeNewMenuServerListTab()
{
	entity me;
	me = spawnNewMenuServerListTab();
	me.configureDialog(me);
	return me;
}
void fillNewMenuServerListTab(entity me)
{
	entity e, slist, btn;

	slist  = makeNewMenuServerList();

	me.TR(me);
		me.TD(me, 1, 0.5, e = makeNewMenuTextLabel(0, "Filter:"));
		me.TD(me, 1, 0.5, btn = makeNewMenuButton("Clear", '0 0 0'));
			btn.onClick = InputBox_Clear_Click;
		me.TD(me, 1, me.columns - 3.1, e = makeNewMenuInputBox(0, string_null));
			e.onChange = ServerList_Filter_Change;
			e.onChangeEntity = slist;
			btn.onClickEntity = e;
			slist.controlledTextbox = e;
		/*
		me.TD(me, 1, 0.35, e = makeNewMenuCheckBox(0, "menu_slist_showonlyex", "Ex"));
			slist.filterShowEmpty = e.checked;
			e.onClickEntity = slist;
			e.onClick = ServerList_ShowOnlyEx_Click;
		*/
		me.TD(me, 1, 0.6, e = makeNewMenuCheckBox(0, "menu_slist_showonlyrm", "Only RM"));
			slist.filterShowEmpty = e.checked;
			e.onClickEntity = slist;
			e.onClick = ServerList_ShowOnlyRM_Click;
		me.TD(me, 1, 0.5, e = makeNewMenuCheckBox(0, "menu_slist_showempty", "Empty"));
			slist.filterShowEmpty = e.checked;
			e.onClickEntity = slist;
			e.onClick = ServerList_ShowEmpty_Click;
		me.TD(me, 1, 0.5, e = makeNewMenuCheckBox(0, "menu_slist_showfull", "Full"));
			slist.filterShowFull = e.checked;
			e.onClickEntity = slist;
			e.onClick = ServerList_ShowFull_Click;
		me.TD(me, 1, 0.5, e = makeNewMenuCheckBox(0, "net_slist_pause", "Pause"));

	me.TR(me);
		me.TD(me, 1, 1, slist.sortButton1 = makeNewMenuButton(string_null, '0 0 0'));
		me.TD(me, 1, 1, slist.sortButton2 = makeNewMenuButton(string_null, '0 0 0'));
		me.TD(me, 1, 1, slist.sortButton3 = makeNewMenuButton(string_null, '0 0 0'));
		me.TD(me, 1, 1, slist.sortButton4 = makeNewMenuButton(string_null, '0 0 0'));
		me.TD(me, 1, 1, slist.sortButton5 = makeNewMenuButton(string_null, '0 0 0'));
	me.TR(me);
		me.TD(me, me.rows - 4, me.columns, slist);

	me.gotoRC(me, me.rows - 2, 0);
		me.TD(me, 1, 0.6, e = makeNewMenuTextLabel(0, "Address:"));
		me.TD(me, 1, 2.9, e = makeNewMenuInputBox(0, string_null));
			e.onEnter = ServerList_Connect_Click;
			e.onEnterEntity = slist;
			slist.ipAddressBox = e;
		me.TD(me, 1, 1.5, e = makeNewMenuButton("", '0 0 0'));
			e.onClick = ServerList_Favorite_Click;
			e.onClickEntity = slist;
			slist.favoriteButton = e;
		me.TD(me, 1, 1.5, e = makeNewMenuButton("Info", '0 0 0'));
			e.onClick = ServerList_Info_Click;
			e.onClickEntity = slist;
			slist.infoButton = e;
	me.TR(me);
		//me.TD(me, 1, 2, e = makeNewMenuModButton("Multiplayer_Join"));
		me.TD(me, 1, me.columns, e = makeNewMenuButton("Join!", '0 0 0'));
			e.onClick = ServerList_Connect_Click;
			e.onClickEntity = slist;
			slist.connectButton = e;
}
#endif
