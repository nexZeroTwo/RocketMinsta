#ifdef INTERFACE
CLASS(NewMenuModButton) EXTENDS(NewMenuButton)
	METHOD(NewMenuModButton, configureNewMenuModButton, void(entity, string))
	ATTRIB(NewMenuModButton, destination, string, string_null)
ENDCLASS(NewMenuModButton)
entity makeNewMenuModButton(string menu);
void NewMenuModButton_Click(entity me, entity other);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuModButton(string menu)
{
	entity me;
	me = spawnNewMenuModButton();
	me.configureNewMenuModButton(me, menu);
	return me;
}

void NewMenuModButton_Click(entity me, entity other)
{
	string thecmd;
	thecmd = strcat("\nmenu_restart");

	if (me.destination != "")
		thecmd = strcat(thecmd, "\ntogglemenu\ndefer 0.1 \"menu_cmd directmenu ", me.destination,"\"\n");

	if (cvar_string("menu_slist_modfilter") == "havoc")
		thecmd = strcat("\ngamedir data", thecmd);
	else
		thecmd = strcat("\ngamedir havoc", thecmd);
	cmd(thecmd);
}

void configureNewMenuModButtonNewMenuModButton(entity me, string menu)
{
	me.configureNewMenuButton(me, "", '0 0 0');
	me.onClick = NewMenuModButton_Click;
	me.onClickEntity = me;
	me.destination = menu;

	if (cvar_string("menu_slist_modfilter") == "havoc")
		me.text = "Switch to NewMenu mode";
	else
		me.text = "Switch to Havoc mode";
}
#endif
