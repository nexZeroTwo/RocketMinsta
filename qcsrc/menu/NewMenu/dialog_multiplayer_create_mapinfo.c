#ifdef INTERFACE
CLASS(NewMenuMapInfoDialog) EXTENDS(NewMenuDialog)
	METHOD(NewMenuMapInfoDialog, fill, void(entity))
	METHOD(NewMenuMapInfoDialog, loadMapInfo, void(entity, float, entity))
	ATTRIB(NewMenuMapInfoDialog, title, string, "Map Information")
	ATTRIB(NewMenuMapInfoDialog, color, vector, SKINCOLOR_DIALOG_MAPINFO)
	ATTRIB(NewMenuMapInfoDialog, intendedWidth, float, 0.85)
	ATTRIB(NewMenuMapInfoDialog, rows, float, 9)
	ATTRIB(NewMenuMapInfoDialog, columns, float, 10)

	ATTRIB(NewMenuMapInfoDialog, previewImage, entity, NULL)
	ATTRIB(NewMenuMapInfoDialog, titleLabel, entity, NULL)
	ATTRIB(NewMenuMapInfoDialog, authorLabel, entity, NULL)
	ATTRIB(NewMenuMapInfoDialog, descriptionLabel, entity, NULL)
	ATTRIB(NewMenuMapInfoDialog, featuresLabel, entity, NULL)

	ATTRIB(NewMenuMapInfoDialog, typeDeathmatchLabel, entity, NULL)
	ATTRIB(NewMenuMapInfoDialog, typeTDMLabel, entity, NULL)
	ATTRIB(NewMenuMapInfoDialog, typeLMSLabel, entity, NULL)
	ATTRIB(NewMenuMapInfoDialog, typeArenaLabel, entity, NULL)
	ATTRIB(NewMenuMapInfoDialog, typeRuneLabel, entity, NULL)
	ATTRIB(NewMenuMapInfoDialog, typeDominationLabel, entity, NULL)
	ATTRIB(NewMenuMapInfoDialog, typeKeyHuntLabel, entity, NULL)
	ATTRIB(NewMenuMapInfoDialog, typeCTFLabel, entity, NULL)
	ATTRIB(NewMenuMapInfoDialog, typeAssaultLabel, entity, NULL)
	ATTRIB(NewMenuMapInfoDialog, typeOnslaughtLabel, entity, NULL)
	ATTRIB(NewMenuMapInfoDialog, typeRaceLabel, entity, NULL)
	ATTRIB(NewMenuMapInfoDialog, typeCTSLabel, entity, NULL)
	ATTRIB(NewMenuMapInfoDialog, typeNexballLabel, entity, NULL)

	ATTRIB(NewMenuMapInfoDialog, currentMapIndex, float, 0)
	ATTRIB(NewMenuMapInfoDialog, currentMapBSPName, string, string_null)
	ATTRIB(NewMenuMapInfoDialog, currentMapTitle, string, string_null)
	ATTRIB(NewMenuMapInfoDialog, currentMapAuthor, string, string_null)
	ATTRIB(NewMenuMapInfoDialog, currentMapDescription, string, string_null)
	ATTRIB(NewMenuMapInfoDialog, currentMapPreviewImage, string, string_null)
	ATTRIB(NewMenuMapInfoDialog, currentMapFeaturesText, string, string_null)
ENDCLASS(NewMenuMapInfoDialog)
#endif

#ifdef IMPLEMENTATION
void loadMapInfoNewMenuMapInfoDialog(entity me, float i, entity mlb)
{
	me.currentMapIndex = i;
	me.startButton.onClickEntity = mlb;
	MapInfo_Get_ByID(i);

	if(me.currentMapBSPName)
	{
		strunzone(me.currentMapBSPName);
		strunzone(me.currentMapTitle);
		strunzone(me.currentMapAuthor);
		strunzone(me.currentMapDescription);
		strunzone(me.currentMapPreviewImage);
		strunzone(me.currentMapFeaturesText);
	}
	me.currentMapBSPName = strzone(MapInfo_Map_bspname);
	me.currentMapTitle = strzone(MapInfo_Map_title);
	me.currentMapAuthor = strzone(MapInfo_Map_author);
	me.currentMapDescription = strzone(MapInfo_Map_description);
	me.currentMapFeaturesText = strzone((MapInfo_Map_supportedFeatures & MAPINFO_FEATURE_WEAPONS) ? "Full item placement" : "MinstaGib only");
	me.currentMapPreviewImage = strzone(strcat("/maps/", MapInfo_Map_bspname));

	me.frame.setText(me.frame, me.currentMapBSPName);
	me.titleLabel.setText(me.titleLabel, me.currentMapTitle);
	me.authorLabel.setText(me.authorLabel, me.currentMapAuthor);
	me.descriptionLabel.setText(me.descriptionLabel, me.currentMapDescription);
	me.featuresLabel.setText(me.featuresLabel, me.currentMapFeaturesText);
	me.previewImage.src = me.currentMapPreviewImage;

	me.typeDeathmatchLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_DEATHMATCH);
	me.typeTDMLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_TEAM_DEATHMATCH);
	me.typeLMSLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_LMS);
	me.typeArenaLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_ARENA);
	me.typeDominationLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_DOMINATION);
	me.typeRuneLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_RUNEMATCH);
	me.typeKeyHuntLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_KEYHUNT);
	me.typeCTFLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_CTF);
	me.typeAssaultLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_ASSAULT);
	me.typeOnslaughtLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_ONSLAUGHT);
	me.typeRaceLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_RACE);
	me.typeCTSLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_CTS);
	me.typeNexballLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_NEXBALL);

	MapInfo_ClearTemps();
}
void fillNewMenuMapInfoDialog(entity me)
{
	entity e;
	float w, wgt;
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, me.rows - 2, 3, e = makeNewMenuImage(string_null, 4.0/3.0));
		me.previewImage = e;
	me.gotoRC(me, 0, 3.5); me.setFirstColumn(me, me.currentColumn);
	w = me.columns - me.currentColumn;
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Title:"));
		me.TD(me, 1, w-1, e = makeNewMenuTextLabel(0, ""));
			e.colorL = SKINCOLOR_MAPLIST_TITLE;
			e.allowCut = 1;
			me.titleLabel = e;
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Author:"));
		me.TD(me, 1, w-1, e = makeNewMenuTextLabel(0, ""));
			e.colorL = SKINCOLOR_MAPLIST_AUTHOR;
			e.allowCut = 1;
			me.authorLabel = e;
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Features:"));
		me.TD(me, 1, w-1, e = makeNewMenuTextLabel(0, ""));
			e.allowCut = 1;
			me.featuresLabel = e;
	me.TR(me);
		me.TD(me, 1, w, e = makeNewMenuTextLabel(0, "Game types:"));
	me.TR(me); wgt = (w-0.2)/5;
		me.TDempty(me, 0.2);
		me.TD(me, 1, wgt, e = makeNewMenuTextLabel(0, "DM"));
			me.typeDeathmatchLabel = e;
		me.TD(me, 1, wgt, e = makeNewMenuTextLabel(0, "TDM"));
			me.typeTDMLabel = e;
		me.TD(me, 1, wgt, e = makeNewMenuTextLabel(0, "LMS"));
			me.typeLMSLabel = e;
		me.TD(me, 1, wgt, e = makeNewMenuTextLabel(0, "Arena"));
			me.typeArenaLabel = e;
		me.TD(me, 1, wgt, e = makeNewMenuTextLabel(0, "Rune"));
			me.typeRuneLabel = e;
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, wgt, e = makeNewMenuTextLabel(0, "Domination"));
			me.typeDominationLabel = e;
		me.TD(me, 1, wgt, e = makeNewMenuTextLabel(0, "Key Hunt"));
			me.typeKeyHuntLabel = e;
		me.TD(me, 1, wgt, e = makeNewMenuTextLabel(0, "CTF"));
			me.typeCTFLabel = e;
		me.TD(me, 1, wgt, e = makeNewMenuTextLabel(0, "Assault"));
			me.typeAssaultLabel = e;
		me.TD(me, 1, wgt, e = makeNewMenuTextLabel(0, "Onslaught"));
			me.typeOnslaughtLabel = e;
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, wgt, e = makeNewMenuTextLabel(0, "Race"));
			me.typeRaceLabel = e;
		me.TD(me, 1, wgt, e = makeNewMenuTextLabel(0, "CTS"));
			me.typeCTSLabel = e;
		me.TD(me, 1, wgt, e = makeNewMenuTextLabel(0, "Nexball"));
			me.typeNexballLabel = e;

	me.gotoRC(me, me.rows - 2, 0);
		me.TD(me, 1, me.columns, e = makeNewMenuTextLabel(0.5, ""));
			e.allowCut = 1;
			me.descriptionLabel = e;

	me.gotoRC(me, me.rows - 1, 0);
		me.TDempty(me, 0.5);

		me.TD(me, 1, me.columns - 5.5, e = makeNewMenuButton("Close", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
		me.TD(me, 1, me.columns - 5.5, me.startButton = e = makeNewMenuButton("Play", '0 0 0'));
			me.startButton.onClick = MapList_LoadMap;
			me.startButton.onClickEntity = NULL; // filled later
		me.TDempty(me, 0.5);
}
#endif
