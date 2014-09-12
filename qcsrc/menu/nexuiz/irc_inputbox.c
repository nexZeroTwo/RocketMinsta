#ifdef INTERFACE
CLASS(IRCInputBox) EXTENDS(NexuizInputBox)
    METHOD(IRCInputBox, keyDown, float(entity, float, float, float))
    ATTRIB(IRCInputBox, historyBuff, float, -1)
    ATTRIB(IRCInputBox, historyPos, float, 0)
ENDCLASS(IRCInputBox)
entity makeIRCInputBox(void);
#endif

#ifdef IMPLEMENTATION

entity makeIRCInputBox(void) {
    entity me;
    me = spawnIRCInputBox();
    me.historyBuff = buf_create();
    me.configureNexuizInputBox(me, TRUE, string_null);
    return me;
}

float IRCTabComplete_cursorpos;
#define ITC_MATCH_MAX 128
float IRCTabComplete_Match_total;
string IRCTabComplete_Match[ITC_MATCH_MAX];

string IRCTabComplete(entity me, string input, float cursor) {
    string head, tail, word;
    float last = -1, o;
    float cmdmode;
    
    IRCTabComplete_cursorpos = cursor;
    
    if(!cursor)
        return input;
    
    head = substring(input, 0, cursor);
    tail = substring(input, cursor, strlen(input));
    
    if(substring(head, strlen(head)-1, 1) == " ")
        return input;
    
    while(o >= 0) {
        o = strstrofs(head, " ", o+1);
        if(o >= 0)
            last = o;
    }
    
    word = substring(head, last+1, strlen(head));
    
    float b = me.onEnterEntity.srcBuffer;
    float s = irc_buffer_session[b];
    string targ = irc_buffer_msgtarget[b];
    
    if(substring(input, 0, 1) == "/" && last < 0) {
        cmdmode = TRUE;
    } else {
        if(!targ)
            return input;
        
        if(!IRC_IsJoinedChannel(s, targ))
            return input;
    }
    
    float full = TRUE;
    string newword;
    float i, j;
    string lword = strtolower(word);
    float wlen = strlen(word);
    
    IRCTabComplete_Match_total = 0;
    float maxlen = 0;
    
    if(cmdmode) {
        entity cent; FOR_EACH_IRC_COMMAND(cent) {
            string n = strcat("/", cent.netname); 
            if(substring(strtolower(n), 0, wlen) == lword) {
                IRCTabComplete_Match[IRCTabComplete_Match_total] = n;
                ++IRCTabComplete_Match_total;
                float l = strlen(n);
                if(l > maxlen)
                    maxlen = l;
                if(IRCTabComplete_Match_total == ITC_MATCH_MAX)
                    break;
            }
        }
    } else {
        float nicks = IRC_TokenizeUserList(s, targ);
        for(i = 0; i < nicks; ++i) {
            string n = argv(i);
            if(substring(strtolower(n), 0, wlen) == lword) {
                IRCTabComplete_Match[IRCTabComplete_Match_total] = n;
                ++IRCTabComplete_Match_total;
                float l = strlen(n);
                if(l > maxlen)
                    maxlen = l;
                if(IRCTabComplete_Match_total == ITC_MATCH_MAX)
                    break;
            }
        }
    }
    
    if(IRCTabComplete_Match_total < 1) {
        IRC_PutInBuffer(b, IRC_MSGPREFIX_ERROR "No matches", IRC_BUFFER_MSGLEVEL_INFO);
        return input;
    }
    
    if(IRCTabComplete_Match_total == 1)
        newword = strcat(IRCTabComplete_Match[0], " ");
    else {
        newword = lword;
        float found;
        
        for(i = wlen; i < maxlen; ++i) {
            float ch = str2chr(strtolower(IRCTabComplete_Match[0]), i);
            
            for(j = 1; j < IRCTabComplete_Match_total; ++j) {
                if(str2chr(strtolower(IRCTabComplete_Match[j]), i) != ch) {
                    found = TRUE;
                    break;
                }
            }
            
            if(found)
                break;
            
            newword = strcat(newword, chr2str(ch));
        }
        
        string msg = IRC_MSGPREFIX_INFO "Matches:^9";
        for(i = 0; i < IRCTabComplete_Match_total; ++i)
            msg = strcat(msg, " ", IRCTabComplete_Match[i]);
        IRC_PutInBuffer(b, msg, IRC_BUFFER_MSGLEVEL_INFO);
    }
    
    IRCTabComplete_cursorpos = cursor + strlen(newword) - strlen(word);
    
    head = substring(head, 0, strlen(head) - strlen(word));
    return strcat(head, newword, tail);
}

float keyDownIRCInputBox(entity me, float key, float ascii, float shift) {
    if(shift & S_CTRL && key == 117) {    // Ctrl+U
        me.setText(me, "");
        return 1;
    }
    
    if(key == K_TAB) {
        me.setText(me, IRCTabComplete(me, strcat("", me.text), me.cursorPos));
        me.cursorPos = IRCTabComplete_cursorpos;
        return 1;
    }
    
    if(key == K_UPARROW) {
        float i = buf_getsize(me.historyBuff) - 1 - me.historyPos;
        if(i >= 0) {
            me.historyPos += 1;
            me.setText(me, bufstr_get(me.historyBuff, i));
            me.cursorPos = strlen(me.text);
        }
        
        return 1;
    }
    
    if(key == K_DOWNARROW) {
        float i = buf_getsize(me.historyBuff) + 1 - me.historyPos;
        if(i >= 0 && i < buf_getsize(me.historyBuff)) {
            me.historyPos -= 1;
            me.setText(me, bufstr_get(me.historyBuff, i));
            me.cursorPos = strlen(me.text);
        }
        
        return 1;
    }
    
    if(keyDownNexuizInputBox(me, key, ascii, shift))
        return 1;
    
    return 0;
}

#endif
