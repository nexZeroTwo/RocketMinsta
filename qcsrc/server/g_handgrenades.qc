
// Handgrenades mutator
// Intended for the Camping Rifle Arena mode

void HG_Init() {
    addstat(STAT_HGFORCE, AS_FLOAT, hg_power);
    addstat(STAT_HGAMMO, AS_INT, hg_ammo);
    addstat(STAT_HGREGEN, AS_FLOAT, hg_regenstat);
    addstat(STAT_HGREGENPAUSED, AS_INT, hg_regenpaused);
    addstat(STAT_HGDETONABLES, AS_INT, hg_detonables);
    addstat(STAT_HGLAUNCH, AS_FLOAT, hg_launchspeed);
    addstat(STAT_HGSHIELD, AS_FLOAT, hg_shield);
    addstat(STAT_HGSHIELDPOWER, AS_FLOAT, hg_shieldpower);
    addstat(STAT_HGTYPE, AS_INT, hg_type);
    addstat(STAT_HGBONUS, AS_INT, hg_bonus);
    addstat(STAT_HGBONUSTYPE, AS_INT, hg_bonustype);
    
    g_handgrenades_oldhitboxes = cvar("g_handgrenades_oldhitboxes");
    g_handgrenades_detonatelaunches = cvar("g_handgrenades_detonatelaunches");
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
    precache_sound("weapons/grenade_stick.wav");
    precache_sound("weapons/rm_nadebeep.wav");
    precache_sound("weapons/electro_bounce.wav");
    precache_sound("weapons/rocket_mode.wav");
    precache_sound("misc/powerup_shield.wav");
    precache_sound("kh/capture.wav");
    precache_model("models/mine.md3");
    precache_model("models/ctf/shield.md3");
    precache_model("models/shield_inner.md3");
}

void HG_GiveBonus(entity p, float hgtype, float amount, string reason) {
    if(p.hg_optout)
        return;
    
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
		if(g_freeze)
		if(e.frozen)
			continue;
		
		if(o.team == e.team && !BUFFS_PRESENT(o, BUFF_MEDIC))
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

	HG_Napalm_Burn(GRENVAR(self.hg_type, "burndelay"), GRENVAR(self.hg_type, "burnradius"), GRENVAR(self.hg_type, "burndamage"), GRENVAR(self.hg_type, "edgeburndamage"), GRENVAR(self.hg_type, "burntime"), self.hg_type);
	self.nextthink = time + GRENVAR(self.hg_type, "burndelay");
}

void HG_Napalm_Middlefire_Think() {
	if(time > self.pushltime) {
		remove(self);
		return;
	}
	
    /*
    if(time >= self.nextparticle) {
        
        float i; for(i = 0; i < 5; ++i) {
            vector v = randomvec();
            v_z = max(0, v_z * 0.3);
            pointparticles(particleeffectnum("fire_big"), self.origin + v * cvar("g_handgrenades_napalm_middleburnradius"), '0 0 0', 1);
        }
        
		self.nextparticle = time + 0.1 + random () * 0.5;
	}
    */
    
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
    
	proj.angles = vectoangles(proj.velocity);
	proj.flags = FL_PROJECTILE;
    proj.csqcprojectile_extradata = GRENVAR(self.hg_type, "burnradius");
    proj.team = self.owner.team;

	CSQCProjectile(proj, TRUE, PROJECTILE_HG_NAPALMSHARD, TRUE);
    proj.jb_proj_ownerstate = self.jb_proj_ownerstate;
}

void HG_Napalm_Explode() {
	local float c;
	for (c = 0; c < cvar("g_handgrenades_napalm_numparticles"); c ++) HG_Napalm();
	
	entity mid = spawn();
	mid.owner = self.owner;
	mid.origin = self.origin;
	setorigin(mid, mid.origin);
	mid.think = HG_Napalm_Middlefire_Think;
    mid.reset = SUB_Remove;
	mid.nextthink = time;
	mid.pushltime = time + cvar("g_handgrenades_napalm_fire_lifetime");
    mid.team = self.team;
    mid.csqcprojectile_extradata = cvar("g_handgrenades_napalm_middleburnradius");
	setsize(mid, '0 0 0', '0 0 0');
    
    CSQCProjectile(mid, TRUE, PROJECTILE_HG_NAPALMSHARD, TRUE);
}

void HG_Plasma_Projectile_Explode() {
	self.event_damage = SUB_Null;
	self.takedamage = DAMAGE_NO;
    self.damage_noinfo = FALSE;
	RadiusDamage(self, self.owner, cvar("g_handgrenades_plasma_projectile_damage"), cvar("g_handgrenades_plasma_projectile_edgedamage"), cvar("g_handgrenades_plasma_projectile_radius"), world, cvar("g_handgrenades_plasma_projectile_force"), self.projectiledeathtype, other);
	remove(self);
}

void HG_Plasma_Projectile_Think() {
    entity e;
    float found;
    
    if(time >= self.hg_detonatetime) {
        HG_Plasma_Projectile_Explode();
        return;
    }
    
    if(self.hg_plasma_projdist) {
        for(e = world; (e = findfloat(e, csqcprojectile_extradata, self.csqcprojectile_extradata));) if(e != self)
            if(e.owner == self.owner) if(e.projectiledeathtype == self.projectiledeathtype)
            if(vlen(self.origin - e.origin) < self.hg_plasma_projdist) {
                found = TRUE;
                break;
            }
        
        if(!found) {
            HG_Plasma_Projectile_Explode();
            return;
        }
    }
    
    if(time > self.hg_plasma_projdps_next) {
        float pdmg = self.hg_plasma_projdps * (time - self.hg_plasma_projdps_last);
        RadiusDamage(self, self.owner, pdmg, pdmg, self.hg_plasma_projrange, world, 0, self.projectiledeathtype, world);
        self.hg_plasma_projdps_next = time + self.hg_plasma_projdps_delay;
        self.hg_plasma_projdps_last = time;
    }
    
    self.nextthink = time;
}

void HG_Plasma_Projectile_Touch()
{
    PROJECTILE_TOUCH;
	if (other.takedamage == DAMAGE_AIM) {
		HG_Plasma_Projectile_Explode();
	} else {
		spamsound(self, CHAN_PROJECTILE, "weapons/electro_bounce.wav", VOL_BASE, ATTN_NORM);
	}
}

void HG_Plasma_Projectile() {
	local entity proj;
    vector kick;
    
	proj = spawn();
	proj.classname = "plasma";
	proj.owner = self.owner;
    proj.team = proj.owner.team;
	proj.use = HG_Plasma_Projectile_Explode;
	proj.think = HG_Plasma_Projectile_Think;
    proj.nextthink = time;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = cvar("g_handgrenades_plasma_projectile_damage");
    proj.hg_detonatetime = time + cvar("g_handgrenades_plasma_projectile_lifetime") + random() * cvar("g_handgrenades_plasma_projectile_lifetime_randomfactor");
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = HG_PLASMA_SHARD;
	setorigin(proj, self.origin);
    
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
	proj.touch = HG_Plasma_Projectile_Touch;
	setsize(proj, '0 0 -3', '0 0 -3');
	proj.takedamage = DAMAGE_NO;
	proj.flags = FL_PROJECTILE;
    proj.hg_plasma_projrange = cvar("g_handgrenades_plasma_projectile_dps_range");
    proj.hg_plasma_projdps = cvar("g_handgrenades_plasma_projectile_dps");
    proj.hg_plasma_projdps_delay = cvar("g_handgrenades_plasma_projectile_dps_delay");
    proj.hg_plasma_projdist = cvar("g_handgrenades_plasma_projectile_maxdistance");
    proj.hg_plasma_projdps_last = time;
    proj.hg_plasma_projdps_next = time + proj.hg_plasma_projdps_delay;
    proj.csqcprojectile_extradata = hg_plasma_group;
    proj.damage_noinfo = TRUE;
    
    sound(proj, CHAN_WEAPON, "weapons/electro_fire2.wav", VOL_BASE, ATTN_NORM);
	CSQCProjectile(proj, TRUE, PROJECTILE_ELECTRO, FALSE);
    proj.jb_proj_ownerstate = self.jb_proj_ownerstate;
}

void HG_Plasma_Explode() {
    float c;
    ++hg_plasma_group;
    for (c = 0; c < cvar("g_handgrenades_plasma_projectile_count"); c ++) HG_Plasma_Projectile();
}

void HG_Remote_Explode() {
    float c;
    for (c = 0; c < cvar("g_handgrenades_remote_numparticles"); c ++) HG_Napalm();
}

void HG_Translocator_Explode() {
    if(g_jailbreak && self.owner.jb_isprisoned)
        return;
        
    if(time < self.jb_jail_resettime)
        return;
    
    setsize(self, self.owner.mins, self.owner.maxs);
    
    if(!move_out_of_solid(self)) {
        if(!self.hg_isbonus)
            self.owner.hg_ammo += 1;
            
        bprint("^1Couldn't move ", self.owner.netname, "^1's translocator out of solid! Teleport aborted. Origin: ", vtos(self.origin), ", velocity: ", vtos(self.velocity), "\n");
        return;
    }
    
    vector a;
    a = vectoangles(normalize(self.velocity));
    a_x = self.owner.v_angle_x;
    makevectors(a);
    
    tdeath_hit = 0;
    tdeath_deathtype = self.hg_type;
    TeleportPlayer(self.owner, self.owner, self.origin, a, v_forward * (
                    GRENVAR(self.hg_type, "push_base")
                  + GRENVAR(self.hg_type, "push_playerfactor") * vlen(self.owner.velocity)
                  + GRENVAR(self.hg_type, "push_projfactor")   * vlen(self.velocity)), '0 0 0', '0 0 0');
    tdeath_deathtype = 0;
    if(tdeath_hit && !self.hg_isbonus) {
        float b = cvar("g_handgrenades_transloc_telefragbonus");
        
        if(b) {
            self.owner.hg_ammo += b * tdeath_hit;
            self.owner.hg_regentime = HG_RegenTime(self.owner);
        }
    }
    
    entity oldself = self;
    self = self.owner;
    if(GRENVAR(oldself.hg_type, "reloadonuse")) {
        weapon_action(self.weapon, WR_RESETPLAYER);
        ATTACK_FINISHED(self) = TRUE;
    }
    self = oldself;
}

float HG_TypeToCSQCProjType(float t) {
	switch(t) {
		case HG_NAPALM  :   return PROJECTILE_HG_NAPALM;
		case HG_PLASMA  :   return PROJECTILE_HG_PLASMA;
        case HG_TRANSLOC:   return PROJECTILE_HG_TRANSLOC;
        case HG_REMOTE  :   return PROJECTILE_HG_REMOTE;
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
	HG_Grenade_Remove();
}
#undef GV

void HG_Grenade_Touch() {
    if(self.hg_type == HG_TRANSLOC) {
        if(SUB_NoImpactCheck()) {
            if(trace_dphitcontents & DPCONTENTS_PLAYERCLIP)
                goto troll;
                
            self.use();
            return;
        }
    }
    
    if(SUB_OwnerCheck())
        return;
    
    if(SUB_NoImpactCheck()) {
        HG_Grenade_Remove();
        return;
    }
    
    if(!self.hg_remote_sticked)
    if(trace_ent && trace_ent.solid > SOLID_TRIGGER) {
        UpdateCSQCProjectileNextFrame(self);
    }

:troll
	if(other.takedamage == DAMAGE_AIM && !(teams_matter && other.team == self.owner.team && self.hg_type == HG_TRANSLOC)) {
        if(self.hg_type == HG_REMOTE)
            goto anothertroll;
            
        self.use();
	} else {
        self.hg_normal = trace_plane_normal;
        if(self.cnt <= 0) {
            if(self.hg_type == HG_REMOTE) {
                spamsound(self, CHAN_PROJECTILE, "weapons/grenade_stick.wav", 1, ATTN_NORM);
                HG_Remote_Stick();
            } else
                self.use();
            return;
        }

:anothertroll
		float r;
		r = random() * 6;
		if(r < 1)
			spamsound(self, CHAN_PROJECTILE, "weapons/grenade_bounce1.wav", VOL_BASE, ATTN_NORM);
		else if(r < 2)
			spamsound(self, CHAN_PROJECTILE, "weapons/grenade_bounce2.wav", VOL_BASE, ATTN_NORM);
		else if(r < 3)
			spamsound(self, CHAN_PROJECTILE, "weapons/grenade_bounce3.wav", VOL_BASE, ATTN_NORM);
		else if(r < 4)
			spamsound(self, CHAN_PROJECTILE, "weapons/grenade_bounce4.wav", VOL_BASE, ATTN_NORM);
		else if(r < 5)
			spamsound(self, CHAN_PROJECTILE, "weapons/grenade_bounce5.wav", VOL_BASE, ATTN_NORM);
		else
			spamsound(self, CHAN_PROJECTILE, "weapons/grenade_bounce6.wav", VOL_BASE, ATTN_NORM);
        
        self.cnt -= 1;
	}
}

void HG_Remote_Stick() {
    vector normal = trace_plane_normal;
    entity e = spawn();
    float d = self.owner.hg_detonables;
    
    e.classname = self.classname;
    e.bot_dodge = self.bot_dodge;
    e.bot_dodgerating = self.bot_dodgerating;
    e.owner = self.owner;
    e.angles = vectoangles(-normal);
    e.skin = TeamColorSkin(e.owner.team);
    setmodel(e, "models/mine.md3");
    e.damageforcescale = self.damageforcescale;
    e.health = self.health;
    e.takedamage = self.takedamage;
    e.event_damage = self.event_damage;
    e.solid = self.solid;
    e.dphitcontentsmask = self.dphitcontentsmask;
    e.use = self.use;
    e.movetype = MOVETYPE_NONE;
    e.hg_type = self.hg_type;
    e.projectiledeathtype = self.projectiledeathtype;
    e.think = self.think;
    e.think = HG_Grenade_Think;
    e.nextthink = self.nextthink;
    e.flags = self.flags;
    e.team = self.team;
    e.hg_remote_sticked = TRUE;
    e.hg_deathtime = self.hg_deathtime;
    e.hg_sndcount = self.hg_sndcount;
    e.hg_nextsnd = self.hg_nextsnd;
    e.hg_detonable = self.hg_detonable;
    e.hg_detonatetime = self.hg_detonatetime;
    e.hg_detonatedelay = self.hg_detonatedelay;
    e.hg_detonable_updated = self.hg_detonable_updated;
    e.reset = self.reset;
    e.jb_proj_ownerstate = self.jb_proj_ownerstate;
    setsize(e, '-4 -4 -4', '4 4 4');
    setorigin(e, self.origin);
    
    if(normal_x)
        setorigin(e, e.origin + v_forward * 4 * abs(normal_x));
    if(normal_z)
        setorigin(e, e.origin - v_forward * 5 * abs(normal_z));
    
    move_out_of_solid(e);
    
    if(self.hg_waypoint)
        WaypointSprite_Kill(self.hg_waypoint);
    HG_Grenade_Remove();
    self = e;
    
    self.owner.hg_detonables = d;
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
    return (p.health >= 1) && !(g_freeze && p.frozen);
}

void HG_Detonate(entity nade) {
    if(!nade || !nade.hg_detonable || nade.hg_detonatetime || nade.hg_detonateready > time)
        return;
        
    nade.hg_detonatetime = time + nade.hg_detonatedelay;
    if(nade.hg_detonable_updated && nade.owner) {
        nade.hg_detonable_updated = FALSE;
        nade.owner.hg_detonables -= 1;
    }
}

void HG_DetonateAll(entity plr) {    
    entity nade;
    
    if(!plr.hg_detonables)
        return;
    
    if(!HG_PlayerMayDetonate(plr))
        return;
    
    sound(plr, CHAN_WEAPON2, "weapons/rocket_mode.wav", VOL_BASE, ATTN_NORM);
    
    for(;(nade = find(nade, classname, "hg_grenade"));)
        if(nade.owner == plr)
            HG_Detonate(nade);
}

void HG_Grenade_Remote_Waypoint_Update(string wpname) {
    if(!self.hg_waypoint) {
        WaypointSprite_Spawn(wpname, 0, 0, self, '0 0 32', self.owner, 0, self, hg_waypoint, 1);
    } else {
        WaypointSprite_UpdateSprites(self.hg_waypoint, wpname, "", "");
    }
}

void HG_Grenade_Waypoint() {
    entity plr;
    float detected;
    float rng;
    
    if(time < self.hg_wp_nextthink)
        return;
    
    if(time < self.jb_defendthink_next)
        return;
    
    rng = max(0, GRENVAR(self.hg_type, "detect_enemies"));
    
    if(!rng) {
        if(self.hg_waypoint)
            WaypointSprite_Disown(self.hg_waypoint, 0.5);
        return;
    }
    
    FOR_EACH_PLAYER(plr) if(plr.team != self.team || !teams_matter) if(plr != self.owner) if(!(g_freeze && plr.frozen)) {
        if(vlen(self.origin - plr.origin) < rng)
        if(checkpvs(self.origin, plr)) {
            detected = TRUE;
            break;
        }
    }
    
    if(detected) {
        if(!self.hg_wp_state) {
            HG_Grenade_Remote_Waypoint_Update("pointer_red");
            self.hg_wp_state = TRUE;
        }
    } else if(self.hg_wp_state || !self.hg_waypoint) {
        HG_Grenade_Remote_Waypoint_Update("pointer_cyan");
        self.hg_wp_state = FALSE;
    }
    
    self.hg_wp_nextthink = time + 0.1;
}

void HG_Grenade_Think() {
	#define GV(v) (GRENVAR(self.hg_type, v))
    
    if(self.hg_type == HG_TRANSLOC) {
        tracebox(self.origin, self.mins, self.maxs, self.origin, MOVE_WORLDONLY, self);
        if(trace_startsolid && !self.hg_ranthink) {
            bprint(self.owner.netname, "^1's translocator spawned in solid! ", vtos(self.origin), "\n");
            HG_Grenade_Remove();
            return;
        }
    }
    
    HG_Grenade_Waypoint();
    
    //move_out_of_solid(self);
    if(time >= self.hg_deathtime) {
        self.use();
        return;
    }
    
    if(self.hg_detonable)
    if(time >= self.hg_detonateready)
    if(!self.hg_detonatetime)
    if(!self.hg_detonable_updated) {
        self.hg_detonable_updated = TRUE;
        self.owner.hg_detonables += 1;
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
    self.hg_ranthink += 1;
    #undef GV
}

void HG_Grenade_ChangeOwner(entity o) {
    if(!o || o == self.owner)
        return;
    
    if(self.hg_detonable_updated) {
        self.owner.hg_detonables -= 1;
        o.hg_detonables += 1;
    }
    
    self.owner = o;
    self.team = o.team;
}

void HG_Grenade_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force) {
    if(DEATH_ISHG(deathtype))
        return;
	if(self.health <= 0)
		return;
	self.health = self.health - damage;
	if(self.health <= 0) {
        if(attacker.classname == "player") {
            HG_Grenade_ChangeOwner(attacker);
        }
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

void HG_Grenade_Remove() {
    if(self.hg_waypoint)
        WaypointSprite_Disown(self.hg_waypoint, 0.5);
    stopsound(self, CHAN_PAIN);
    
    if(self.hg_detonable_updated && self.owner)
        self.owner.hg_detonables -= 1;
    
    remove(self);
}

void HG_ShieldModel_Think() {
    if(self.owner.hg_shield)
        self.alpha = approach(self.alpha, 1, frametime * 3);
    else
        self.alpha = approach(self.alpha, 0, frametime * 3);
        
    if(!self.alpha) {
        self.owner.hg_shieldmodel = world;
        remove(self);
        return;
    }
    
    self.colormod = '1 1 0';
    self.colormod_z = 1 - self.owner.hg_shieldpower;
    setorigin(self, self.owner.origin);
    self.nextthink = time;
}

void HG_Shield(float hgtype) {
    entity e;
    
    self.hg_shieldmax = GRENVAR(hgtype, "duration");
    self.hg_shield = self.hg_shieldmax;
    self.hg_shieldhealth = GRENVAR(hgtype, "health");
    self.hg_shieldpower = 1;
    sound(self, CHAN_AUTO, "misc/powerup_shield.wav", VOL_BASE, ATTN_NORM);
    
    if(!self.hg_shieldmodel) {
        e = spawn();
        e.classname = "hg_shieldmodel";
        e.owner = self;
        e.think = HG_ShieldModel_Think;
        e.nextthink = time;
        e.alpha = 0.1;
        e.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
        e.glow_size = 256;
        e.glow_color = 230;
        e.glow_trail = 1;
        e.avelocity = '14 0 22';
        e.movetype = MOVETYPE_FOLLOW;
        e.aiment = e.owner;
        setorigin(e, self.origin);
        setmodel(e, "models/ctf/shield.md3");
        e.scale = 0.5;
        setsize(e, e.scale * e.mins, e.scale * e.maxs);
        
        self.hg_shieldmodel = e;
    }
}

void HG_Shield_Frame() {
    if(!self.hg_shield)
        return;
    
    if(self.hg_shieldhealth <= 0)
        self.hg_shield = 0;
    else {
        self.hg_shield = max(0, self.hg_shield - frametime);
        if(cvar("g_handgrenades_shield_diminish"))
            self.hg_shieldpower = self.hg_shield / self.hg_shieldmax;
    }
}

.float spawntime;
.float hg_linker_nexteffect;

void HG_Linker_Think() {
    entity p, e;
    float denom, thealth, tarmor;
    
    FOR_EACH_PLAYER(p) {
        if(p.team != self.team) {
            if(p.hg_linker == self)
                p.hg_linker = world;
        } else if(p.hg_linker == self) {
            if(vlen(self.origin - p.origin) > self.hg_linker_range)
                p.hg_linker = world;
        } else if(!p.hg_linker) {
            if(vlen(self.origin - p.origin) <= self.hg_linker_range)
                p.hg_linker = self;
        }
        
        if(p.hg_linker == self) IF_HG_LINKER_APPLICABLE(p) {
            if(time > self.hg_linker_nexteffect) {
                ++denom;
                thealth += p.health;
                tarmor += p.armorvalue;
                
                FOR_EACH_PLAYER(e) if(e != p) if(e.hg_linker == self) IF_HG_LINKER_APPLICABLE(e) {
                    te_csqc_lightningarc(p.origin, e.origin, FALSE, e.team);
                }
            }
        }
    }
    
    if(time > self.hg_linker_nexteffect) {
        self.hg_linker_nexteffect = time + 1;
        
        if(denom > 1) {
            sound(self, CHAN_AUTO, "kh/capture.wav", 0.4, 1.5);
            FOR_EACH_PLAYER(p) if(p.hg_linker == self) IF_HG_LINKER_APPLICABLE(p) {
                p.health = thealth / denom;
                p.armorvalue = tarmor / denom;
                p.pauserothealth_finished = max(p.pauserothealth_finished, time + 1);
                p.pauserotarmor_finished = max(p.pauserotarmor_finished, time + 1);
            }
        }
    }
    
    self.alpha = bound(0, (self.cnt - time) * 2, 1);
    
    if(self.alpha == 0) {
        remove(self.enemy);
        remove(self);
    }
    
    self.alpha = max(0.01, self.alpha * bound(0, (time - self.spawntime) * 2, 1));
    self.enemy.alpha = self.alpha * 0.7;
    self.glow_size = self.hg_linker_range * self.alpha * 3;
    self.nextthink = time;
}

void HG_Linker(float hgtype) {
    entity e = spawn();
    e.classname = "hg_linker";
    e.owner = self;
    e.team = self.team;
    e.think = HG_Linker_Think;
    e.nextthink = time;
    e.spawntime = time;
    e.reset = SUB_Remove;
    e.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
    e.movetype = MOVETYPE_NONE;
    e.hg_linker_range = GRENVAR(hgtype, "range");
    e.hg_linker_factor = GRENVAR(hgtype, "damagefactor");
    e.cnt = time + GRENVAR(hgtype, "duration");
    e.alpha = 0.01;
    setmodel(e, "models/ctf/shield.md3");
    if(e.team) e.skin = TeamColorSkin(e.team);
    e.scale = e.hg_linker_range / e.maxs_x;
    e.glow_color = 0xF5;
    setorigin(e, self.origin);
    
    e.enemy = spawn();
    e.enemy.owner = e;
    e.enemy.effects = e.effects;
    //e.enemy.colormod = TeamColor(e.team);
    e.enemy.movetype = e.movetype;
    e.enemy.scale = e.scale;
    e.enemy.reset = SUB_Remove;
    e.enemy.alpha = e.alpha;
    e.enemy.skin = e.skin;
    setmodel(e.enemy, "models/shield_inner.md3");
    setorigin(e.enemy, e.origin);
    
    sound(e, CHAN_PROJECTILE, "misc/powerup.wav", 1, 1.5);
}

void HG_Attack()
{
    #define GV(v) (GRENVAR(hgtype, v))
    float hgtype;
    float freebonus;
    
    if(self.deadflag != DEAD_NO)
        return;
    
    HG_FixNadeType(self);
    
    if(self.hg_bonus) {
        hgtype = self.hg_bonustype;
        freebonus = cvar("g_handgrenades_bonus_free");
    } else {
        if(time < self.hg_next)
            return;
            
        hgtype = self.hg_type;
    }
    
    if(!freebonus && !self.hg_ammo)
        return;
    
    if(hgtype == HG_SHIELD) {
        // shield is special
        HG_Shield(hgtype);
        goto finish;
    } else if(hgtype == HG_LINKER) {
        HG_Linker(hgtype);
        goto finish;
    }
    
    vector hitmins, hitmaxs;
    
    if(g_handgrenades_oldhitboxes) {
        hitmins = '0 0 -3';
        hitmaxs = '0 0 -3';
    } else {
        hitmins = '-8 -4 -3';
        hitmaxs = ' 8  4  3';
    }
    
	makevectors(self.v_angle);
	W_SetupShot_ProjectileSize(self, hitmins, hitmaxs, FALSE, 4, "weapons/grenade_fire.wav", GV("damage"));
	//w_shotdir = v_forward;
	
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
    gren.gravity = GV("gravity");
    setsize(gren, hitmins, hitmaxs);
	setorigin(gren, w_shotorg);

	gren.hg_deathtime = ((self.hg_power == 1)? time + 0.01 : time + GV("lifetime"));
	gren.think = HG_Grenade_Think;
    gren.nextthink = time;
	gren.use = HG_Grenade_Explode;
	gren.touch = HG_Grenade_Touch;
    gren.reset = HG_Grenade_Remove;
    gren.team = self.team;
    gren.cnt = GV("bouncelimit");
    gren.hg_isbonus = self.hg_bonus;
    
    if(gren.hg_type == HG_TRANSLOC)
        gren.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP;
    
    if(GV("takedamage")) {
        gren.takedamage = DAMAGE_AIM;
        gren.event_damage = HG_Grenade_Damage;
    } else {
        gren.takedamage = DAMAGE_NO;
        gren.event_damage = SUB_Null;
    }
    
	gren.health = GV("health");
	gren.damageforcescale = GV("damageforcescale");
    
    float spd  = GV("speed");
    float mspd = GV("speed_min");
    
    if(GV("launchspeed") && !g_handgrenades_detonatelaunches) {
        gren.velocity = w_shotdir * (mspd + (spd-mspd) * self.hg_power) + v_up * GV("speed_up") * self.hg_power;
    } else
        gren.velocity = w_shotdir * spd + v_up * GV("speed_up");
        
	W_SetupProjectileVelocity(gren);
	
	gren.angles = vectoangles(gren.velocity);
	gren.flags = FL_PROJECTILE;
    
	CSQCProjectile(gren, TRUE, HG_TypeToCSQCProjType(hgtype), TRUE);
	
	if(hgtype == HG_NAPALM && self.hg_power == 1)
		Damage(self, self, self, GV("kamikaze_damage"), DEATH_SHOOTING_STAR, self.origin, '0 0 0');

:finish
    self.hg_next = time + GV("cooldown") * (BUFFS_PRESENT(self, BUFF_HASTE)? cvar("g_buffs_haste_refire_rate") : 1);
    
    if(!freebonus) {
        self.hg_ammo -= 1;
        self.hg_regentime = HG_RegenTime(self);
    }
    
    if(self.hg_bonus)
		self.hg_bonus -= 1;
    
    self.hg_nadesused += 1;
	
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
    if(!g_handgrenades)
        return;
    
    if(time < game_starttime)
        return;
    
    if(self.hg_linker && wasfreed(self.hg_linker))
        self.hg_linker = world;
    
    HG_FixNadeType(self);
    HG_Shield_Frame();
    
    if(roundstate == ROUNDSTATE_OVER) {
        self.hg_power = 0;
        return;
    }
    
	float mayfire = (!g_grappling_hook || (!self.hook && !CustomHGHookButton(self))) || self.hg_power;
	
	float held;
	held = self.BUTTON_HG;
	
	if((self.hg_power && !self.hg_state		)||
	   (g_freeze && self.frozen)||
       (g_jailbreak && self.jb_isprisoned))
			held = 0;
	
    if(held && held != self.hg_state && !self.hg_ammo && self.deadflag == DEAD_NO)
        bigprint_spec(self, strcat("Out of ", HG_TypeToExpandedName(self.hg_type), "s!"), "", 1);
	
	if(held && (time >= self.hg_next || self.hg_bonus) && HG_PlayerMayFire(self) && mayfire) {
        float t = HG_PLAYERNADETYPE(self);
        float ls;
        
        if(!g_handgrenades_detonatelaunches)
            ls = GRENVAR(t, "launchspeed");
        
        self.hg_launchspeed = ls;
        
        if(ls)
            self.hg_power = bound(0, self.hg_power + frametime * ls, 1);
        else {
            self.hg_power = 0;
            HG_Attack();
        }
	} else {
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
            
            if(g_freeze && self.frozen)
                rate *= cvar("g_handgrenades_regen_frozenfactor");
            rate *= GRENVAR(self.hg_type, "regenscale");
            if(BUFFS_PRESENT(self, BUFF_SUPPLY))
                rate *= cvar("g_buffs_supply_hg_regenscale");
            
            self.hg_regentime -= rate;
            
            if(self.hg_regentime <= 0) {
                self.hg_ammo += 1;
                self.hg_regentime = HG_RegenTime(self);
                //sprint(self, strcat("Regen time: ", ftos(self.hg_regentime), "\n"));
            }
        }
        
        self.hg_regenstat = bound(0, self.hg_regentime / HG_RegenTime(self), 1);
    }
    
    if(self.hg_detonatepressed)
        self.hg_detonatepressed = FALSE;
}

void HG_ResetState(entity p) {
    p.hg_power = 0;
    p.hg_ammo = (p.hg_clearammo? 0 : cvar("g_handgrenades_ammo"));
    p.hg_bonus = 0;
    p.hg_bonustype = HG_NORMAL;
    p.hg_regentime = HG_RegenTime(self);
    p.hg_clearammo = 0;
    p.hg_shield = 0;
    HG_SetGrenadeType(p, HG_PlayerGrenadeType(p));
}

void HG_PlayerSpawn()
{
    if(self.classname != "player")
        return;
    
    if(cvar("g_handgrenades_resetonrespawn"))
        HG_ResetState(self);
        
    self.hg_shield = 0;
    HG_UpdateDetonables();
}

void HG_PlayerSpawnEx(entity p) {
    entity o;
    o = self;
    self = p;
    HG_PlayerSpawn();
    self = o;
}

void HG_PlayerJoin() {
    if(self.classname != "player")
        return;
        
    if((g_freeze && self.frozen) || (g_jailbreak && self.jb_isprisoned))
        self.hg_clearammo = TRUE;
    
    HG_ResetState(self);
    HG_UpdateDetonables();
}

float HG_ShowMenu(float always) {
    if(g_handgrenades && cvar_string("g_handgrenades_type_selectable") != "" && (always || !self.hg_type_picked)) {
        stuffcmd(self, strcat("set _nade_options \"", cvar_string("g_handgrenades_type_selectable"), "\"; menu_cmd update_rmvars; menu_shownadeselect\n"));
        return TRUE;
    }
    
    return FALSE;
}
