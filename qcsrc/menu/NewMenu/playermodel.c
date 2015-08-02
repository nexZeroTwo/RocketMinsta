#ifdef INTERFACE
CLASS(NewMenuPlayerModelSelector) EXTENDS(NewMenuImage)
	METHOD(NewMenuPlayerModelSelector, configureNewMenuPlayerModelSelector, void(entity))
	METHOD(NewMenuPlayerModelSelector, loadCvars, void(entity))
	METHOD(NewMenuPlayerModelSelector, saveCvars, void(entity))
	METHOD(NewMenuPlayerModelSelector, draw, void(entity))
	METHOD(NewMenuPlayerModelSelector, resizeNotify, void(entity, vector, vector, vector, vector))
	ATTRIB(NewMenuPlayerModelSelector, currentModel, string, string_null)
	ATTRIB(NewMenuPlayerModelSelector, currentSkin, float, 0)
	ATTRIB(NewMenuPlayerModelSelector, currentModelName, string, string_null)
	ATTRIB(NewMenuPlayerModelSelector, currentModelTitle, string, string_null)
	ATTRIB(NewMenuPlayerModelSelector, currentModelTxtName, string, string_null)
	ATTRIB(NewMenuPlayerModelSelector, currentModelDescription, string, string_null)
	METHOD(NewMenuPlayerModelSelector, go, void(entity, float))
	ATTRIB(NewMenuPlayerModelSelector, origin, vector, '0 0 0')
	ATTRIB(NewMenuPlayerModelSelector, size, vector, '0 0 0')
	ATTRIB(NewMenuPlayerModelSelector, realFontSize, vector, '0 0 0')
	ATTRIB(NewMenuPlayerModelSelector, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NewMenuPlayerModelSelector, titleFontSize, float, SKINFONTSIZE_TITLE)
ENDCLASS(NewMenuPlayerModelSelector)
entity makeNewMenuPlayerModelSelector();
void PlayerModelSelector_Next_Click(entity btn, entity me);
void PlayerModelSelector_Prev_Click(entity btn, entity me);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuPlayerModelSelector()
{
	entity me;
	me = spawnNewMenuPlayerModelSelector();
	me.configureNewMenuPlayerModelSelector(me);
	return me;
}

void configureNewMenuPlayerModelSelectorNewMenuPlayerModelSelector(entity me)
{
	me.configureNewMenuImage(me, string_null, 263.0/360.0);
	me.loadCvars(me);
}

void loadCvarsNewMenuPlayerModelSelector(entity me)
{
	float glob, i, fh;
	string fn;
	string nm, t, l;

	if(me.currentModel)
		strunzone(me.currentModel);
	if(me.currentModelTitle)
		strunzone(me.currentModelTitle);
	if(me.currentModelName)
		strunzone(me.currentModelName);
	if(me.currentModelTxtName)
		strunzone(me.currentModelTxtName);
	if(me.currentModelDescription)
		strunzone(me.currentModelDescription);
	me.currentSkin = CVAR(_cl_playerskin);
	me.currentModel = strzone(CVAR_STR(_cl_playermodel));
	me.currentModelName = string_null;
	me.currentModelDescription = string_null;
	me.currentModelTitle = string_null;
	me.currentModelTxtName = string_null;

	// lookup model name
	glob = search_begin("models/player/*.txt", TRUE, TRUE);
	if(glob < 0)
		return;
	for(i = 0; i < search_getsize(glob); ++i)
	{
		fn = search_getfilename(glob, i);
		fh = fopen(fn, FILE_READ);
		if(fh < 0)
			continue;
		t = fgets(fh);
		nm = fgets(fh);
		if(stof(fgets(fh)) == me.currentSkin)
		if(fgets(fh) == me.currentModel)
		{
			me.currentModelName = strzone(strcat("/", nm));
			me.currentModelTxtName = strzone(fn);
			me.currentModelTitle = strzone(t);
			me.currentModelDescription = "";
			fgets(fh); // Skip species
			while((l = fgets(fh)))
			{
				if(me.currentModelDescription != "")
					me.currentModelDescription = strcat(me.currentModelDescription, "\n");
				me.currentModelDescription = strcat(me.currentModelDescription, l);
			}
			me.currentModelDescription = strzone(me.currentModelDescription);
			fclose(fh);
			break;
		}
		fclose(fh);
	}
	search_end(glob);
}

void goNewMenuPlayerModelSelector(entity me, float d)
{
	float glob, i, fh;
	string l;

	glob = search_begin("models/player/*.txt", TRUE, TRUE);
	if(glob < 0)
		return;
	for(i = 0; i < search_getsize(glob); ++i)
		if(search_getfilename(glob, i) == me.currentModelTxtName)
			break;
	// now i is search_getsize(glob) if not found, and the right index if found.
	if(i == search_getsize(glob))
	{
		if(d < 0)
			i = search_getsize(glob) - 1;
		else
			i = 0;
	}
	else
	{
		i = mod(i + d + search_getsize(glob), search_getsize(glob));
	}

	if(me.currentModel)
		strunzone(me.currentModel);
	if(me.currentModelTitle)
		strunzone(me.currentModelTitle);
	if(me.currentModelName)
		strunzone(me.currentModelName);
	if(me.currentModelTxtName)
		strunzone(me.currentModelTxtName);
	if(me.currentModelDescription)
		strunzone(me.currentModelDescription);

	// select model #i!
	me.currentModelTxtName = strzone(search_getfilename(glob, i));
	fh = fopen(me.currentModelTxtName, FILE_READ);
	search_end(glob);
	if(fh < 0)
		return;
	me.currentModelTitle = strzone(fgets(fh));
	me.currentModelName = strzone(strcat("/", fgets(fh)));
	me.currentSkin = stof(fgets(fh));
	me.currentModel = strzone(fgets(fh));
	me.currentModelDescription = "";
	fgets(fh); // Skip species
	while((l = fgets(fh)))
	{
		if(me.currentModelDescription != "")
			me.currentModelDescription = strcat(me.currentModelDescription, "\n");
		me.currentModelDescription = strcat(me.currentModelDescription, l);
	}
	me.currentModelDescription = strzone(me.currentModelDescription);
	fclose(fh);
}

void PlayerModelSelector_Next_Click(entity btn, entity me)
{
	me.go(me, +1);
	me.saveCvars(me);
}

void PlayerModelSelector_Prev_Click(entity btn, entity me)
{
	me.go(me, -1);
	me.saveCvars(me);
}

void saveCvarsNewMenuPlayerModelSelector(entity me)
{
	// TODO rather set the _cl ones and apply later?
	localcmd(strcat("playermodel ", me.currentModel, "\nplayerskin ", ftos(me.currentSkin), "\n"));
}

void drawNewMenuPlayerModelSelector(entity me)
{
	float i, n;
	vector o;

	me.src = me.currentModelName;
	drawImage(me);
	me.src = string_null;

	// draw text on the image, handle \n in the description
	draw_CenterText('0.5 0 0', me.currentModelTitle, me.realFontSize * (me.titleFontSize / me.fontSize), SKINCOLOR_MODELTITLE, SKINALPHA_MODELTITLE, FALSE);

	o = '0.5 1 0' - eY * me.realFontSize_y * ((n = tokenizebyseparator(me.currentModelDescription, "\n")) + 0.5);
	for(i = 0; i < n; ++i)
	{
		draw_CenterText(o, argv(i), me.realFontSize, '1 1 1', 1, FALSE);
		o += eY * me.realFontSize_y;
	}
}

void resizeNotifyNewMenuPlayerModelSelector(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	resizeNotifyImage(me, relOrigin, relSize, absOrigin, absSize);
	me.realFontSize_y = me.fontSize / absSize_y;
	me.realFontSize_x = me.fontSize / absSize_x;
}
#endif
