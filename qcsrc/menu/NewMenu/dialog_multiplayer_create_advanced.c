#ifdef INTERFACE
CLASS(NewMenuAdvancedDialog) EXTENDS(NewMenuDialog)
	METHOD(NewMenuAdvancedDialog, fill, void(entity))
	METHOD(NewMenuAdvancedDialog, showNotify, void(entity))
	METHOD(NewMenuAdvancedDialog, close, void(entity))
	ATTRIB(NewMenuAdvancedDialog, title, string, "Advanced server settings")
	ATTRIB(NewMenuAdvancedDialog, color, vector, SKINCOLOR_DIALOG_ADVANCED)
	ATTRIB(NewMenuAdvancedDialog, intendedWidth, float, 0.5)
	ATTRIB(NewMenuAdvancedDialog, rows, float, 14)
	ATTRIB(NewMenuAdvancedDialog, columns, float, 3)
	ATTRIB(NewMenuAdvancedDialog, refilterEntity, entity, NULL)
ENDCLASS(NewMenuAdvancedDialog)
#endif

#ifdef IMPLEMENTATION
void showNotifyNewMenuAdvancedDialog(entity me)
{
	loadAllCvars(me);
}

void fillNewMenuAdvancedDialog(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 1, 1.2, makeNewMenuTextLabel(0, "Game settings:"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeNewMenuCheckBox(0, "sv_spectate", "Allow spectating"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeNewMenuTextLabel(0, "Spawn shield:"));
		me.TD(me, 1, 1.7, e = makeNewMenuSlider(0, 15, 0.5, "g_spawnshieldtime"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeNewMenuTextLabel(0, "Start delay:"));
		me.TD(me, 1, 1.7, e = makeNewMenuSlider(0, 30, 0.5, "g_start_delay"));
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeNewMenuTextLabel(0, "Game speed:"));
		me.TD(me, 1, 1.7, e = makeNewMenuSlider(0.5, 2.0, 0.1, "slowmo"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeNewMenuCheckBoxEx(2, 0, "g_antilag", "AntiLag"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1.2, makeNewMenuTextLabel(0, "Teamplay settings:"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeNewMenuTextLabel(0, "Friendly fire scale:"));
		me.TD(me, 1, 1.7, e = makeNewMenuSlider(0, 1.0, 0.05, "g_friendlyfire"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeNewMenuTextLabel(0, "Friendly fire penalty:"));
		me.TD(me, 1, 1.7, e = makeNewMenuSlider(0, 1.0, 0.05, "g_mirrordamage"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeNewMenuTextLabel(0, "Teams:"));
		me.TD(me, 1, 1.7, e = makeNewMenuTextSlider("g_tdm_teams_override"));
			e.addValue(e, "Default", "0");
			e.addValue(e, "2 teams", "2");
			e.addValue(e, "3 teams", "3");
			e.addValue(e, "4 teams", "4");
			e.configureNewMenuTextSliderValues(e);
		makeMulti(e, "g_domination_teams_override g_keyhunt_teams_override");

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeNewMenuButton("OK", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}

void closeNewMenuAdvancedDialog(entity me)
{
	if(me.refilterEntity)
		me.refilterEntity.refilter(me.refilterEntity);
	closeDialog(me);
}
#endif
