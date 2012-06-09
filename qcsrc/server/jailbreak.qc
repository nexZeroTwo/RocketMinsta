
//
//	Initialization
//

void JB_Init() {
	if(inWarmupStage)
		warmup = time;
	else
		warmup = time + cvar("g_start_delay");
	
	precache_sound("ctf/red_capture.wav");
	precache_sound("ctf/blue_capture.wav");
	
	entity e = spawn();
	e.classname = "jailbreak_logic";
	e.think = JB_Frame;
	e.nextthink = time;
}

void JB_Log(string s) {
	bprint(strcat("Jailbreak: ", s, "\n"));
}

//
//	Gametype logic
//

void JB_Frame() {
	JB_CountPlayers();
	self.nextthink = time + 0.1;
}

void JB_Imprison(entity attacker) {
	float et;
	
	if(self.jb_isprisoned) {
		JB_Log(strcat("Tried to imprison a prisoned player (", self.netname, ")"));
		return;
	}
	
	JB_Log(strcat("Imprisoning ", self.netname, "^7, attacker: ", etos(attacker), " with netname: ", attacker.netname));
	
	if(attacker && attacker.team != self.team)
		et = attacker.team;
	else
		et = JB_GetEnemyTeamOf(self.team);
	
	entity spot = JB_ChooseJailSpawnpoint(et);
	self.origin = spot.origin;
	setorigin(self, self.origin);
	self.angles = spot.angles;
	self.angles_z = 0; // never spawn tilted even if the spot says to
	self.fixangle = TRUE; // turn this way immediately
	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';
	self.punchangle = '0 0 0';
	self.punchvector = '0 0 0';
	self.oldvelocity = self.velocity;
	
	self.jb_isprisoned = TRUE;
	self.jb_prisontime = time;
	bigprint_spec(self, "you're in a jail, prisoner!", ((attacker && attacker != self)? strcat("You've been imprisoned by ^3", attacker.netname) : ""), 10);
	
	if(g_handgrenades) {
		self.hg_ammo = 0;
		self.hg_bonus = 0;
	}
	
	JB_CountPlayers();
}

void JB_ImprisonLater_Think() {
	entity oldself = self, attacker = self.jb_prisoned_by;
	self = self.enemy;
	JB_Imprison(attacker);
	self = oldself;
	remove(self);
}

// Imprison in the next frame
void JB_ImprisonLater(entity attacker) {
	entity e = spawn();
	e.jb_prisoned_by = attacker;
	e.enemy = self;
	e.think = JB_ImprisonLater_Think;
	e.nextthink = time;
}

void JB_Release(entity saviour) {
	if(!self.jb_isprisoned) {
		JB_Log(strcat("Tried to release a free player (", self.netname, ")"));
		return;
	}
	
	self.jb_isprisoned = FALSE;
	bprint(self.netname, "^3 has broken free!\n");
	
	if(g_handgrenades)
		HG_PlayerSpawn();
	
	JB_CountPlayers();
}

void JB_TeamWins(float theteam) {
	string teamname, teamname_full;
	
	switch(theteam) {
		case COLOR_TEAM1:	teamname = "^1red";		play2all("ctf/red_capture.wav");	break;
		case COLOR_TEAM2:	teamname = "^2blue";	play2all("ctf/blue_capture.wav");	break;
	}
	
	teamname_full = ColoredTeamName(theteam);
	
	entity e; FOR_EACH_PLAYER(e) {
		bigprint_spec(e, strcat(teamname, "^7scores!"), "All opponents are imprisoned", 5);
		
		if(e.team == theteam)
			hudflash_teamcolor_default_spec(e);
	}
	
	bprint(teamname_full, "^5 wins the round since all their opponents are in a jail\n");
	TeamScore_AddToTeam(theteam, ST_SCORE, +1);
	
	JB_EndRound();
}

void JB_CountPlayers() {
	entity p;
	
	jb_totalred = jb_totalblue = totalalive = redalive = bluealive = 0;
	
	FOR_EACH_PLAYER(p) { 
		switch(p.team) {
			case COLOR_TEAM1:	jb_totalred++;		break;
			case COLOR_TEAM2:	jb_totalblue++;		break;
		}
		
		if(!p.jb_isprisoned && p.health > 0) {
			totalalive++;
			
			switch(p.team) {
				case COLOR_TEAM1:	redalive++; 	break;
				case COLOR_TEAM2:	bluealive++; 	break;
			}
		}
	}
	
	FOR_EACH_REALCLIENT(p) {
		p.redalive_stat = redalive;
		p.bluealive_stat = bluealive;
	}
	
	DEPENDON(JB_GAME_ACTIVE)
	
	if(jb_totalred < 1 || jb_totalblue < 1)
		return;
	
	if(!redalive)
		JB_TeamWins(COLOR_TEAM2);
	else if(!bluealive)
		JB_TeamWins(COLOR_TEAM1);
}

//
//	Callbacks
//

float JB_PlayerDies() {
	DEPENDON_F(g_jailbreak && JB_GAME_ACTIVE, 0)
	
	if(!self.jb_isprisoned) {
		self.health = 100;
		JB_ImprisonLater(frag_attacker);
	} else {
		JB_Log(strcat("Prisoned player ", self.netname, " ^7just died. Should this really happen?"));
		PutClientInServer();
	}
	
	return 1;
}

void JB_PlayerSpawn() {
	DEPENDON(g_jailbreak)
	
	self.jb_isprisoned = FALSE;
	DEPENDON(JB_GAME_ACTIVE)
	
	if(JB_TotalPlayersOnTeam(self.team))	// allow to spawn non-prisoned if there are no players on that team
		JB_Imprison(world);
}

void JB_RemovePlayer() {
	DEPENDON(g_jailbreak)
	
	if(self.jb_isprisoned)
		JB_Release(world);
}

void JB_PlayerPreThink() {
	DEPENDON(g_jailbreak && JB_GAME_ACTIVE)
	
	if not(self.jb_isprisoned)
		return;
		
	if(time - self.jb_prisontime < 1)
		return;
	
	if(time - self.jb_jail_lasttouch >= max(0.1, frametime))
		JB_Release(self.jb_saviour);
}

//
//	Round logic
//	TODO: Generalize this, also see freezetag.qc and domination.qc
//

void JB_EndRound_Think()
{
	local float timeleft = rint(self.cnt - time);
	local entity e;
	
	if(intermission_running)
	{
		remove(self);
		return;
	}
	
	JB_CountPlayers();
	
	if(timeleft <= cvar("g_explosive_jailbreak_warmup"))
	{
		if(timeleft <= 0)
		{
			FOR_EACH_PLAYER(e)
			{
				bigprint_clear_spec(e);
				bigprint_spec(e, "^5Begin!", "", 1);
				jb_roundover = FALSE;
				defer(0.1, JB_CountPlayers);
			}
			
			remove(self);
			shooting_forbidden = FALSE;
			return;
		}
		
		shooting_forbidden = TRUE;
		FOR_EACH_PLAYER(e)
		{
			bigprint_clear_spec(e);
			bigprint_spec(e, strcat("jailbreak starts in: ", ftos(timeleft)), "", 1);
		}
	}
	self.nextthink = time + 1;
}

void JB_EndRound()
{
	local entity e = spawn();
	e.think = JB_EndRound_Think;
	e.nextthink = time + 1;
	next_round = time + 5;
	e.cnt = cvar("g_explosive_jailbreak_warmup") + next_round;
	jb_roundover = TRUE;
	JB_CountPlayers();
}

//
//	Utility functions
//

entity JB_ChooseJailSpawnpoint(float theteam) {
	entity spot;
	
	RandomSelection_Init();
	for(;spot = find(spot, classname, "info_jailbreak_jailspawn");) if(spot.team == theteam) {
		RandomSelection_Add(spot, 0, string_null, 1, 1);
	}
	
	spot = RandomSelection_chosen_ent;
	if(!spot)
		JB_Log(strcat("JB_ChooseJailSpawnpoint(", ftos(theteam), ") failed!"));
	
	return spot;
}

float JB_GetEnemyTeamOf(float t) {
	return ((t == COLOR_TEAM1)? COLOR_TEAM2 : COLOR_TEAM1);
}

float JB_TotalPlayersOnTeam(float theteam) {
	JB_CountPlayers();	// just in case ;)
	
	switch(theteam) {
		case COLOR_TEAM1: return jb_totalred;
		case COLOR_TEAM2: return jb_totalblue;
	}
	
	return -1;	// wtf? wrong team dude.
}

//
//	Setup functions
//

void JB_SetupJailSpawnpoint() {
	self.classname = "info_jailbreak_jailspawn";
	bprint("JB_SetupJailSpawn() for team ", ftos(self.team), " at ", vtos(self.origin), "\n");
}

void JB_Jail_Touch() {
	//JB_Log(strcat(other.netname, "^7 is in the ", ColoredTeamName(self.team), " ^7jail"));
	
	if(other.classname != "player")
		return;
	
	if not(other.jb_isprisoned) {
		other.velocity = other.velocity * -1.5;
		return;
	}
	
	if(other.team == self.team)
		return;
	
	other.jb_jail_lasttouch = time;
}

void JB_SetupJail() {
	if not(g_jailbreak)
		remove(self);
	
	self.classname = "func_jailbreak_jail";
	self.touch = JB_Jail_Touch;
	EXACTTRIGGER_INIT;
}

//
//	Spawn functions
//

void spawnfunc_info_jailbreak_jailspawn_red() {
	self.team = COLOR_TEAM1;
	JB_SetupJailSpawnpoint();
}

void spawnfunc_info_jailbreak_jailspawn_blue() {
	self.team = COLOR_TEAM2;
	JB_SetupJailSpawnpoint();
}

void spawnfunc_func_jailbreak_jail_red() {
	self.team = COLOR_TEAM1;
	JB_SetupJail();
}

void spawnfunc_func_jailbreak_jail_blue() {
	self.team = COLOR_TEAM2;
	JB_SetupJail();
}
