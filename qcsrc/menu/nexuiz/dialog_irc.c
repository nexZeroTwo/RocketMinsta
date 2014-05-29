#ifdef INTERFACE
CLASS(NexuizIRCTab) EXTENDS(NexuizTab)
    METHOD(NexuizIRCTab, fill, void(entity))
    ATTRIB(NexuizIRCTab, title, string, "IRC")
    ATTRIB(NexuizIRCTab, intendedWidth, float, 0.9)
    ATTRIB(NexuizIRCTab, rows, float, 22)
    ATTRIB(NexuizIRCTab, columns, float, 6.5)
    ATTRIB(NexuizIRCTab, name, string, "IRC")
ENDCLASS(NexuizIRCTab)
entity makeNexuizIRCTab();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizIRCTab() {
    entity me;
    me = spawnNexuizIRCTab();
    me.configureDialog(me);
    return me;
}

void IRCInputBoxSend(entity ibox, entity buffer) {
    string txt = ibox.text;
    
    if(!txt)
        return;
    
    string msgtarget = irc_buffer_msgtarget[buffer.srcBuffer];
    
    if(!msgtarget) {
        IRC_PutInBuffer(buffer.srcBuffer, "^8-^1!^8- Can't send here", IRC_BUFFER_MSGLEVEL_INFO);
    } else {    
        IRC_PutInBuffer(buffer.srcBuffer,
                        strcat("<^2", IRC_CurrentNick(irc_buffer_session[buffer.srcBuffer]), "^7> ", txt),
                        IRC_BUFFER_MSGLEVEL_NORMAL);
        IRC_Privmsg(irc_buffer_session[buffer.srcBuffer], msgtarget, txt);
    }
    
    ibox.setText(ibox, "");
}

void IRCInputBoxSendButton(entity btn, entity ibox) {
    ibox.onEnter(ibox, ibox.onEnterEntity);
}

void fillNexuizIRCTab(entity me) {
    entity e;
    entity btn;
    entity bufflist;
    entity nicklist;
    entity buffer;
    entity input;
    entity titlebar;
    
    titlebar = makeNexuizTextLabel(0, "^5[IRC]");
    titlebar.allowColors = TRUE;
    titlebar.allowCut = TRUE;
    
    bufflist = makeIRCBufferList();
    nicklist = makeIRCNickList();
    buffer = makeIRCTextBuffer();
    input = makeIRCInputBox();
    
    input.onEnter = IRCInputBoxSend;
    input.onEnterEntity = buffer;
    
    nicklist.bufferListControl = bufflist;
    nicklist.textBufferControl = buffer;
    bufflist.textBufferControl = buffer;
    bufflist.nicklistControl = nicklist;
    bufflist.titleControl = titlebar;
    
    me.TR(me);
        me.TD(me, 1, me.columns, titlebar);
    me.TR(me);
        me.TD(me, me.rows - 1, 1, bufflist);
        me.TD(me, me.rows - 2, me.columns - 2, buffer);
        me.TD(me, me.rows - 2, 1, nicklist);
    me.gotoRC(me, me.rows - 1, 1);
        me.TD(me, 1, me.columns - 2, e = input);
        me.TD(me, 1, 0.5, btn = makeNexuizButton("Send", '0 0 0'));
            btn.onClickEntity = input;
            btn.onClick = IRCInputBoxSendButton;
        me.TD(me, 1, 0.5, btn = makeNexuizButton("Clear", '0 0 0'));
            btn.onClickEntity = input;
            btn.onClick = InputBox_Clear_Click;
}
#endif
