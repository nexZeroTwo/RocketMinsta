
//
//	Initialization
//

void JB_Init() {
	
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
	
	DEPENDON(JB_GAME_ACTIVE)
	// TODO: Check for virtory here
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
