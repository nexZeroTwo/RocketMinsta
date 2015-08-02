#ifdef INTERFACE
CLASS(NewMenuTeamSelectDialog) EXTENDS(NewMenuRootDialog)
	METHOD(NewMenuTeamSelectDialog, fill, void(entity)) // to be overridden by user to fill the dialog with controls
	METHOD(NewMenuTeamSelectDialog, showNotify, void(entity))
	ATTRIB(NewMenuTeamSelectDialog, title, string, "Team Selection") // ;)
	ATTRIB(NewMenuTeamSelectDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(NewMenuTeamSelectDialog, intendedWidth, float, 0.4)
	ATTRIB(NewMenuTeamSelectDialog, rows, float, 5)
	ATTRIB(NewMenuTeamSelectDialog, columns, float, 4)
	ATTRIB(NewMenuTeamSelectDialog, name, string, "TeamSelect")
	ATTRIB(NewMenuTeamSelectDialog, team1, entity, NULL)
	ATTRIB(NewMenuTeamSelectDialog, team2, entity, NULL)
	ATTRIB(NewMenuTeamSelectDialog, team3, entity, NULL)
	ATTRIB(NewMenuTeamSelectDialog, team4, entity, NULL)
ENDCLASS(NewMenuTeamSelectDialog)
#endif

#ifdef IMPLEMENTATION
entity makeTeamButton(string theName, vector theColor, string commandtheName)
{
	entity b;
	b = makeNewMenuBigCommandButton(theName, theColor, commandtheName, 1);
	return b;
}

void showNotifyNewMenuTeamSelectDialog(entity me)
{
	float teams, nTeams;
	teams = CVAR(_teams_available);
	nTeams = 0;
	me.team1.disabled = !(teams & 1); nTeams += !!(teams & 1);
	me.team2.disabled = !(teams & 2); nTeams += !!(teams & 2);
	me.team3.disabled = !(teams & 4); nTeams += !!(teams & 4);
	me.team4.disabled = !(teams & 8); nTeams += !!(teams & 8);
}

void fillNewMenuTeamSelectDialog(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 2, 4, e = makeTeamButton("join 'best' team (auto-select)", '0 0 0', "cmd selectteam auto; cmd join"));
			e.preferredFocusPriority = 1;
	me.TR(me);
	me.TR(me);
		me.TD(me, 2, 1, me.team1 = makeTeamButton("red", '1 0.5 0.5', "cmd selectteam red; cmd join"));
		me.TD(me, 2, 1, me.team2 = makeTeamButton("blue", '0.5 0.5 1', "cmd selectteam blue; cmd join"));
		me.TD(me, 2, 1, me.team3 = makeTeamButton("yellow", '1 1 0.5', "cmd selectteam yellow; cmd join"));
		me.TD(me, 2, 1, me.team4 = makeTeamButton("pink", '1 0.5 1', "cmd selectteam pink; cmd join"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 4, makeNewMenuCommandButton("spectate", '0 0 0', "cmd spectate", 1));
}
#endif

/* Click. The c-word is here so you can grep for it :-) */
