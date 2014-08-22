#ifdef INTERFACE
CLASS(NewMenuServerInfoDialog) EXTENDS(NewMenuDialog)
	METHOD(NewMenuServerInfoDialog, fill, void(entity))
	METHOD(NewMenuServerInfoDialog, loadServerInfo, void(entity, float))
	ATTRIB(NewMenuServerInfoDialog, title, string, "Server Information")
	ATTRIB(NewMenuServerInfoDialog, color, vector, SKINCOLOR_DIALOG_SERVERINFO)
	ATTRIB(NewMenuServerInfoDialog, intendedWidth, float, 0.68)
	ATTRIB(NewMenuServerInfoDialog, rows, float, 11)
	ATTRIB(NewMenuServerInfoDialog, columns, float, 12)

	ATTRIB(NewMenuServerInfoDialog, currentServerName, string, string_null)
	ATTRIB(NewMenuServerInfoDialog, currentServerCName, string, string_null)
	ATTRIB(NewMenuServerInfoDialog, currentServerType, string, string_null)
	ATTRIB(NewMenuServerInfoDialog, currentServerMap, string, string_null)
	ATTRIB(NewMenuServerInfoDialog, currentServerPlayers, string, string_null)
	ATTRIB(NewMenuServerInfoDialog, currentServerNumPlayers, string, string_null)
	ATTRIB(NewMenuServerInfoDialog, currentServerNumBots, string, string_null)
	ATTRIB(NewMenuServerInfoDialog, currentServerMod, string, string_null)
	ATTRIB(NewMenuServerInfoDialog, currentServerVersion, string, string_null)
	ATTRIB(NewMenuServerInfoDialog, currentServerPing, string, string_null)

	ATTRIB(NewMenuServerInfoDialog, nameLabel, entity, NULL)
	ATTRIB(NewMenuServerInfoDialog, cnameLabel, entity, NULL)
	ATTRIB(NewMenuServerInfoDialog, typeLabel, entity, NULL)
	ATTRIB(NewMenuServerInfoDialog, mapLabel, entity, NULL)
	ATTRIB(NewMenuServerInfoDialog, rawPlayerList, entity, NULL)
	ATTRIB(NewMenuServerInfoDialog, numPlayersLabel, entity, NULL)
	ATTRIB(NewMenuServerInfoDialog, numBotsLabel, entity, NULL)
	ATTRIB(NewMenuServerInfoDialog, modLabel, entity, NULL)
	ATTRIB(NewMenuServerInfoDialog, versionLabel, entity, NULL)
	ATTRIB(NewMenuServerInfoDialog, pingLabel, entity, NULL)
    ATTRIB(NewMenuServerInfoDialog, rmLabel, entity, NULL)
ENDCLASS(NewMenuServerInfoDialog)

float SLIST_FIELD_NAME;
float SLIST_FIELD_CNAME;
float SLIST_FIELD_QCSTATUS;
float SLIST_FIELD_MAP;
float SLIST_FIELD_PLAYERS;
float SLIST_FIELD_NUMHUMANS;
float SLIST_FIELD_MAXPLAYERS;
float SLIST_FIELD_NUMBOTS;
float SLIST_FIELD_MOD;
float SLIST_FIELD_PING;
void Join_Click(entity btn, entity me);
#endif

#ifdef IMPLEMENTATION
void loadServerInfoNewMenuServerInfoDialog(entity me, float i)
{
	float m;
	string s, typestr, versionstr, rmversion, numh, maxp;

	SLIST_FIELD_NAME = gethostcacheindexforkey("name");
	me.currentServerName = strzone(gethostcachestring(SLIST_FIELD_NAME, i));
	me.nameLabel.setText(me.nameLabel, me.currentServerName);

	SLIST_FIELD_CNAME = gethostcacheindexforkey("cname");
	me.currentServerCName = strzone(gethostcachestring(SLIST_FIELD_CNAME, i));
	me.cnameLabel.setText(me.cnameLabel, me.currentServerCName);

	SLIST_FIELD_QCSTATUS = gethostcacheindexforkey("qcstatus");
	s = gethostcachestring(SLIST_FIELD_QCSTATUS, i);
	m = tokenizebyseparator(s, ":");
	if(m > 1)
	{
		typestr = argv (0);
		versionstr = argv(1);
	}
	else
	{
		typestr = "N/A";
		versionstr = "N/A";
	}
	
	m = tokenizebyseparator(versionstr, "_rm-");
	rmversion = argv(1);

	me.currentServerType = gametype_Name_to_LongName(typestr); //strzone(typestr);
	me.typeLabel.setText(me.typeLabel, me.currentServerType);

	SLIST_FIELD_MAP = gethostcacheindexforkey("map");
	me.currentServerMap = strzone(gethostcachestring(SLIST_FIELD_MAP, i));
	me.mapLabel.setText(me.mapLabel, me.currentServerMap);

	SLIST_FIELD_PLAYERS = gethostcacheindexforkey("players");
	me.currentServerPlayers = strzone(gethostcachestring(SLIST_FIELD_PLAYERS, i));
	me.rawPlayerList.setPlayerList(me.rawPlayerList, me.currentServerPlayers);

	SLIST_FIELD_NUMHUMANS = gethostcacheindexforkey("numhumans");
	numh = ftos(gethostcachenumber(SLIST_FIELD_NUMHUMANS, i));
	SLIST_FIELD_MAXPLAYERS = gethostcacheindexforkey("maxplayers");
	maxp = ftos(gethostcachenumber(SLIST_FIELD_MAXPLAYERS, i));
	me.currentServerNumPlayers = strzone(strcat(numh,"/",maxp));
	me.numPlayersLabel.setText(me.numPlayersLabel, me.currentServerNumPlayers);

	SLIST_FIELD_NUMBOTS = gethostcacheindexforkey("numbots");
	s = ftos(gethostcachenumber(SLIST_FIELD_NUMBOTS, i));
	me.currentServerNumBots = strzone(s);
	me.numBotsLabel.setText(me.numBotsLabel, me.currentServerNumBots);

	SLIST_FIELD_MOD = gethostcacheindexforkey("mod");
	me.currentServerMod = strzone(gethostcachestring(SLIST_FIELD_MOD, i));
	me.modLabel.setText(me.modLabel, me.currentServerMod);

	me.currentServerVersion = strzone(versionstr);
	me.versionLabel.setText(me.versionLabel, me.currentServerVersion);
	me.currentServerRMLabel = strzone(((rmversion && rmversion != "")? strcat("This server is running RocketMinsta ", rmversion) : 
																	   strcat("This server is running ", cvar_string("sys_project_name"), " ", versionstr)));
	me.rmLabel.setText(me.rmLabel, me.currentServerRMLabel);

	SLIST_FIELD_PING = gethostcacheindexforkey("ping");
	s = ftos(gethostcachenumber(SLIST_FIELD_PING, i));
	me.currentServerPing = strzone(s);
	me.pingLabel.setText(me.pingLabel, me.currentServerPing);
}

void fillNewMenuServerInfoDialog(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 1, me.columns, e = makeNewMenuTextLabel(0.5, ""));
			e.colorL = SKINCOLOR_SERVERINFO_NAME;
			e.allowCut = 1;
			me.nameLabel = e;
	me.TR(me);
		me.TD(me, 0.2, me.columns, e = makeNewMenuTextLabel(0.5, ""));
			e.colorL = SKINCOLOR_SERVERINFO_NAME;
			e.allowCut = 1;
			me.rmLabel = e;
	me.TR(me);
		me.TD(me, 0.2, me.columns, e = makeNewMenuTextLabel(0.5, ""));
			e.colorL = SKINCOLOR_SERVERINFO_IP;
			e.allowCut = 1;
			me.cnameLabel = e;

	me.TR(me);
		me.TD(me, 1, 5.5, e = makeNewMenuTextLabel(0, "Players:"));
	me.TR(me);
		me.TD(me, me.rows - 5, 6, e = makeNewMenuPlayerList());
			me.rawPlayerList = e;

	me.gotoRC(me, 1, 6.25); me.setFirstColumn(me, me.currentColumn);

	me.TR(me);
		me.TD(me, 1, 1.75, e = makeNewMenuTextLabel(0, "Type:"));
		me.TD(me, 1, 4.0, e = makeNewMenuTextLabel(0, ""));
			e.allowCut = 1;
			me.typeLabel = e;
	me.TR(me);
		me.TD(me, 1, 1.75, e = makeNewMenuTextLabel(0, "Map:"));
		me.TD(me, 1, 4.0, e = makeNewMenuTextLabel(0, ""));
			e.allowCut = 1;
			me.mapLabel = e;
	me.TR(me);
		me.TD(me, 1, 1.75, e = makeNewMenuTextLabel(0, "Players:"));
		me.TD(me, 1, 4.0, e = makeNewMenuTextLabel(0, ""));
			e.allowCut = 1;
			me.numPlayersLabel = e;
	me.TR(me);
		me.TD(me, 1, 1.75, e = makeNewMenuTextLabel(0, "Bots:"));
		me.TD(me, 1, 4.0, e = makeNewMenuTextLabel(0, ""));
			e.allowCut = 1;
			me.numBotsLabel = e;
	me.TR(me);
		me.TD(me, 1, 1.75, e = makeNewMenuTextLabel(0, "Mod:"));
		me.TD(me, 1, 4.0, e = makeNewMenuTextLabel(0, ""));
			e.allowCut = 1;
			me.modLabel = e;
	me.TR(me);
		me.TD(me, 1, 1.75, e = makeNewMenuTextLabel(0, "Version:"));
		me.TD(me, 1, 4.0, e = makeNewMenuTextLabel(0, ""));
			e.allowCut = 1;
			me.versionLabel = e;
	me.TR(me);
		me.TD(me, 1, 1.75, e = makeNewMenuTextLabel(0, "Ping:"));
		me.TD(me, 1, 4.0, e = makeNewMenuTextLabel(0, ""));
			e.allowCut = 1;
			me.pingLabel = e;

	me.gotoRC(me, me.rows - 1, 0);

		me.TD(me, 1, me.columns - 6, e = makeNewMenuButton("Close", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
		me.TD(me, 1, me.columns - 6, e = makeNewMenuButton("Join!", '0 0 0'));
			e.onClick = Join_Click;
			e.onClickEntity = me;
}

void Join_Click(entity btn, entity me)
{
	localcmd("connect ", me.currentServerCName, "\n");
}

#endif
