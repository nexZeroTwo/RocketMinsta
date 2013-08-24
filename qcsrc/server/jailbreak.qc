
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
    
    g_jailbreak_claim = cvar("g_jailbreak_controlpoint_claim");
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
	
	self.jb_fragrow = 0;
	
	if(attacker.classname == "player")
	if(attacker.team != self.team) {
		attacker.jb_fragrow += 1;
		
		if(cvar("g_jailbreak_frag_bonusgrenade"))
		if(attacker.jb_fragrow >= cvar("g_jailbreak_frag_bonusgrenade_requirement")) {
			HG_GiveBonus(attacker, HG_NameToType(cvar_string("g_jailbreak_frag_bonusgrenade_type")), 1,
								   strcat(ftos(attacker.jb_fragrow), " frags in a row")
			);
			attacker.jb_fragrow = 0;
		}
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
	bigprint_spec(self, "You're in a jail, prisoner!", ((attacker && attacker != self)? strcat("You've been imprisoned by ^3", attacker.netname) : ""), 10);
	
	if(g_handgrenades) {
        if(!cvar("g_handgrenades_regen_time"))
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
    if(!cvar("g_handgrenades_regen_time"))
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
		case COLOR_TEAM1:	teamname = "^1Red";		play2all("ctf/red_capture.wav");	break;
		case COLOR_TEAM2:	teamname = "^4Blue";	play2all("ctf/blue_capture.wav");	break;
	}
	
	teamname_full = ColoredTeamName(theteam);
	
	entity e; FOR_EACH_PLAYER(e) {
		bigprint_spec(e, strcat(teamname, "^7 Scores!"), "All opponents are imprisoned", 15);
		
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
	
	if(gameover && !redalive && !bluealive)
		return;
	
	if(!redalive)
		JB_TeamWins(COLOR_TEAM2);
	else if(!bluealive)
		JB_TeamWins(COLOR_TEAM1);
}

void JB_HandleProjectile(entity proj) {
	DEPENDON(g_jailbreak)
	
	if(proj.owner.classname == "player" || proj.owner.classname == "corpse") {
		if(proj.owner.jb_isprisoned)
			proj.jb_proj_ownerstate = JB_PROJ_OWNERSTATE_IMPRISONED;
		else
			proj.jb_proj_ownerstate = JB_PROJ_OWNERSTATE_FREE;
	}
}

//
//	Torture logic
//

var jb_torture_logic jb_torture_logic1;
var jb_torture_logic jb_torture_logic2;

#define JITTER(v,j) (v) + (j) * 2 * (random() - 0.5)

jb_torture_logic JB_Torture_PickFunction() {
	/*
	entity e;
	
	RandomSelection_Init();
	for(;(e = find(e, classname, "jailbreak_torture_logic"));)
		RandomSelection_Add(e, 0, string_null, 1, 1);
	return RandomSelection_chosen_ent.use;
	*/
	
	return ((random() < 0.5)? jb_torture_logic1 : jb_torture_logic2);
}

void JB_TorturePrisoners(float theteam) {
	entity spot, logic;
	
	//	Here we will choose two random torture logics to run at the same time
	RandomSelection_Init();
	for(;(logic = find(logic, classname, "jailbreak_torture_logic"));)
		RandomSelection_Add(logic, 0, string_null, 1, 1);
	jb_torture_logic1 = RandomSelection_chosen_ent.use;
	RandomSelection_Init();
	for(;(logic = find(logic, classname, "jailbreak_torture_logic"));)
		if(logic.use != jb_torture_logic1)
			RandomSelection_Add(logic, 0, string_null, 1, 1);
	jb_torture_logic2 = RandomSelection_chosen_ent.use;
	
	for(;(spot = find(spot, classname, "info_jailbreak_torturespawn"));)
		if(spot.team == theteam)
			JB_Torture_Start(spot);
}

void JB_Torture_Think() {
	if(gameover) {
		remove(self);
		return;
	}
	
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
		//remove(self);
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
	e.team = e.owner.team;
	setorigin(e, spot.origin);
	e.nextthink = time + JITTER(0, e.jb_torture_delay_jitter);
}

void JB_Torture_Register(jb_torture_logic logic) {
	entity e = spawn();
	e.classname = "jailbreak_torture_logic";
	e.use = logic;
}

void JB_Torture_Napalm_Touch() {
	self.cnt -= 1;
	
	if(!self.cnt)
		remove(self);
	
	W_Firemine_Touch();
}

void JB_Torture_Napalm() {
	local entity proj;
	local vector kick;

	proj = spawn ();
	proj.owner = self;
	proj.classname = "jb_torture_napalm";
	proj.movetype = MOVETYPE_BOUNCE;
	proj.projectiledeathtype = DEATH_HG_NAPALM;
	proj.touch = JB_Torture_Napalm_Touch;
	PROJECTILE_MAKETRIGGER(proj);
	setsize (proj, '0 0 0', '0 0 0');
	setorigin (proj, self.origin);
	proj.org_explosion = self.origin;
	proj.think = HG_Napalm_Think;
	proj.nextthink = time;
	proj.damageforcescale = 1;
	proj.cnt = 3; //	max bounces
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

void JB_Torture_Plasma() {
	float i, j;
	
	vector oldangles = self.angles;
	for(i = 0; i < 2; ++i) {
		self.angles_y -= 30 * random();
		self.angles_x += JITTER(0, 20);
		self.angles_z += JITTER(0, 20);
		
		if(i)
			W_Electro_Attack2();
		else
			W_Electro_Attack();
		
		for(j = 0; j < 2; ++j) {
			if(random() < 0.5) {
				self.angles = oldangles;
				self.angles_y += JITTER(0, 20);
				self.angles_x += JITTER(0, 25);
				self.angles_z += JITTER(0, 25);
				
				if(random() < 0.5)
					W_Crylink_Attack();
				else
					W_Crylink_Attack2();
			}
		}
		
		self.angles = oldangles;
	}
}

void JB_Torture_Grenade_Explode (void)
{
	self.event_damage = SUB_Null;
	self.takedamage = DAMAGE_NO;
	RadiusDamage (self, self.owner, 100, 100, 250, world, 700, self.projectiledeathtype, other);
	remove (self);
}

void JB_Torture_Grenades() {
	makevectors(self.angles + randomvec() * 30);
	W_SetupShot_ProjectileSize(self, '0 0 -3', '0 0 -3', FALSE, 4, "weapons/grenade_fire.wav", 100);
	w_shotdir = v_forward;
	w_shotorg = self.origin;
	
	pointparticles(particleeffectnum("grenadelauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);
	
	entity gren = spawn();
	gren.owner = self;
	gren.classname = "jb_torture_copypasta_from_g_handgrenades";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = 300;
	gren.movetype = MOVETYPE_BOUNCE;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_GRENADE_LAUNCHER;
	gren.hg_type = DEATH_HG_NORMAL;		// HG_Grenade_Explode and such use this -- I don't feel like copypasting them too
	setsize(gren, '0 0 -3', '0 0 -3');
	setorigin(gren, w_shotorg);

	gren.nextthink = time + 3;
	gren.think = adaptor_think2use;
	gren.use = JB_Torture_Grenade_Explode; //HG_Grenade_Explode;
	gren.touch = HG_Touch;
	gren.takedamage = DAMAGE_YES;
	gren.health = 1;
	gren.damageforcescale = 4;
	gren.event_damage = W_Grenade_Damage;
	gren.velocity = w_shotdir * self.jb_torture_suggestedforce + v_up * (self.jb_torture_suggestedforce + crandom() * 0.2 * self.jb_torture_suggestedforce);
	W_SetupProjectileVelocity(gren);
	
	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;
	
	CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE_BOUNCING, TRUE);
}

void JB_Torture_Zap_AimAt(vector org, entity targ) {
	vector shotanle = vectoangles(org - targ.origin);
	shotanle_y += 180;
	makevectors(shotanle);
}

void JB_Torture_Zap() {
	entity unlucky_guy, p;

	RandomSelection_Init();
	FOR_EACH_PLAYER(p) if(p.team != self.team) if(p.deadflag == DEAD_NO)
		RandomSelection_Add(p, 0, string_null, 1, 1);
	unlucky_guy = RandomSelection_chosen_ent;
	
	if(!unlucky_guy) {
		// nobody left alive? shoot the corpses / death origins
		RandomSelection_Init();
		FOR_EACH_PLAYER(p) if(p.team != self.team)
			RandomSelection_Add(p, 0, string_null, 1, 1);
		unlucky_guy = RandomSelection_chosen_ent;
	}
	
	// this should not happen, but just in case...
	if(!unlucky_guy)
		return;

	JB_Torture_Zap_AimAt(self.origin, unlucky_guy);
	sound(self, CHAN_WEAPON, "weapons/nexfire.wav", VOL_BASE, ATTN_NORM);
	
	FireRailgunBullet (self.origin, self.origin + v_forward * 1024, 70, 700, 0, 0, 0, 0, WEP_NEX);
	w_shotorg = self.origin;	// needed for the beam to appear correctly
	SendCSQCNexBeamParticle();
	
	// flash and burn the wall
	if (trace_ent.solid == SOLID_BSP && !(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		Damage_DamageInfo(trace_endpos, 200, 0, 0, 700 * v_forward, WEP_NEX, self);
}

void JB_Torture_RegisterAll() {
	JB_Torture_Register(JB_Torture_Napalm);
	JB_Torture_Register(JB_Torture_Plasma);
	JB_Torture_Register(JB_Torture_Grenades);
	JB_Torture_Register(JB_Torture_Zap);
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
			PlayerScore_Add(self, SP_SCORE, -cvar("g_jailbreak_penalty_death"));
		else if(frag_attacker.classname == "player") {
			if(frag_attacker.team != self.team) {
				PlayerScore_Add(self, SP_SCORE, -cvar("g_jailbreak_penalty_death"));
				PlayerScore_Add(frag_attacker, SP_SCORE, cvar("g_jailbreak_score_imprison"));
			}
			else PlayerScore_Add(frag_attacker, SP_SCORE, -cvar("g_jailbreak_penalty_teamkill"));
		}
		
		Boobs_DropAllAndRespawn(frag_force);
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
	
	if(JB_TotalPlayersOnTeam(self.team)) {	// allow to spawn non-prisoned if there are no players on that team
		JB_Imprison(world);
        self.hg_clearammo = 1;
    }
	
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
//

void JB_EndRound_Finalize() {
	jb_roundover = FALSE;
	defer(0.1, JB_CountPlayers);
}

void JB_EndRound() {
	G_EndRound("Jailbreak", 15, cvar("g_jailbreak_warmup"), JB_CountPlayers, func_null, JB_EndRound_Finalize);
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

string JB_ControlPoint_ModelForTeam(float t) {
    switch(t) {
        case COLOR_TEAM1:       return "models/domination/dom_red.md3";
        case COLOR_TEAM2:       return "models/domination/dom_blue.md3";
        default:                return "models/domination/dom_yellow.md3";
    }
}

string JB_ControlPoint_WaypointForTeam(float t) {
    switch(t) {
        case COLOR_TEAM1:       return "dom-red";
        case COLOR_TEAM2:       return "dom-blue";
        default:                return "dom-yellow";
    }
}

float JB_ControlPoint_Cooldown(entity e) {
    float base, pw, f, c;
    
    c = e.jb_capturecount;
    
    if(e.team == JB_TEAM_NEUTRAL) {
        base = cvar("g_jailbreak_controlpoint_idletime_neutral");
        pw   = cvar("g_jailbreak_controlpoint_idletime_neutral_power");
        f    = cvar("g_jailbreak_controlpoint_idletime_neutral_factor");
    } else {
        base = cvar("g_jailbreak_controlpoint_idletime");
        pw   = cvar("g_jailbreak_controlpoint_idletime_power");
        f    = cvar("g_jailbreak_controlpoint_idletime_factor");
    }
    
    return base + pow(c, pw) * f * base;
}

float JB_ControlPoint_InitialCooldown(entity e) {
    return cvar((e.team == JB_TEAM_NEUTRAL)? "g_jailbreak_controlpoint_idletime_neutral_initial" : "g_jailbreak_controlpoint_idletime_initial");
}

void JB_ControlPoint_Activate(entity e) {
    e.jb_active = TRUE;
    e.jb_cooldown = 0;
    e.jb_cooldown_max = 0;
    setmodel(e, JB_ControlPoint_ModelForTeam(e.team));
    WaypointSprite_UpdateMaxHealth(e.waypointsprite_attached, 0);
    WaypointSprite_UpdateHealth(e.waypointsprite_attached, 0);
}

void JB_ControlPoint_Deactivate(entity e, float cooldown) {
    e.jb_cooldown_max = max(e.jb_cooldown_max, cooldown);
    e.jb_cooldown     = max(e.jb_cooldown,     cooldown);
    
    JB_Log(strcat(etos(e), ": ", ftos(e.jb_cooldown), "s cooldown. Team: ", ftos(e.team), ", Caps: ", ftos(e.jb_capturecount)));
    
    if(e.jb_active && e.jb_cooldown > 0) {
        setmodel(e, "models/domination/dom_unclaimed.md3");
        e.jb_active = FALSE;
    }
}

void JB_ControlPoint_UpdateCooldownProgress(entity e) {
    WaypointSprite_UpdateMaxHealth(e.waypointsprite_attached, e.jb_cooldown_max);
    WaypointSprite_UpdateHealth(e.waypointsprite_attached, e.jb_cooldown_max - e.jb_cooldown);
}

void JB_ControlPoint_Think() {
    self.nextthink = time;
    AnimateDomPoint();
    
    if(time < game_starttime || jb_roundover)
        return;
    
    if(self.jb_cooldown) {
        JB_ControlPoint_UpdateCooldownProgress(self);
    } else if(!self.jb_active) {
        JB_ControlPoint_Activate(self);
    }
    
    self.jb_cooldown = max(0, self.jb_cooldown - frametime);
}

void JB_ControlPoint_SwitchTeam(entity e, float t) {
    e.team = t;
    
    if(e.waypointsprite_attached)
        WaypointSprite_Kill(e.waypointsprite_attached);
    
    e.waypointsprite_attached = WaypointSprite_SpawnFixed(JB_ControlPoint_WaypointForTeam(e.team), e.origin + '0 0 37', e, sprite);
    WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_FLAG, colormapPaletteColor(e.team - 1, FALSE));
}

void JB_TriggerTeamControlPoints(float t) {
    entity e, o;
    for(e = world; (e = find(e, classname, "jailbreak_controlpoint"));) {
        if(e.jb_team_initial == t) {
            o = self;
            self = e;
            SUB_UseTargets_PreventReuse();
            self = o;
        }
    }
}

void JB_ControlPoint_Capture(entity player) {
    entity e, o;
    
	activator = self;
    
    if(self.team == JB_TEAM_NEUTRAL || g_jailbreak_claim)
        JB_TriggerTeamControlPoints(JB_GetEnemyTeamOf(player.team));
    else SUB_UseTargets();
	
	string teamname;
	switch(player.team) {
		case COLOR_TEAM1: teamname = "^1REDS"	; break ;
		case COLOR_TEAM2: teamname = "^4BLUES"	; break ;
		default			: teamname = "^6FAGS"	; break ;
	}
	
	FOR_EACH_PLAYER(e) {
		bigprint_spec(e, 	strcat("Jailbreak! The ", teamname, " ^7are escaping!"),
							strcat("Unlocked by ", player.netname), 5);
		
		if(e.jb_isprisoned && e.team != self.team)
			bigprint_spec(e, "You're free! Run away!",
							 strcat("And don't forget to give ", player.netname, " ^7a tight hug!"), 5);
	}
	
	bprint(player.netname, " ^5unlocked the enemy jail! The ", ColoredTeamName(player.team), " ^5is escaping!\n");
	PlayerScore_Add(player, SP_SCORE, cvar("g_jailbreak_score_jbreak"));
	PlayerScore_Add(player, SP_JB_JBREAKS, 1);
	play2all("kh/alarm.wav");
    
    if(cvar("g_jailbreak_controlpoint_claim_noneutral"))
    if(self.team == JB_TEAM_NEUTRAL)
        return;
    
    JB_ControlPoint_SwitchTeam(self, player.team);
}

void JB_ControlPoint_Touch() {
    if(jb_roundover)
        return;
    
	if(other.team == self.team)
		return;

	if(other.health < 1)
		return;
	
    if(!self.jb_active)
        return;
    
	if(other.classname != "player")
		return;
		
	if(JB_TotalPlayersOnTeam(other.team) == JB_AlivePlayersOnTeam(other.team))
		return;	// no imprisoned players on team - sorta makes no sense to jailbreak
	
	if(time - self.pointupdatetime >= 0.1)
		self.jb_unlock_progress = 0;
	
	self.jb_unlock_progress = bound(0, self.jb_unlock_progress + frametime * cvar("g_jailbreak_controlpoint_unlock_speed"), 1);
	self.pointupdatetime = time;
	other.pointupdatetime = time;
	other.jb_unlock_progress = self.jb_unlock_progress;
	
	if(self.jb_unlock_progress >= 1) {
		JB_ControlPoint_Capture(other);
        
        JB_ControlPoint_Deactivate(self, JB_ControlPoint_Cooldown(self));
        entity e; for(;(e = find(e, classname, "jailbreak_controlpoint"));) if(e != self)
            if(e.team == other.team)
                JB_ControlPoint_Deactivate(e, cvar("g_jailbreak_controlpoint_idletime_global_own"));
            else if(e.team == JB_TEAM_NEUTRAL || e.team == JB_GetEnemyTeamOf(other.team))
                JB_ControlPoint_Deactivate(e, cvar("g_jailbreak_controlpoint_idletime_global"));
                
        self.jb_capturecount += 1;
	}
}

void JB_ControlPoint_Reset() {
    self.jb_capturecount = 0;
    self.jb_active = TRUE;
    self.jb_cooldown = 0;
    self.jb_cooldown_max = 0;
    JB_ControlPoint_Deactivate(self, JB_ControlPoint_InitialCooldown(self));
    WaypointSprite_UpdateMaxHealth(self.waypointsprite_attached, 0);
    WaypointSprite_UpdateHealth(self.waypointsprite_attached, 0);
    JB_ControlPoint_SwitchTeam(self, cvar("g_jailbreak_controlpoint_claim_allneutral")? JB_TEAM_NEUTRAL : self.jb_team_initial);
}

void JB_SetupControlPoint() {
	if not(g_jailbreak) {
		remove(self);
		return;
	}
	
	self.classname = "jailbreak_controlpoint";
    self.jb_team_initial = self.team;
    
    if(cvar("g_jailbreak_controlpoint_claim_allneutral"))
        self.team = JB_TEAM_NEUTRAL;
	
	setmodel(self, JB_ControlPoint_ModelForTeam(self.team));
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
    self.reset = JB_ControlPoint_Reset;
    self.jb_capturecount = 0;
    self.jb_active = TRUE;
    JB_ControlPoint_Deactivate(self, JB_ControlPoint_InitialCooldown(self));
	setsize(self, '-32 -32 -32', '32 32 32');
	setorigin(self, self.origin + '0 0 20');
	droptofloor();
	
	waypoint_spawnforitem_force(self, self.origin);
	self.nearestwaypointtimeout = 0; // activate waypointing again
	self.basewaypoint = self.nearestwaypoint;
	self.waypointsprite_attached = WaypointSprite_SpawnFixed(JB_ControlPoint_WaypointForTeam(self.team), self.origin + '0 0 37', self, sprite);
	WaypointSprite_UpdateTeamRadar(self.sprite, RADARICON_FLAG, colormapPaletteColor(self.team - 1, FALSE));
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
JB_SPAWNFUNC(jailbreak_controlpoint_neutral, JB_SetupControlPoint, JB_TEAM_NEUTRAL)
