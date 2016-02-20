
float ca_recount;

void CA_Frame(void) {
    self.nextthink = time;
    if(ca_recount) {
        TeamCount_RecountPlayers(CA_AliveCheck);
        CA_CheckWinner();
        ca_recount = FALSE;
    }
}

void CA_Initialize(void) {
    ca_teams = bound(2, CVAR(g_clanarena_teams), 4);
    
    addstat(STAT_REDALIVE, AS_INT, redalive_stat);
    addstat(STAT_BLUEALIVE, AS_INT, bluealive_stat);
    addstat(STAT_YELLOWALIVE, AS_INT, yellowalive_stat);
    addstat(STAT_PINKALIVE, AS_INT, pinkalive_stat);
    
    precache_sound("ctf/red_capture.wav");
    precache_sound("ctf/blue_capture.wav");
    precache_sound("kh/capture.wav");
    
    g_clanarena_pickups = CVAR(g_clanarena_pickups);
    
    if(inWarmupStage)
        warmup = time;
    else
        warmup = time + CVAR(g_start_delay);
    
    entity ca = spawn();
    ca.think = CA_Frame;
    ca.nextthink = time;
    
    sv_nicehealth = CVAR(g_clanarena_start_health) + CVAR(g_clanarena_start_armor);
}

float CA_AliveCheck(entity plr) {
    return plr.health > 0;
}

void CA_EndRound(float tout) {
    G_EndRound(tout, CVAR(g_clanarena_warmup), CA_RecountPlayers, NULL, CA_BeginRound);
    CA_RecountPlayers();
}

void CA_RecountPlayers(void) {
    ca_recount = TRUE;
}

void CA_CheckWinner(void) {
    /*
     * XXX: this is mostly copypaste from Freezetag_CheckWinner, it need to be generalized somehow
     */
    
    string teamname, teamname_full;
    float winnerteam, i, teams_found, alivefound;
    entity e;
    
    if(roundstate != ROUNDSTATE_GAME)
        return;
    
    for(i = 0; i < ca_teams; ++i) {
        if(teamcount_playerstotal[i]) {
            if(teamcount_playersalive[i]) {
                alivefound = TRUE;
                if(!winnerteam)
                    winnerteam = Team_FromIndex(i);
                else
                    return;
            }
            
            ++teams_found;
        }
    }
    
    if((!winnerteam && alivefound) || teams_found < 2)
        return;
    
    if(winnerteam == COLOR_TEAM1) {
        teamname = "^1Red";
        teamname_full = "^1Red team";
        if(ft_teams < 3) play2all("ctf/red_capture.wav");
    } else if(winnerteam == COLOR_TEAM2) {
        teamname = "^4Blue";
        teamname_full = "^4Blue team";
        if(ft_teams < 3) play2all("ctf/blue_capture.wav");
    } else if(winnerteam == COLOR_TEAM3) {
        teamname = "^3Yellow";
        teamname_full = "^3Yellow team";
    } else if(winnerteam == COLOR_TEAM4) {
        teamname = "^6Pink";
        teamname_full = "^6Pink team";
    } else {
        FOR_EACH_PLAYER(e)
            bigprint_spec(e, "Round Draw!", "", 5);
        CA_EndRound(ENDROUND_TIMEOUT_NORMAL);
        return;
    }
    
    if(ft_teams > 2)
        play2all("kh/capture.wav");
    
    FOR_EACH_PLAYER(e) {
        bigprint_spec(e, strcat(teamname, " ^7Scores!"), "All opponents are down", 5);
        
        if(e.team == winnerteam)
            hudflash_teamcolor_default_spec(e);
    }
    
    bprint(teamname_full, "^5 wins the round since all their opponents got wrecked\n");
    TeamScore_AddToTeam(winnerteam, ST_SCORE, +1);
    
    CA_EndRound(ENDROUND_TIMEOUT_NORMAL);
}

float CA_Assert(float f, string errmsg) {
    if(f)
        return FALSE;

    backtrace("assertion failed");
    bprint("^1CA BUG: ^3", errmsg, "\n");

    CA_RecountPlayers();
    return TRUE;
}

void CA_PlayerDies(entity attacker) {
    if(!g_clanarena)
        return;
    
    if(roundstate != ROUNDSTATE_GAME)
        return;
    
    if(attacker.classname == "player") {
        if(CA_Assert(attacker.scorekeeper != world, "attacker has no scorekeeper"))
            return;

        if(self == attacker) {
        } else if(self.team == attacker.team) {
            PlayerScore_Add(attacker, SP_SCORE, -CVAR(g_clanarena_penalty_teamkill));
        } else {
            PlayerScore_Add(attacker, SP_SCORE,  CVAR(g_clanarena_score_kill));
        }
    }

    if(CA_Assert(self.scorekeeper != world, "self has no scorekeeper"))
        return;

    PlayerScore_Add(self, SP_SCORE, -CVAR(g_clanarena_penalty_death));
    PlayerScore_SetFlags(self, SPFLAG_FROZEN);
    
    AloneWarning(self.team, CA_AliveCheck);
    CA_RecountPlayers();
}

void CA_PlayerLeaves(void) {
    if(g_clanarena)
        CA_RecountPlayers();
}

void CA_PlayerJoins(void) {
    if(g_clanarena)
        CA_RecountPlayers();
}

float CA_AttemptRespawn(void) {
    if(!g_clanarena)
        return FALSE;
    
    if(roundstate == ROUNDSTATE_GAME) {
        if(self.clientcamera == self)
            PlayerSpectatorStart();
        return TRUE;
    }

    if(roundstate == ROUNDSTATE_OVER)
        return TRUE;
        
    return FALSE;
}

void CA_BeginRound(void) {
    if(!g_clanarena)
        return;

    if(CVAR(g_clanarena_imbalance_compensation)) {
        TeamCount_RecountPlayers(CA_AliveCheck);

        var maxplrs = teamcount_playersalive[0], e;
        for(var t = 1; t < 4; ++t) {
            if(teamcount_playersalive[t] > maxplrs)
                maxplrs = teamcount_playersalive[t];
        }

        FOR_EACH_PLAYER(e) {
            var tidx = Team_Index(e.team);

            if(tidx < 0)
                continue;

            var present = teamcount_playersalive[tidx];
            var missing = maxplrs - present;

            if(missing) {
                var fract = missing / present;
                e.health = e.health + start_health * fract;
                e.armorvalue = e.armorvalue + start_armorvalue * fract;
            }
        }
    }
}
