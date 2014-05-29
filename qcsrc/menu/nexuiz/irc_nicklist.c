#ifdef INTERFACE
CLASS(IRCNickList) EXTENDS(NexuizListBox)
    METHOD(IRCNickList, configureIRCNickList, void(entity))
    ATTRIB(IRCNickList, fontSize, float, SKINFONTSIZE_NORMAL)
    ATTRIB(IRCNickList, scrollbarWidth, float, SKINWIDTH_SCROLLBAR)
    ATTRIB(IRCNickList, src, string, SKINGFX_SCROLLBAR)
    ATTRIB(IRCNickList, tolerance, vector, SKINTOLERANCE_SLIDER)
    ATTRIB(IRCNickList, rowsPerItem, float, 1)
    METHOD(IRCNickList, resizeNotify, void(entity, vector, vector, vector, vector))
    METHOD(IRCNickList, drawListBoxItem, void(entity, float, vector, float))
    METHOD(IRCNickList, setSelected, void(entity, float))
    METHOD(IRCNickList, updateNickList, void(entity))
    METHOD(IRCNickList, mouseRelease, float(entity, vector))
    ATTRIB(IRCNickList, color, vector, SKINCOLOR_SCROLLBAR_N)
    ATTRIB(IRCNickList, colorF, vector, SKINCOLOR_SCROLLBAR_F)
    ATTRIB(IRCNickList, color2, vector, SKINCOLOR_SCROLLBAR_S)
    ATTRIB(IRCNickList, colorC, vector, SKINCOLOR_SCROLLBAR_C)
    ATTRIB(IRCNickList, receiveIRCNicklistUpdates, float, TRUE)
    ATTRIB(IRCNickList, nlist_buf, float, -1)
    ATTRIB(IRCNickList, nprefs_buf, float, -1)
    ATTRIB(IRCNickList, prevSelected, float, -1)
    ATTRIB(IRCNickList, textBufferControl, entity, NULL)
    ATTRIB(IRCNickList, bufferListControl, entity, NULL)
    ATTRIB(IRCNickList, lastRelease, float, 0)
ENDCLASS(IRCNickList)
entity makeIRCNickList();
#endif

#ifdef IMPLEMENTATION

entity makeIRCNickList() {
    entity me;
    me = spawnIRCNickList();
    me.configureIRCNickList(me);
    return me;
}

void setSelectedIRCNickList(entity me, float i) {
    setSelectedListBox(me, i);
    
    if(i != me.prevSelected) {
        me.prevSelected = i;
    }
}

void SortNickList_Swap(float i1, float i2, entity me) {
    string s1, s2;
    
    s1 = bufstr_get(me.nlist_buf, i1);
    s2 = bufstr_get(me.nlist_buf, i2);
    
    bufstr_set(me.nlist_buf, i1, s2);
    bufstr_set(me.nlist_buf, i2, s1);
}

float SortNickList_Compare(float i1, float i2, entity me) {
    string s1 = bufstr_get(me.nlist_buf, i1);
    string s2 = bufstr_get(me.nlist_buf, i2);
    
    float b = me.textBufferControl.srcBuffer;
    float s = irc_buffer_session[b];
    string targ = irc_buffer_msgtarget[b];
    
    if(IRC_IsJoinedChannel(s, targ)) {
        string p1 = IRC_GetPrefix(s, targ, s1);
        string p2 = IRC_GetPrefix(s, targ, s2);
        
        // TODO: use the server's priority instead of this crap
        if(p1 == "@" && p2 != "@")
            return -1;
        else if(p2 == "@" && p1 != "@")
            return 1;
        else if(p1 == "+" && p2 != "+")
            return -1;
        else if(p2 == "+" && p1 != "+")
            return 1;
    }
    
    return strcmp(s1, s2);
}

void updateNickListIRCNickList(entity me) {
    float i, b, s;
    string targ;
    
    if(me.nlist_buf > -1)
        buf_del(me.nlist_buf);
    if(me.nprefs_buf > -1)
        buf_del(me.nprefs_buf);
    
    me.nlist_buf = buf_create();
    me.nprefs_buf = buf_create();
    me.nItems = 0;
    
    b = me.textBufferControl.srcBuffer;
    s = irc_buffer_session[b];
    targ = irc_buffer_msgtarget[b];
    
    if(!targ)
        return;
    
    if(!IRC_IsJoinedChannel(s, targ)) {
        bufstr_set(me.nlist_buf, 0, targ);
        me.nItems = 1;
        return;
    }
    
    me.nItems = IRC_TokenizeUserList(s, targ);
    for(i = 0; i < me.nItems; ++i)
        bufstr_set(me.nlist_buf, i, argv(i));
    
    heapsort(me.nItems, SortNickList_Swap, SortNickList_Compare, me);
    
    for(i = 0; i < me.nItems; ++i)
        bufstr_set(me.nprefs_buf, i, IRC_GetPrefix(s, targ, bufstr_get(me.nlist_buf, i)));
}

float mouseReleaseIRCNickList(entity me, vector pos) {
    float r = mouseReleaseListBox(me, pos);
    
    // double click
    if(time - me.lastRelease < 1) {
        string nick = bufstr_get(me.nlist_buf, me.selectedItem);
        float session = irc_buffer_session[me.textBufferControl.srcBuffer];
        float buf = IRC_GetOrCreateBuffer(IRC_QueryBufferName(session, nick), session, nick);
        
        float i = 0;
        for(i = 0; i < me.bufferListControl.nItems; ++i) {
            float b = irc_bufferbind[i];
            if(irc_buffer_session[b] == session)
            if(irc_buffer_msgtarget[b] == nick) {
                setSelectedIRCBufferList(me.bufferListControl, i);
                break;
            }
        }
    }
    
    me.lastRelease = time;
    
    return 1;
}

void configureIRCNickListIRCNickList(entity me) {
    me.configureNexuizListBox(me);
    me.updateNickList(me);
}

void resizeNotifyIRCNickList(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize) {
    resizeNotifyNexuizListBox(me, relOrigin, relSize, absOrigin, absSize);

    me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
    me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
    me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);
}

void drawListBoxItemIRCNickList(entity me, float i, vector absSize, float isSelected) {
    string s;
    vector clr;
    float a = 1;
    
    if(isSelected)
    
        draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
    
    vector o = me.realUpperMargin2 * eY + (me.columnNameOrigin + 0.00 * (me.columnNameSize - draw_TextWidth(s, 1) * me.realFontSize_x)) * eX;
    
    s = bufstr_get(me.nprefs_buf, i);
    
    if(s == "@")
        clr = '1 0.2 0.2';
    else 
        clr = '1 1 0.2';
    
    draw_Text('0.5 0 0' * me.realFontSize_x * (1 - draw_TextWidth(s, FALSE)) + o, s, me.realFontSize, clr, a, FALSE);
    s = draw_TextShortenToWidth(bufstr_get(me.nlist_buf, i), (1/me.realFontSize_x - me.realFontSize_x), FALSE);
    draw_Text('1 0 0' * me.realFontSize_x + o, s, me.realFontSize, '1 1 1', a, FALSE);
}
#endif
