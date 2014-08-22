#ifdef INTERFACE
CLASS(NewMenuDemoList) EXTENDS(NewMenuListBox)
    METHOD(NewMenuDemoList, configureNewMenuDemoList, void(entity))
    ATTRIB(NewMenuDemoList, rowsPerItem, float, 1)
    METHOD(NewMenuDemoList, resizeNotify, void(entity, vector, vector, vector, vector))
    METHOD(NewMenuDemoList, drawListBoxItem, void(entity, float, vector, float))
    METHOD(NewMenuDemoList, getDemos, void(entity))
    METHOD(NewMenuDemoList, startDemo, void(entity))    
    METHOD(NewMenuDemoList, demoName, string(entity, float))
    METHOD(NewMenuDemoList, clickListBoxItem, void(entity, float, vector))
    METHOD(NewMenuDemoList, keyDown, float(entity, float, float, float))
    METHOD(NewMenuDemoList, destroy, void(entity))
    METHOD(NewMenuDemoList, showNotify, void(entity))
    ATTRIB(NewMenuDemoList, listDemo, float, -1)
    ATTRIB(NewMenuDemoList, realFontSize, vector, '0 0 0')
    ATTRIB(NewMenuDemoList, columnNameOrigin, float, 0)
    ATTRIB(NewMenuDemoList, columnNameSize, float, 0)
    ATTRIB(NewMenuDemoList, realUpperMargin, float, 0)
    ATTRIB(NewMenuDemoList, origin, vector, '0 0 0')
    ATTRIB(NewMenuDemoList, itemAbsSize, vector, '0 0 0')
    ATTRIB(NewMenuDemoList, lastClickedDemo, float, -1)
    ATTRIB(NewMenuDemoList, lastClickedTime, float, 0)
    ATTRIB(NewMenuDemoList, filterString, string, string_null)    
ENDCLASS(NewMenuDemoList)

entity makeNewMenuDemoList();
void StartDemo_Click(entity btn, entity me);
void TimeDemo_Click(entity btn, entity me);
void DemoList_Filter_Change(entity box, entity me);
#endif

#ifdef IMPLEMENTATION

entity makeNewMenuDemoList()
{
    entity me;
    me = spawnNewMenuDemoList();
    me.configureNewMenuDemoList(me);
    return me;
}

void configureNewMenuDemoListNewMenuDemoList(entity me)
{
    me.configureNewMenuListBox(me);
    me.getDemos(me);    
}

string demoNameNewMenuDemoList(entity me, float i )
{
    string s;
    s = search_getfilename(me.listDemo, i);
    s = substring(s, 6, strlen(s) - 6 - 4);  // demos/, .dem
    return s;
}


void getDemosNewMenuDemoList(entity me)
{
    string s;
    
    if(me.filterString)
    	//subdirectory in filterString allowed    
    	s=strcat("demos/*", me.filterString, "*.dem");    	
    else
    	s="demos/*.dem";
	
    //dprint("Search demos with the pattern ", s, "\n");    
	if(me.listDemo >= 0)
		search_end(me.listDemo);
    me.listDemo = search_begin(s, FALSE, TRUE);
    if(me.listDemo < 0)
    	me.nItems=0;
    else
    	me.nItems=search_getsize(me.listDemo);				
}

void destroyNewMenuDemoList(entity me)
{
    search_end(me.listDemo);
}

void resizeNotifyNewMenuDemoList(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
    me.itemAbsSize = '0 0 0';
    resizeNotifyNewMenuListBox(me, relOrigin, relSize, absOrigin, absSize);

    me.realFontSize_y = me.fontSize / (me.itemAbsSize_y = (absSize_y * me.itemHeight));
    me.realFontSize_x = me.fontSize / (me.itemAbsSize_x = (absSize_x * (1 - me.controlWidth)));
    me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);

    me.columnNameOrigin = me.realFontSize_x;
    me.columnNameSize = 1 - 2 * me.realFontSize_x;
}

void drawListBoxItemNewMenuDemoList(entity me, float i, vector absSize, float isSelected)
{
    string s;
    if(isSelected)
    	draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
		
    s = me.demoName(me,i);
    s = draw_TextShortenToWidth(s, me.columnNameSize / me.realFontSize_x, 0);
    draw_Text(me.realUpperMargin * eY + (me.columnNameOrigin + 0.00 * (me.columnNameSize - draw_TextWidth(s, 0) * me.realFontSize_x)) * eX, s, me.realFontSize, '1 1 1', SKINALPHA_TEXT, 0);		
}

void showNotifyNewMenuDemoList(entity me)
{
    me.getDemos(me);
}

void DemoList_Filter_Change(entity box, entity me)
{	
    if(me.filterString)
    	strunzone(me.filterString);
    
    if(box.text != "")
    	me.filterString = strzone(box.text);
    else
    	me.filterString = string_null;
		
    me.getDemos(me);
}

void startDemoNewMenuDemoList(entity me)
{
    string s;
    s = me.demoName(me,me.selectedItem);
    localcmd("playdemo demos/", s, ".dem\nwait\ntogglemenu\n");	
}

void StartDemo_Click(entity btn, entity me)
{
    me.startDemo(me);
}

void TimeDemo_Click(entity btn, entity me)
{
    string s;
    s = me.demoName(me,me.selectedItem);
    localcmd("timedemo demos/", s, ".dem\nwait\ntogglemenu\n");	
}

void clickListBoxItemNewMenuDemoList(entity me, float i, vector where)
{
    if(i == me.lastClickedDemo)
        if(time < me.lastClickedTime + 0.3)
        {
            // DOUBLE CLICK!
            me.setSelected(me, i);
            me.startDemo(me);
        }
    me.lastClickedDemo = i;
    me.lastClickedTime = time;
}

float keyDownNewMenuDemoList(entity me, float scan, float ascii, float shift)
{
    if(scan == K_ENTER) {
        me.startDemo(me);
        return 1;
    }
    else
        return keyDownListBox(me, scan, ascii, shift);
}
#endif

