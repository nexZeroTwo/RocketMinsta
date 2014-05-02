
entity irc;

float IRC_CheckSession(float s) {
    if(!IRC_SessionExists(s))
        s = IRC_CreateSession();
    
    if(!IRC_SessionIsConnected(s)) {
        if(IRC_ConnectSession(s,
            cvar_string("sv_ircbot_server"),
            cvar("sv_ircbot_server_port"),
            cvar_string("sv_ircbot_server_password"),
            cvar_string("sv_ircbot_nick"),
            cvar_string("sv_ircbot_user"),
            cvar_string("sv_ircbot_realname")
        ) == IRC_ERR_STATE)
            IRC_TerminateSession(s);
    }
    
    cvar_set("_sv_ircbot_session", ftos(s));
    return s;
}

#define IRC_STRING_SEPARATOR "^9  //  "

string IRC_GameInfoString(void) {
    return strcat("^7playing ^5", gametype_ID_to_LongName(game), "^7 on ^2", mapname);
}

string IRC_ClientsInfoString(void) {
    float bots = totalclients - realclients;
    string s = strcat("^1", ftos(totalclients), "^7/", ftos(maxclients), " clients");
    if(bots > 0)
        s = strcat(s, " (", ftos(bots), " bots)");
    return s;
}

void IRC_UpdateTopic(void) {
    if(!cvar("sv_ircbot_update_topic"))
        return;
        
    string s = strcat(cvar_string("hostname"), IRC_STRING_SEPARATOR, IRC_GameInfoString());
    if(!realclients)
        s = strcat(s, IRC_STRING_SEPARATOR, "^1server empty");
    else if(totalclients == maxclients)
        s = strcat(s, IRC_STRING_SEPARATOR, "^1server full");
    
    IRC_Topic(irc.cnt, irc.target, s);
    irc.skin = 0;
}

void IRC_Think(void) {
    self.cnt = IRC_CheckSession(self.cnt);
    self.nextthink = time + 5;
    
    if(self.skin) {
        IRC_UpdateTopic();
        self.skin = 0;
    }
}

void IRC_Init(void) {
    float s;
    
    if(!cvar("sv_ircbot"))
        return;
    
    if(!checkextension("DP_RM_IRC")) {
        print("IRC_Init: engine doesn't implement the DP_RM_IRC extension. Install DarkPlacesRM to use IRC.\n");
        return;
    }
    
    if(!cvar("irc_initialized")) {
        print("IRC_Init: the IRC module is not initialized, make sure you have libircclient installed.\n");
        return;
    }
    
    // These are internal cvars used to achieve persistence between restarts
    registercvar("_sv_ircbot_session", "-1");
    registercvar("_sv_ircbot_joinlog", "");
    
    s = IRC_CheckSession(cvar("_sv_ircbot_session"));
    
    irc = spawn();
    irc.classname = "ircbot";
    irc.cnt = s;
    irc.target = strzone(strtolower(cvar_string("sv_ircbot_channel")));
    irc.targetname = strzone(cvar_string("sv_ircbot_channel_key"));
    irc.think = IRC_Think;
    irc.nextthink = time + 5;
    
    IRC_Announce_GameStart();
}

void IRC_AdminCommand(float handle, string nick, string cmdline) {
    float argc = tokenize_console(cmdline), i, j, k, l, reasonarg, entno, bantime, masksize;
    string cmd = argv(0), s, reason;
    entity e, client;

#define INITARG(c) reasonarg = c
#define GETARG(v,d) if((argc > reasonarg) && ((v = stof(argv(reasonarg))) != 0)) ++reasonarg; else v = d
#define RESTARG(v) if(argc > reasonarg) v = substring(cmdline, argv_start_index(reasonarg), strlen(cmdline) - argv_start_index(reasonarg)); else v = ""

    switch(cmd) {
        case "status": case "list": case "players": {
            IRC_Notice(handle, nick, strcat("^5", gametype_ID_to_LongName(game), "^7 on ^2", mapname, "^7, ^1", 
                                     strcat(ftos(realclients), "^7/", ftos(maxclients), " clients")));
            FOR_EACH_CLIENT(e) {
                s = IRC_DP2IRC(e.netname);
                if(argc < 2 || strstrofs(strdecolorize(s), argv(1), 0) >= 0) {
                    s = strcat("^3#", ftos(num_for_edict(e)));
                    l = strlen(s);
                    for(i = 0; i < 7 - l; ++i) s = strcat(s, " ");
                    s = strcat(s, " ^4", e.netaddress);
                    for(i = 0; i < 15 - strlen(e.netaddress); ++i) s = strcat(s, " ");
                    s = strcat(s, " ^7", e.netname);
                    IRC_Notice(handle, nick, s);
                }
            }
            IRC_Notice(handle, nick, "- End of list -");
            
            break;
        }
        
        case "kickban": case "gtfo": {
            if(argc < 2) {
                IRC_Notice(handle, nick, strcat("Usage: ", argv(0), " <id> [bantime [masksize]] [reason]"));
                break;
            }
            
            entno = stof(argv(1));
            
            if(entno > maxclients || entno < 1) {
                IRC_Notice(handle, nick, strcat("Invalid client id: ", ftos(entno)));
                break;
            }
            
            client = edict_num(entno);
            
            if(clienttype(client) != CLIENTTYPE_REAL) {
                IRC_Notice(handle, nick, strcat("Not a real client: ", ftos(entno)));
                break;
            }
            
            INITARG(2);
            GETARG(bantime, cvar("g_ban_default_bantime"));
            GETARG(masksize, cvar("g_ban_default_masksize"));
            RESTARG(reason);
            reason = strcat("[IRC ", nick, "] ", reason);
            
            IRC_Notice(handle, nick, strcat(client.netname, "^7 is now banned for ", ftos(bantime), " seconds (masksize ", ftos(masksize), ")"));
            Ban_KickBanClient(client, bantime, masksize, reason);
            break;
        }
        
        case "ban": {
            if(argc < 2) {
                IRC_Notice(handle, nick, "Usage: ban <ip> [bantime] [reason]");
                break;
            }
            
            s = argv(1);
            
            INITARG(2);
            GETARG(bantime, cvar("g_ban_default_bantime"));
            RESTARG(reason);
            reason = strcat("[IRC ", nick, "] ", reason);
            
            IRC_Notice(handle, nick, strcat("^4", s, "^7 is now banned for ", ftos(bantime), " seconds"));
            Ban_Insert(s, bantime, reason, 1);
            break;
        }
        
        case "bans": {
            float maxrange = min(10, max(5, stof(argv(2))));
            IRC_Notice(handle, nick, strcat("Total bans: ^1", ftos(ban_count), "^7, showing ^3#",
                                     ftos(min(ban_count, stof(argv(1)))), "^7 to ^3#", 
                                     ftos(min(ban_count, stof(argv(1)) + maxrange - 1))));
            for(l = i = stof(argv(1)); i < ban_count, k < maxrange; ++i, ++k) {
                if(time > ban_expire[i])
                    continue;
                
                ++l;
                s = strcat("^3#", ftos(i), " ", ((i < 10)? " " : ""));
                s = strcat(s, "^4", ban_ip[i], "^7 ");
                for(j = 0; j < 15 - strlen(ban_ip[i]); ++j) s = strcat(s, " ");
                s = strcat(s, ftos(rint(ban_expire[i] - time)), "s");
                if(ban_reason[i])
                    s = strcat(s, ", ", ban_reason[i]);
                IRC_Notice(handle, nick, s);
            }
            if(l == ban_count || l == stof(argv(1)))
                IRC_Notice(handle, nick, "- End of list -");
            else
                IRC_Notice(handle, nick, "- List truncated, use bans <position> [item count] to start from a different item -");
            break;
        }
        
        case "unban": {
            if(argc < 2) {
                IRC_Notice(handle, nick, "Usage: unban <id>");
                break;
            }
            
            i = stof(argv(1));
            s = strcat(ban_ip[i], "");
            
            if(Ban_Delete(i))
                IRC_Notice(handle, nick, strcat("Unbanned ^4", s));
            else 
                IRC_Notice(handle, nick, "Failed to unban");
            
            break;
        }
        
        case "cmd": {
            if(cvar("sv_ircbot_admin_allow_cmd")) {
                if(argc < 2) {
                    IRC_Notice(handle, nick, "Usage: cmd <console command>");
                    break;
                }
                
                localcmd(substring(cmdline, argv_start_index(1), strlen(cmdline)), "\n");
                break;
            } else goto help;
        }
        
        case "masktest": {
            IRC_Notice(handle, nick, argv(1));
            IRC_Notice(handle, nick, argv(2));
            if(IRC_MaskMatches(argv(1), argv(2)))
                IRC_Notice(handle, nick, "MATCH");
            IRC_Notice(handle, nick, ftos(IRC_MaskMatches(argv(1), argv(2))));
        }
        
        default: {
:help
            s = "Available commands: status kickban ban bans unban";
            if(cvar("sv_ircbot_admin_allow_cmd"))
                s = strcat(s, " cmd");
            IRC_Notice(handle, nick, s);
            break;
        }
    }

#undef INITARG
#undef GETARG
#undef RESTARG
}

float IRC_IsAdmin(string mask) {
    float i, argc = tokenizebyseparator(cvar_string("sv_ircbot_admin_list"), " ");
    for(i = 0; i < argc; ++i)
        if(IRC_MaskMatches(mask, argv(i)))
            return TRUE;
    return FALSE;
}

void IRC_Event(float handle, string event, float numeric, string src, float argc) {
    float ijp;
    string nick, user, host;
    
    if(handle != irc.cnt)    // not our session
        return;
    
    ijp = cvar("sv_ircbot_announce_irc_joinparts");
    
    nick = substring(src, 0, strstrofs(src, "!", 0));
    user = substring(src, strstrofs(src, "!", 0) + 1, strstrofs(src, "@", 0) - strstrofs(src, "!", 0) - 1);
    host = substring(src, strstrofs(src, "@", 0) + 1, strlen(src));
    
    if(event == "CONNECT") {
        IRC_JoinChannel(handle, irc.target, irc.targetname);
        if(cvar_string("sv_ircbot_connectcommand") != "")
            IRC_SendRaw(handle, cvar_string("sv_ircbot_connectcommand"));
    } else if(event == "CHANNEL") {
        if(cvar("sv_ircbot_chat_irc2game"))
        if(strtolower(argv(0)) == irc.target)
            bprint("\{1}^5IRC ^8<^3", nick, "^8>^7 ", IRC_IRC2DP(argv(1)), "\n");
    } else if(event == "PRIVMSG" || event == "NOTICE") {
        string cmd = argv(1);
        if(argv(0) == IRC_CurrentNick(handle)) {
            if(IRC_IsAdmin(src))
                IRC_AdminCommand(handle, nick, cmd);
            else
                IRC_Notice(handle, nick, "Permission denied");
        }
    } else if(event == "CTCP") {
        if(cvar("sv_ircbot_chat_irc2game"))
        if(substring(argv(0), 0, 7) == "ACTION ")
            bprint("\{1}^5IRC  ^3* ", nick, "^7 ", IRC_IRC2DP(substring(argv(0), 7, strlen(argv(0)))), "\n");
    } else if(event == "KICK") {
        if(cvar("sv_ircbot_channel_auto_rejoin"))
        if(argv(1) == IRC_CurrentNick(handle)) {
            IRC_JoinChannel(handle, argv(0), ((argv(0) == irc.target)? irc.targetname : ""));
            return;
        }
        
        if(ijp) if(argv(0) == irc.target) {
            bprint("\{1}^5IRC  ^1* ^3", nick, " ^1kicked ^3", argv(1), " ^1from ^2", argv(0));
            if(argv(2) != "" && argv(2) != argv(1))
               bprint(" ^8(", argv(2), ")");
            bprint("\n");
        }
    } else if(event == "JOIN") {
        if(ijp) if(argv(0) == irc.target)
            bprint("\{1}^5IRC  ^7* ^3", nick, " ^7joined ^2", argv(0), "\n");
    } else if(event == "PART") {
        if(ijp) if(argv(0) == irc.target)
            bprint("\{1}^5IRC  ^7* ^3", nick, " ^7left ^2", argv(0));
            if(argv(1) != "" && argv(1) != nick)
                bprint(" ^8(", argv(1), ")");
            bprint("\n");
    } else if(event == "QUIT") {
        if(ijp)
            bprint("\{1}^5IRC  ^1* ^3", nick, " ^1has quit IRC");
            if(argv(0) != "" && argv(0) != "Quit")
                bprint(" ^8(", argv(0), ")");
            bprint("\n");
    } else if(event == "MODE") {
        if(argv(0) == irc.target) if(argv(1) == "+o") if(argv(2) == IRC_CurrentNick(irc.cnt))
            irc.skin = 1;
    } else if(event == "NICK") {
        if(cvar("sv_ircbot_announce_irc_nick"))
            bprint("\{1}^5IRC  ^7* ^3", nick, " ^7is now known as ^3", argv(0), "\n");
    } else if(numeric == IRC_RFC_ERR_NICKNAMEINUSE) {
        IRC_ChangeNick(handle, strcat(argv(1), "`"));
    }
}

void IRC_Announce_PlayerChat(entity plr, string msg) { if(!irc) return;
    IRC_Privmsg(irc.cnt, irc.target, strcat("<", plr.netname, "> ", msg));
}

void IRC_Announce_Client(entity plr, float ispart) {
    if(!cvar("sv_ircbot_announce_joinparts"))
        return;
    
    string msg;
    
    if(ispart)  msg = "^1- part ^3#";
    else        msg = "^2+ join ^3#";
    msg = strcat(msg, ftos(num_for_edict(plr)), "^7: ", plr.netname);
    
    if(cvar("sv_ircbot_announce_joinparts_showip"))
        msg = strcat(msg, "^7 (^4", plr.netaddress, "^7)");
    if(!cvar("sv_ircbot_update_topic"))
        msg = strcat(msg, IRC_STRING_SEPARATOR, IRC_GameInfoString());
    msg = strcat(msg, IRC_STRING_SEPARATOR, IRC_ClientsInfoString());
    
    IRC_Privmsg(irc.cnt, irc.target, msg);
    irc.skin = 1;
}

void IRC_Announce_ClientConnect(entity plr) { if(!irc) return;
    if(ListContains(cvar_string("_sv_ircbot_joinlog"), ftos(num_for_edict(plr)), " "))
        return;
    
    GameCommand(strcat("addtolist _sv_ircbot_joinlog ", ftos(num_for_edict(plr))));
    IRC_Announce_Client(plr, FALSE);
}

void IRC_Announce_ClientDisconnect(entity plr) { if(!irc) return;
    GameCommand(strcat("delfromlist _sv_ircbot_joinlog ", ftos(num_for_edict(plr))));
    IRC_Announce_Client(plr, TRUE);
}

void IRC_Announce_GameStart(void) { if(!irc) return;
    if(cvar("sv_ircbot_announce_gamestart"))
        IRC_Privmsg(irc.cnt, irc.target, strcat("^3--> ^7Now playing ^5", gametype_ID_to_LongName(game), "^7 on ^2", mapname, " ^3<-- "));
    defer(10, IRC_UpdateTopic);
}

void IRC_Announce_GameOver(void) { if(!irc) return;
    if(cvar("sv_ircbot_announce_gameover"))
        IRC_Privmsg(irc.cnt, irc.target, strcat("^1--> ^5", gametype_ID_to_LongName(game), "^7 on ^2", mapname, " ^7ended ^1<-- "));
}

void IRC_Announce_Vote(string vstr) { if(!irc) return;
    if(cvar("sv_ircbot_announce_votes"))
        IRC_Privmsg(irc.cnt, irc.target, vstr);
}

void IRC_Announce_Ban(string bstr) { if(!irc) return;
    if(cvar("sv_ircbot_announce_bans"))
        IRC_Privmsg(irc.cnt, irc.target, bstr);
}

void IRC_Announce_Name(entity plr, string name) { if(!irc) return;
    if(cvar("sv_ircbot_announce_name") && (strdecolorize(plr.netname) != strdecolorize(name)))
        IRC_Privmsg(irc.cnt, irc.target, strcat("* ^3", plr.netname, "^7 changed name to ^3", name));
}
