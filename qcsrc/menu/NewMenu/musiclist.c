
#ifdef INTERFACE
CLASS(MusicList) EXTENDS(NewMenuListBox)
    METHOD(MusicList, configureMusicList, void(entity))
    ATTRIB(MusicList, rowsPerItem, float, 1)
    METHOD(MusicList, resizeNotify, void(entity, vector, vector, vector, vector))
    METHOD(MusicList, drawListBoxItem, void(entity, float, vector, float))
    METHOD(MusicList, getMusic, void(entity))
    METHOD(MusicList, startMusic, void(entity))
    METHOD(MusicList, musicName, string(entity, float))
    METHOD(MusicList, clickListBoxItem, void(entity, float, vector))
    METHOD(MusicList, keyDown, float(entity, float, float, float))
    METHOD(MusicList, destroy, void(entity))
    METHOD(MusicList, showNotify, void(entity))
    ATTRIB(MusicList, listMusic, float, -1)
    ATTRIB(MusicList, realFontSize, vector, '0 0 0')
    ATTRIB(MusicList, columnNameOrigin, float, 0)
    ATTRIB(MusicList, columnNameSize, float, 0)
    ATTRIB(MusicList, realUpperMargin, float, 0)
    ATTRIB(MusicList, origin, vector, '0 0 0')
    ATTRIB(MusicList, itemAbsSize, vector, '0 0 0')
    ATTRIB(MusicList, lastClickedMusic, float, -1)
    ATTRIB(MusicList, lastClickedTime, float, 0)
    ATTRIB(MusicList, filterString, string, string_null)
ENDCLASS(MusicList)

entity makeMusicList();
void StartMusic_Click(entity btn, entity me);
void StopMusic_Click(entity btn, entity me);
void MusicList_Filter_Change(entity box, entity me);
#endif

#ifdef IMPLEMENTATION

entity makeMusicList()
{
    entity me;
    me = spawnMusicList();
    me.configureMusicList(me);
    return me;
}

void configureMusicListMusicList(entity me)
{
    me.configureNewMenuListBox(me);
    me.getMusic(me);
}

string musicNameMusicList(entity me, float i )
{
    string s;
    s = search_getfilename(me.listMusic, i);
    s = substring(s, 6, strlen(s) - 6 - 4);  // music/, .ogg
    return s;
}


void getMusicMusicList(entity me)
{
    string s;

    if(me.filterString)
    	//subdirectory in filterString allowed
    	s=strcat("music/*", me.filterString, "*.ogg");
    else
    	s="music/*.ogg";

    //dprint("Search music with the pattern ", s, "\n");
	if(me.listMusic >= 0)
		search_end(me.listMusic);
    me.listMusic = search_begin(s, FALSE, TRUE);
    if(me.listMusic < 0)
    	me.nItems=0;
    else
    	me.nItems=search_getsize(me.listMusic);
}

void destroyMusicList(entity me)
{
    search_end(me.listMusic);
}

void resizeNotifyMusicList(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
    me.itemAbsSize = '0 0 0';
    resizeNotifyNewMenuListBox(me, relOrigin, relSize, absOrigin, absSize);

    me.realFontSize_y = me.fontSize / (me.itemAbsSize_y = (absSize_y * me.itemHeight));
    me.realFontSize_x = me.fontSize / (me.itemAbsSize_x = (absSize_x * (1 - me.controlWidth)));
    me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);

    me.columnNameOrigin = me.realFontSize_x;
    me.columnNameSize = 1 - 2 * me.realFontSize_x;
}

void drawListBoxItemMusicList(entity me, float i, vector absSize, float isSelected)
{
    string s;
    if(isSelected)
    	draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
    dprint("line 101\n");
    s = me.musicName(me,i);
    s = draw_TextShortenToWidth(s, me.columnNameSize / me.realFontSize_x, 0);
    draw_Text(me.realUpperMargin * eY + (me.columnNameOrigin + 0.00 * (me.columnNameSize - draw_TextWidth(s, 0) * me.realFontSize_x)) * eX, s, me.realFontSize, '1 1 1', SKINALPHA_TEXT, 0);
}

void showNotifyMusicList(entity me)
{
    me.getMusic(me);
}

void MusicList_Filter_Change(entity box, entity me)
{
    if(me.filterString)
    	strunzone(me.filterString);

    if(box.text != "")
    	me.filterString = strzone(box.text);
    else
    	me.filterString = string_null;

    me.getMusic(me);
}

void startMusicMusicList(entity me)
{
    string s;
    s = me.musicName(me,me.selectedItem);
    localcmd("cd loop \"music/", s, "\".ogg\n");
}

void StartMusic_Click(entity btn, entity me)
{
    me.startMusic(me);
}

void StopMusic_Click(entity btn, entity me)
{
    localcmd("cd stop\n");
}

void clickListBoxItemMusicList(entity me, float i, vector where)
{
    if(i == me.lastClickedMusic)
        if(time < me.lastClickedTime + 0.3)
        {
            // DOUBLE CLICK!
            me.setSelected(me, i);
            me.startMusic(me);
        }
    me.lastClickedMusic = i;
    me.lastClickedTime = time;
}

float keyDownMusicList(entity me, float scan, float ascii, float shift)
{
    if(scan == K_ENTER) {
        me.startMusic(me);
        return 1;
    }
    else
        return keyDownListBox(me, scan, ascii, shift);
}
#endif
