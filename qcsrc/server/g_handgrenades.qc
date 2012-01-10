
// Handgrenades mutator
// Intended for the Camping Rifle Arena mode

void HG_Napalm_Burn (float dt, float dist, float damage, float edgedamage, float burntime)
{
	entity e;
	float d;
	vector p;

	for(e = findradius(self.origin, dist); e; e = e.chain) if(e.classname == "player")
	//if(e != self.owner) if(e.takedamage == DAMAGE_AIM) if(e.classname != "player" || !self.owner || IsDifferentTeam(e, self))
	{
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
			Fire_AddDamage(e, self.owner, d * burntime, burntime, self.projectiledeathtype | HITTYPE_BOUNCE);
		}
	}
}

void HG_Napalm_Think ()
{
	if (time > self.pushltime)
	{
		remove (self);
		return;
	}

	HG_Napalm_Burn (0.1, cvar ("g_explosive_napalm_burnradius"), cvar ("g_explosive_napalm_burndamage"), cvar ("g_explosive_napalm_edgeburndamage"), cvar ("g_explosive_napalm_burntime"));
	if (time >= self.nextparticle)
	{
		pointparticles (particleeffectnum ("fire_big"), self.org_explosion + (self.origin - self.org_explosion) * random (), '0 0 0', 1);
		self.nextparticle = time + 0.2 + random () * 0.2;
	}

	self.nextthink = time + 0.1;
}

void HG_Napalm_Middlefire_Think() {
	if(time > self.pushltime) {
		remove (self);
		return;
	}
	
	HG_Napalm_Burn(0.1, cvar("g_explosive_napalm_middleburnradius"), cvar("g_explosive_napalm_burndamage"), cvar("g_explosive_napalm_edgeburndamage"), cvar("g_explosive_napalm_burntime"));
	self.nextthink = time + 0.1;
}

void HG_Napalm (void)
{
	local entity proj;
	local vector kick;

	proj = spawn ();
	proj.owner = self.owner;
	proj.classname = "grenade";
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = cvar ("g_explosive_napalm_burndamage");
	proj.movetype = MOVETYPE_BOUNCE;
	proj.projectiledeathtype = WEP_FIREBALL;
	proj.touch = W_Firemine_Touch;
	PROJECTILE_MAKETRIGGER(proj);
	setsize (proj, '0 0 0', '0 0 0');
	setorigin (proj, self.origin);
	proj.org_explosion = self.origin;
	proj.think = HG_Napalm_Think;
	proj.nextthink = time;
	proj.damageforcescale = cvar ("g_explosive_napalm_damageforcescale");
	kick_x = (random () - 0.5) * 2 * cvar ("g_explosive_napalm_spread_xy");
	kick_y = (random () - 0.5) * 2 * cvar ("g_explosive_napalm_spread_xy");
	kick_z = random () * cvar ("g_explosive_napalm_spread_z");
	proj.velocity = kick;
	proj.pushltime = time + cvar ("g_explosive_napalm_lifetime");
	W_SetupProjectileVelocity(proj);

	proj.angles = vectoangles(proj.velocity);
	proj.flags = FL_PROJECTILE;

	CSQCProjectile(proj, TRUE, PROJECTILE_FIREMINE, TRUE);
}

void HG_Napalm_Init (void)
{
	local float c;
	for (c = 0; c < cvar ("g_explosive_napalm_numparticles"); c ++) HG_Napalm ();
	
	// since we have a ton of fire in the middle, let's make it a real fire
	entity mid = spawn();
	mid.owner = self.owner;
	mid.origin = self.origin;
	setorigin(mid, mid.origin);
	mid.think = HG_Napalm_Middlefire_Think;
	mid.nextthink = time;
	mid.pushltime = time + cvar ("g_explosive_napalm_lifetime");
	setsize(mid, '0 0 0', '0 0 0');
}

void HG_Attack()
{
	if(time < self.hg_next || !self.hg_ammo)
		return;
	
	makevectors(self.v_angle);
	self.hg_type = HG_NAPALM;
	W_Grenade_Attack2_Real(self.hg_power, self.hg_power == 1, self.hg_type); // hack hack
	if (self.hg_type == HG_NAPALM && self.hg_power == 1)
		Damage (self, self, self, cvar ("g_explosive_napalm_kamikaze_damage"), DEATH_SHOOTING_STAR, self.origin, '0 0 0');
	self.hg_next = time + cvar("g_explosive_handgrenades_mindelay");
	self.hg_ammo -= 1;
}

void HG_Frame()
{
	if(!g_handgrenades)
		return;
	
	float held;
	held = self.BUTTON_HG;
	
	if((self.hg_power && !self.hg_state		)||
	   (g_freezetag && self.freezetag_frozen))
			held = 0;
	
	if(held && held != self.hg_state && !self.hg_ammo && self.deadflag == DEAD_NO)
		bigprint_spec(self, "out of grenades", "", 1);
	
	if(held && time >= self.hg_next && self.hg_ammo)
		self.hg_power = bound(0,
			self.hg_power + frametime *
			cvar("g_explosive_handgrenades_speed"),
		1);
	else
	{
		self.hg_power = bound(0,
			self.hg_power - frametime *
			cvar("g_explosive_handgrenades_clearspeed"),
		1);
		
		if(self.hg_state)
			HG_Attack();
	}
	
	if(self.hg_power == 1)
		HG_Attack(); 	// inhand explosion
	
	self.hg_state = held;
}

void HG_PlayerSpawn()
{
	self.hg_power = 0;
	self.hg_ammo = cvar("g_explosive_handgrenades_ammo");
}
