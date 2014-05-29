#ifdef INTERFACE
CLASS(IRCTextBuffer) EXTENDS(NexuizListBox)
    METHOD(IRCTextBuffer, configureIRCTextBuffer, void(entity))
    ATTRIB(IRCTextBuffer, fontSize, float, SKINFONTSIZE_NORMAL)
    ATTRIB(IRCTextBuffer, scrollbarWidth, float, SKINWIDTH_SCROLLBAR)
    ATTRIB(IRCTextBuffer, src, string, SKINGFX_SCROLLBAR)
    ATTRIB(IRCTextBuffer, tolerance, vector, SKINTOLERANCE_SLIDER)
    ATTRIB(IRCTextBuffer, rowsPerItem, float, 1)
    METHOD(IRCTextBuffer, resizeNotify, void(entity, vector, vector, vector, vector))
    METHOD(IRCTextBuffer, drawListBoxItem, void(entity, float, vector, float))
    METHOD(IRCTextBuffer, setSelected, void(entity, float))
    METHOD(IRCTextBuffer, updateBufferText, void(entity))
    METHOD(IRCTextBuffer, selectSourceBuffer, void(entity, float))
    ATTRIB(IRCTextBuffer, color, vector, SKINCOLOR_SCROLLBAR_N)
    ATTRIB(IRCTextBuffer, colorF, vector, SKINCOLOR_SCROLLBAR_F)
    ATTRIB(IRCTextBuffer, color2, vector, SKINCOLOR_SCROLLBAR_S)
    ATTRIB(IRCTextBuffer, colorC, vector, SKINCOLOR_SCROLLBAR_C)
    ATTRIB(IRCTextBuffer, receiveIRCBufferTextUpdates, float, TRUE)
    ATTRIB(IRCTextBuffer, btext_buf, float, -1)
    ATTRIB(IRCTextBuffer, prevSelected, float, -1)
    ATTRIB(IRCTextBuffer, srcBuffer, float, 0)
    ATTRIB(IRCTextBuffer, lastDraw, float, 0)
ENDCLASS(IRCTextBuffer)
entity makeIRCTextBuffer();
#endif

#ifdef IMPLEMENTATION
entity makeIRCTextBuffer() {
    entity me;
    me = spawnIRCTextBuffer();
    me.configureIRCTextBuffer(me);
    return me;
}

void setSelectedIRCTextBuffer(entity me, float i) {
    setSelectedListBox(me, i);
    
    if(i != me.prevSelected) {
        me.prevSelected = i;
    }
}

void selectSourceBufferIRCTextBuffer(entity me, float id) {
    me.srcBuffer = id;
    me.updateBufferText(me);
}

void updateBufferTextIRCTextBuffer(entity me) {
    float i, j, sz;
    string s;
    
    float scrolldown = (me.scrollPos >= me.nItems * me.itemHeight - 1);
    
    if(me.btext_buf > -1)
        buf_del(me.btext_buf);
    
    me.btext_buf = buf_create();
    float h = IRC_GetBufferHandle(me.srcBuffer);
    
    if(h < 0)
        return;
    
    sz = IRC_GetBufferSize(me.srcBuffer);
    for(i = 0; i < sz; ++i) {
        getWrappedLine_remaining = bufstr_get(h, i);
        while(getWrappedLine_remaining) {
            s = getWrappedLine(1/me.realFontSize_x, draw_TextWidth_WithColors);
            bufstr_set(me.btext_buf, j, s);
            ++j;
        }
    }
    
    me.nItems = j;
    
    if(scrolldown) {
        me.selectedItem = j - 1;
        me.scrollPos = max(0, me.nItems * me.itemHeight - 1);
    }
}

void configureIRCTextBufferIRCTextBuffer(entity me) {
    me.configureNexuizListBox(me);
    me.updateBufferText(me);
}

void resizeNotifyIRCTextBuffer(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize) {
    resizeNotifyNexuizListBox(me, relOrigin, relSize, absOrigin, absSize);

    me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
    me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
    me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);
}

void drawListBoxItemIRCTextBuffer(entity me, float i, vector absSize, float isSelected) {
    string s;
    
    if(time - me.lastDraw > 1)
        me.updateBufferText(me);
    me.lastDraw = time;
    
    if(isSelected)
        draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
    
    vector o = me.realUpperMargin2 * eY + (me.columnNameOrigin + 0.00 * (me.columnNameSize - draw_TextWidth(s, 1) * me.realFontSize_x)) * eX;
    
    s = draw_TextShortenToWidth(bufstr_get(me.btext_buf, i), 1/me.realFontSize_x, TRUE);
    draw_Text(o, s, me.realFontSize, '1 1 1', 1, TRUE);
}
#endif
