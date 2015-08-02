#ifdef INTERFACE
CLASS(NewMenuNetworkSettingsTab) EXTENDS(NewMenuTab)
	METHOD(NewMenuNetworkSettingsTab, fill, void(entity))
	ATTRIB(NewMenuNetworkSettingsTab, title, string, "Network")
	ATTRIB(NewMenuNetworkSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NewMenuNetworkSettingsTab, rows, float, 17)
	ATTRIB(NewMenuNetworkSettingsTab, columns, float, 6.5)
ENDCLASS(NewMenuNetworkSettingsTab)
entity makeNewMenuNetworkSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuNetworkSettingsTab()
{
	entity me;
	me = spawnNewMenuNetworkSettingsTab();
	me.configureDialog(me);
	return me;
}

void fillNewMenuNetworkSettingsTab(entity me)
{
	entity e;

	if(CVAR(menu_advanced) > 0){
		me.TR(me);
			me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "cl_movement", "Client-side movement prediction"));
	}
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "shownetgraph", "Show network use graph"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Network speed (Bps):"));
		me.TD(me, 1, 2, e = makeNewMenuTextSlider("_cl_rate"));
			e.addValue(e, "56k (4000)", "4000");
			e.addValue(e, "ISDN (7000)", "7000");
			e.addValue(e, "Slow ADSL (15000)", "15000");
			e.addValue(e, "Fast ADSL (20000)", "20000");
			e.addValue(e, "Broadband (25000)", "25000");
			e.addValue(e, "Real Internet (40000)", "40000");
			e.configureNewMenuTextSliderValues(e);
	if(CVAR(menu_advanced) > 0){
		me.TR(me);
			me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Input packets/s:"));
			me.TD(me, 1, 2, e = makeNewMenuSlider(20, 100, 1, "cl_netfps"));
	}
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuTextLabel(0, "HTTP downloads:"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeNewMenuTextLabel(0, "Downloads:"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(1, 5, 1, "cl_curl_maxdownloads"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeNewMenuTextLabel(0, "Speed (kB/s):"));
		me.TD(me, 1, 2, e = makeNewMenuSlider(10, 1500, 10, "cl_curl_maxspeed"));
	me.TR(me);
	if(CVAR(menu_advanced) > 0){
		me.TR(me);
			me.TD(me, 1, 1, e = makeNewMenuTextLabel(0, "Client UDP port:"));
			me.TD(me, 1, 0.64, e = makeNewMenuInputBox(0, "cl_port"));
	}
}
#endif
