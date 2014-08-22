#ifdef INTERFACE
CLASS(NewMenuVoteList) EXTENDS(NewMenuListBox)
	METHOD(NewMenuVoteList, configureNewMenuVoteList, void(entity))
	METHOD(NewMenuVoteList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(NewMenuVoteList, loadCvars, void(entity))
	METHOD(NewMenuVoteList, setSelected, void(entity, float))
	METHOD(NewMenuVoteList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(NewMenuVoteList, RMUpdate, void(entity))
	ATTRIB(NewMenuVoteList, RMUpdatable, float, TRUE)
	ATTRIB(NewMenuVoteList, textBox, entity, NULL)
ENDCLASS(NewMenuVoteList)
entity makeNewMenuVoteList();
#endif

#ifdef IMPLEMENTATION

#define MAX_VOTES 100
string votelist[MAX_VOTES];
float numvotes;

void RMUpdateNewMenuVoteList(entity me)
{
	me.loadCvars(me);
}

entity makeNewMenuVoteList(void)
{
	entity me;
	me = spawnNewMenuVoteList();
	me.configureNewMenuVoteList(me);
	return me;
}

void configureNewMenuVoteListNewMenuVoteList(entity me)
{
	me.loadCvars(me);
	me.configureNewMenuListBox(me);
}

void setSelectedNewMenuVoteList(entity me, float i)
{
	setSelectedListBox(me, i);
    string s = strcat(votelist[i], " ");
    me.textBox.setText(me.textBox, s);
    me.textBox.cursorPos = strlen(s);
}

void loadCvarsNewMenuVoteList(entity me)
{
    local float i, limit;
    numvotes = tokenizebyseparator(cvar_string("_vote_commands"), " ");
    limit = min(MAX_VOTES, numvotes);
    
    for(i = 0; i < limit; i++)
    {
        if(votelist[i])
            strunzone(votelist[i]);
        
        votelist[i] = strzone(argv(i));
    }
    
    me.nItems = limit;
}

void resizeNotifyNewMenuVoteList(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	resizeNotifyNewMenuListBox(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
	me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);
}

void drawListBoxItemNewMenuVoteList(entity me, float i, vector absSize, float isSelected)
{
	string s;
	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
	s = votelist[i];
	draw_Text(me.realUpperMargin * eY + (me.columnNameOrigin) * eX, s, me.realFontSize, '1 1 1', SKINALPHA_TEXT, 0);
}

#endif

