
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
	
	JB_CountPlayers();
}

void JB_Log(string s) {
	bprint(strcat("Jailbreak: ", s, "\n"));
}

//
//	Gametype logic
//

void JB_Imprison(entity attacker) {
	float et;
	
	if(self.jb_isprisoned) {
		JB_Log(strcat("Tried to imprison a prisoned player (", self.netname, ")"));
		return;
	}
	
	JB_Log(strcat("Imprisoning ", self.netname, "^7, attacker: ", etos(attacker), " with netname: ", attacker.netname));
	
	if(attacker)
		et = attacker.team;
	else
		et = JB_GetEnemyTeamOf(self.team);
	
	entity spot = JB_ChooseJailSpawnpoint(et);
	setorigin(self, spot.origin);
	self.angles = spot.angles;
	self.angles_z = 0; // never spawn tilted even if the spot says to
	self.fixangle = TRUE; // turn this way immediately
	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';
	self.punchangle = '0 0 0';
	self.punchvector = '0 0 0';
	self.oldvelocity = self.velocity;
	
	self.jb_isprisoned = TRUE;
	bigprint_spec(self, "you're in a jail, prisoner!", (attacker? strcat("You've been imprisoned by ^3", attacker.netname) : ""), 10);
	
	if(g_handgrenades) {
		self.hg_ammo = 0;
		self.hg_bonus = 0;
	}
	
	JB_CountPlayers();
}

void JB_Release(entity saviour) {
	if(!self.jb_isprisoned) {
		JB_Log(strcat("Tried to release a free player (", self.netname, ")"));
		return;
	}
	
	self.jb_isprisoned = FALSE;
	
	if(g_handgrenades)
		HG_PlayerSpawn();
	
	JB_CountPlayers();
}

void JB_CountPlayers() {
	entity p;
	
	totalalive = redalive = bluealive = yellowalive = pinkalive = 0;
	
	FOR_EACH_PLAYER(p) if(!p.jb_isprisoned && p.health > 0) {
		totalalive++;
		
		switch(p.team) {
			case COLOR_TEAM1:	redalive++; 	break;
			case COLOR_TEAM2:	bluealive++; 	break;
			case COLOR_TEAM3:	yellowalive++;	break;
			case COLOR_TEAM4:	pinkalive++;	break;
		}
	}
	
	FOR_EACH_REALCLIENT(p) {
		p.redalive_stat = redalive;
		p.bluealive_stat = bluealive;
	}
	
	DEPENDON(JB_GAME_ACTIVE)
	// TODO: Check for victory here
}

//
//	Callbacks
//

float JB_PlayerDies() {
	DEPENDON_F(g_jailbreak && JB_GAME_ACTIVE, 0)
	
	if(!self.jb_isprisoned) {
		self.health = 100;
		JB_Imprison(frag_attacker);
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
	JB_Imprison(world);
}

void JB_RemovePlayer() {
	DEPENDON(g_jailbreak && JB_GAME_ACTIVE)
	JB_Release(world);
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

void JB_SetupJailSpawnpoint() {
	self.classname = "info_jailbreak_jailspawn";
	bprint("JB_SetupJailSpawn() for team ", ftos(self.team), " at ", vtos(self.origin), "\n");
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
