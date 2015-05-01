
void W_Shotgun_Attack (void)
{
	float	sc;
	float	ammoamount;
	float	bullets;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	local entity flash;

	ammoamount = CVAR(g_balance_shotgun_primary_ammo);
	bullets = CVAR(g_balance_shotgun_primary_bullets);
	d = CVAR(g_balance_shotgun_primary_damage);
	f = CVAR(g_balance_shotgun_primary_force);
	spread = CVAR(g_balance_shotgun_primary_spread);
	bulletspeed = CVAR(g_balance_shotgun_primary_speed);
	bulletconstant = CVAR(g_balance_shotgun_primary_bulletconstant);

	W_SetupShot (self, CVAR(g_antilag_bullets) && bulletspeed >= CVAR(g_antilag_bullets), 5, "weapons/shotgun_fire.wav", CVAR(g_balance_shotgun_primary_damage));
	for (sc = 0;sc < bullets;sc = sc + 1)
		fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, 0, f, WEP_SHOTGUN, 0, 1, bulletconstant);
	endFireBallisticBullet();
	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_shells = self.ammo_shells - ammoamount;

	pointparticles(particleeffectnum("shotgun_muzzleflash"), w_shotorg_visual, w_shotdir_visual * 1000, CVAR(g_balance_shotgun_primary_ammo));

	// casing code
	if (CVAR(g_casings) >= 1)
		for (sc = 0;sc < ammoamount;sc = sc + 1)
			SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 30) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 1, self);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '5 0 0');

}

void W_Shotgun_Attack2 (void)
{
	float	sc;
	float	ammoamount;
	float	bullets;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	local entity flash;

	ammoamount = CVAR(g_balance_shotgun_secondary_ammo);
	bullets = CVAR(g_balance_shotgun_secondary_bullets);
	d = CVAR(g_balance_shotgun_secondary_damage);
	f = CVAR(g_balance_shotgun_secondary_force);
	spread = CVAR(g_balance_shotgun_secondary_spread);
	bulletspeed = CVAR(g_balance_shotgun_secondary_speed);
	bulletconstant = CVAR(g_balance_shotgun_secondary_bulletconstant);

	W_SetupShot (self, CVAR(g_antilag_bullets) && bulletspeed >= CVAR(g_antilag_bullets), 5, "weapons/shotgun_fire.wav", CVAR(g_balance_shotgun_secondary_damage));
	for (sc = 0;sc < bullets;sc = sc + 1)
		fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, 0, f, WEP_SHOTGUN | HITTYPE_SECONDARY, 0, 1, bulletconstant);
	endFireBallisticBullet();
	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_shells = self.ammo_shells - ammoamount;

	pointparticles(particleeffectnum("shotgun_muzzleflash"), w_shotorg_visual, w_shotdir_visual * 1000, CVAR(g_balance_shotgun_secondary_ammo));

	// casing code
	if (CVAR(g_casings) >= 1)
		for (sc = 0;sc < ammoamount;sc = sc + 1)
			SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 30) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 1, self);

	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.scale = 1.2;
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '5 0 0');
}

// weapon frames
void shotgun_fire2_03()
{
    if(!PlayerMayFire(self)) {
        w_ready();
        return;
    }

	W_Shotgun_Attack2();
	weapon_thinkf(WFRAME_FIRE2, CVAR(g_balance_shotgun_secondary_animtime), w_ready);
}
void shotgun_fire2_02()
{
    if(!PlayerMayFire(self)) {
        w_ready();
        return;
    }

	W_Shotgun_Attack2();
	weapon_thinkf(WFRAME_FIRE2, CVAR(g_balance_shotgun_secondary_animtime), shotgun_fire2_03);
}

void spawnfunc_weapon_shotgun(); // defined in t_items.qc

float w_shotgun(float req)
{
	if (req == WR_AIM)
		if(vlen(self.origin-self.enemy.origin)>200)
			self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
		else
			self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK)
		if (weapon_prepareattack(0, CVAR(g_balance_shotgun_primary_refire)))
		{
			W_Shotgun_Attack();
			weapon_thinkf(WFRAME_FIRE1, CVAR(g_balance_shotgun_primary_animtime), w_ready);
		}
		if (self.BUTTON_ATCK2)
		if (cvar("g_balance_shotgun_secondary"))
		if (weapon_prepareattack(1, CVAR(g_balance_shotgun_secondary_refire)))
		{
			W_Shotgun_Attack2();
			weapon_thinkf(WFRAME_FIRE2, CVAR(g_balance_shotgun_secondary_animtime), shotgun_fire2_02);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/shotgun_fire.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_SHOTGUN);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_shells >= CVAR(g_balance_shotgun_primary_ammo);
	else if (req == WR_CHECKAMMO2)
		return self.ammo_shells >= CVAR(g_balance_shotgun_secondary_ammo) * 3;
	return TRUE;
};
