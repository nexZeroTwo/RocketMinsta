#ifdef INTERFACE
CLASS(NewMenuRMConfigDialog) EXTENDS(NewMenuRootDialog)
	METHOD(NewMenuRMConfigDialog, fill, void(entity)) // to be overridden by user to fill the dialog with controls
	ATTRIB(NewMenuRMConfigDialog, title, string, "RocketMinsta Configuration")
	ATTRIB(NewMenuRMConfigDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(NewMenuRMConfigDialog, intendedWidth, float, 0.8)
	ATTRIB(NewMenuRMConfigDialog, rows, float, 19)
	ATTRIB(NewMenuRMConfigDialog, columns, float, 16)
	ATTRIB(NewMenuRMConfigDialog, name, string, "RMConfig")
ENDCLASS(NewMenuRMConfigDialog)
#endif

#ifdef IMPLEMENTATION

#define OPTDEP(o) setDependent(e, "_rm_optavail_"##o, 1, 1);

void fillNewMenuRMConfigDialog(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(0, "showspec", "Show spectators"));
			OPTDEP("showspec")
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(0, "showdamage", "Hit/damage indicator"));
			OPTDEP("showdamage")
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(0, "crosshealth", "Color crosshair by health"));
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(0, "shownames", "Show player names above their heads"));
			OPTDEP("shownames")
	me.setFirstColumn(me, me.firstColumn + 0.1);
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(0, "shownames_teamonly", "Only allies"));
			OPTDEP("shownames")
	me.setFirstColumn(me, me.firstColumn - 0.1);
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(0, "teamlasers", "Team-colored particles"));
			//OPTDEP("teamlasers")
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(0, "legacyvote", "Simple voting screen"));
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(1, "simpleeffects", "Effects for textual notifications"));
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(0, "anonspec", "Spectate anonymously"));
			OPTDEP("anonspec")
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(1, "nobigtext", "Enable big notifications"));
	me.setFirstColumn(me, me.firstColumn + 0.1);
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(1, "hidebigcomments", "with comments"));
		setDependent(e, "rm_nobigtext", 0, 0);
	me.setFirstColumn(me, me.firstColumn - 0.1);
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(1, "noflags", "Country flags in scoreboard"));
	me.TR(me);
		me.TD (me, 1, 4, e = makeRMCheckBox (0, "hidecountry", "Hide my country"));
			OPTDEP("hidecountry")
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(1, "notimer", "\"time\" column in scoreboard"));
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(1, "nokillsound", "Separate kill and hit sounds"));
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(1, "nogamemenu", "Enable the Game Menu"));
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(1, "hidewatermark", "Show version information"));
	me.TR(me);
		me.TD(me, 1, 4, e = makeNewMenuTextLabel(0, "Note: You can access these options through Multiplayer -> Player Setup"));
	me.TR(me);
		me.TD(me, 1, me.columns, e = makeNewMenuButton("Ok", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
	
	me.gotoRC(me, 0, 8); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 4, e = makeRMCheckBox(0, "freezetag_danger", "Danger shortcut for freezetag"));
			OPTDEP("freezetag_danger")
	me.setFirstColumn(me, me.firstColumn + 0.1);
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(0, "freezetag_danger_silent", "Without teamchat notification"));
			OPTDEP("freezetag_danger")
	me.setFirstColumn(me, me.firstColumn - 0.1);
	me.TR(me);
		me.TD(me, 1, 4, e = makeNewMenuTextLabel(0, "HUD settings:"));
	me.setFirstColumn(me, me.firstColumn + 0.1);
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(0, "oldhud", "Use default Vecxis HUD"));
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(0, "althud", "Use an alternative HUD layout"));
            setDependent(e, "rm_oldhud", 0, 0);
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(0, "oldbigfont", "Use default Vecxis fonts"));
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(0, "visualscore", "Scoring notifications in the HUD"));
	me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(0, "showrankings", "Show top players in the HUD"));
    me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(0, "showtimer", "Always show the timer"));
    me.TR(me);
		me.TD(me, 1, 4, e = makeRMCheckBox(0, "shownadgetregen", "Show Nadget regeneration in seconds"));
            setDependentAND(e, "rm_oldhud", 0, 0, "_rm_optavail_shownadgetregen", 1, 1);
	me.setFirstColumn(me, me.firstColumn - 0.1);
		me.TR(me);
		me.TD(me, 1, 4, e = makeNewMenuTextLabel(0, "HUD skin:"));
		setDependent(e, "rm_oldhud", 0, 0);
	me.TR(me);
		me.TD(me, me.rows - 13, 8, e = makeRMHudSkinList());
		setDependent(e, "rm_oldhud", 0, 0);
	//me.gotoRC(me, me.rows - 5, 8); me.setFirstColumn(me, me.currentColumn);
}
#endif

/* Click. The c-word is here so you can grep for it :-) */
