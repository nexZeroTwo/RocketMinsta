
entity irc;

float irc_was_connected;
float irc_reconnect_time;
float irc_disconnections;

float IRC_CheckSession(float s) {
    if(!IRC_SessionExists(s))
        s = IRC_CreateSession();
    
    if(!IRC_SessionIsConnected(s)) {
        if(irc_was_connected) {
            float d = CVAR(sv_ircbot_reconnect_interval) + CVAR(sv_ircbot_reconnect_interval_add) * irc_disconnections;
            print("IRC_CheckSession: trying to reconnect in ", ftos(d), " seconds\n");

            irc_was_connected = FALSE;
            irc_reconnect_time = time + d;
            irc_disconnections += 1;
        }

        if(!irc || time >= irc_reconnect_time) {
            float err = IRC_ConnectSession(s,
                CVAR_STR(sv_ircbot_server),
                CVAR(sv_ircbot_server_port),
                CVAR_STR(sv_ircbot_server_password),
                CVAR_STR(sv_ircbot_nick),
                CVAR_STR(sv_ircbot_user),
                CVAR_STR(sv_ircbot_realname)
            );

            if(!err)
                irc_was_connected = TRUE;
            else if(err == IRC_ERR_STATE)
                IRC_TerminateSession(s);
        }
    } else
        irc_was_connected = TRUE;

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

float IRC_Privmsg(float handle, string targ, string msg) {
    float r = IRC_Privmsg_Builtin(handle, targ, msg);
    
    float spam = max(0, CVAR(sv_ircbot_spamstatus));
    if(spam && handle == irc.cnt && strtolower(targ) == irc.target) {
        float c = CVAR(_sv_ircbot_msgsent) + 1;
        if(c >= spam) {
            c = 0;
            IRC_Privmsg_Builtin(handle, targ, strcat("^1Game status: ^7", IRC_GameInfoString(), IRC_STRING_SEPARATOR, IRC_ClientsInfoString()));
        }
        cvar_set("_sv_ircbot_msgsent", ftos(c));
    }
    
    return r;
}

float IRC_Announce(float handle, string targ, string msg) {
	if(CVAR(sv_ircbot_announce_when_empty) || realclients > 0)
		return IRC_Privmsg(handle, targ, msg);
	return 0;
}

void IRC_UpdateTopic(void) {
    if(!CVAR(sv_ircbot_update_topic))
        return;
        
    string s = CVAR_STR(sv_ircbot_update_topic_static);
    if(s != "")
        s = strcat(s, IRC_STRING_SEPARATOR, "^7");
    if(CVAR(sv_ircbot_update_topic_hostname))
        s = strcat(s, CVAR_STR(hostname), IRC_STRING_SEPARATOR);
    s = strcat(s, IRC_GameInfoString());
    
    if(!realclients && CVAR(sv_ircbot_update_topic_serverempty))
        s = strcat(s, IRC_STRING_SEPARATOR, "^1server empty");
    else if(totalclients == maxclients && CVAR(sv_ircbot_update_topic_serverfull))
        s = strcat(s, IRC_STRING_SEPARATOR, "^1server full");
    
    if(CVAR_STR(_sv_ircbot_lasttopic) != IRC_DP2IRC(s) || irc.skin > 1) {
        IRC_Topic(irc.cnt, irc.target, s);
    }

    irc.skin = 0;
}

void IRC_Think(void) {
    self.cnt = IRC_CheckSession(self.cnt);
    self.nextthink = time + 1;
    
    if(self.skin) {
        IRC_UpdateTopic();
        self.skin = 0;
    }
}

string IRC_DP2IRC_NoColors(string s) {
//#NO AUTOCVARS START
    string v1 = cvar_string("irc_translate_dp2irc_color");
    string v2 = cvar_string("irc_translate_dp2irc_qfont");
    cvar_set("irc_translate_dp2irc_color", "1");
    cvar_set("irc_translate_dp2irc_qfont", "1");
    s = IRC_DP2IRC(s);
    cvar_set("irc_translate_dp2irc_color", v1);
    cvar_set("irc_translate_dp2irc_qfont", v2);
    return s;
//#NO AUTOCVARS END
}

void IRC_Init(void) {
    float s;
    
    if(!CVAR(sv_ircbot))
        return;
    
    if(!checkextension("DP_RM_IRC")) {
        print("IRC_Init: engine doesn't implement the DP_RM_IRC extension. Install DarkPlacesRM to use IRC.\n");
        return;
    }
    
    if(!CVAR(irc_initialized)) {
        print("IRC_Init: the IRC module is not initialized, make sure you have libircclient installed.\n");
        return;
    }
    
    // These are internal cvars used to achieve persistence between restarts
    registercvar("_sv_ircbot_session", "-1");
    registercvar("_sv_ircbot_joinlog", "");
    registercvar("_sv_ircbot_msgsent", "0");
    registercvar("_sv_ircbot_lasttopic", "");
    
    s = IRC_CheckSession(CVAR(_sv_ircbot_session));
    
    irc = spawn();
    irc.classname = "ircbot";
    irc.cnt = s;
    irc.target = strzone(strtolower(CVAR_STR(sv_ircbot_channel)));
    irc.targetname = strzone(CVAR_STR(sv_ircbot_channel_key));
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

            string search;
            if(argc > 1)
                search = strtolower(substring(cmdline, argv_start_index(1), strlen(cmdline)));

            FOR_EACH_CLIENT(e) {
                if(!search || strstrofs(strtolower(IRC_DP2IRC_NoColors(e.netname)), search, 0) >= 0) {
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
            GETARG(bantime, CVAR(g_ban_default_bantime));
            GETARG(masksize, CVAR(g_ban_default_masksize));
            RESTARG(reason);
            reason = strcat("[IRC ", nick, "] ", reason);
            
            string clname = strzone(client.netname);
            i = Ban_KickBanClient(client, bantime, masksize, reason);
            
            if(i >= 0)
                IRC_Notice(handle, nick, strcat(clname, "^7 is now banned for ", ftos(bantime),
                                         strcat(" seconds (masksize ", ftos(masksize), ", id ^3#", ftos(i), "^7)")));
            else
                IRC_Notice(handle, nick, "Failed to kickban, just kicked");
            
            strunzone(clname);
            break;
        }
        
        case "ban": {
            if(argc < 2) {
                IRC_Notice(handle, nick, "Usage: ban <ip> [bantime] [reason]");
                break;
            }
            
            s = argv(1);
            
            INITARG(2);
            GETARG(bantime, CVAR(g_ban_default_bantime));
            RESTARG(reason);
            reason = strcat("[IRC ", nick, "] ", reason);
            
            i = Ban_Insert(s, bantime, reason, 1);
            
            if(i >= 0)
                IRC_Notice(handle, nick, strcat("^4", s, "^7 is now banned for ", ftos(bantime), " seconds (id ^3#", ftos(i), "^7)"));
            else
                IRC_Notice(handle, nick, "Failed to ban");
            break;
        }
        
        case "bans": {
            float maxrange = min(10, max(5, floor(stof(argv(2)))));
            float activebans = 0;
            float startfrom = stof(argv(1));
            
            for(i = 0; i < ban_count; ++i)
                if(time <= ban_expire[i]) {
                    ++activebans;
                } else if(i == startfrom)
                    ++startfrom;
            
            if(!activebans) {
                IRC_Notice(handle, nick, "No active bans");
                break;
            }
            
            IRC_Notice(handle, nick, strcat("Active bans: ^1", ftos(activebans),
                                            "^7, showing up to ^1", ftos(maxrange), "^7 entries starting from ^3#", ftos(startfrom)));
            
            for(l = 0, k = i = startfrom; i < ban_count && l < maxrange; ++i) {
                if(time > ban_expire[i])
                    continue;
                
                ++l; ++k;
                
                s = strcat("^3#", ftos(i), " ", if(i < 10) " " else "");
                s = strcat(s, "^4", ban_ip[i], "^7 ");
                for(j = 0; j < 15 - strlen(ban_ip[i]); ++j) s = strcat(s, " ");
                s = strcat(s, ftos(rint(ban_expire[i] - time)), "s");
                if(ban_reason[i])
                    s = strcat(s, ", ", ban_reason[i]);
                IRC_Notice(handle, nick, s);
            }
            
            if(k == activebans)
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
            if(CVAR(sv_ircbot_admin_allow_cmd)) {
                if(argc < 2) {
                    IRC_Notice(handle, nick, "Usage: cmd <console command>");
                    break;
                }
                
                localcmd(substring(cmdline, argv_start_index(1), strlen(cmdline)), "\n");
                break;
            } else goto help;
        }

        case "announce": {
            var msg = IRC_IRC2DP(substring(cmdline, argv_start_index(1), strlen(cmdline)));
            bprint("\x01^7", msg, "\n");
            // IRC_Announce(irc.cnt, irc.target, msg);
            break;
        }
        
        default: {
:help
            s = "Available commands: status kickban ban bans unban announce";
            if(CVAR(sv_ircbot_admin_allow_cmd))
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
    float i, argc = tokenizebyseparator(CVAR_STR(sv_ircbot_admin_list), " ");
    for(i = 0; i < argc; ++i)
        if(IRC_MaskMatches(mask, argv(i)))
            return TRUE;
    return FALSE;
}

float IRC_IsIgnored(string mask) {
    float i, argc = tokenizebyseparator(CVAR_STR(sv_ircbot_ignore_list), " ");
    for(i = 0; i < argc; ++i)
        if(IRC_MaskMatches(mask, argv(i)))
            return TRUE;
    return FALSE;
}

void IRC_Event(float handle, string event, float numeric, string src, float argc) {
    float ijp;
    string nick, user, host;
    
    if(!irc)
        return;

    if(handle != irc.cnt)    // not our session
        return;
    
    ijp = CVAR(sv_ircbot_announce_irc_joinparts);
    
    nick = substring(src, 0, strstrofs(src, "!", 0));
    user = substring(src, strstrofs(src, "!", 0) + 1, strstrofs(src, "@", 0) - strstrofs(src, "!", 0) - 1);
    host = substring(src, strstrofs(src, "@", 0) + 1, strlen(src));
    
    if(event == "CONNECT") {
        irc_disconnections = 0;
        IRC_JoinChannel(handle, irc.target, irc.targetname);
        if(CVAR_STR(sv_ircbot_connectcommand) != "")
            IRC_SendRaw(handle, CVAR_STR(sv_ircbot_connectcommand));
    } else if(event == "CHANNEL") {
        if(CVAR(sv_ircbot_chat_irc2game))
        if(strtolower(argv(0)) == irc.target) {
            string msg = argv(1);

            if(IRC_IsIgnored(src))
                return;

            msg = IRC_IRC2DP(msg);

            if(CVAR(sv_ircbot_chat_irc2game_require_highlight)) {
                string mynick = IRC_CurrentNick(handle);
                float nl = strlen(mynick);
                float ml = strlen(msg);
                
                if(substring(msg, 0, nl + 1) == strcat(mynick, " "))
                    msg = substring(msg, nl + 1, ml);
                else if(substring(msg, 0, nl + 2) == strcat(mynick, ": ") ||
                        substring(msg, 0, nl + 2) == strcat(mynick, ", "))
                    msg = substring(msg, nl + 2, ml);
                else
                    msg = "";
            }
            
            if(msg != "")
                bprint("\{1}^5IRC ^8<^3", nick, "^8>^7 ", msg, "\n");
        }
    } else if(event == "PRIVMSG") {
        string cmd = argv(1);
        if(argv(0) == IRC_CurrentNick(handle)) {
            if(IRC_IsAdmin(src))
                IRC_AdminCommand(handle, nick, cmd);
            else
                IRC_Notice(handle, nick, "Permission denied");
        }
    } else if(event == "CTCP") {
        // /me for borked libircclient
        if(CVAR(sv_ircbot_chat_irc2game))
        if(!CVAR(sv_ircbot_chat_irc2game_require_highlight))
        if(substring(argv(0), 0, 7) == "ACTION ") {
            string msg = argv(0);
            if(!IRC_IsIgnored(src))
                bprint("\{1}^5IRC  ^3* ", nick, "^7 ", IRC_IRC2DP(substring(msg, 7, strlen(msg))), "\n");
        }
    } else if(event == "ACTION") {
        // /me for unborked libircclient
        if(CVAR(sv_ircbot_chat_irc2game))
        if(!CVAR(sv_ircbot_chat_irc2game_require_highlight))
        if(strtolower(argv(0)) == irc.target) {
            string msg = argv(1);
            if(!IRC_IsIgnored(src))
                bprint("\{1}^5IRC  ^3* ", nick, "^7 ", IRC_IRC2DP(msg), "\n");
        }
    } else if(event == "KICK") {
        if(CVAR(sv_ircbot_channel_auto_rejoin))
        if(argv(1) == IRC_CurrentNick(handle)) {
            IRC_JoinChannel(handle, argv(0), if(strtolower(argv(0)) == irc.target) irc.targetname else "");
            return;
        }
        
        if(ijp) if(strtolower(argv(0)) == irc.target) {
            bprint("\{1}^5IRC  ^1* ^3", nick, " ^1kicked ^3", argv(1), " ^1from ^2", argv(0));
            if(argv(2) != "" && argv(2) != argv(1))
               bprint(" ^8(", argv(2), ")");
            bprint("\n");
        }
    } else if(event == "JOIN") {
        if(ijp) if(strtolower(argv(0)) == irc.target)
            bprint("\{1}^5IRC  ^7* ^3", nick, " ^7joined ^2", argv(0), "\n");
    } else if(event == "PART") {
        if(ijp) if(strtolower(argv(0)) == irc.target) {
            bprint("\{1}^5IRC  ^7* ^3", nick, " ^7left ^2", argv(0));
            if(argv(1) != "" && argv(1) != nick)
                bprint(" ^8(", argv(1), ")");
            bprint("\n");
        }
    } else if(event == "QUIT") {
        if(ijp) {
            bprint("\{1}^5IRC  ^1* ^3", nick, " ^1has quit IRC");
            if(argv(0) != "" && argv(0) != "Quit")
                bprint(" ^8(", argv(0), ")");
            bprint("\n");
        }
    } else if(event == "MODE") {
        if(strtolower(argv(0)) == irc.target) if(argv(1) == "+o") if(argv(2) == IRC_CurrentNick(irc.cnt))
            irc.skin = 1;
    } else if(event == "NICK") {
        if(CVAR(sv_ircbot_announce_irc_nick))
            bprint("\{1}^5IRC  ^7* ^3", nick, " ^7is now known as ^3", argv(0), "\n");
    } else if(event == "TOPIC") {
        if(strtolower(argv(0)) == irc.target) {
            cvar_set("_sv_ircbot_lasttopic", argv(1));

            if(nick != IRC_CurrentNick(handle))
                IRC_UpdateTopic();
        }
    } else if(numeric == IRC_RFC_ERR_NICKNAMEINUSE) {
        IRC_ChangeNick(handle, strcat(argv(1), "`"));
    } else if(numeric == IRC_RFC_RPL_TOPIC) {
        if(strtolower(argv(1)) == irc.target)
            cvar_set("_sv_ircbot_lasttopic", argv(2));
    } else if(numeric == IRC_RFC_RPL_NOTOPIC) {
        if(strtolower(argv(1)) == irc.target)
            cvar_set("_sv_ircbot_lasttopic", "");
    }
}

void IRC_Announce_PlayerChat(entity plr, string msg) { if(!irc) return;
    IRC_Privmsg(irc.cnt, irc.target, strcat("<", plr.netname, "> ", msg));
}

void IRC_Announce_Client_Callback(string ip, string cn, entity ctx) {
    entity plr = ctx.owner;
    string msg;
    
    if(ctx.cnt) msg = "^1- part ^3#";
    else        msg = "^2+ join ^3#";
    msg = strcat(msg, ftos(num_for_edict(plr)), "^7: ", plr.netname);
    
    if(CVAR(sv_ircbot_announce_joinparts_showip))
        msg = strcat(msg, "^7 (^4", ip, "^7)");
    if(cn != "")
        msg = strcat(msg, "^7 [^6", strtoupper(cn), "^7]");
    if(CVAR(sv_ircbot_announce_joinparts_showgameinfo))
        msg = strcat(msg, IRC_STRING_SEPARATOR, IRC_GameInfoString());
    msg = strcat(msg, IRC_STRING_SEPARATOR, IRC_ClientsInfoString());
    
    IRC_Privmsg(irc.cnt, irc.target, msg);
    irc.skin = 1;
    
    remove(ctx);
}

void IRC_Announce_Client(entity plr, float ispart) {
    if(!CVAR(sv_ircbot_announce_joinparts))
        return;
    
    entity ctx = spawn();
    ctx.cnt = ispart;
    ctx.owner = plr;
    
    if(CVAR(sv_ircbot_announce_joinparts_showcountry))
    if(CVAR(sv_ip2country))
    if(CVAR_STR(sv_ip2country_server) != "") {
        IP2C_Lookup(plr.netaddress, IRC_Announce_Client_Callback, CVAR(sv_ircbot_announce_joinparts_showcountry_timeout), ctx);
        return;
    }
    
    IRC_Announce_Client_Callback(plr.netaddress, "", ctx);
}

void IRC_Announce_ClientConnect(entity plr) { if(!irc) return;
    if(ListContains(CVAR_STR(_sv_ircbot_joinlog), ftos(num_for_edict(plr)), " "))
        return;
    
    GameCommand(strcat("addtolist _sv_ircbot_joinlog ", ftos(num_for_edict(plr))));
    IRC_Announce_Client(plr, FALSE);
}

void IRC_Announce_ClientDisconnect(entity plr) { if(!irc) return;
    GameCommand(strcat("delfromlist _sv_ircbot_joinlog ", ftos(num_for_edict(plr))));
    IRC_Announce_Client(plr, TRUE);
}

void IRC_Announce_GameStart(void) { if(!irc) return;
    if(CVAR(sv_ircbot_announce_gamestart))
        IRC_Announce(irc.cnt, irc.target, strcat("^3--> ^7Now playing ^5", gametype_ID_to_LongName(game), "^7 on ^2", mapname, " ^3<-- "));
    defer(10, IRC_UpdateTopic);
}

void IRC_Announce_GameOver(void) { if(!irc) return;
    if(CVAR(sv_ircbot_announce_gameover))
        IRC_Announce(irc.cnt, irc.target, strcat("^1--> ^5", gametype_ID_to_LongName(game), "^7 on ^2", mapname, " ^7ended ^1<-- "));
}

void IRC_Announce_GameEvent(string estr) { if(!irc) return;
	if(CVAR(sv_ircbot_announce_game_events))
		IRC_Announce(irc.cnt, irc.target, estr);
}

void IRC_Announce_Vote(string vstr) { if(!irc) return;
    if(CVAR(sv_ircbot_announce_votes))
        IRC_Announce(irc.cnt, irc.target, vstr);
}

void IRC_Announce_Ban(string bstr) { if(!irc) return;
    if(CVAR(sv_ircbot_announce_bans))
        IRC_Announce(irc.cnt, irc.target, bstr);
}

void IRC_Announce_Name(entity plr, string name) { if(!irc) return;
    if(CVAR(sv_ircbot_announce_name) && (strdecolorize(plr.netname) != strdecolorize(name)))
        IRC_Announce(irc.cnt, irc.target, strcat("* ^3", plr.netname, "^7 changed name to ^3", name));
}

void IRC_Announce_Radio(string rstr) { if(!irc) return;
    if(CVAR(sv_ircbot_announce_radio))
        IRC_Announce(irc.cnt, irc.target, rstr);
}
