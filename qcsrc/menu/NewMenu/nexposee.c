#ifdef INTERFACE
CLASS(NewMenuNexposee) EXTENDS(Nexposee)
	METHOD(NewMenuNexposee, configureNewMenuNexposee, void(entity))
	METHOD(NewMenuNexposee, close, void(entity))
ENDCLASS(NewMenuNexposee)
entity makeNewMenuNexposee();
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuNexposee()
{
	entity me;
	me = spawnNewMenuNexposee();
	me.configureNewMenuNexposee(me);
	return me;
}

void configureNewMenuNexposeeNewMenuNexposee(entity me)
{
}

void closeNewMenuNexposee(entity me)
{
	m_goto(string_null); // hide
}
#endif
