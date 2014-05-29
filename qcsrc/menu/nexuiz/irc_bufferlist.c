#ifdef INTERFACE
CLASS(IRCBufferList) EXTENDS(NexuizListBox)
    METHOD(IRCBufferList, configureIRCBufferList, void(entity))
    ATTRIB(IRCBufferList, fontSize, float, SKINFONTSIZE_NORMAL)
    ATTRIB(IRCBufferList, scrollbarWidth, float, SKINWIDTH_SCROLLBAR)
    ATTRIB(IRCBufferList, src, string, SKINGFX_SCROLLBAR)
    ATTRIB(IRCBufferList, tolerance, vector, SKINTOLERANCE_SLIDER)
    ATTRIB(IRCBufferList, rowsPerItem, float, 1)
    METHOD(IRCBufferList, resizeNotify, void(entity, vector, vector, vector, vector))
    METHOD(IRCBufferList, drawListBoxItem, void(entity, float, vector, float))
    METHOD(IRCBufferList, setSelected, void(entity, float))
    METHOD(IRCBufferList, updateBufferList, void(entity))
    METHOD(IRCBufferList, updateTitle, void(entity))
    METHOD(IRCBufferList, handleIRCJoin, void(entity, float))
    ATTRIB(IRCBufferList, color, vector, SKINCOLOR_SCROLLBAR_N)
    ATTRIB(IRCBufferList, colorF, vector, SKINCOLOR_SCROLLBAR_F)
    ATTRIB(IRCBufferList, color2, vector, SKINCOLOR_SCROLLBAR_S)
    ATTRIB(IRCBufferList, colorC, vector, SKINCOLOR_SCROLLBAR_C)
    ATTRIB(IRCBufferList, receiveIRCBufferUpdates, float, TRUE)
    ATTRIB(IRCBufferList, receiveIRCJoinEvent, float, TRUE)
    ATTRIB(IRCBufferList, receiveIRCTitleUpdates, float, TRUE)
    ATTRIB(IRCBufferList, blist_buf, float, -1)
    ATTRIB(IRCBufferList, prevSelected, float, -1)
    ATTRIB(IRCBufferList, textBufferControl, entity, NULL)
    ATTRIB(IRCBufferList, nicklistControl, entity, NULL)
    ATTRIB(IRCBufferList, titleControl, entity, NULL)
    ATTRIB(IRCBufferList, allocatedTitle, string, string_null)
ENDCLASS(IRCBufferList)
entity makeIRCBufferList();

float irc_bufferbind[IRC_MAX_BUFFERS];

#endif

#ifdef IMPLEMENTATION

entity makeIRCBufferList() {
    entity me;
    me = spawnIRCBufferList();
    me.configureIRCBufferList(me);
    return me;
}

void updateTitleIRCBufferList(entity me) {
    string t;
    if(irc_buffer_session[irc_activebuffer] >= 0)
        t = IRC_GetChannelTopic(irc_buffer_session[irc_activebuffer], irc_buffer_msgtarget[irc_activebuffer]);
    if(!t) t = strcat("^5", bufstr_get(me.blist_buf, me.selectedItem));
    
    if(me.allocatedTitle)
        strunzone(me.allocatedTitle);
    me.allocatedTitle = strzone(t);
    me.titleControl.setText(me.titleControl, me.allocatedTitle);
}

void setSelectedIRCBufferList(entity me, float i) {
    setSelectedListBox(me, i);
    
    if(i != me.prevSelected) {
        float b = irc_bufferbind[i];
        irc_buffer_msglevel[b] = IRC_BUFFER_MSGLEVEL_NONE;
        b = irc_bufferbind[me.prevSelected];
        irc_buffer_msglevel[b] = IRC_BUFFER_MSGLEVEL_NONE;
        
        me.prevSelected = i;
        me.textBufferControl.selectSourceBuffer(me.textBufferControl, irc_bufferbind[i]);
        me.nicklistControl.updateNickList(me.nicklistControl);
        irc_activebuffer = irc_bufferbind[i];
        
        me.updateTitle(me);
    }
}

void handleIRCJoinIRCBufferList(entity me, float buffer) {
    float i;
    
    for(i = 0; i < me.nItems; ++i)
        if(irc_bufferbind[i] == buffer) {
            me.setSelected(me, i);
            return;
        }
}

void SortBufferList_Swap(float i1, float i2, entity me) {
    float b1, b2;
    string s1, s2;
    
    s1 = bufstr_get(me.blist_buf, i1);
    s2 = bufstr_get(me.blist_buf, i2);
    b1 = irc_bufferbind[i1];
    b2 = irc_bufferbind[i2];
    
    bufstr_set(me.blist_buf, i1, s2);
    bufstr_set(me.blist_buf, i2, s1);
    irc_bufferbind[i1] = b2;
    irc_bufferbind[i2] = b1;
    
    if(me.selectedItem == i1)
        me.selectedItem = i2;
    else if(me.selectedItem == i2)
        me.selectedItem = i1;
}

float SortBufferList_Compare(float i1, float i2, entity me) {
    float b1 = irc_bufferbind[i1];
    float b2 = irc_bufferbind[i2];
    
    float s1 = irc_buffer_session[b1];
    float s2 = irc_buffer_session[b2];
    
    if(s1 < s2) return -1;
    if(s2 < s1) return  1;
    
    string t1 = irc_buffer_msgtarget[b1];
    string t2 = irc_buffer_msgtarget[b2];
    
    if(!t1 && t2) return -1;
    if(!t2 && t1) return  1;
    
    float c1 = IRC_IsJoinedChannel(s1, t1);
    float c2 = IRC_IsJoinedChannel(s2, t2);
    
    if(t1 && !t2) return -1;
    if(t2 && !t1) return  1;
    
    return strcmp(bufstr_get(me.blist_buf, i1), bufstr_get(me.blist_buf, i2));
}

void updateBufferListIRCBufferList(entity me) {
    float i, j;
    if(me.blist_buf > -1)
        buf_del(me.blist_buf);
    
    me.blist_buf = buf_create();
    
    for(i = 0, j = 0; i < IRC_MAX_BUFFERS; ++i) {
        if(irc_buffer_ids[i]) {
            irc_bufferbind[j] = i;
            if(irc_buffer_session[i] >= 0) {
                if(irc_buffer_msgtarget[i])
                    bufstr_set(me.blist_buf, j, strcat(ftos(irc_buffer_session[i]), ":", irc_buffer_msgtarget[i]));
                else
                    bufstr_set(me.blist_buf, j,
                               strcat(ftos(irc_buffer_session[i]), ":",
                               IRC_ServerAddress(irc_buffer_session[i]), ":",
                               ftos(IRC_ServerPort(irc_buffer_session[i]))));
            } else
                bufstr_set(me.blist_buf, j, irc_buffer_ids[i]);
            ++j;
        }
    }
    
    me.nItems = j;
    heapsort(me.nItems, SortBufferList_Swap, SortBufferList_Compare, me);
}

void configureIRCBufferListIRCBufferList(entity me) {
    me.configureNexuizListBox(me);
    me.updateBufferList(me);
}

void resizeNotifyIRCBufferList(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize) {
    resizeNotifyNexuizListBox(me, relOrigin, relSize, absOrigin, absSize);

    me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
    me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
    me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);
}

void drawListBoxItemIRCBufferList(entity me, float i, vector absSize, float isSelected) {
    string s;
    vector clr;
    float a;
    
    float b = irc_bufferbind[i];
    
    if(isSelected) {
        a = 1;
        clr = '1 1 1';
    } else switch(irc_buffer_msglevel[b]) {
        case IRC_BUFFER_MSGLEVEL_URGENT:
            a = 1;
            clr = '1 0.1 0.1';
            break;
        
        case IRC_BUFFER_MSGLEVEL_NORMAL:
            a = 0.8;
            clr = '1 1 1';
            break;
        
        case IRC_BUFFER_MSGLEVEL_INFO:
            a = 0.5;
            clr = '1 1 1';
            break;
        
        default:
        case IRC_BUFFER_MSGLEVEL_NONE:
            a = 0.5;
            clr = '0.5 0.5 0.5';
            break;
    }
    
    if(isSelected)
        draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
    
    vector o = me.realUpperMargin2 * eY + (me.columnNameOrigin + 0.00 * (me.columnNameSize - draw_TextWidth(s, 1) * me.realFontSize_x)) * eX;
    
    s = draw_TextShortenToWidth(bufstr_get(me.blist_buf, i), 1/me.realFontSize_x, FALSE);
    draw_Text(o, s, me.realFontSize, clr, a, FALSE);
}
#endif
