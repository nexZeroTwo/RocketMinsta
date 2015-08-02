#ifdef INTERFACE
CLASS(NewMenuGameMenuDialog) EXTENDS(NewMenuRootDialog)
	METHOD(NewMenuGameMenuDialog, fill, void(entity)) // to be overridden by user to fill the dialog with controls
	ATTRIB(NewMenuGameMenuDialog, title, string, "Game Menu")
	ATTRIB(NewMenuGameMenuDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(NewMenuGameMenuDialog, intendedWidth, float, 0.25)
	ATTRIB(NewMenuGameMenuDialog, rows, float, 13)
	ATTRIB(NewMenuGameMenuDialog, columns, float, 10)
	ATTRIB(NewMenuGameMenuDialog, name, string, "GameMenu")
ENDCLASS(NewMenuGameMenuDialog)
#endif

#ifdef IMPLEMENTATION

void m_activate_window(entity);
void m_display();
void GotoMainMenu(entity button, entity me)
{
	m_activate_window(main.mainNexposee);
	m_display();
}

void fillNewMenuGameMenuDialog(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 1, me.columns, e = makeNewMenuButton("Main menu", '0 0 0'));
			e.onClick = GotoMainMenu;
			e.onClickEntity = me;
	me.TR(me);
		me.TD(me, 1, me.columns, e = makeNewMenuCommandButton("RM options", '0 0 0', "menu_cmd directmenu RMConfig;", COMMANDBUTTON_CLOSE));
		setDependent(e, "_rm_server", 1, 1);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, me.columns, e = makeNewMenuCommandButton("Join", '0 0 0', "cmd join;", COMMANDBUTTON_CLOSE));
	me.TR(me);
		me.TD(me, 1, me.columns, e = makeNewMenuCommandButton("Switch team", '0 0 0', "menu_cmd directmenu TeamSelect;", COMMANDBUTTON_CLOSE));
		setDependent(e, "_teams_available", 1, 1337);
	me.TR(me);
		me.TD(me, 1, me.columns, e = makeNewMenuCommandButton("Switch nadget", '0 0 0', "cmd picknade;", COMMANDBUTTON_CLOSE));
		setDependent(e, "_g_nadgets_select_available", 1, 1337);
	me.TR(me);
		me.TD(me, 1, me.columns, e = makeNewMenuCommandButton("Spectate", '0 0 0', "cmd spectate;", COMMANDBUTTON_CLOSE));
	me.TR(me);
		me.TD(me, 1, me.columns, e = makeNewMenuCommandButton("Call a vote", '0 0 0', "menu_cmd directmenu VcallMenu;", COMMANDBUTTON_CLOSE));
		setDependent(e, "_voting_allowed", 1, 1);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, me.columns, e = makeNewMenuCommandButton("Disconnect", '0 0 0', "disconnect;", COMMANDBUTTON_CLOSE));
	me.TR(me);
		me.TD(me, 1, me.columns, e = makeNewMenuCommandButton("Reconnect", '0 0 0', "disconnect; reconnect;", COMMANDBUTTON_CLOSE));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, me.columns, e = makeNewMenuButton("Return to game", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
#endif

/* Click. The c-word is here so you can grep for it :-) */
