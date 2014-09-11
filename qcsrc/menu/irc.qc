
void IRC_DispatchNicklistUpdates(void) {
    entity e;
    
    for(e = world; (e = findfloat(e, receiveIRCNicklistUpdates, TRUE));)
        e.updateNickList(e);
}

void IRC_DispatchBufferUpdates(void) {
    entity e;
    
    for(e = world; (e = findfloat(e, receiveIRCBufferUpdates, TRUE));)
        e.updateBufferList(e);
}

void IRC_DispatchBufferTextUpdates(float id) {
    entity e;
    
    for(e = world; (e = findfloat(e, receiveIRCBufferTextUpdates, TRUE));)
        if(e.srcBuffer == id)
            e.updateBufferText(e);
}

void IRC_DispatchIRCJoinEvent(float buffer) {
    entity e;
    
    for(e = world; (e = findfloat(e, receiveIRCJoinEvent, TRUE));)
        e.handleIRCJoin(e, buffer);
}

void IRC_DispatchIRCTitleUpdates(void) {
    entity e;
    
    for(e = world; (e = findfloat(e, receiveIRCTitleUpdates, TRUE));)
        e.updateTitle(e);
}

void IRC_Init(void) {
    float i, s;
    
    irc_activebuffer = -1;
    
    for(i = 0; i < IRC_MAX_BUFFERS; ++i) {
        irc_buffer_ids[i] = string_null;
        irc_buffer_msgtarget[i] = string_null;
        irc_buffer_handles[i] = -1;
        irc_buffer_size[i] = 0;
        irc_buffer_msglevel[i] = 0;
        irc_buffer_session[i] = -1;
    }
    
    float m = IRC_CreateBuffer("[IRC]", -1, string_null);
    string err;
    
    if(!checkextension("DP_RM_IRC"))
        err = "Your engine doesn't support the DP_RM_IRC extension. Install the latest DarkPlacesRM from ^2https://github.com/nexAkari/DarkPlacesRM";
    else if(!cvar("irc_initialized"))
        err = "The IRC library couldn't be loaded. Install the latest libircclient from ^2http://sourceforge.net/projects/libircclient/";
    else if(cvar("irc_initialized") == 1)
        err = "Your engine is outdated. Install the latest DarkPlacesRM from ^2https://github.com/nexAkari/DarkPlacesRM";
    
    if(err) {
        IRC_PutInBuffer(m, strcat(IRC_MSGPREFIX_ERROR "^7Can't use IRC: ", err), IRC_BUFFER_MSGLEVEL_NONE);
        return;
    }
    
    if(cvar("irc_initialized") < 1.8) {
        IRC_PutInBuffer(m, strcat(IRC_MSGPREFIX_ERROR "^7Broken libircclient detected (version ", cvar_string("irc_initialized"), "), expect CTCP ACTION (/me messages) to not work."), IRC_BUFFER_MSGLEVEL_NONE);
        IRC_PutInBuffer(m, "Please update libircclient to version 1.8 or higher at ^2http://sourceforge.net/projects/libircclient/", IRC_BUFFER_MSGLEVEL_NONE);
    }
    
    IRC_PutInBuffer(m, IRC_MSGPREFIX_INFO "^7This interface is not yet complete. Use ^2irc_create^7 followed by ^2irc_connect^7 in console to connect to an IRC server, and then ^2irc_sendraw \"JOIN #channel\"^7 to join a channel.", IRC_BUFFER_MSGLEVEL_NONE);
    
    for(s = 0; s < IRC_MAX_SESSIONS; ++s) if(IRC_SessionExists(s)) {
        IRC_CreateBuffer(IRC_ServerBufferName(s), s, string_null);
        float chans = IRC_TokenizeChannelList(s);
        for(i = 0; i < chans; ++i)
            IRC_CreateBuffer(IRC_ChannelBufferName(s, argv(i)), s, argv(i));
    }
    
    IRC_DispatchBufferTextUpdates(m);
    IRC_Command_RegisterAll();
    
    irc_initialized = TRUE;
}

string IRC_ChannelBufferName(float session, string channel) {
    return strcat(ftos(session), "/channel/", strtolower(channel));
}

string IRC_QueryBufferName(float session, string nick) {
    return strcat(ftos(session), "/query/", nick);
}

string IRC_ServerBufferName(float session) {
    return strcat(ftos(session), "/main");
}

string IRC_BufferPrefix(float session) {
    return strcat(ftos(session), "/");
}

void IRC_PutInBuffersForNick(float session, string nick, string msg, float lvl) {
    float i, chans = IRC_TokenizeChannelList(session);
    
    for(i = 0; i < chans; ++i)
        if(IRC_IsUserInChannel(session, argv(i), nick))
            IRC_PutInBuffer(IRC_GetOrCreateBuffer(IRC_ChannelBufferName(session, argv(i)), session, argv(i)), msg, lvl);
    
    i = IRC_GetBuffer(IRC_QueryBufferName(session, nick));
    if(i >= 0)
        IRC_PutInBuffer(i, msg, lvl);
}

void IRC_PutNoticeInBuffers(float session, string nick, string msg, float lvl) {
    float srvbuff, buff;
    
    srvbuff = buff = IRC_GetOrCreateBuffer(IRC_ServerBufferName(session), session, string_null);
    IRC_PutInBuffer(buff, msg, lvl);
    
    buff = IRC_GetBuffer(IRC_QueryBufferName(session, nick));
    if(buff >= 0)
        IRC_PutInBuffer(buff, msg, lvl);
    else if(irc_activebuffer >= 0 && irc_buffer_session[irc_activebuffer] == session)
        IRC_PutInBuffer(irc_activebuffer, msg, lvl);
}

void IRC_PreEvent(float session, string event, float numeric, string orig, float argc) {
    string nick, user, host, spref, s;
    
    if(!irc_initialized)
        return;
    
    spref = strcat(ftos(session), "/");
    nick = substring(orig, 0, strstrofs(orig, "!", 0));
    user = substring(orig, strstrofs(orig, "!", 0) + 1, strstrofs(orig, "@", 0) - strstrofs(orig, "!", 0) - 1);
    host = substring(orig, strstrofs(orig, "@", 0) + 1, strlen(orig));
    
    if(event == "QUIT") {
        s = strcat("^1<-- ^3", nick, "^8!", user, "@", host, "^7 has quit IRC");
        
        if(argv(0) != "")
            s = strcat(s, "^8 [", IRC_IRC2DP(argv(0)), "^8]");
        
        IRC_PutInBuffersForNick(session, nick, s, IRC_BUFFER_MSGLEVEL_INFO);
    }
}

float IRC_CheckHilight(float session, string msg, float defaultlvl) {
    if(strstrofs(strtolower(msg), strtolower(IRC_CurrentNick(session)), 0) >= 0)
        return IRC_BUFFER_MSGLEVEL_URGENT;
    return defaultlvl;
}

void IRC_Event(float session, string event, float numeric, string orig, float argc) {
    float buff, i;
    string nick, user, host, spref, s;
    
    if(!irc_initialized)
        return;
    
    spref = strcat(ftos(session), "/");
    nick = substring(orig, 0, strstrofs(orig, "!", 0));
    user = substring(orig, strstrofs(orig, "!", 0) + 1, strstrofs(orig, "@", 0) - strstrofs(orig, "!", 0) - 1);
    host = substring(orig, strstrofs(orig, "@", 0) + 1, strlen(orig));
    
    // we need to handle it in IRC_PreEvent before the engine does
    if(event == "QUIT")
        return;
    
    if(event == "SESSION_CREATED") {
        IRC_CreateBuffer(IRC_ServerBufferName(session), session, string_null);
    } else if(event == "SESSION_TERMINATING") {
        IRC_DeleteBuffersByPrefix(IRC_BufferPrefix(session));
    } else if(event == "JOIN") {
        buff = IRC_GetOrCreateBuffer(IRC_ChannelBufferName(session, argv(0)), session, argv(0));
        IRC_PutInBuffer(buff, strcat(IRC_MSGPREFIX_IN "^3", nick, "^8!", user, "@", host, "^7 has joined ^2", argv(0)), IRC_BUFFER_MSGLEVEL_INFO);
        IRC_DispatchNicklistUpdates();
        
        if(nick == IRC_CurrentNick(session))
            IRC_DispatchIRCJoinEvent(buff);
    } else if(event == "PART") {
        buff = IRC_GetOrCreateBuffer(IRC_ChannelBufferName(session, argv(0)), session, argv(0));
        s = strcat(IRC_MSGPREFIX_OUT "^3", nick, "^8!", user, "@", host, "^7 has left ^2", argv(0));
        
        if(argv(1) != "")
            s = strcat(s, "^8 [", IRC_IRC2DP(argv(1)), "^8]");
        
        IRC_PutInBuffer(buff, s, IRC_BUFFER_MSGLEVEL_INFO);
        IRC_DispatchNicklistUpdates();
    } else if(event == "PRIVMSG") {
        buff = IRC_GetOrCreateBuffer(IRC_QueryBufferName(session, nick), session, nick);
        IRC_PutInBuffer(buff, strcat("<^3", nick, "^7> ", IRC_IRC2DP(argv(1))), IRC_BUFFER_MSGLEVEL_URGENT);
    } else if(event == "CHANNEL") {
        buff = IRC_GetOrCreateBuffer(IRC_ChannelBufferName(session, argv(0)), session, argv(0));
        s = IRC_IRC2DP(argv(1));
        IRC_PutInBuffer(buff, strcat("<^3", nick, "^7> ", s), IRC_CheckHilight(session, s, IRC_BUFFER_MSGLEVEL_NORMAL));
    } else if(event == "ACTION") {
        buff = IRC_GetOrCreateBuffer(IRC_ChannelBufferName(session, argv(0)), session, argv(0));
        s = IRC_IRC2DP(argv(1));
        IRC_PutInBuffer(buff, strcat(IRC_MSGPREFIX_ACTION "^3", nick, "^7 ", s), IRC_CheckHilight(session, s, IRC_BUFFER_MSGLEVEL_NORMAL));
    } else if(event == "NOTICE") {
        if(argv(0) == IRC_CurrentNick(session)) {
            s = strcat(IRC_MSGPREFIX_NOTICE "^3", nick, "^9:^7 ", IRC_IRC2DP(argv(1)));
            IRC_PutNoticeInBuffers(session, nick, s, IRC_BUFFER_MSGLEVEL_INFO);
        } else {
            buff = IRC_GetOrCreateBuffer(IRC_ChannelBufferName(session, argv(0)), session, argv(0));
            s = IRC_IRC2DP(argv(1));
            IRC_PutInBuffer(buff, strcat(IRC_MSGPREFIX_NOTICE "^3", nick, "^9 -> ^2", argv(0), "^9:^7 ", s), IRC_CheckHilight(session, s, IRC_BUFFER_MSGLEVEL_INFO));
        }
    } else if(event == "NICK") {
        s = strcat(IRC_MSGPREFIX_INFO "^3", nick, "^7 is now known as ^3", argv(0));
        
        buff = IRC_GetBuffer(IRC_QueryBufferName(session, nick));
        if(buff >= 0)
            IRC_ChangeBufferInfo(buff, IRC_QueryBufferName(session, argv(0)), argv(0));
        
        IRC_PutInBuffersForNick(session, argv(0), s, IRC_BUFFER_MSGLEVEL_INFO);
        IRC_DispatchNicklistUpdates();
    } else if(event == "KICK") {
        buff = IRC_GetOrCreateBuffer(IRC_ChannelBufferName(session, argv(0)), session, argv(0));
        s = strcat(IRC_MSGPREFIX_OUT "^3", argv(1), " ^7has been kicked from^2 ", argv(0), "^7 by^3 ", nick);
        
        if(argv(2) != "")
            s = strcat(s, "^8 [", IRC_IRC2DP(argv(2)), "^8]");
        
        IRC_PutInBuffer(buff, s, IRC_BUFFER_MSGLEVEL_INFO);
        IRC_DispatchNicklistUpdates();
    } else if(event == "MODE" && argv(1)) {
        buff = IRC_GetOrCreateBuffer(IRC_ChannelBufferName(session, argv(0)), session, argv(0));
        IRC_PutInBuffer(buff, strcat(IRC_MSGPREFIX_INFO "^3", nick, "^7 set mode on ^2", argv(0), "^7: ", argv(1), " ", argv(2)), IRC_BUFFER_MSGLEVEL_INFO);
        IRC_DispatchNicklistUpdates();  // the engine doesn't actually update it's internal nicklist here yet, but it should
    } else if(event == "TOPIC") {
        buff = IRC_GetOrCreateBuffer(IRC_ChannelBufferName(session, argv(0)), session, argv(0));
        IRC_PutInBuffer(buff, strcat(IRC_MSGPREFIX_INFO "^3", nick, "^7 set the topic for ^2", argv(0), "^7: ", IRC_IRC2DP(argv(1))), IRC_BUFFER_MSGLEVEL_INFO);
        IRC_DispatchIRCTitleUpdates();
    } else if(numeric == IRC_RFC_RPL_TOPIC) {
        buff = IRC_GetOrCreateBuffer(IRC_ChannelBufferName(session, argv(1)), session, argv(1));
        IRC_PutInBuffer(buff, strcat(IRC_MSGPREFIX_INFO "^7Topic for ^2", argv(1), "^7: ", IRC_IRC2DP(argv(2))), IRC_BUFFER_MSGLEVEL_INFO);
        IRC_DispatchIRCTitleUpdates();
    } else if(numeric == IRC_RFC_RPL_TOPICBY) {
        buff = IRC_GetOrCreateBuffer(IRC_ChannelBufferName(session, argv(1)), session, argv(1));
        IRC_PutInBuffer(buff, strcat(IRC_MSGPREFIX_INFO "^7Topic set by ^3", argv(2)), IRC_BUFFER_MSGLEVEL_INFO);
    } else if(numeric == IRC_RFC_RPL_NAMREPLY) {
        IRC_DispatchNicklistUpdates();
    } else {
        buff = IRC_GetOrCreateBuffer(IRC_ServerBufferName(session), session, string_null);
        s = strcat("^1unhandled:^7 [^2", event, "^7] (^5", ftos(numeric), "^7) ^2", orig, "^7:");
        for(i = 0; i < argc; ++i)
            s = strcat(s, " ", argv(i), ";");
        IRC_PutInBuffer(buff, s, IRC_BUFFER_MSGLEVEL_INFO);
    } 
}

float IRC_CreateBuffer(string id, float session, string targ) {
    float i, h;
    
    if(IRC_GetBufferHandle(IRC_GetBuffer(id)) >= 0) {
        print("IRC_CreateBuffer: buffer ", id, " already exists\n");
        return -1;
    }
    
    for(i = 0; i < IRC_MAX_BUFFERS; ++i)
        if(!irc_buffer_ids[i])
            break;
    
    if(i == IRC_MAX_BUFFERS) {
        print("IRC_CreateBuffer: buffer limit exceeded\n");
        return -1;
    }
    
    h = buf_create();
    
    if(h < 0) {
        print("IRC_CreateBuffer: buf_create failed\n");
        return -1;
    }
    
    irc_buffer_ids[i] = strzone(id);
    if(targ)
        irc_buffer_msgtarget[i] = strzone(targ);
    irc_buffer_session[i] = session;
    irc_buffer_handles[i] = h;
    irc_buffer_size[i] = 0;
    
    IRC_DispatchBufferUpdates();
    
    print("Buffer created: ", id, "\n");
    return i;
}

float IRC_GetBuffer(string id) {
    float i;
    
    for(i = 0; i < IRC_MAX_BUFFERS; ++i)
        if(id == irc_buffer_ids[i])
            return i;
    
    return -1;
}

float IRC_GetBufferHandle(float i) {
    if(i < 0 || i >= IRC_MAX_BUFFERS) {
        // print("IRC_GetBufferHandle: invalid buffer: ", ftos(i), "\n");
        return -1;
    }
    
    return irc_buffer_handles[i];
}

float IRC_GetOrCreateBuffer(string id, float session, string targ) {
    float i = IRC_GetBuffer(id);
    if(i < 0)
        i = IRC_CreateBuffer(id, session, targ);
    return i;
}

void IRC_ChangeBufferInfo(float i, string id, string targ) {
    if(i < 0 || i >= IRC_MAX_BUFFERS) {
        print("IRC_ChangeBufferInfo: invalid buffer: ", ftos(i), "\n");
        return;
    }
    
    if(irc_buffer_handles[i] >= 0) {
        if(irc_buffer_ids[i])
            strunzone(irc_buffer_ids[i]);
        irc_buffer_ids[i] = strzone(id);
        
        if(irc_buffer_msgtarget[i])
            strunzone(irc_buffer_msgtarget[i]);
        irc_buffer_msgtarget[i] = strzone(targ);
        
        IRC_DispatchBufferUpdates();
    } else
        print("IRC_ChangeBufferInfo: buffer was not created: ", ftos(i), "\n");
}

void IRC_DeleteBuffer(float i) {
    if(i < 0 || i >= IRC_MAX_BUFFERS) {
        print("IRC_DeleteBuffer: invalid buffer: ", ftos(i), "\n");
        return;
    }
    
    if(irc_buffer_handles[i] >= 0) {
        buf_del(irc_buffer_handles[i]);
        irc_buffer_handles[i] = -1;
        
        if(irc_buffer_ids[i])
            strunzone(irc_buffer_ids[i]);
        irc_buffer_ids[i] = string_null;
        
        if(irc_buffer_msgtarget[i])
            strunzone(irc_buffer_msgtarget[i]);
        irc_buffer_msgtarget[i] = string_null;
        
        irc_buffer_size[i] = 0;
        irc_buffer_session[i] = -1;
        IRC_DispatchBufferUpdates();
    } else
        print("IRC_DeleteBuffer: buffer was not created: ", ftos(i), "\n");
}

void IRC_DeleteBufferByID(string id) {
    float i = IRC_GetBuffer(id);
    
    if(i < 0) {
        print("IRC_DeleteBufferByID: buffer ", id, " does not exist");
        return;
    }
    
    IRC_DeleteBuffer(i);
}

void IRC_DeleteBuffersByPrefix(string prefix) {
    float i;
    
    for(i = 0; i < IRC_MAX_BUFFERS; ++i)
        if(irc_buffer_ids[i])
            if(substring(irc_buffer_ids[i], 0, strlen(prefix)) == prefix)
                IRC_DeleteBuffer(i);
}

void IRC_PutInBuffer(float i, string str, float level) {
    float h = IRC_GetBufferHandle(i);
    
    if(h < 0) {
        print("IRC_PutInBuffer: invalid buffer: ", ftos(i), "\n");
        return;
    }
    
    if(level == IRC_BUFFER_MSGLEVEL_URGENT)
    if(IRC_IsJoinedChannel(irc_buffer_session[i], irc_buffer_msgtarget[i]))
        str = strcat("^8=^1!^8=^7 ", str);
    
    while(irc_buffer_size[i] >= IRC_BUFFER_SIZE) {
        bufstr_free(h, 0);
        float j, sz = irc_buffer_size[i];
        for(j = 1; j < sz; ++j)
            bufstr_set(h, j-1, bufstr_get(h, j));
        bufstr_free(h, j-1);
        irc_buffer_size[i] = irc_buffer_size[i] - 1;
    }
    
    bufstr_add(h, str, TRUE);
    irc_buffer_size[i] = irc_buffer_size[i] + 1;
    if(level >irc_buffer_msglevel[i])
        irc_buffer_msglevel[i] = level;
    
    IRC_DispatchBufferTextUpdates(i);
    
    string s = strcat("^5[", irc_buffer_ids[i], "] ^7", str, "\n");
    if(level == IRC_BUFFER_MSGLEVEL_URGENT)
        print("\x01", s);
    else
        print(s);
        
}

float IRC_GetBufferSize(float i) {
    if(i < 0 || i >= IRC_MAX_BUFFERS) {
        print("IRC_GetBufferSize: invalid buffer: ", ftos(i), "\n");
        return -1;
    }
    
    return irc_buffer_size[i];
}

