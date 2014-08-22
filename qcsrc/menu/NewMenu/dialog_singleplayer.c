#ifdef INTERFACE
CLASS(NewMenuSingleplayerDialog) EXTENDS(NewMenuDialog)
	METHOD(NewMenuSingleplayerDialog, fill, void(entity))
	ATTRIB(NewMenuSingleplayerDialog, title, string, "Singleplayer")
	ATTRIB(NewMenuSingleplayerDialog, color, vector, SKINCOLOR_DIALOG_SINGLEPLAYER)
	ATTRIB(NewMenuSingleplayerDialog, intendedWidth, float, 0.80)
	ATTRIB(NewMenuSingleplayerDialog, rows, float, 24)
	ATTRIB(NewMenuSingleplayerDialog, columns, float, 5)
	ATTRIB(NewMenuSingleplayerDialog, campaignBox, entity, NULL)
ENDCLASS(NewMenuSingleplayerDialog)
#endif

#ifdef IMPLEMENTATION

void InstantAction_LoadMap(entity btn, entity dummy)
{
	float glob, i, n, fh;
	string s;
	glob = search_begin("maps/*.instantaction", TRUE, TRUE);
	if(glob < 0)
		return;
	i = ceil(random() * search_getsize(glob)) - 1;
	fh = fopen(search_getfilename(glob, i), FILE_READ);
	search_end(glob);
	if(fh < 0)
		return;
	while((s = fgets(fh)))
	{
		if(substring(s, 0, 4) == "set ")
			s = substring(s, 4, strlen(s) - 4);
		n = tokenize_console(s);
		if(argv(0) == "bot_number")
			cvar_set("bot_number", argv(1));
		else if(argv(0) == "skill")
			cvar_set("skill", argv(1));
		else if(argv(0) == "timelimit")
			cvar_set("timelimit_override", argv(1));
		else if(argv(0) == "fraglimit")
			cvar_set("fraglimit_override", argv(1));
		else if(argv(0) == "changelevel")
		{
			fclose(fh);
			localcmd("\nmenu_loadmap_prepare\n");
			gametype_SetMenu(GAME_DEATHMATCH);
            MapInfo_LoadMap(argv(1));
			cvar_set("lastlevel", "1");
			return;
		}
	}
	fclose(fh);
}

void fillNewMenuSingleplayerDialog(entity me)
{
	entity e, btnPrev, btnNext, lblTitle;

	me.TR(me);
		me.TDempty(me, (me.columns - 3) / 2);
		me.TD(me, 2, 3, e = makeNewMenuBigButton("Instant action! (random map with bots)", '0 0 0'));
			e.onClick = InstantAction_LoadMap;
			e.onClickEntity = NULL;
	me.TR(me);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, btnPrev = makeNewMenuButton("<<", '0 0 0'));
		me.TD(me, 1, me.columns - 2, lblTitle = makeNewMenuTextLabel(0.5, "???"));
		me.TD(me, 1, 1, btnNext = makeNewMenuButton(">>", '0 0 0'));
	me.TR(me);
		me.TD(me, me.rows - 6, me.columns, me.campaignBox = makeNewMenuCampaignList());
			btnPrev.onClick = MultiCampaign_Prev;
			btnPrev.onClickEntity = me.campaignBox;
			btnNext.onClick = MultiCampaign_Next;
			btnNext.onClickEntity = me.campaignBox;
			me.campaignBox.buttonNext = btnNext;
			me.campaignBox.buttonPrev = btnPrev;
			me.campaignBox.labelTitle = lblTitle;
			me.campaignBox.campaignGo(me.campaignBox, 0);

	me.gotoRC(me, me.rows - 2, 0);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeNewMenuTextLabel(0, "Bot skill:"));
		me.TD(me, 1, 2, e = makeNewMenuTextSlider("g_campaign_skill"));
			e.addValue(e, "Noob", "0");
			e.addValue(e, "Beginner", "1");
			e.addValue(e, "You will win", "2");
			e.addValue(e, "You can win", "3");
			e.addValue(e, "You might win", "4");
			e.addValue(e, "Advanced", "5");
			e.addValue(e, "Expert", "6");
			e.addValue(e, "Pro", "7");
			e.addValue(e, "Assassin", "8");
			e.addValue(e, "Unhuman", "9");
			e.addValue(e, "Godlike", "10");
			e.configureNewMenuTextSliderValues(e);

	me.gotoRC(me, me.rows - 1, 0);
#ifdef MODMODE
		me.TD(me, 1, 2, e = makeNewMenuModButton("Singleplayer"));
		me.TD(me, 1, me.columns - 2 , e = makeNewMenuButton("Start Singleplayer!", '0 0 0'));
#else
		me.TD(me, 1, me.columns, e = makeNewMenuButton("Start Singleplayer!", '0 0 0'));
#endif
			e.onClick = CampaignList_LoadMap;
			e.onClickEntity = me.campaignBox;
}
#endif
