#ifdef INTERFACE
CLASS(MainWindow) EXTENDS(ModalController)
	METHOD(MainWindow, configureMainWindow, void(entity))
	ATTRIB(MainWindow, advancedDialog, entity, NULL)
	ATTRIB(MainWindow, mutatorsDialog, entity, NULL)
	ATTRIB(MainWindow, weaponsDialog, entity, NULL)
	ATTRIB(MainWindow, mapInfoDialog, entity, NULL)
	ATTRIB(MainWindow, userbindEditDialog, entity, NULL)
	ATTRIB(MainWindow, winnerDialog, entity, NULL)
	ATTRIB(MainWindow, radarDialog, entity, NULL)
	ATTRIB(MainWindow, rmDialog, entity, NULL)
	ATTRIB(MainWindow, gameMenuDialog, entity, NULL)
	ATTRIB(MainWindow, nadeMenuDialog, entity, NULL)
	ATTRIB(MainWindow, vcallDialog, entity, NULL)
	ATTRIB(MainWindow, serverInfoDialog, entity, NULL)
	ATTRIB(MainWindow, cvarsDialog, entity, NULL)
	ATTRIB(MainWindow, mainNexposee, entity, NULL)
	ATTRIB(MainWindow, fadedAlpha, float, SKINALPHA_BEHIND)
ENDCLASS(MainWindow)
#endif

#ifdef IMPLEMENTATION

void DemoButton_Click(entity me, entity other)
{
	if(me.text == "Do not press this button again!")
		DialogOpenButton_Click(me, other);
	else
		me.setText(me, "Do not press this button again!");
}

void configureMainWindowMainWindow(entity me)
{
	entity n, i;

	i = spawnNewMenuTeamSelectDialog();
	i.configureDialog(i);
	me.addItemCentered(me, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);
    
	me.rmDialog = i = spawnNewMenuRMConfigDialog();
	i.configureDialog(i);
	me.addItemCentered(me, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);
    
	me.gameMenuDialog = i = spawnNewMenuGameMenuDialog();
	i.configureDialog(i);
	me.addItemCentered(me, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);
    
    me.nadeMenuDialog = i = spawnNewMenuNadeMenuDialog();
	i.configureDialog(i);
	me.addItemCentered(me, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);

	me.vcallDialog = i = spawnNewMenuVcallDialog();
	i.configureDialog(i);
	me.addItemCentered(me, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);

	me.advancedDialog = i = spawnNewMenuAdvancedDialog();
	i.configureDialog(i);
	me.addItemCentered(me, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);

	me.mutatorsDialog = i = spawnNewMenuMutatorsDialog();
	i.configureDialog(i);
	me.addItemCentered(me, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);

	me.mapInfoDialog = i = spawnNewMenuMapInfoDialog();
	i.configureDialog(i);
	me.addItemCentered(me, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);

	me.userbindEditDialog = i = spawnNewMenuUserbindEditDialog();
	i.configureDialog(i);
	me.addItemCentered(me, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);

	me.winnerDialog = i = spawnNewMenuWinnerDialog();
	i.configureDialog(i);
	me.addItemCentered(me, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);

	me.weaponsDialog = i = spawnNewMenuWeaponsDialog();
	i.configureDialog(i);
	me.addItemCentered(me, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);

	me.radarDialog = i = spawnNewMenuRadarDialog();
	i.configureDialog(i);
	me.addItemCentered(me, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);
	
	me.serverInfoDialog = i = spawnNewMenuServerInfoDialog();
	i.configureDialog(i);
	me.addItemCentered(me, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);
	
	me.cvarsDialog = i = spawnNewMenuCvarsDialog();
	i.configureDialog(i);
	me.addItemCentered(me, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);
	
	me.mainNexposee = n = spawnNewMenuNexposee();
	/*
		if(checkextension("DP_GECKO_SUPPORT"))
		{
			i = spawnNewMenuNewsDialog();
			i.configureDialog(i);
			n.addItemCentered(n, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);
			n.setNexposee(n, i, '0.1 0.1 0', SKINALPHAS_MAINMENU_x, SKINALPHAS_MAINMENU_y);
		}
	*/
    /*
		i = spawnNewMenuSingleplayerDialog();
		i.configureDialog(i);
		n.addItemCentered(n, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);
		n.setNexposee(n, i, SKINPOSITION_DIALOG_SINGLEPLAYER, SKINALPHAS_MAINMENU_x, SKINALPHAS_MAINMENU_y);
    */
        
		i = spawnNewMenuMultiplayerDialog();
		i.configureDialog(i);
		n.addItemCentered(n, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);
		n.setNexposee(n, i, '0.5 0.1 0.0', SKINALPHAS_MAINMENU_x, SKINALPHAS_MAINMENU_y);

		i = spawnNewMenuSettingsDialog();
		i.configureDialog(i);
		n.addItemCentered(n, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);
		n.setNexposee(n, i, '0.5 0.9 0.0', SKINALPHAS_MAINMENU_x, SKINALPHAS_MAINMENU_y);

		i = spawnNewMenuCreditsDialog();
		i.configureDialog(i);
		n.addItemCentered(n, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);
		n.setNexposee(n, i, SKINPOSITION_DIALOG_CREDITS, SKINALPHAS_MAINMENU_x, SKINALPHAS_MAINMENU_y);
		n.pullNexposee(n, i, eY * (SKINHEIGHT_TITLE * SKINFONTSIZE_TITLE / conheight));

		i = spawnNewMenuQuitDialog();
		i.configureDialog(i);
		n.addItemCentered(n, i, i.intendedWidth * eX + i.intendedHeight * eY, SKINALPHAS_MAINMENU_z);
		n.setNexposee(n, i, SKINPOSITION_DIALOG_QUIT, SKINALPHAS_MAINMENU_x, SKINALPHAS_MAINMENU_y);
		n.pullNexposee(n, i, eY * (SKINHEIGHT_TITLE * SKINFONTSIZE_TITLE / conheight));
	me.addItem(me, n, '0 0 0', '1 1 0', SKINALPHAS_MAINMENU_z);
	me.moveItemAfter(me, n, NULL);

	me.initializeDialog(me, n);
}
#endif

/* Click. The c-word is here so you can grep for it :-) */
