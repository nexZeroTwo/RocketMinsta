
float TeamCount_TotalTeams(void) {
    float i;
    if(c1 >= 0) ++i;
    if(c2 >= 0) ++i;
    if(c3 >= 0) ++i;
    if(c4 >= 0) ++i;
    return i;
}

void TeamCount_RecountPlayers(float(entity) alivecheck) {
    float i;
    float nteams;
    entity e;
    
    nteams = TeamCount_TotalTeams();
    
    for(i = 0; i < 4; ++i) {
        teamcount_playersalive[i] = 0;
        teamcount_playerstotal[i] = 0;
    }
    
    FOR_EACH_PLAYER(e) {
        float idx = Team_Index(e.team);
        float fteqcc_sucks;
        
        fteqcc_sucks = teamcount_playerstotal[idx];
        teamcount_playerstotal[idx] = fteqcc_sucks + 1;
        
        if(alivecheck(e)) {
            fteqcc_sucks = teamcount_playersalive[idx];
            teamcount_playersalive[idx] = fteqcc_sucks + 1;
        }
    }
    
    FOR_EACH_REALCLIENT(e) {
        e.redalive_stat     = teamcount_playersalive[0];
        e.bluealive_stat    = teamcount_playersalive[1];
        e.yellowalive_stat  = ((nteams > 2)? teamcount_playersalive[2] : -1);
        e.pinkalive_stat    = ((nteams > 3)? teamcount_playersalive[3] : -1);
    }
}

float TeamCount_AliveCheck_Null(entity e) {
    return TRUE;
}
