float VoteCheckNasty(string cmd)
{
	if(strstrofs(cmd, ";", 0) >= 0)
		return TRUE;
	if(strstrofs(cmd, "\n", 0) >= 0)
		return TRUE;
	if(strstrofs(cmd, "\r", 0) >= 0)
		return TRUE;
	if(strstrofs(cmd, "$", 0) >= 0)
		return TRUE;
	return FALSE;
}

#define STUPID_VNO_STRINGS 10
#define STUPID_VNO_PASSWORD 16645

string GetStupidVNoString() {
	switch(floor(random() * STUPID_VNO_STRINGS)) {
		case 0:
			return "NOPE.avi";
		case 1:
			return "FUCK OFF AND DIE";
		case 2:
			return "YOU SUCK";
		case 3:
			return "GTFO";
		case 4:
			return "FFFFFFFFFFFUUUUUUUUUUUUUUU";
		case 5:
			return "SUCK MY COCK DUDE";
		case 6:
			return "I FUCKING HATE YOU";
		case 7:
			return "PLEASE KILL YOURSELF";
		case 8:
			return "Mr. Frez Tag for president";
		case 9: default:
			return "FUCK NO";
	}
}

string GetKickVoteVictim_newcommand;
string GetKickVoteVictim_reason;

entity GetKickVoteVictim(string vote, string cmd, entity caller)
{
	float tokens;
	string ns;
	entity e;
	string reason;

	tokens = tokenize_console(vote);
	ns = "";
	
	if(argv(0) == "pointkick") {
		e = caller.cursor_trace_ent;
        ParseCommandPlayerSlotTarget_firsttoken = 1;
	}
	else {
		e = GetCommandPlayerSlotTargetFromTokenizedCommand(tokens, 1);
	}
	if(e && (clienttype(e) != CLIENTTYPE_NOTACLIENT))
	{
		if(ParseCommandPlayerSlotTarget_firsttoken < tokens)
			GetKickVoteVictim_reason = substring(vote, argv_start_index(ParseCommandPlayerSlotTarget_firsttoken), argv_end_index(-1) - argv_start_index(ParseCommandPlayerSlotTarget_firsttoken));
		else
			GetKickVoteVictim_reason = "";

		reason = "";
		if(cmd != "vdo" || GetKickVoteVictim_reason == "")
			reason = "~"; // by convention, ~ prefixes a "unverified" kickban which will not be networked

		if(substring(GetKickVoteVictim_reason, 0, 1) == "~")
		{
			reason = "~";
			GetKickVoteVictim_reason = substring(GetKickVoteVictim_reason, 1, strlen(GetKickVoteVictim_reason) - 1);
		}

		if(caller)
			reason = strcat(reason, "player ", strdecolorize(caller.netname));
		else
			reason = strcat(reason, "console vote");
		if(GetKickVoteVictim_reason != "")
			reason = strcat(reason, ": ", strdecolorize(GetKickVoteVictim_reason));

		if not(cvar_value_issafe(reason))
			reason = uri_escape(reason);

		GetKickVoteVictim_newcommand = strcat(argv(0), " # ", ftos(num_for_edict(e)));
		if(argv(0) == "kickban")
		{
			GetKickVoteVictim_newcommand = strcat(GetKickVoteVictim_newcommand, " ", ftos(CVAR(g_ban_default_bantime)), " ", ftos(CVAR(g_ban_default_masksize)), " ", reason);
		}
		else if(argv(0) == "kick")
		{
			GetKickVoteVictim_newcommand = strcat(GetKickVoteVictim_newcommand, " ", reason);
		}
		else if(argv(0) == "pointkick"){
			GetKickVoteVictim_newcommand = strcat("kick", " # ", ftos(num_for_edict(e)));
			GetKickVoteVictim_newcommand = strcat(GetKickVoteVictim_newcommand, " ", reason);
		}
		return e;
	}
	if(argv(0) != "pointkick"){
		print_to(caller, strcat("Usage: ", cmd, " ", argv(0), " #playernumber (as in \"status\")\n"));
	}
	else{
		print_to(caller, "Look at a player and then call pointkick\n");
	}
	return world;
}

string RemapVote_display;
string RemapVote_vote;
float RemapVote(string vote, string cmd, entity e)
{
	float vote_argc;
	entity victim;
	vote_argc = tokenize_console(vote);
	string s;

	if(!e.vote_master)
	if (time - CVAR(_sv_rm_lastvote) < CVAR(sv_vote_mindelay))
	{
		sprint (e, strcat ("^1You cannot call votes this often. Please wait for another ^2", ftos ((CVAR(_sv_rm_lastvote) + CVAR(sv_vote_mindelay)) - time), " ^1second(s) and try again.\n"));
		return FALSE;
	}

	if(!VoteAllowed(e, argv(0), cmd))
		return FALSE;

	// VoteAllowed tokenizes!
	vote_argc = tokenize_console(vote);

	float min_argc = cvar (strcat ("sv_vote_", argv (0), "_min_arguments"));
	if (vote_argc <= min_argc && min_argc > 0)
	{
		sprint (e, strcat ("^2", argv (0), " ^1requires at least ^2", ftos (min_argc), " ^1argument(s).\n"));
		return FALSE;
	}

	// remap chmap to gotomap (forces intermission)
	if(vote_argc < 2)
		if(argv(0) == "chmap" || argv(0) == "gotomap" || argv(0) == "kick" || argv(0) == "kickban" || argv (0) == "nickban") // won't work without arguments
			return FALSE;
	if(argv(0) == "chmap")
	{
		vote = strcat("gotomap ", substring(vote, argv_start_index(1), argv_end_index(-1) - argv_start_index(1)));
		vote_argc = tokenize_console(vote);
	}
	if(argv(0) == "gotomap")
	{
		if(vote_argc > 2)
			s = strcat(" ", argv(2));
		
		//if(!(vote = ValidateMap(substring(vote, argv_start_index(1), argv_end_index(-1) - argv_start_index(1)), e)))
		if(!(vote = ValidateMap(argv(1), e)))
			return FALSE;
		
		vote = strcat("gotomap ", vote, s);
		vote_argc = tokenize_console(vote); // ValidateMap may have done some stuff to it

		if(vote_argc > 2)
		{
			if (! CVAR(sv_vote_gametype_call))
			{
				sprint (e, "^1Gametype voting is not allowed.\n");
				return FALSE;
			}
			
			s = NormalizeGametypeName(argv(2));
			if(!ListContainsEx(CVAR_STR(sv_vote_gametype_options), s, " ", NormalizeGametypeName)) s = "";
			
			// ListContains tokenizes
			vote_argc = tokenize_console(vote);
			
			if(s == "")
			{
				sprint(e, strcat("^1'", argv(2), "' is not a valid gametype or is forbidden\n"));
				return FALSE;
			}
			else if (!MapInfo_CheckMap(argv(1), gametype_Name_to_MapID(s)))
			{
				sprint (e, strcat ("^1", gametype_Name_to_LongName (s), " is not allowed on the selected map\n"));
				return FALSE;
			}
			else if (GameTypeVote_AvailabilityStatus (s) == GTV_OVERPLAYED) if(!CVAR(sv_vote_gametype_overplayed_allowcall)) if(!e.vote_master)
			{
				// Gametype overplayed?
				sprint (e, "^1This gametype is currently overplayed.");
				if (s == "ft")
					sprint (e, " Quit the freezefaggotry.");
				sprint (e, "\n");
				return FALSE;
			}
            
            if(e.vote_master)
                hack_forcenextmap = TRUE;
            
			RemapVote_vote = strzone(strcat("sv_cmd ", vote));
			RemapVote_display = strzone(strcat("^1", vote, " ^7(^5", gametype_Name_to_LongName(s), "^7)"));
			
			return TRUE;
		}
		else
		{
			if (!MapInfo_CheckMap(argv(1), gametype_ID_to_MapID(game)))
			{
				// Moved from ValidateMap
				sprint (e, strcat ("^1", gametype_ID_to_LongName(game), " is not allowed on the selected map\n"));
				return FALSE;
			}
			// In case freezefags decide to vcall gotomap on the last round just so they can continue fapping on -20°C
			// Akari: not needed, will show a gametype voting screen instead
			
			/*
			if(!CVAR(sv_vote_gametype_overplayed_allowcall))
			if (GameTypeVote_AvailabilityStatus (gametype_ID_to_Name(game)) == GTV_OVERPLAYED)
			{
				sprint (e, "^1This gametype is currently overplayed.");
				if (s == "ft")
					sprint (e, " Quit the freezefaggotry.");
				sprint (e, "\n");
				return FALSE;
			}
			*/
			
			// Why the hell was this never needed before?
			RemapVote_vote = strzone(strcat("sv_cmd ", vote));
			RemapVote_display = strzone(strcat("^1", vote));
			return TRUE;
		}
	}
    if(argv(0) == "endround")
    {
        if(!EndRound_Allowed())
        {
            sprint(self, "endround is not available in current gametype\n");
            return FALSE;
        }
    }

	// make kick and kickban votes a bit nicer (and reject them if formatted badly)
	if(argv(0) == "kick" || argv(0) == "kickban" || argv(0) == "kill" || argv (0) == "nickban" || argv(0) == "pointkick")
	{
		if(!(victim = GetKickVoteVictim(vote, cmd, e)))
			return FALSE;

		if(argv(0) == "kill" && victim.classname != "player")
		{
			sprint(self, strcat(victim.netname, "^1 is not playing.\n"));
			return FALSE;
		}
		if(argv(0) == "pointkick" && victim.classname != "player"){
			return FALSE;
		}
		RemapVote_vote = GetKickVoteVictim_newcommand;
		RemapVote_display = strcat("^1", vote, " (^7", VoteNetname(victim), "^1)");
        if(GetKickVoteVictim_reason != "")
            RemapVote_display = strcat(RemapVote_display, ": ", GetKickVoteVictim_reason);
	}
	else if(argv(0) == "config" || argv(0) == "rmcustom")
	{
		if(!CVAR(sv_rmcustom_votable))
		{
			sprint(e, "This server has disabled rmcustom voting\n");
			return FALSE;
		}
		
		string cfgname = argv(1), strcfgs, tmpname;
		float i, globsize, rmglob = search_begin("rm-custom/*.cfg", FALSE, TRUE);
		globsize = search_getsize(rmglob);
		
		if(globsize <= 0)
		{
			sprint(e, "This server doesn't have any custom configurations\n");
			search_end(rmglob);
			return FALSE;
		}
		
		float v;
		v = CVAR(sv_rmcustom_votable_restrict);
		string r;
		r = CVAR_STR(sv_rmcustom_votable_restrictions);
		
		for(i = 0; i < globsize; ++i)
		{
			tmpname = search_getfilename(rmglob, i);
			tmpname = substring(tmpname, strlen("rm-custom/"), strlen(tmpname));
			tmpname = substring(tmpname, 0, strlen(tmpname) - 4);
			
			// Apply restriction rules
			float restricted;
			switch(v)
			{
				case 0:
					restricted =  FALSE;							break;
				
				case 1:
					restricted = !ListContains(r, tmpname, " ");	break;
				
				case 2:
					restricted =  ListContains(r, tmpname, " ");	break;
			}
			
			if(restricted) continue;
			
			if(tmpname == cfgname)
			{
				RemapVote_vote = strcat("rmcustom ", tmpname); //vote;
				
				float fhandle = fopen(strcat("rm-custom/", cfgname, ".cfg"), FILE_READ);
				
				if(fhandle != -1)
				{
					string fullname;
					fullname = fgets(fhandle);
					fullname = substring(fullname, strlen("//cfgname:"), strlen(fullname));
					
					RemapVote_display = strzone(strcat("^1config ", cfgname, " ^1(^7", fullname, "^1)"));
				}
				else
					RemapVote_display = strzone(strcat("^1config ", cfgname));
				
				search_end(rmglob);
				return TRUE;
			}
			
			strcfgs = strcat(strcfgs, tmpname, " ");
		}
		
		search_end(rmglob);
		sprint(e, strcat("No such config available. Available configurations: ^2", strcfgs, "\n"));
		return FALSE;
	}
	else if(argv(0) == "walpurgis")
	{
		RemapVote_vote = vote;
		RemapVote_display = strzone("^2something terrible");
	}
	else if(argv(0) == "supermentalrescue")
	{
		RemapVote_vote = vote;
		RemapVote_display = strzone("^2something awesome");
	}
	else if(argv(0) == "gotoserver") {
		if(vote_argc < 2) {
			sprint(e, strcat("^1Go to WHICH server? ^1Allowed servers are: ^2", GetAllowedServers(), "\n"));
			return FALSE;
		}
		
		string srv = ResolveServer(argv(1));
		if(!ServerIsAllowed(srv)) {
			sprint(e, strcat("^1Allowed servers are: ^2", GetAllowedServers(), "\n"));
			return FALSE;
		}
		
		string tail;
		if(argv(1) != srv)
			tail = strcat(" (^5", srv, "^1)");
		
		RemapVote_vote = vote;
		RemapVote_display = strzone(strcat("^1", vote, tail));
	} else
	{
		s = NormalizeGametypeName(argv(0));
		
		if(s != "")	// detected a gametype vote
		{
			// Gametype already being played?
			if (s == gametype_ID_to_Name(game))
			{
				sprint (e, strcat ("^1A game of ^2", gametype_Name_to_LongName(s), " ^1is already being played!\n"));
				return FALSE;
			}

			// Gametype overplayed?
			// TODO: Get rid of this, if the gametype is overplayed a gametype voting screen should appear
            if(!e.vote_master)
			if(!CVAR(sv_vote_gametype_overplayed_allowcall))
			if(GameTypeVote_AvailabilityStatus (s) == GTV_OVERPLAYED)
			{
				sprint (e, "^1This gametype is currently overplayed.");
				if (s == "ft")
					sprint (e, " Quit the freezefaggotry.");
				sprint (e, "\n");
				return FALSE;
			}

			// Let's give this another shot
			if (!MapInfo_CheckMap(mapname, gametype_Name_to_MapID(s))) {
				sprint(e, strcat("^1", gametype_Name_to_LongName(s), " is not allowed on the current map\n"));
				return FALSE;
			}
			
			if (! CVAR(sv_vote_gametype_call))
			{
				sprint (e, "^1Gametype voting is not allowed.\n");
				return FALSE;
			}
			RemapVote_vote = s;
			RemapVote_display = strzone(strcat("^1", vote, " ^7(^5", gametype_Name_to_LongName(s), "^7)"));
		}
		else
		{
			RemapVote_vote = vote;
			RemapVote_display = strzone(strcat("^1", vote));
		}
	}

	if(argv(0) == "topic")
	{
		keeptopic = TRUE;
		cvar_set("_sv_explosive_topicby", e.netname);
	}
    
    if(argv(0) == "balanceteams" && teamcount_balancenext) {
        sprint(e, "Team rebalance is already scheduled for the next round.\n");
        return FALSE;
    }
    
	cvar_set ("_sv_rm_lastvote", ftos (time));

	return TRUE;
}

void VoteDialog_UpdateHighlight(float selected) {
	if(msg_entity.classname == "")
		return;
	
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CSQC_VOTE);
	WriteByte(MSG_ONE, 1);
	WriteShort(MSG_ONE, selected);
}

void VoteDialog_Update(float msg, float vyes, float vno, float needed) {
	if(msg_entity.classname == "")
		return;
	
	WriteByte(msg, SVC_TEMPENTITY);
	WriteByte(msg, TE_CSQC_VOTE);
	WriteByte(msg, 0);
	WriteShort(msg, vyes);
	WriteShort(msg, vno);
	WriteShort(msg, needed);
}

void VoteDialog_Reset() {
	entity e;
	FOR_EACH_REALCLIENT(e)
	{
		if(e.classname == "")
			continue;
		
		msg_entity = e;
		WriteByte(MSG_ONE, SVC_TEMPENTITY);
		WriteByte(MSG_ONE, TE_CSQC_VOTERESET);
	}
}

void Vote_SendInvitation(void) {
    WriteByte(MSG_ALL, SVC_TEMPENTITY);
    WriteByte(MSG_ALL, TE_CSQC_VOTEINVITE);
}

float GameCommand_Vote(string s, entity e) {
	float argc;
    string tmp;
	argc = tokenize_console(s);
	if(argv(0) == "help") {
		UnmarkAway(e);
		print_to(e, "  vote COMMANDS ARGUMENTS. See 'vhelp' for more info.");
		return TRUE;
	} else if(argv(0) == "vote") {
		if(e.classname == "")
		{
			sprint(e, "^1You must be connected to use vote commands\n");
			return TRUE;
		}
		
		UnmarkAway(e);
		
		if(argv(1) == "") {
			print_to(e, "^1You have to supply a vote command. See 'vhelp' for more info.");
		} else if(argv(1) == "help") {
			VoteHelp(e);
		} else if(argv(1) == "status") {
			if(votecalled) {
				print_to(e, strcat("^7Vote for ", votecalledvote_display, "^7 called by ^7", VoteNetname(votecaller), "^7."));
			} else {
				print_to(e, "^1No vote called.");
			}
		} else if(argv(1) == "call") {
			if(!e || CVAR(sv_vote_call)) {
				if(CVAR(sv_vote_nospectators) && e && e.classname != "player" && !e.vote_master) {
					print_to(e, "^1Error: Only players can call a vote."); // TODO invent a cvar name for allowing votes by spectators during warmup anyway
				}
				else if(timeoutStatus) { //don't allow a vote call during a timeout
					print_to(e, "^1Error: You can not call a vote while a timeout is active.");
				}
				else if(votecalled) {
					print_to(e, "^1There is already a vote or an invitation called.");
				} else {
					string vote;
					vote = VoteParse(s, argc);
					if(vote == "") {
						print_to(e, "^1Your vote is empty. See 'vhelp' for more info.");
					} else if(vote == "$*") {	// happens on "vcall" without arguments
						stuffcmd(e, "menu_cmd directmenu VcallMenu\n");
					} else if(e && time < e.vote_next && !e.vote_master) {
						print_to(e, strcat("^1You have to wait ^2", ftos(e.vote_next - time), "^1 seconds before you can again call a vote or an invitation."));
					} else if(VoteCheckNasty(vote)) {
						print_to(e, "Syntax error in command. See 'vhelp' for more info.");
					} else if(RemapVote(vote, "vcall", e)) {
						votecalledvote = strzone(RemapVote_vote);
						votecalledvote_display = strzone(RemapVote_display);
						votecalled = TRUE;
						votecalledmaster = FALSE;
						votefinished = time + CVAR(sv_vote_timeout);
                        vote_invite = FALSE;
						votecaller = e; // remember who called the vote
						if(e) {
							e.vote_vote = 1; // of course you vote yes
							e.vote_next = time + CVAR(sv_vote_wait);
						}
                        tmp = strcat("^2* ^3", VoteNetname(votecaller), "^2 calls a vote for ", votecalledvote_display);
						bprint("\{1}", tmp, "\n");
                        IRC_Announce_Vote(tmp);
						if(CVAR(sv_eventlog))
							GameLogEcho(strcat(":vote:vcall:", ftos(votecaller.playerid), ":", votecalledvote_display));
						VoteCount(); // needed if you are the only one
						Nagger_VoteChanged();
						msg_entity = e;
						VoteDialog_UpdateHighlight(1);
					} else {
						print_to(e, "^1This vote is not ok. See 'vhelp' for more info.");
					}
				}
			} else {
				print_to(e, "^1Vote calling is NOT allowed.");
			}
        } else if(argv(1) == "invite") {
            if(!e || e.vote_master || CVAR(sv_vote_invite)) {
                if(timeoutStatus) {
                    print_to(e, "^1Error: You can not call an invitation while a timeout is active.");
                } else if(votecalled) {
                    print_to(e, "^1There is already a vote or an invitation called.");
                } else if(e && time < e.vote_next && !e.vote_master) {
                    print_to(e, strcat("^1You have to wait ^2", ftos(e.vote_next - time), "^1 seconds before you can again call a vote or an invitation."));
                } else {
                    string a = argv(2);
                    string srv = ResolveServer(a);

                    if(srv && !VoteCheckNasty(srv) && ServerIsAllowed(srv)) {
                        votecalledvote = strzone(srv);
                        votecalledvote_display = a;

                        if(a != srv)
                            votecalledvote_display = strcat(votecalledvote_display, " (^5", srv, "^1)");
                        
                        votecalledvote_display = strzone(votecalledvote_display);

                        votecalled = TRUE;
                        votecalledmaster = FALSE;
                        vote_invite = TRUE;
                        votefinished = time + CVAR(sv_vote_invite_timeout);
                        votecaller = e;

                        if(e) {
                            e.vote_next = time + CVAR(sv_vote_wait);
                        }

                        tmp = strcat("^2* ^3", VoteNetname(votecaller), "^2 invites everyone to play on ^1", votecalledvote_display);
                        bprint("\{1}", tmp, "\n");
                        IRC_Announce_Vote(tmp);

                        if(CVAR(sv_eventlog))
                            GameLogEcho(strcat(":vote:invite:", ftos(votecaller.playerid), ":", votecalledvote_display));

                        Vote_SendInvitation();
                        Nagger_VoteChanged();
                    } else {
                        sprint(e, strcat("^1Allowed servers are: ^2", GetAllowedServers(), "\n"));
                    }
                }
            } else {
                print_to(e, "^1Invitations are NOT allowed.");
            }
		} else if(argv(1) == "stop") {
			if(!votecalled) {
				print_to(e, "^1No vote called.");
			} else if(e == votecaller) { // the votecaller can stop a vote
				VoteDialog_Reset();
				VoteStop(e);
			} else if(!e) { // server admin / console can too
				VoteDialog_Reset();
				VoteStop(e);
			} else if(e.vote_master) { // masters can too
				VoteDialog_Reset();
				VoteStop(e);
			} else {
				print_to(e, "^1You are not allowed to stop that Vote.");
			}
		} else if(argv(1) == "master") {
			if(CVAR(sv_vote_master)) {
				if(votecalled) {
					print_to(e, "^1There is already a vote called.");
				} else {
					votecalled = TRUE;
					votecalledmaster = TRUE;
					votecalledvote = strzone("XXX");
					votecalledvote_display = strzone("^3master");
					votefinished = time + CVAR(sv_vote_timeout);
					votecaller = e; // remember who called the vote
					if(e) {
						e.vote_vote = 1; // of course you vote yes
						e.vote_next = time + CVAR(sv_vote_wait);
					}
                    tmp = strcat("^2* ^3", VoteNetname(votecaller), "^2 calls a vote to become ^3master^2");
					bprint("\{1}", tmp, "\n");
                    vote_invite = FALSE;
                    IRC_Announce_Vote(tmp);
					if(CVAR(sv_eventlog))
						GameLogEcho(strcat(":vote:vcall:", ftos(votecaller.playerid), ":", votecalledvote_display));
					VoteCount(); // needed if you are the only one
					Nagger_VoteChanged();
				}
			} else {
				print_to(e, "^1Vote to become master is NOT allowed.");
			}
		} else if(argv(1) == "do") {
			if(!e || e.vote_master) {
				string dovote;
				dovote = VoteParse(s, argc);
				if(dovote == "") {
					print_to(e, "^1Your command was empty. See 'vhelp' for more info.");
				} else if(VoteCheckNasty(dovote)) {
					print_to(e, "Syntax error in command. See 'vhelp' for more info.");
				} else if(RemapVote(dovote, "vdo", e)) { // strcat seems to be necessary
                    tmp = strcat("^2* ^3", VoteNetname(e), "^2 used his ^3", e.vote_mastername, "^2 status to do ^2", RemapVote_display, "^2");
					bprint("\{1}", tmp, "\n");
                    IRC_Announce_Vote(tmp);
					if(CVAR(sv_eventlog))
						GameLogEcho(strcat(":vote:vdo:", ftos(e.playerid), ":", RemapVote_display));
					localcmd(strcat(RemapVote_vote, "\n"));
				} else {
					print_to(e, "^1This command is not ok. See 'vhelp' for more info.");
				}
			} else {
				print_to(e, "^1You are NOT a master.  You might need to login or vote to become master first. See 'vhelp' for more info.");
			}
		} else if(argv(1) == "login") {
            if(!e)
                return TRUE;

            string masterpwd, masterusers, password;
            masterpwd = CVAR_STR(sv_vote_master_password);
            masterusers = CVAR_STR(sv_vote_master_users);
            password = argv(2);

            if(password == "")
                return TRUE;

            if(masterpwd != "" || masterusers != "") {
                if(e.vote_masteruser) {
                    strunzone(e.vote_masteruser);
                    e.vote_masteruser = NULL;
                }

                float granted = (masterpwd == password);

                if(!granted && masterusers != "") {
                    granted = (strstrofs(strcat(" ", masterusers, " "), strcat(" ", password, " "), 0) >= 0);
                    if(granted)
                        e.vote_masteruser = strzone(substring(password, 0, strstrofs(password, ":", 0)));
                }

                e.vote_master = granted;

                if(granted) {
                    string lname;
                    
                    if(argc > 3 && CVAR(sv_vote_master_arbitrary_login))
                        lname = argv(3);
                    else
                        lname = CVAR_STR(sv_vote_master_default_login);
                    
                    if(e) {
                        if(e.vote_mastername) {
                            strunzone(e.vote_mastername);
                            e.vote_mastername = NULL;
                        }
                        e.vote_mastername = strzone(lname);
                    }
                    
                    print("Accepted master login from ", VoteNetname(e), "\n");
                    tmp = strcat("^2* ^3", VoteNetname(e), "^2 logged in as ^3", e.vote_mastername, "^2");
                    bprint("\{1}", tmp, "\n");
                    IRC_Announce_Vote(tmp);
                    if(CVAR(sv_eventlog))
                        GameLogEcho(strcat(":vote:vlogin:", ftos(e.playerid)));
                }
                else
                    print("REJECTED master login from ", VoteNetname(e), "\n");
            }
            else
                print_to(e, "^1Login to become master is NOT allowed.");
		} else if(argv(1) == "yes") {
			if(!votecalled) {
				print_to(e, "^1No vote called.");
			} else if (!e) {
				print_to(e, "^1You can't vote from the server console.");
            } else if(vote_invite) {
                if(!e.vote_vote) {
                    stuffcmd(e, strcat("connect ", votecalledvote ,"\n"));
                    e.vote_vote = 1;
                    Nagger_VoteCountChanged();
                }
			} else if(e.vote_vote == 0
				  || CVAR(sv_vote_change)) {
				
				msg_entity = e;
				VoteDialog_UpdateHighlight(1);
				
				print_to(e, "^1You accepted the vote.");
				if(!CVAR(sv_vote_anonymous)) bprint(strcat("^3", e.netname, "^7 votes ^2YES\n"));
				e.vote_vote = 1;
				centerprint_expire(e, CENTERPRIO_VOTE);
				if(!CVAR(sv_vote_singlecount)) {
					VoteCount();
				}
			} else {
				print_to(e, "^1You have already voted.");
			}
		} else if(argv(1) == "no") {
			if(!votecalled) {
				print_to(e, "^1No vote called.");
			} else if (!e) {
				print_to(e, "^1You can't vote from the server console.");
            } else if(vote_invite) {
                if(!e.vote_vote) {
                    msg_entity = e;
                    e.vote_vote = -1;
                    Nagger_VoteCountChanged();
                }
			} else if(e.vote_vote == 0
				  || CVAR(sv_vote_change)) {
				
				msg_entity = e;
				VoteDialog_UpdateHighlight(2);
				
				print_to(e, "^1You rejected the vote.");
				if(!CVAR(sv_vote_anonymous)) bprint(strcat("^3", e.netname, "^7 votes ^1",
																if(crc16(FALSE, argv(2)) == STUPID_VNO_PASSWORD)
																	GetStupidVNoString() else "NO", "\n"));
				e.vote_vote = -1;
				centerprint_expire(e, CENTERPRIO_VOTE);
				if(!CVAR(sv_vote_singlecount)) {
					VoteCount();
				}
			} else {
				print_to(e, "^1You have already voted.");
			}
		} else if(argv(1) == "abstain" || argv(1) == "dontcare") {
			if(!votecalled) {
				print_to(e, "^1No vote called.");
			} else if (!e) {
				print_to(e, "^1You can't vote from the server console.");
            } else if(vote_invite) {
                if(!e.vote_vote) {
                    msg_entity = e;
                    e.vote_vote = -1;
                    Nagger_VoteCountChanged();
                }
			} else if(e.vote_vote == 0
				  || CVAR(sv_vote_change)) {
				
				msg_entity = e;
				VoteDialog_UpdateHighlight(3);
				
				print_to(e, "^1You abstained from your vote.");
				if(!CVAR(sv_vote_anonymous)) bprint(strcat("^3", e.netname, "^7 abstained his vote\n"));
				e.vote_vote = -2;
				centerprint_expire(e, CENTERPRIO_VOTE);
				if(!CVAR(sv_vote_singlecount)) {
					VoteCount();
				}
			} else {
				print_to(e, "^1You have already voted.");
			}
		} else {
			// ignore this?
			print_to(e, "^1Unknown vote command.");
		}
		return TRUE;
	}
	return FALSE;
}

void VoteHelp(entity e) {
	string vmasterdis;
	if(!CVAR(sv_vote_master)) {
		vmasterdis = " ^1(disabled)";
	}

	string vlogindis;
	if("" == CVAR_STR(sv_vote_master_password) && "" == CVAR_STR(sv_vote_master_users)) {
		vlogindis = " ^1(disabled)";
	}

	string vcalldis;
	if(!CVAR(sv_vote_call)) {
		vcalldis = " ^1(disabled)";
	}

	print_to(e, "^7You can use voting with \"^2cmd vote help^7\" \"^2cmd vote status^7\" \"^2cmd vote call ^3COMMAND ARGUMENTS^7\" \"^2cmd vote stop^7\" \"^2cmd vote master^7\" \"^2cmd vote login^7\" \"^2cmd vote do ^3COMMAND ARGUMENTS^7\" \"^2cmd vote yes^7\" \"^2cmd vote no^7\" \"^2cmd vote abstain^7\" \"^2cmd vote dontcare^7\".");
	print_to(e, "^7Or if your version is up to date you can use these aliases \"^2vhelp^7\" \"^2vstatus^7\" \"^2vcall ^3COMMAND ARGUMENTS^7\" \"^2vstop^7\" \"^2vmaster^7\" \"^2vlogin^7\" \"^2vdo ^3COMMAND ARGUMENTS^7\" \"^2vyes^7\" \"^2vno^7\" \"^2abstain^7\" \"^2vdontcare^7\".");
	print_to(e, "^7\"^2help^7\" shows this info.");
	print_to(e, "^7\"^2status^7\" shows if there is a vote called and who called it.");
	print_to(e, strcat("^7\"^2call^7\" is used to call a vote. See the list of allowed commands.", vcalldis, "^7"));
	print_to(e, "^7\"^2stop^7\" can be used by the vote caller or an admin to stop a vote and maybe correct it.");
	print_to(e, strcat("^7\"^2master^7\" call a vote to become master who can execute commands without a vote", vmasterdis, "^7"));
	print_to(e, strcat("^7\"^2login^7\" login to become master who can execute commands without a vote.", vlogindis, "^7"));
	print_to(e, "^7\"^2do^7\" executes a command if you are a master. See the list of allowed commands.");
	print_to(e, "^7\"^2yes^7\", \"^2no^7\", \"^2abstain^7\" and \"^2dontcare^7\" to make your vote.");
	print_to(e, "^7If enough of the players vote yes the vote is accepted.");
	print_to(e, "^7If enough of the players vote no the vote is rejected.");
	print_to(e, strcat("^7If neither the vote will timeout after ", ftos(CVAR(sv_vote_timeout)), "^7 seconds."));
	print_to(e, "^7You can call a vote for or execute these commands:");
	print_to(e, strcat("^3", GetVoteList_Filtered(e.vote_master, FALSE), "^7and maybe further ^3arguments^7"));
}

string VoteNetname(entity e)
{
	if(e) {
		if(CVAR(sv_vote_showids)){
            if(e.vote_masteruser)
                return strcat(e.netname, " ^6(#", ftos(num_for_edict(e)), " ^5", e.vote_masteruser, "^6)");
			return strcat(e.netname, " ^6(#", ftos(num_for_edict(e)), ")");
		}
		else{
			return e.netname;
		}
	} else {
		if(CVAR_STR(sv_adminnick) != "") {
			return CVAR_STR(sv_adminnick);
		} else {
			return CVAR_STR(hostname);
		}
	}
}

string ValidateMap(string m, entity e)
{
	m = MapInfo_FixName(m);
	if(!m || !ListContains(CVAR_STR(g_maplist), m, " "))
	{
		print_to(e, "This map is not available on this server.");
		return NULL;
	}
	if(!CVAR(sv_vote_override_mostrecent) && !e.vote_master)
		if(Map_IsRecent(m))
		{
			print_to(e, "This server does not allow for recent maps to be played again. Please be patient for some rounds.");
			return NULL;
		}
	if(!MapInfo_CheckMap(m, GameTypeVote_MapIDMask()))
	{
		print_to(e, strcat("^1Invalid mapname, \"^3", m, "^1\" does not support the current game mode."));
		return NULL;
	}
	return m;
}


void VoteThink() {
	if(votefinished > 0) // a vote was called
	if(time > votefinished) // time is up
	{
		VoteCount();
	}
}

string VoteParse(string all, float argc) {
	if(argc < 3)
		return "";
	return substring(all, argv_start_index(2), argv_end_index(-1) - argv_start_index(2));
}

float VoteCommandInList(string votecommand, string list)
{
	string l;
	l = strcat(" ", list, " ");
	
	if(strstrofs(l, strcat(" ", votecommand, " "), 0) >= 0)
		return TRUE;
	
	// if gotomap is allowed, chmap is too, and vice versa
	if(votecommand == "gotomap")
		if(strstrofs(l, " chmap ", 0) >= 0)
			return TRUE;
	if(votecommand == "chmap")
		if(strstrofs(l, " gotomap ", 0) >= 0)
			return TRUE;
	
	return FALSE;
}

float VoteAllowed(entity caller, string votecommand, string cmd) {
	string s;
	
	if(VoteCommandInList(votecommand, GetVoteList(caller.vote_master, (cmd == "vdo"))))
		return TRUE;

	if(CVAR(sv_vote_gametype_call))
	if((s = NormalizeGametypeName(votecommand)) != "")
	if(ListContainsEx(CVAR_STR(sv_vote_gametype_options), s, " ", NormalizeGametypeName))
		return TRUE;			// gametype alias

	return FALSE;
}

void VoteReset() {
	entity player;

	FOR_EACH_CLIENT(player)
	{
		player.vote_vote = 0;
		centerprint_expire(player, CENTERPRIO_VOTE);
	}

	if(votecalled)
	{
		strunzone(votecalledvote);
		strunzone(votecalledvote_display);
	}

	votecalled = FALSE;
	votecalledmaster = FALSE;
	votefinished = 0;
    vote_invite = FALSE;
	Nagger_VoteChanged();
}

void VoteAccept() {
    string tmp = strcat("^2* ^3", VoteNetname(votecaller), "^2's vote for ^1", votecalledvote_display, "^2 was accepted");
	bprint("\{1}", tmp, "\n");
    IRC_Announce_Vote(tmp);
	if(votecalledmaster)
	{
		if(votecaller) {
			votecaller.vote_master = 1;
			string tmpMasterName = CVAR_STR(sv_vote_master_default_login);
			if(votecaller.vote_mastername){
				strunzone(votecaller.vote_mastername);
			}
			votecaller.vote_mastername = strzone(tmpMasterName);
		}
	} else {
		localcmd(strcat(votecalledvote, "\n"));
	}
	if(votecaller) {
		votecaller.vote_next = 0; // people like your votes,
					  // no wait for next vote
	}
	VoteReset();
}

void VoteReject() {
	string tmp = strcat("^2* ^3", VoteNetname(votecaller), "^2's vote for ", votecalledvote_display, "^2 was rejected");
	bprint("\{1}", tmp, "\n");
    IRC_Announce_Vote(tmp);
	VoteReset();
    hack_forcenextmap = FALSE;
}

void VoteTimeout() {
	string tmp = strcat("^2* ^3", VoteNetname(votecaller), "^2's vote for ", votecalledvote_display, "^2 timed out");
	bprint("\{1}", tmp, "\n");
    IRC_Announce_Vote(tmp);
	VoteReset();
    hack_forcenextmap = FALSE;
}

void VoteStop(entity stopper) {
	string tmp = strcat("^2* ^3", VoteNetname(stopper), "^2 stopped ^3", VoteNetname(votecaller), "^2's vote");
	bprint("\{1}", tmp, "\n");
    IRC_Announce_Vote(tmp);
	if(CVAR(sv_eventlog))
		GameLogEcho(strcat(":vote:vstop:", ftos(stopper.playerid)));
	if(stopper == votecaller) {
		// no wait for next vote so you can correct your vote
		if(votecaller) {
			votecaller.vote_next = time + CVAR(sv_vote_stop);
		}
	}
	VoteReset();
    hack_forcenextmap = FALSE;
}

void VoteSpam(float yescount, float nocount, float abstaincount, float notvoters, float mincount, string result)
{
	string s;
	if(mincount >= 0)
	{
		s = strcat("\{1}^2* vote results: ^1", ftos(yescount), "^2:^1");
		s = strcat(s, ftos(nocount), "^2 (^1");
		s = strcat(s, ftos(mincount), "^2 needed), ^1");
		s = strcat(s, ftos(abstaincount), "^2 didn't care, ^1");
		s = strcat(s, ftos(notvoters), "^2 didn't vote\n");
	}
	else
	{
		s = strcat("\{1}^2* vote results: ^1", ftos(yescount), "^2:^1");
		s = strcat(s, ftos(nocount), "^2, ^1");
		s = strcat(s, ftos(abstaincount), "^2 didn't care, ^1");
		s = strcat(s, ftos(notvoters), "^2 didn't have to vote\n");
	}
	bprint(s);
    IRC_Announce_Vote(substring(s, 1, strlen(s) - 2));
	if(CVAR(sv_eventlog))
	{
		s = strcat(":vote:v", result, ":", ftos(yescount));
		s = strcat(s, ":", ftos(nocount));
		s = strcat(s, ":", ftos(abstaincount));
		s = strcat(s, ":", ftos(notvoters));
		s = strcat(s, ":", ftos(mincount));
		GameLogEcho(s);
	}
}

void VoteCount() {
	float playercount;
	playercount = 0;
	float yescount;
	yescount = 0;
	float nocount;
	nocount = 0;
	float abstaincount;
	abstaincount = 0;
	entity player;
	//same for real players
	float realplayercount;
	float realplayeryescount;
	float realplayernocount;
	float realplayerabstaincount;
	realplayercount = realplayernocount = realplayerabstaincount = realplayeryescount = 0;

    if(vote_invite) {
        if(time > votefinished) {
            string tmp = strcat("^2* ^3", VoteNetname(votecaller), "^2's invitation timed out");
            bprint("\{1}", tmp, "\n");
            IRC_Announce_Vote(tmp);
            VoteReset();
            VoteDialog_Reset();
        }

        return;
    }

	FOR_EACH_REALCLIENT(player)
	{
		if(player.is_away)
			continue;
		
		if(player.vote_vote == -1) {
			++nocount;
		} else if(player.vote_vote == 1) {
			++yescount;
		} else if(player.vote_vote == -2) {
			++abstaincount;
		}
		++playercount;
		//do the same for real players
		if(player.classname == "player") {
			if(player.vote_vote == -1) {
				++realplayernocount;
			} else if(player.vote_vote == 1) {
				++realplayeryescount;
			} else if(player.vote_vote == -2) {
				++realplayerabstaincount;
			}
			++realplayercount;
		}
	}

	//in tournament mode, if we have at least one player then don't make the vote dependent on spectators (so specs don't have to press F1)
	if(CVAR(sv_vote_nospectators))
	if(realplayercount > 0) {
		yescount = realplayeryescount;
		nocount = realplayernocount;
		abstaincount = realplayerabstaincount;
		playercount = realplayercount;
	}
	
	//abstaincount += CountAFKClients();

	float votefactor, simplevotefactor;
	votefactor = bound(0.5, CVAR(sv_vote_majority_factor), 0.999);
	simplevotefactor = CVAR(sv_vote_simple_majority_factor);
	float needed;
	needed = floor((playercount - abstaincount) * max(votefactor, simplevotefactor)) + 1;
	//VoteDialog_Update(MSG_ALL, yescount, nocount, needed);
	
	entity _e;
	FOR_EACH_REALCLIENT(_e) if(_e.classname != "")
	{
		msg_entity = _e;
		VoteDialog_Update(MSG_ONE, yescount, nocount, needed);
	}

	if(votecalledmaster
	   && playercount == 1) {
		// if only one player is on the server becoming vote
		// master is not allowed.  This could be used for
		// trolling or worse. 'self' is the user who has
		// called the vote because this function is called
		// by SV_ParseClientCommand. Maybe all voting should
		// be disabled for a single player?
		print_to(votecaller, "^1You are the only player on this server so you can not become vote master.");
		if(votecaller) {
			votecaller.vote_next = 0;
		}
		VoteReset();
	} else {
		if(yescount > (playercount - abstaincount) * votefactor)
		{
			VoteSpam(yescount, nocount, abstaincount, playercount - yescount - nocount - abstaincount, -1, "yes");
			VoteAccept();
			VoteDialog_Reset();
		}
		else if(nocount >= (playercount - abstaincount) * (1 - votefactor)) // that means, yescount cannot reach minyes any more
		{
			VoteSpam(yescount, nocount, abstaincount, playercount - yescount - nocount - abstaincount, -1, "no");
			VoteReject();
			VoteDialog_Reset();
		}
		else if(time > votefinished)
		{
			if(simplevotefactor)
			{
				string result;
				simplevotefactor = bound(votefactor, simplevotefactor, 0.999);
				if(yescount > (yescount + nocount) * simplevotefactor)
					result = "yes";
				else if(yescount + nocount > 0)
					result = "no";
				else
					result = "timeout";
				VoteSpam(yescount, nocount, abstaincount, playercount - yescount - nocount - abstaincount, floor(min((playercount - abstaincount) * votefactor, (yescount + nocount) * simplevotefactor)) + 1, result);
				if(result == "yes")
					VoteAccept();
				else if(result == "no")
					VoteReject();
				else
					VoteTimeout();
			}
			else
			{
				VoteSpam(yescount, nocount, abstaincount, playercount - yescount - nocount - abstaincount, floor((playercount - abstaincount) * votefactor) + 1, "timeout");
				VoteTimeout();
			}

            VoteDialog_Reset();
		}
	}

	Nagger_VoteCountChanged();
}
