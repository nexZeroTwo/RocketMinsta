
// Handgrenades mutator
// Intended for the Camping Rifle Arena mode

void HG_Init() {
    addstat(STAT_HGFORCE, AS_FLOAT, hg_power);
    addstat(STAT_HGAMMO, AS_INT, hg_ammo);
    addstat(STAT_HGREGEN, AS_FLOAT, hg_regenstat);
    addstat(STAT_HGREGENPAUSED, AS_INT, hg_regenpaused);
    addstat(STAT_HGDETONABLES, AS_INT, hg_detonables);
    g_handgrenades_oldhitboxes = cvar("g_handgrenades_oldhitboxes");
}

void HG_Precache() {
    precache_sound("hk/alarm.wav");
    precache_sound("weapons/grenade_bounce1.wav");
    precache_sound("weapons/grenade_bounce2.wav");
    precache_sound("weapons/grenade_bounce3.wav");
    precache_sound("weapons/grenade_bounce4.wav");
    precache_sound("weapons/grenade_bounce5.wav");
    precache_sound("weapons/grenade_bounce6.wav");
    precache_sound("weapons/grenade_fire.wav");
    precache_sound("weapons/rm_nadebeep.wav");
}

void HG_GiveBonus(entity p, float hgtype, float amount, string reason) {
	p.hg_bonus += amount;
	p.hg_bonustype = hgtype;
    
    if(!cvar("g_handgrenades_bonus_free"))
        p.hg_ammo += amount;
	
	string n = HG_TypeToExpandedName(hgtype);
	entity e;
	
	FOR_EACH_PLAYER(e)
		bigprint_spec(e, strcat("^3", p.netname), strcat("Got a ^3", n, "^7 bonus (", reason, ")"), 3);
	bprint(strcat("^3", p.netname, " ^7got a ^3", n, "^7 bonus (", reason, ")\n"));
	play2all("kh/alarm.wav");
}

void HG_Napalm_Burn(float dt, float dist, float damage, float edgedamage, float burntime, float dtype)
{
	entity e, o;
	float d, df;
	vector p;
	
	o = self.owner;
	df = 1;

	for(e = findradius(self.origin, dist); e; e = e.chain) if(e.classname == "player")
	{
		if(g_freezetag)
		if(e.freezetag_frozen)
			continue;
		
		if(o.team == e.team)
		{
			if(teamplay == 1)
				continue;
			else if(e != o)
			{
				if(teamplay == 3)
					continue;
				else if(teamplay == 4) {
					df = cvar("g_friendlyfire");
					
					if(df == 0)
						continue;
				}
			}
		}
		
		p = e.origin;
		p_x += e.mins_x + random() * (e.maxs_x - e.mins_x);
		p_y += e.mins_y + random() * (e.maxs_y - e.mins_y);
		p_z += e.mins_z + random() * (e.maxs_z - e.mins_z);
		d = vlen(self.origin - p);
		if(d < dist)
		{
			traceline(p, self.origin, MOVE_NORMAL, e);
			if(/* trace_startsolid || */ trace_fraction != 1)
				continue;
			e.fireball_impactvec = p;
			d = vlen(self.origin - e.fireball_impactvec);
			d = damage + (edgedamage - damage) * (d / dist);
			Fire_AddDamage(e, self.owner, d * burntime * df, burntime, dtype);
		}
	}
}

void HG_Napalm_Think()
{
	if (time > self.pushltime)
	{
		remove(self);
		return;
	}

	HG_Napalm_Burn(0.1, GRENVAR(self.hg_type, "burnradius"), GRENVAR(self.hg_type, "burndamage"), GRENVAR(self.hg_type, "edgeburndamage"), GRENVAR(self.hg_type, "burntime"), self.hg_type);
	if(time >= self.nextparticle) {
		pointparticles(particleeffectnum("fire_big"), self.origin, '0 0 0', 1);
		self.nextparticle = time + 0.2 + random () * 0.2;
	}

	self.nextthink = time + 0.1;
}

void HG_Napalm_Middlefire_Think() {
	if(time > self.pushltime) {
		remove (self);
		return;
	}
	
    if(time >= self.nextparticle) {
        
        float i; for(i = 0; i < 5; ++i) {
            vector v = randomvec();
            v_z = max(0, v_z * 0.3);
            pointparticles(particleeffectnum("fire_big"), self.origin + v * cvar("g_handgrenades_napalm_middleburnradius"), '0 0 0', 1);
        }
        
		self.nextparticle = time + 0.1 + random () * 0.5;
	}
    
	HG_Napalm_Burn(0.1, cvar("g_handgrenades_napalm_middleburnradius"), cvar("g_handgrenades_napalm_burndamage"), cvar("g_handgrenades_napalm_edgeburndamage"), cvar("g_handgrenades_napalm_burntime"), DEATH_HG_NAPALM);
	self.nextthink = time + 0.1;
}

void HG_Napalm_Projectile_Touch()
{
	PROJECTILE_TOUCH;
	if(other.takedamage == DAMAGE_AIM)
	if(Fire_AddDamage(other, self.realowner, GRENVAR(self.hg_type, "burndamage"), GRENVAR(self.hg_type, "burntime"), self.hg_type) >= 0) {
		remove(self);
		return;
	}
}

void HG_Napalm()
{
	entity proj;
	vector kick;
    
	proj = spawn();
	proj.owner = self.owner;
    proj.hg_type = self.hg_type;
	proj.classname = "grenade";
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = GRENVAR(self.hg_type, "burndamage");
	proj.movetype = MOVETYPE_BOUNCE;
	proj.projectiledeathtype = DEATH_HG_NAPALM;
	proj.touch = HG_Napalm_Projectile_Touch;
	PROJECTILE_MAKETRIGGER(proj);
	setsize (proj, '0 0 0', '0 0 0');
	setorigin (proj, self.origin);
	proj.org_explosion = self.origin;
	proj.think = HG_Napalm_Think;
	proj.nextthink = time;
	proj.reset = SUB_Remove;
	proj.damageforcescale = GRENVAR(self.hg_type, "damageforcescale");
	kick_x = (random () - 0.5) * 2 * GRENVAR(self.hg_type, "spread_xy");
	kick_y = (random () - 0.5) * 2 * GRENVAR(self.hg_type, "spread_xy");
	kick_z = max(
						GRENVAR(self.hg_type, "spread_z")
					*	random(),
					
						GRENVAR(self.hg_type, "spread_z_min")
					+ 	GRENVAR(self.hg_type, "spread_z_min_randomfactor")
					*	(random() - 0.5) * 2
				);
	proj.velocity = kick;
	proj.pushltime = time + GRENVAR(self.hg_type, "fire_lifetime") + GRENVAR(self.hg_type, "fire_lifetime_randomfactor") * (random() - 0.5) * 2;
	W_SetupProjectileVelocity(proj);

	proj.angles = vectoangles(proj.velocity);
	proj.flags = FL_PROJECTILE;

	CSQCProjectile(proj, TRUE, PROJECTILE_FIREMINE, TRUE);
}

void HG_Napalm_Explode() {
	local float c;
	for (c = 0; c < cvar("g_handgrenades_napalm_numparticles"); c ++) HG_Napalm();
	
	// since we have a ton of fire in the middle, let's make it a real fire
	entity mid = spawn();
	mid.owner = self.owner;
	mid.origin = self.origin;
	setorigin(mid, mid.origin);
	mid.think = HG_Napalm_Middlefire_Think;
    mid.reset = SUB_Remove;
	mid.nextthink = time;
	mid.pushltime = time + cvar("g_handgrenades_napalm_fire_lifetime");
	setsize(mid, '0 0 0', '0 0 0');
}

void HG_Plasma_Projectile_Explode() {
	self.event_damage = SUB_Null;
	self.takedamage = DAMAGE_NO;
	RadiusDamage(self, self.owner, cvar("g_handgrenades_plasma_projectile_damage"), cvar("g_handgrenades_plasma_projectile_edgedamage"), cvar("g_handgrenades_plasma_projectile_radius"), world, cvar("g_handgrenades_plasma_projectile_force"), self.projectiledeathtype, other);
	remove(self);
}

void HG_Plasma_Projectile_Think() {
    entity e;
    float dps, rng;
    
    if(time >= self.hg_detonatetime) {
        HG_Plasma_Projectile_Explode();
        return;
    }
    
    dps = cvar("g_handgrenades_plasma_projectile_dps");
    rng = cvar("g_handgrenades_plasma_projectile_dps_range");
    
    FOR_EACH_PLAYER(e) if(vlen(e.origin - self.origin) <= rng)
        Damage(e, self, self.owner, dps * frametime, self.projectiledeathtype, '0 0 0', '0 0 0');
    
    self.nextthink = time;
}

void HG_Plasma_Projectile_Touch()
{
	PROJECTILE_TOUCH;
	if (other.takedamage == DAMAGE_AIM) {
		HG_Plasma_Projectile_Explode();
	} else {
		spamsound (self, CHAN_PROJECTILE, "weapons/electro_bounce.wav", VOL_BASE, ATTN_NORM);
	}
}

void HG_Plasma_Projectile() {
	local entity proj;
    vector kick;

	W_SetupShot_ProjectileSize (self, '0 0 -3', '0 0 -3', FALSE, 2, "weapons/electro_fire2.wav", cvar("g_balance_electro_secondary_damage"));
	w_shotdir = v_forward; // no TrueAim for grenades please

	pointparticles(particleeffectnum("electro_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn();
	proj.classname = "plasma";
	proj.owner = self.owner;
	proj.use = HG_Plasma_Projectile_Explode;
	proj.think = HG_Plasma_Projectile_Think;
    proj.nextthink = time;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = cvar("g_handgrenades_plasma_projectile_damage");
    proj.hg_detonatetime = time + cvar("g_handgrenades_plasma_projectile_lifetime") + random() * cvar("g_handgrenades_plasma_projectile_lifetime_randomfactor");
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = HG_PLASMA_SHARD;
	setorigin(proj, w_shotorg);
    
	proj.movetype = MOVETYPE_BOUNCE;
    kick_x = (random () - 0.5) * 2 * cvar("g_handgrenades_plasma_spread_xy");
	kick_y = (random () - 0.5) * 2 * cvar("g_handgrenades_plasma_spread_xy");
	kick_z = max(
						cvar("g_handgrenades_plasma_spread_z")
					*	random(),
					
						cvar("g_handgrenades_plasma_spread_z_min")
					+ 	cvar("g_handgrenades_plasma_spread_z_min_randomfactor")
					*	(random() - 0.5) * 2
				);
    proj.velocity = kick;
	W_SetupProjectileVelocity(proj);
	proj.touch = HG_Plasma_Projectile_Touch;
	setsize(proj, '0 0 -3', '0 0 -3');
	proj.takedamage = DAMAGE_NO;
	proj.event_damage = W_Plasma_Damage;
	proj.flags = FL_PROJECTILE;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_ELECTRO, FALSE);
}

void HG_Plasma_Explode() {
    local float c;
	for (c = 0; c < cvar("g_handgrenades_plasma_projectile_count"); c ++) HG_Plasma_Projectile();
}

void HG_Remote_Explode() {
    local float c;
    for (c = 0; c < cvar("g_handgrenades_remote_numparticles"); c ++) HG_Napalm();
}

void HG_Translocator_Explode() {
    if(g_jailbreak && self.owner.jb_isprisoned)
        return;
    
    setsize(self, self.owner.mins, self.owner.maxs);
    
    if(!move_out_of_solid(self)) {
        bprint("^1Couldn't move ", self.owner.netname, "^1's translocator out of solid! Teleport aborted. Origin: ", vtos(self.origin), ", velocity: ", vtos(self.velocity), "\n");
        return;
    }
    
    makevectors(self.angles);
    TeleportPlayer(self.owner, self.owner, self.origin, self.angles, vlen(self.owner.velocity) * v_forward * 1.5, '0 0 0', '0 0 0');
}

float HG_TypeToCSQCProjType(float t) {
	switch(t) {
		case HG_NAPALM  :   return PROJECTILE_HG_NAPALM;
		case HG_PLASMA  :   return PROJECTILE_HG_PLASMA;
        case HG_TRANSLOC:   return PROJECTILE_HG_TRANSLOC;
		default         :   return PROJECTILE_HG_GENERIC;
	}
}

#define GV(v) (GRENVAR(self.hg_type, v))
void HG_Grenade_Explode()
{
	if(other.takedamage == DAMAGE_AIM)
		if(other.classname == "player")
			if(IsDifferentTeam(self.owner, other))
				if(IsFlying(other))
					announce(self.owner, "announcer/male/airshot.wav");

	self.event_damage = SUB_Null;
	self.takedamage = DAMAGE_NO;
	
	if(self.hg_type == HG_NAPALM)
		HG_Napalm_Explode();
    else if(self.hg_type == HG_PLASMA)
        HG_Plasma_Explode();
    else if(self.hg_type == HG_REMOTE)
        HG_Remote_Explode();
    else if(self.hg_type == HG_TRANSLOC)
        HG_Translocator_Explode();
	
	RadiusDamage(self, self.owner, GV("damage"), GV("edgedamage"), GV("radius"), world, GV("force"), self.projectiledeathtype, other);
	remove (self);
}
#undef GV

void HG_Grenade_Touch() {
	PROJECTILE_TOUCH;
	if(other.takedamage == DAMAGE_AIM && !(other.team == self.owner.team && self.hg_type == HG_TRANSLOC)) {
		self.use();
	} else {
        if(self.cnt <= 0) {
            self.use();
            return;
        }
        
		float r;
		r = random() * 6;
		if(r < 1)
			spamsound (self, CHAN_PROJECTILE, "weapons/grenade_bounce1.wav", VOL_BASE, ATTN_NORM);
		else if(r < 2)
			spamsound (self, CHAN_PROJECTILE, "weapons/grenade_bounce2.wav", VOL_BASE, ATTN_NORM);
		else if(r < 3)
			spamsound (self, CHAN_PROJECTILE, "weapons/grenade_bounce3.wav", VOL_BASE, ATTN_NORM);
		else if(r < 4)
			spamsound (self, CHAN_PROJECTILE, "weapons/grenade_bounce4.wav", VOL_BASE, ATTN_NORM);
		else if(r < 5)
			spamsound (self, CHAN_PROJECTILE, "weapons/grenade_bounce5.wav", VOL_BASE, ATTN_NORM);
		else
			spamsound (self, CHAN_PROJECTILE, "weapons/grenade_bounce6.wav", VOL_BASE, ATTN_NORM);
        
        self.cnt -= 1;
	}
}

float HG_RegenTime(entity e) {
    return cvar("g_handgrenades_regen_time") + pow(e.hg_ammo, cvar("g_handgrenades_regen_power")) * cvar("g_handgrenades_regen_time") * cvar("g_handgrenades_regen_factor");
}

float HG_PlayerMayFire(entity p) {
    return p.hg_ammo || (p.hg_bonus && cvar("g_handgrenades_bonus_free"));
}

float HG_PlayerMayDetonate(entity p) {
    if(cvar("g_handgrenades_detonate_on_death"))
        return TRUE;
    return (p.health >= 1) && !(g_freezetag && p.freezetag_frozen);
}

void HG_Detonate(entity nade) {
    if(!nade || !nade.hg_detonable || nade.hg_detonatetime || nade.hg_detonateready > time)
        return;
    nade.hg_detonatetime = time + nade.hg_detonatedelay;
}

void HG_DetonateAll(entity plr) {    
    entity nade;
    
    if(!HG_PlayerMayDetonate(plr))
        return;
    
    for(;(nade = find(nade, classname, "hg_grenade"));)
        if(nade.owner == plr)
            HG_Detonate(nade);
}

void HG_Grenade_Think() {
	#define GV(v) (GRENVAR(self.hg_type, v))
    
    if(time >= self.hg_deathtime) {
        self.use();
        return;
    }
    
    if(self.hg_detonable && self.hg_detonatetime) {
        if(time >= self.hg_detonatetime) {
            self.use();
            return;
        } else if(time >= self.hg_nextsnd) {
            spamsound(self, CHAN_PROJECTILE, "weapons/rm_nadebeep.wav", VOL_BASE * 0.5, ATTN_NORM * 2);
            self.hg_sndcount += 1;
            self.hg_nextsnd = time + max((self.hg_detonatedelay * 0.3) / (pow(self.hg_sndcount, 1.2)), 0.1);
        }
    }
    
    self.nextthink = time;
    
    #undef GV
}

void HG_Grenade_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force) {
    if(self.hg_type == HG_REMOTE && DEATH_ISHG(deathtype))
        return;
	if(self.health <= 0)
		return;
	self.health = self.health - damage;
	if(self.health <= 0) {
        self.owner = attacker;
        self.hg_deathtime = time;
	}
}

float HG_PlayerGrenadeType(entity e) {
    float def = HG_NameToType(cvar_string("g_handgrenades_type"));
    float argc = tokenize_console(cvar_string("g_handgrenades_type_selectable"));
    float i;
    
    if(argc)
        for(i = 0; i < argc; ++i)
            if(e.hg_type_picked == HG_NameToType(argv(i)))
                return e.hg_type_picked;
    
    e.hg_type_picked = def;
    return def;
}

void HG_SetGrenadeType(entity p, float t) {
    p.hg_type = t;
    
    if(p.scorekeeper) {
        p.scorekeeper.SendFlags |= pow(2, SP_NADEMODE);
        p.scorekeeper.(scores[SP_NADEMODE]) = t;
    }
}

void HG_FixNadeType(entity p) {
    if(!p.hg_type) {
        print("Player ", p.netname, " ^7doesn't have a grenade type - fixing\n");
        HG_SetGrenadeType(p, HG_PlayerGrenadeType(p));
    }
}

void HG_Attack()
{
	#define GV(v) (GRENVAR(hgtype, v))
	float hgtype;
    float freebonus;
	
	if(time < self.hg_next)
		return;
	
    HG_FixNadeType(self);
	
	if(self.hg_bonus) {
		hgtype = self.hg_bonustype;
        freebonus = cvar("g_handgrenades_bonus_free");
	} else
		hgtype = self.hg_type;
	
    if(!freebonus && !self.hg_ammo)
        return;
    
    vector hitmins, hitmaxs;
    
    if(self.hg_type == HG_TRANSLOC+100) {
        hitmins = self.mins,
        hitmaxs = self.maxs;
    } else if(g_handgrenades_oldhitboxes) {
        hitmins = '0 0 -3';
        hitmaxs = '0 0 -3';
    } else {
        hitmins = '-8 -4 -3';
        hitmaxs = ' 8  4  3';
    }
    
	makevectors(self.v_angle);
	W_SetupShot_ProjectileSize (self, hitmins, hitmaxs, FALSE, 4, "weapons/grenade_fire.wav", GV("damage"));
	w_shotdir = v_forward;
	
	pointparticles(particleeffectnum("grenadelauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);
	
	entity gren = spawn();
	gren.owner = self;
	gren.classname = "hg_grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = GV("damage");
	gren.movetype = GV("movetype");
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = hgtype;
	gren.hg_type = hgtype;
    gren.hg_detonable = GV("detonable");
    gren.hg_detonatedelay = GV("detonate_delay");
    gren.hg_detonateready = time + GV("detonate_threshold");
    setsize(gren, hitmins, hitmaxs);
	setorigin(gren, w_shotorg);

	gren.hg_deathtime = ((self.hg_power == 1)? time + 0.01 : time + GV("lifetime"));
	gren.think = HG_Grenade_Think;
    gren.nextthink = time;
	gren.use = HG_Grenade_Explode;
	gren.touch = HG_Grenade_Touch;
    gren.team = self.team;
    gren.cnt = GV("bouncelimit");
    
    if(GV("takedamage")) {
        gren.takedamage = DAMAGE_AIM;
        gren.event_damage = HG_Grenade_Damage;
    } else {
        gren.takedamage = DAMAGE_NO;
        gren.event_damage = SUB_Null;
    }
    
	gren.health = GV("health");
	gren.damageforcescale = GV("damageforcescale");
    if(GV("launchspeed"))
        gren.velocity = w_shotdir * GV("speed") * self.hg_power + v_up * GV("speed_up") * self.hg_power;
    else
        gren.velocity = w_shotdir * GV("speed") + v_up * GV("speed_up");
	W_SetupProjectileVelocity(gren);
	
	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;
	
	CSQCProjectile(gren, TRUE, HG_TypeToCSQCProjType(hgtype), TRUE);
	
	if (hgtype == HG_NAPALM && self.hg_power == 1)
		Damage(self, self, self, GV("kamikaze_damage"), DEATH_SHOOTING_STAR, self.origin, '0 0 0');
		
	self.hg_next = time + GV("cooldown");
    
    if(!freebonus) {
        self.hg_ammo -= 1;
        self.hg_regentime = HG_RegenTime(self);
        //sprint(self, strcat("Regen time: ", ftos(self.hg_regentime), "\n"));
    }
    
    if(self.hg_bonus)
		self.hg_bonus -= 1;
	
	#undef GV
}

void HG_UpdateDetonables() {
    entity nade;
    self.hg_detonables = 0;
    
    for(;(nade = find(nade, classname, "hg_grenade"));)
        if(nade.owner == self && !nade.hg_detonatetime && nade.hg_detonable && nade.hg_detonateready <= time)
            self.hg_detonables += 1;
}

void HG_Frame()
{
	if(!g_handgrenades || time < game_starttime)
		return;
	
    HG_UpdateDetonables();
    HG_FixNadeType(self);
    
	float mayfire = (!g_grappling_hook || (!self.hook && !CustomCRAHookButton(self))) || self.hg_power;
	
	float held;
	held = self.BUTTON_HG;
	
	if((self.hg_power && !self.hg_state		)||
	   (g_freezetag && self.freezetag_frozen))
			held = 0;
	
	if(held && held != self.hg_state && !self.hg_ammo && self.deadflag == DEAD_NO && !g_grappling_hook)
		bigprint_spec(self, "Out of Grenades", "", 1);
	
	if(held && time >= self.hg_next && HG_PlayerMayFire(self) && mayfire) {
        float t = HG_PLAYERNADETYPE(self);
        float ls = GRENVAR(t, "launchspeed");
        
        if(ls)
            self.hg_power = bound(0, self.hg_power + frametime * ls, 1);
        else {
            self.hg_power = 0;
            HG_Attack();
        }
	} else
	{
		if(self.hg_state && mayfire)
			HG_Attack();
		self.hg_power = 0;
	}
	
	if(self.hg_power == 1 && mayfire)
		HG_Attack(); 	// inhand explosion
	
	self.hg_state = held;
    self.hg_regenpaused = time - self.lastdamage <= cvar("g_handgrenades_regen_damagepause");
    
    if(cvar("g_handgrenades_regen_time")) {
        float mx = cvar("g_handgrenades_regen_max");
        if(mx <= 0) mx = cvar("g_handgrenades_ammo");
        
        if(self.hg_ammo < mx && !self.hg_regenpaused) {
            float rate;
            rate = frametime;
            
            if(g_freezetag && self.freezetag_frozen)
                rate *= cvar("g_handgrenades_regen_frozenfactor");
            
            self.hg_regentime -= rate;
            
            if(self.hg_regentime <= 0) {
                self.hg_ammo += 1;
                self.hg_regentime = HG_RegenTime(self);
                //sprint(self, strcat("Regen time: ", ftos(self.hg_regentime), "\n"));
            }
        }
        
        self.hg_regenstat = bound(0, self.hg_regentime / HG_RegenTime(self), 1);
    }
}

void HG_PlayerSpawn()
{
    if(self.classname != "player")
        return;
    
    if(g_freezetag && self.freezetag_frozen)
        return;
    
	self.hg_power = 0;
	self.hg_ammo = (self.hg_clearammo? 0 : cvar("g_handgrenades_ammo"));
	self.hg_bonus = 0;
	self.hg_bonustype = HG_NORMAL;
    self.hg_regentime = HG_RegenTime(self);
    self.hg_clearammo = 0;
    HG_SetGrenadeType(self, HG_PlayerGrenadeType(self));
}

float HG_ShowMenu() {
    if(g_handgrenades && cvar_string("g_handgrenades_type_selectable") != "" && !self.hg_type_picked) {
        stuffcmd(self, strcat("set _nade_options \"", cvar_string("g_handgrenades_type_selectable"), "\"; menu_cmd update_rmvars; menu_shownadeselect\n"));
        return TRUE;
    }
    
    return FALSE;
}
