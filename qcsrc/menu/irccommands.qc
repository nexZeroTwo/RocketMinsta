
void IRC_Command_Call(entity cent, string cmdline, float argc, float b, float ishelp) {
    if(cent.classname != "irc_command") {
        IRC_PutInBuffer(b, strcat(IRC_MSGPREFIX_ERROR
                        "Attempted to call invalid command object '",
                        etos(cent), "'"), IRC_BUFFER_MSGLEVEL_INFO);
        return;
    }
    
    entity oself = self;
    self = cent;
    
    float session = irc_buffer_session[b];
    string msgtarget = irc_buffer_msgtarget[b];
    
    if(ishelp) {
        if(cent.cmd_help)
            cent.cmd_help(cmdline, argc, b, session, msgtarget);
        else
            IRC_PutInBuffer(b, strcat(IRC_MSGPREFIX_ERROR, "/", cent.netname,
                            " has no help function"), IRC_BUFFER_MSGLEVEL_INFO);
    } else {
        if(cent.cmd_call) {
            if(argc < cent.cmd_minargs)
                IRC_PutInBuffer(b, strcat(IRC_MSGPREFIX_ERROR, "/", cent.netname, 
                                ": not enough arguments (see /help ", cent.netname, ")"),
                                IRC_BUFFER_MSGLEVEL_INFO);
            else
                cent.cmd_call(cmdline, argc, b, session, msgtarget);
        } else
            IRC_PutInBuffer(b, strcat(IRC_MSGPREFIX_ERROR,
                            "/", cent.netname, " has no call function"),
                            IRC_BUFFER_MSGLEVEL_INFO);
    }
    
    self = oself;
}

void IRC_Command_Eval(string cmdline, float b) {
    float argc = tokenize_console(cmdline);
    entity cent;
    
    FOR_EACH_IRC_COMMAND(cent) if(cent.netname == argv(0)) {
        IRC_Command_Call(cent, cmdline, argc, b, FALSE);
        return;
    }
    
    IRC_PutInBuffer(b, strcat(IRC_MSGPREFIX_ERROR, 
                    "/", argv(0), ": command not found"), IRC_BUFFER_MSGLEVEL_INFO);
}

void IRC_Command_Register(string cname, float minargs, irc_command_f cmdfunc, irc_command_help_f helpfunc) {
    entity c = spawn();
    c.classname = "irc_command";
    c.netname = cname;
    c.cmd_minargs = minargs;
    c.cmd_call = cmdfunc;
    c.cmd_help = helpfunc;
}

void IRC_Command_test_call(string cmdline, float argc, float b, float session, string targ) {
    IRC_PutInBuffer(b, IRC_MSGPREFIX_INFO "^6Hello world!", IRC_BUFFER_MSGLEVEL_INFO);
}

void IRC_Command_echo_call(string cmdline, float argc, float b, float session, string targ) {
    IRC_PutInBuffer(b, strcat(IRC_MSGPREFIX_INFO, 
                    substring(cmdline, argv_start_index(1), strlen(cmdline))),
                    IRC_BUFFER_MSGLEVEL_INFO);
}

void IRC_Command_msg_call(string cmdline, float argc, float b, float s, string t) {
    if(s < 0) {
        IRC_PutInBuffer(b, strcat(IRC_MSGPREFIX_ERROR, 
                            "/", argv(0), ": must be used in a session-bound buffer"),
                            IRC_BUFFER_MSGLEVEL_INFO);
        return;
    }
    
    float err = (if(argv(0) == "notice") IRC_Notice else IRC_Privmsg)
                (s, argv(1), substring(cmdline, argv_start_index(2), strlen(cmdline)));
                
    if(err > 0) IRC_PutInBuffer(b, strcat(IRC_MSGPREFIX_ERROR, "/", argv(0), ": ",
                                IRC_StrError(err)),
                                IRC_BUFFER_MSGLEVEL_INFO);
}

void IRC_Command_close_call(string cmdline, float argc, float b, float s, string t) {
    if(b <= 0 || !t) {
        IRC_PutInBuffer(b, IRC_MSGPREFIX_ERROR
                    "/close: can't close a system buffer",
                    IRC_BUFFER_MSGLEVEL_INFO);
        return;
    }
    
    if(IRC_IsJoinedChannel(s, t))
        IRC_PartChannel(s, t);
    
    IRC_DeleteBuffer(b);
}

void IRC_Command_join_call(string cmdline, float argc, float b, float s, string t) {
    if(s < 0) {
        IRC_PutInBuffer(b, strcat(IRC_MSGPREFIX_ERROR, 
                            "/join: must be used in a session-bound buffer"),
                            IRC_BUFFER_MSGLEVEL_INFO);
        return;
    }
    
    IRC_JoinChannel(s, argv(1), argv(2));
}

void IRC_Command_part_call(string cmdline, float argc, float b, float s, string t) {
    if(s < 0) {
        IRC_PutInBuffer(b, strcat(IRC_MSGPREFIX_ERROR, 
                            "/part: must be used in a session-bound buffer"),
                            IRC_BUFFER_MSGLEVEL_INFO);
        return;
    }
    
    // XXX: add reason support to IRC_PartChannel?
    IRC_PartChannel(s, (if(argc > 1) argv(1) else t));
}

void IRC_Command_connect_call(string cmdline, float argc, float b, float s, string t) {
    float created, err;
    string errstr;
    
    if(s < 0) {
        s = IRC_CreateSession();
        created = TRUE;
    }
    
    if(s < 0) {
        IRC_PutInBuffer(b, strcat(IRC_MSGPREFIX_ERROR, 
                            "/connect: session creation failed"),
                            IRC_BUFFER_MSGLEVEL_INFO);
        return;
    }
    
    string serv, nick, user, realname, password;
    float port;

    serv = argv(1);
    port = 6667;
    nick = argv(2);
    user = "rmirc";
    realname = "RM IRC user";
    password = string_null;

    float o = strstrofs(serv, ":", 0);
    if(o >= 0) {
        port = stof(substring(serv, o+1, strlen(serv)));
        serv = substring(serv, 0, o);
    }

    if(argc > 3) {
        user = argv(3);
        if(argc > 4) {
            realname = argv(4);
            if(argc > 5)
                password = argv(5);
        }
    }

    err = IRC_ConnectSession(s, serv, port, password, nick, user, realname);
    if      (err < 0) errstr = "session error";
    else if (err > 0) errstr = IRC_StrError(err);
    
    if(errstr) {
        IRC_PutInBuffer(b, strcat(IRC_MSGPREFIX_ERROR, 
                            "/connect: connection error: ", errstr),
                            IRC_BUFFER_MSGLEVEL_INFO);
        
        if(created)
            IRC_TerminateSession(s);
    }
}

void IRC_Command_quit_call(string cmdline, float argc, float b, float s, string t) {
    if(s < 0) {
        IRC_PutInBuffer(b, strcat(IRC_MSGPREFIX_ERROR, 
                            "/", argv(0), ": must be used in a session-bound buffer"),
                            IRC_BUFFER_MSGLEVEL_INFO);
        return;
    }

    IRC_Quit(s, (if(argc > 1) substring(cmdline, argv_start_index(1), strlen(cmdline)) else string_null));
    if(argv(0) == "quit")
        IRC_TerminateSession(s);
}

void IRC_Command_RegisterAll(void) {
    IRC_Command_Register("echo",        2, IRC_Command_echo_call,       irc_command_null);
    IRC_Command_Register("msg",         3, IRC_Command_msg_call,        irc_command_null);
    IRC_Command_Register("notice",      3, IRC_Command_msg_call,        irc_command_null);
    IRC_Command_Register("close",       1, IRC_Command_close_call,      irc_command_null);
    IRC_Command_Register("join",        2, IRC_Command_join_call,       irc_command_null);
    IRC_Command_Register("part",        1, IRC_Command_part_call,       irc_command_null);
    IRC_Command_Register("connect",     3, IRC_Command_connect_call,    irc_command_null);
    IRC_Command_Register("quit",        0, IRC_Command_quit_call,       irc_command_null);
    IRC_Command_Register("disconnect",  0, IRC_Command_quit_call,       irc_command_null);
}

