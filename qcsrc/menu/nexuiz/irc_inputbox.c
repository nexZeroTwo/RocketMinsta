#ifdef INTERFACE
CLASS(IRCInputBox) EXTENDS(NexuizInputBox)
    METHOD(IRCInputBox, keyDown, float(entity, float, float, float))
    
ENDCLASS(IRCInputBox)
entity makeIRCInputBox(void);
#endif

#ifdef IMPLEMENTATION

entity makeIRCInputBox(void) {
    entity me;
    me = spawnIRCInputBox();
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
    
    if(!targ)
        return input;
    
    if(!IRC_IsJoinedChannel(s, targ))
        return input;
    
    float full = TRUE;
    string nick, lnick;
    float i, j, nicks = IRC_TokenizeUserList(s, targ);
    string lword = strtolower(word);
    float wlen = strlen(word);
    
    IRCTabComplete_Match_total = 0;
    float maxlen = 0;
    
    for(i = 0; i < nicks; ++i) {
        string n = argv(i);
        if(substring(strtolower(n), 0, wlen) == lword) {
            IRCTabComplete_Match[IRCTabComplete_Match_total] = n;
            ++IRCTabComplete_Match_total;
            float l = strlen(n);
            if(l > maxlen)
                maxlen = l;
        }
    }
    
    if(IRCTabComplete_Match_total < 1) {
        IRC_PutInBuffer(b, "^8-^1!^8- No matches", IRC_BUFFER_MSGLEVEL_INFO);
        return input;
    }
    
    if(IRCTabComplete_Match_total == 1)
        nick = strcat(IRCTabComplete_Match[0], " ");
    else {
        nick = lword;
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
            
            nick = strcat(nick, chr2str(ch));
        }
        
        string msg = strcat("^8-^1!^8- Matched nicks:^9");
        for(i = 0; i < IRCTabComplete_Match_total; ++i)
            msg = strcat(msg, " ", IRCTabComplete_Match[i]);
        IRC_PutInBuffer(b, msg, IRC_BUFFER_MSGLEVEL_INFO);
    }
    
    IRCTabComplete_cursorpos = cursor + strlen(nick) - strlen(word);
    
    head = substring(head, 0, strlen(head) - strlen(word));
    return strcat(head, nick, tail);
}

float keyDownIRCInputBox(entity me, float key, float ascii, float shift) {
    float r;
    r = 0;
    
    if(key == K_TAB) {
        me.setText(me, IRCTabComplete(me, strcat("", me.text), me.cursorPos));
        me.cursorPos = IRCTabComplete_cursorpos;
        return 1;
    }
    
    if(keyDownNexuizInputBox(me, key, ascii, shift))
        r = 1;
    return r;
}

#endif
