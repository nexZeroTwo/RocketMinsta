#ifndef COMMANDBUTTON_CLOSE
# define COMMANDBUTTON_CLOSE 1
# define COMMANDBUTTON_APPLY 2
//# define COMMANDBUTTON_REVERT 4
#endif

#ifdef INTERFACE
CLASS(NewMenuCommandButton) EXTENDS(NewMenuButton)
	METHOD(NewMenuCommandButton, configureNewMenuCommandButton, void(entity, string, vector, string, float))
	ATTRIB(NewMenuCommandButton, onClickCommand, string, string_null)
	ATTRIB(NewMenuCommandButton, flags, float, 0)
ENDCLASS(NewMenuCommandButton)
entity makeNewMenuCommandButton(string theText, vector theColor, string theCommand, float closesMenu);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuCommandButton(string theText, vector theColor, string theCommand, float theFlags)
{
	entity me;
	me = spawnNewMenuCommandButton();
	me.configureNewMenuCommandButton(me, theText, theColor, theCommand, theFlags);
	return me;
}

void NewMenuCommandButton_Click(entity me, entity other)
{
	//if(me.flags & COMMANDBUTTON_APPLY)
	//	saveAllCvars(me.parent);
	cmd("\n", me.onClickCommand, "\n");
	//if(me.flags & COMMANDBUTTON_REVERT)
	//	loadAllCvars(me.parent);
	if(me.flags & COMMANDBUTTON_CLOSE)
		m_goto(string_null);
}

void configureNewMenuCommandButtonNewMenuCommandButton(entity me, string theText, vector theColor, string theCommand, float theFlags)
{
	me.configureNewMenuButton(me, theText, theColor);
	me.onClickCommand = theCommand;
	me.flags = theFlags;
	me.onClick = NewMenuCommandButton_Click;
	me.onClickEntity = me;
}
#endif
