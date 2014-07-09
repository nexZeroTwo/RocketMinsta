#ifdef INTERFACE
CLASS(NewMenuMusicBrowserTab) EXTENDS(NewMenuTab)
	METHOD(NewMenuMusicBrowserTab, fill, void(entity))
	ATTRIB(NewMenuMusicBrowserTab, title, string, "Music")
	ATTRIB(NewMenuMusicBrowserTab, intendedWidth, float, 0.9)
	ATTRIB(NewMenuMusicBrowserTab, rows, float, 22)
	ATTRIB(NewMenuMusicBrowserTab, columns, float, 6.5)
	ATTRIB(NewMenuMusicBrowserTab, name, string, "MusicBrowser")
ENDCLASS(NewMenuMusicBrowserTab)
entity makeNewMenuMusicBrowserTab();
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuMusicBrowserTab()
{
	entity me;
	me = spawnNewMenuMusicBrowserTab();
	me.configureDialog(me);
	return me;
}
void fillNewMenuMusicBrowserTab(entity me)
{
	entity e;//, s;
	entity btn;
	entity dlist;

	me.TR(me);
		/*
		s = makeNewMenuDecibelsSlider(-20, 0, 0.5, "bgmvolume");
		me.TD(me, 1, 1, e = makeNewMenuSliderCheckBox(-1000000, 1, s, "Music Volume:"));
		me.TD(me, 1, 2, s);
		*/
		me.TD(me, 1, me.columns, e = makeNewMenuCheckBox(0, "bgmvolume", "Play Music While playing"));
	me.TR(me);
	dlist = makeMusicList();
	me.TR(me);
		me.TD(me, 1, 0.5, e = makeNewMenuTextLabel(0, "Filter:"));
		me.TD(me, 1, 0.5, btn = makeNewMenuButton("Clear", '0 0 0'));
			btn.onClick = InputBox_Clear_Click;
		me.TD(me, 1, me.columns - 1, e = makeNewMenuInputBox(0, string_null));
			e.onChange = MusicList_Filter_Change;
			e.onChangeEntity = dlist;
			btn.onClickEntity = e;
			dlist.controlledTextbox = e;
	me.TR(me);
		me.TD(me, me.rows - 4, me.columns, dlist);
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns / 2, e = makeNewMenuButton("Play", '0 0 0'));
			e.onClick = StartMusic_Click;
			e.onClickEntity = dlist;
        me.TD(me, 1, me.columns / 2, e = makeNewMenuButton("Stop", '0 0 0'));
			e.onClick = StopMusic_Click;
			e.onClickEntity = dlist;

}
#endif
