
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
	precache_sound("kh/alarm.wav");
	
	ScoreRules_JB();
	JB_Torture_RegisterAll();
	
	entity e = spawn();
	e.classname = "jailbreak_logic";
	e.think = JB_Frame;
	e.nextthink = time;
}

void JB_Log(string s) {
	print(strcat("Jailbreak: ", s, "\n"));
}

void JB_BLog(string s) {
	bprint(strcat("Jailbreak: ", s, "\n"));
}

//
//	Gametype logic
//

void JB_Frame() {
	JB_CountPlayers();
	self.nextthink = time + 0.1;
}

void TeleportPlayer(entity teleporter, entity player, vector to, vector to_angles, vector to_velocity, vector telefragmin, vector telefragmax);
void JB_Imprison(entity attacker) {
	float et;
	
	if(self.jb_isprisoned) {
		JB_Log(strcat("Tried to imprison a prisoned player (", self.netname, ")"));
		return;
	}
	
	attacker.jb_fragrow += 1;
	
	if(attacker.classname == "player")
	if(cvar("g_explosive_jailbreak_frag_bonusgrenade"))
	if(attacker.jb_fragrow >= cvar("g_explosive_jailbreak_frag_bonusgrenade_requirement")) {
		HG_GiveBonus(attacker, HG_NameToType(cvar_string("g_explosive_jailbreak_frag_bonusgrenade_type")), 1,
							   strcat(ftos(attacker.jb_fragrow), " frags in a row")
		);
		attacker.jb_fragrow = 0;
	}
	
	JB_Log(strcat("Imprisoning ", self.netname, "^7, attacker: ", etos(attacker), " with netname: ", attacker.netname));
	
	if(attacker && attacker.team && attacker.team != self.team)
		et = attacker.team;
	else
		et = JB_GetEnemyTeamOf(self.team);
	
	entity spot = JB_ChooseJailSpawnpoint(et);
	
	float tries;
	tries = 3;
	
	while(!spot && tries) {
		spot = JB_ChooseJailSpawnpoint(et);
		tries--;
	}
	
	if(!spot) {
		JB_BLog(strcat("Failed to pick a jail spawnpoint for ", self.netname, "^7, cannot imprison!"));
		return;
	}
	
	//self.origin = spot.origin;
	//setorigin(self, self.origin);
	
	entity oldself = self;
	self = spot;
	TeleportPlayer(spot, oldself, spot.origin, spot.angles, '0 0 0', '0 0 0', '0 0 0');
	self = oldself;
	
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
	
	if(self.scorekeeper) {
		self.scorekeeper.SendFlags |= pow(2, SP_FREEZETAG_FROZENSTATUS);
		self.scorekeeper.(scores[SP_FREEZETAG_FROZENSTATUS]) = 1;
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

void JB_TorturePrisonersLater_Think() {
	JB_TorturePrisoners(self.team);
	remove(self);
}

void JB_TorturePrisonersLater(float theteam, float thedelay) {
	entity e = spawn();
	e.team = theteam;
	e.think = JB_TorturePrisonersLater_Think;
	e.nextthink = time + thedelay;
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
	
	if(self.scorekeeper) {
		self.scorekeeper.SendFlags |= pow(2, SP_FREEZETAG_FROZENSTATUS);
		self.scorekeeper.(scores[SP_FREEZETAG_FROZENSTATUS]) = 0;
	}
	
	JB_CountPlayers();
}

void JB_TeamWins(float theteam) {
	string teamname, teamname_full;
	
	switch(theteam) {
		case COLOR_TEAM1:	teamname = "^1red";		play2all("ctf/red_capture.wav");	break;
		case COLOR_TEAM2:	teamname = "^4blue";	play2all("ctf/blue_capture.wav");	break;
	}
	
	teamname_full = ColoredTeamName(theteam);
	
	entity e; FOR_EACH_PLAYER(e) {
		bigprint_spec(e, strcat(teamname, "^7scores!"), "All opponents are imprisoned", 15);
		
		if(e.team == theteam)
			hudflash_teamcolor_default_spec(e);
	}
	
	bprint(teamname_full, "^5 wins the round since all their opponents are in a jail\n");
	TeamScore_AddToTeam(theteam, ST_SCORE, +1);
	
	JB_ActivateCamera(theteam, 15);
	JB_TorturePrisonersLater(theteam, 3);
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

void JB_TorturePrisoners(float theteam) {
	entity spot;
	
	for(;(spot = find(spot, classname, "info_jailbreak_torturespawn"));)
		if(spot.team == theteam)
			JB_Torture_Start(spot);
}

//
//	Torture logic
//

#define JITTER(v,j) (v) + (j) * 2 * (random() - 0.5)

jb_torture_logic JB_Torture_PickFunction() {
	entity e;
	
	RandomSelection_Init();
	for(;(e = find(e, classname, "jailbreak_torture_logic"));)
		RandomSelection_Add(e, 0, string_null, 1, 1);
	return RandomSelection_chosen_ent.use;
}

void JB_Torture_Think() {
	makevectors(self.angles);
	//self.nextthink = time + JITTER(self.jb_torture_delay, self.jb_torture_delay_jitter);
	
	float j = self.jb_torture_delay - JITTER(self.jb_torture_delay, self.jb_torture_delay_jitter);
	
	if(j > 0)
		j = 0.5 * j;
	
	self.nextthink = time + max(0.1, self.jb_torture_delay + j);
	self.jb_torture_suggestedforce = JITTER(self.jb_torture_force, self.jb_torture_force_jitter);
	
	var jb_torture_logic logic;
	logic = JB_Torture_PickFunction();
	
	if(!logic) {
		JB_Log("Failed to pick torture logic!");
		remove(self);
		return;
	}
	
	logic();
}

void JB_Torture_Start(entity spot) {
	entity e = spawn();
	e.classname = "jailbreak_torture";
	e.reset = SUB_Remove;
	e.reset2 = e.reset;
	e.think = JB_Torture_Think;
	e.angles = spot.angles;
	e.jb_torture_delay = spot.jb_torture_delay;
	e.jb_torture_delay_jitter = spot.jb_torture_delay_jitter;
	e.jb_torture_force = spot.jb_torture_force;
	e.jb_torture_force_jitter = spot.jb_torture_force_jitter;
	e.owner = spot;
	setorigin(e, spot.origin);
	e.nextthink = time + JITTER(0, e.jb_torture_delay_jitter);
}

void JB_Torture_Register(jb_torture_logic logic) {
	entity e = spawn();
	e.classname = "jailbreak_torture_logic";
	e.use = logic;
}

void W_Firemine_Touch();
void HG_Napalm_Think();
.float pushltime;
void W_SetupProjectileVelocity(entity);

void JB_Torture_Napalm() {
	local entity proj;
	local vector kick;

	proj = spawn ();
	proj.owner = self;
	proj.classname = "jb_torture_napalm";
	proj.movetype = MOVETYPE_BOUNCE;
	proj.projectiledeathtype = DEATH_HG_NAPALM;
	proj.touch = W_Firemine_Touch;
	PROJECTILE_MAKETRIGGER(proj);
	setsize (proj, '0 0 0', '0 0 0');
	setorigin (proj, self.origin);
	proj.org_explosion = self.origin;
	proj.think = HG_Napalm_Think;
	proj.nextthink = time;
	proj.damageforcescale = 1;
	kick_z = self.jb_torture_suggestedforce;
	kick_x = (random () - 0.5) * 2 * kick_z;
	kick_y = (random () - 0.5) * 2 * kick_z;
	proj.velocity = kick;
	proj.pushltime = time + 3;
	W_SetupProjectileVelocity(proj);

	proj.angles = vectoangles(proj.velocity);
	proj.flags = FL_PROJECTILE;

	CSQCProjectile(proj, TRUE, PROJECTILE_FIREMINE, TRUE);
}

void W_Electro_Attack();
void W_Electro_Attack2();
void W_Crylink_Attack();
void W_Crylink_Attack2();

void JB_Torture_Plasma() {
	float i;
	
	vector oldangles = self.angles;
	for(i = 0; i < 4; ++i) {
		self.angles_y -= 30 * random();
		self.angles_x += JITTER(0, 20);
		self.angles_z += JITTER(0, 20);
		
		if(i)
			W_Electro_Attack2();
		else
			W_Electro_Attack();
			
		if(random() < 0.5)
		{
			self.angles = oldangles;
			self.angles_y += JITTER(0, 20);
			self.angles_x += JITTER(0, 25);
			self.angles_z += JITTER(0, 25);
			
			if(random() < 0.5)
				W_Crylink_Attack();
			else
				W_Crylink_Attack2();
		}
		
		self.angles = oldangles;
	}
}

void JB_Torture_RegisterAll() {
	JB_Torture_Register(JB_Torture_Napalm);
	JB_Torture_Register(JB_Torture_Plasma);
}

#undef JITTER

//
//	Callbacks
//

float JB_PlayerDies() {
	DEPENDON_F(g_jailbreak && JB_GAME_ACTIVE, 0)
	
	if(!self.jb_isprisoned) {
		self.health = 100;
	
		if(frag_attacker == self || !frag_attacker)
			PlayerScore_Add(self, SP_SCORE, -cvar("g_explosive_jailbreak_penalty_death"));
		else if(frag_attacker.classname == "player") {
			if(frag_attacker.team != self.team) {
				PlayerScore_Add(self, SP_SCORE, -cvar("g_explosive_jailbreak_penalty_death"));
				PlayerScore_Add(frag_attacker, SP_SCORE, cvar("g_explosive_jailbreak_score_imprison"));
			}
			else PlayerScore_Add(frag_attacker, SP_SCORE, -cvar("g_explosive_jailbreak_penalty_teamkill"));
		}
		
		JB_ImprisonLater(frag_attacker);
	} else {
		JB_Log(strcat("Prisoned player ", self.netname, " ^7just died. Should this really happen?"));
		PutClientInServer();
		
		if(self.scorekeeper) {
			self.scorekeeper.SendFlags |= pow(2, SP_FREEZETAG_FROZENSTATUS);
			self.scorekeeper.(scores[SP_FREEZETAG_FROZENSTATUS]) = 1;
		}
	}
	
	return 1;
}

void JB_PlayerSpawn() {
	DEPENDON(g_jailbreak)
	
	self.jb_isprisoned = FALSE;
	if(self.scorekeeper) {
		self.scorekeeper.SendFlags |= pow(2, SP_FREEZETAG_FROZENSTATUS);
		self.scorekeeper.(scores[SP_FREEZETAG_FROZENSTATUS]) = 0;
	}
	
	self.jb_fragrow = 0;
	
	DEPENDON(JB_GAME_ACTIVE)
	
	if(JB_TotalPlayersOnTeam(self.team))	// allow to spawn non-prisoned if there are no players on that team
		JB_Imprison(world);
	
	self.jb_roundlost = FALSE;
}

void JB_RemovePlayer() {
	DEPENDON(g_jailbreak)
	
	if(self.jb_isprisoned)
		JB_Release(world);
	
	self.jb_roundlost = FALSE;
}

.float pointupdatetime;
void JB_PlayerPreThink() {
	DEPENDON(g_jailbreak && JB_GAME_ACTIVE)
	
	if(time - self.pointupdatetime >= 0.01)
		self.jb_unlock_progress = 0;
	
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
	next_round = time + 15;
	defer(15, JB_ClearCameraForAll);
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
	for(;(spot = find(spot, classname, "info_jailbreak_jailspawn"));) if(spot.team == theteam) {
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

float JB_AlivePlayersOnTeam(float theteam) {
	JB_CountPlayers();	// just in case ;)
	
	switch(theteam) {
		case COLOR_TEAM1: return redalive;
		case COLOR_TEAM2: return bluealive;
	}
	
	return -1;	// wtf? wrong team dude.
}


entity JB_FindCamera(float theteam) {
	RandomSelection_Init();
	
	entity e;
	for(;(e = find(e, classname, "info_jailbreak_jailcamera"));) if(e.team == theteam)
		RandomSelection_Add(e, 0, string_null, 1, 1);
	
	return RandomSelection_chosen_ent;
}

//float SVC_SETVIEWPORT = 5;   
//float SVC_SETVIEWANGLES = 10;

float jb_ce_pvs, jb_ce_trace;

void JB_RestoreCullEntities() {
	cvar_set("sv_cullentities_pvs", ftos(jb_ce_pvs));
	cvar_set("sv_cullentities_trace", ftos(jb_ce_trace));
	remove(self);
}

void JB_SetCamera(entity player, entity cam, float timeout) {
	msg_entity = player;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CSQC_CAMERA);
	WriteByte(MSG_ONE, TRUE);
	WriteShort(MSG_ONE, cam.origin_x);
	WriteShort(MSG_ONE, cam.origin_y);
	WriteShort(MSG_ONE, cam.origin_z);
	WriteShort(MSG_ONE, timeout);
}

void JB_ClearCamera(entity player) {
	msg_entity = player;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CSQC_CAMERA);
	WriteByte(MSG_ONE, FALSE);
}

void JB_ClearCameraForAll() {
	entity p; FOR_EACH_REALCLIENT(p) JB_ClearCamera(p);
}

void JB_ActivateCamera(float theteam, float timeout) {
	entity cam = JB_FindCamera(theteam);
	
	if(!cam) {
		JB_Log(strcat("JB_ActivateCamera: the ", ColoredTeamName(theteam), "^7 has no camera entities, mapper sucks!"));
		return;
	}
	
	jb_ce_pvs = cvar("sv_cullentities_pvs");
	jb_ce_trace = cvar("sv_cullentities_trace");
	
	// without this we won't be able to watch them burn!
	cvar_settemp("sv_cullentities_pvs", "0");
	cvar_settemp("sv_cullentities_trace", "0");
	
	entity e = spawn();
	e.think = JB_RestoreCullEntities;
	e.nextthink = time + timeout;
	
	entity p; FOR_EACH_PLAYER(p) {
		if(clienttype(p) == CLIENTTYPE_REAL) {
			if(p.team == theteam) {
				p.angles = cam.angles;
				p.angles_z = 0;
				p.fixangle = TRUE;
				p.jb_roundlost = FALSE;
			} else p.jb_roundlost = TRUE;
		}
		
		entity s; FOR_EACH_REALCLIENT(s) if(s == p || (s.classname == "spectator" && s.enemy == p))
			JB_SetCamera(s, cam, timeout);
	}
	
	jb_activecamera = cam;
}

//
//	Setup functions
//

void JB_SetupJailSpawnpoint() {
	if not(g_jailbreak) {
		remove(self);
		return;
	}
	
	self.classname = "info_jailbreak_jailspawn";
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
	if not(g_jailbreak) {
		remove(self);
		return;
	}
	
	self.classname = "func_jailbreak_jail";
	self.touch = JB_Jail_Touch;
	EXACTTRIGGER_INIT;
}

void JB_SetupJailCamera() {
	if not(g_jailbreak) {
		remove(self);
		return;
	}
	
	self.classname = "info_jailbreak_jailcamera";
}

void JB_SetupTortureSpawnpoint() {
	if not(g_jailbreak) {
		remove(self);
		return;
	}
	
	self.classname = "info_jailbreak_torturespawn";
	
	if(!self.jb_torture_force)
		self.jb_torture_force = 400;
	
	if(!self.jb_torture_force_jitter)
		self.jb_torture_force_jitter = self.jb_torture_force * 0.1;
	
	if(!self.jb_torture_delay)
		self.jb_torture_delay = 2;
	
	if(!self.jb_torture_delay_jitter)
		self.jb_torture_delay_jitter = self.jb_torture_delay * 0.5;
}

.entity sprite;
void AnimateDomPoint();

void JB_ControlPoint_Think() {
	self.nextthink = time + 0.1;
	AnimateDomPoint();
	
	if(self.jb_unlock_progress == 1) {
		if(!self.jb_capturestate) {
			self.jb_capturestate = TRUE;
			setmodel(self, "models/domination/dom_unclaimed.md3");
		}
		
		if(time - self.jb_capturetime >= cvar("g_explosive_jailbreak_controlpoint_idletime"))
			self.jb_unlock_progress = 0;
		
		return;
	} else if(self.jb_capturestate) {
		self.jb_capturestate = FALSE;
		setmodel(self, ((self.team == COLOR_TEAM1)? "models/domination/dom_red.md3" : "models/domination/dom_blue.md3"));
	}
}

void JB_ControlPoint_Capture(entity player) {
	activator = self;
	SUB_UseTargets();
	
	string teamname;
	switch(player.team) {
		case COLOR_TEAM1: teamname = "^1reds"	; break ;
		case COLOR_TEAM2: teamname = "^4blues"	; break ;
		default			: teamname = "^6fags"	; break ;
	}
	
	entity e; FOR_EACH_PLAYER(e) {
		bigprint_spec(e, 	strcat("jailbreak! The ", teamname, " ^7are escaping!"),
							strcat("Unlocked by ", player.netname), 5);
		
		if(e.jb_isprisoned && e.team != self.team)
			bigprint_spec(e, strcat("you're free! Run away!"),
							 strcat("And don't forget to give ", player.netname, " ^7a tight hug!"), 5);
	}
	
	bprint(player.netname, " ^5unlocked the enemy jail! The ", ColoredTeamName(player.team), " ^5is escaping!\n");
	PlayerScore_Add(player, SP_SCORE, cvar("g_explosive_jailbreak_score_jbreak"));
	PlayerScore_Add(player, SP_JB_JBREAKS, 1);
	play2all("kh/alarm.wav");
}

void JB_ControlPoint_Touch() {
	if(other.team == self.team)
		return;

	if(other.health < 1)
		return;
	
	if(self.jb_unlock_progress == 1)
		return;
	
	if(other.classname != "player")
		return;
		
	if(JB_TotalPlayersOnTeam(other.team) == JB_AlivePlayersOnTeam(other.team))
		return;	// no imprisoned players on team - sorta makes no sense to jailbreak
	
	if(time - self.pointupdatetime >= 0.1)
		self.jb_unlock_progress = 0;
	
	self.jb_unlock_progress = bound(0, self.jb_unlock_progress + frametime * cvar("g_explosive_jailbreak_controlpoint_unlock_speed"), 1);
	self.pointupdatetime = time;
	other.pointupdatetime = time;
	other.jb_unlock_progress = self.jb_unlock_progress;
	
	if(self.jb_unlock_progress >= 1) {
		self.jb_capturetime = time;
		JB_ControlPoint_Capture(other);
	}
}

void JB_SetupControlPoint() {
	if not(g_jailbreak) {
		remove(self);
		return;
	}
	
	self.classname = "jailbreak_controlpoint";
	
	setmodel(self, ((self.team == COLOR_TEAM1)? "models/domination/dom_red.md3" : "models/domination/dom_blue.md3"));
	self.skin = 0;
	
	if(!self.t_width)
		self.t_width = 0.02; // frame animation rate
	if(!self.t_length)
		self.t_length = 239; // maximum frame
		
	self.think = JB_ControlPoint_Think;
	self.nextthink = time;
	self.touch = JB_ControlPoint_Touch;
	self.solid = SOLID_TRIGGER;
	self.flags = FL_ITEM;
	setsize(self, '-32 -32 -32', '32 32 32');
	setorigin(self, self.origin + '0 0 20');
	droptofloor();
	
	waypoint_spawnforitem_force(self, self.origin);
	self.nearestwaypointtimeout = 0; // activate waypointing again
	self.basewaypoint = self.nearestwaypoint;
	WaypointSprite_SpawnFixed(((self.team == COLOR_TEAM1)? "redbase" : "bluebase"), self.origin + '0 0 37', self, sprite);
	WaypointSprite_UpdateTeamRadar(self.sprite, RADARICON_FLAG, colormapPaletteColor(COLOR_TEAM1 - 1, FALSE));
}

//
//	Spawn functions
//

#define JB_SPAWNFUNC(e,s,t) void spawnfunc_##e() { self.team = t; s(); }

JB_SPAWNFUNC(info_jailbreak_jailspawn_red, JB_SetupJailSpawnpoint, COLOR_TEAM1)
JB_SPAWNFUNC(info_jailbreak_jailspawn_blue, JB_SetupJailSpawnpoint, COLOR_TEAM2)

JB_SPAWNFUNC(func_jailbreak_jail_red, JB_SetupJail, COLOR_TEAM1)
JB_SPAWNFUNC(func_jailbreak_jail_blue, JB_SetupJail, COLOR_TEAM2)

JB_SPAWNFUNC(info_jailbreak_jailcamera_red, JB_SetupJailCamera, COLOR_TEAM1)
JB_SPAWNFUNC(info_jailbreak_jailcamera_blue, JB_SetupJailCamera, COLOR_TEAM2)

JB_SPAWNFUNC(info_jailbreak_torturespawn_red, JB_SetupTortureSpawnpoint, COLOR_TEAM1)
JB_SPAWNFUNC(info_jailbreak_torturespawn_blue, JB_SetupTortureSpawnpoint, COLOR_TEAM2)

JB_SPAWNFUNC(jailbreak_controlpoint_red, JB_SetupControlPoint, COLOR_TEAM1)
JB_SPAWNFUNC(jailbreak_controlpoint_blue, JB_SetupControlPoint, COLOR_TEAM2)
