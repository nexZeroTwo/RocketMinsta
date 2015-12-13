// leilei's fancy muzzleflash stuff
void W_Uzi_Flash_Go() {
	if (self.frame > 10){
		SUB_Remove();
		return;
	}
	self.frame = self.frame + 2;
	self.alpha = self.alpha - 0.2;
	self.think = W_Uzi_Flash_Go;
	self.nextthink = time + 0.02;
};

.float uzi_hitstreak;
.float uzi_hitstreak_expiretime;

float W_Uzi_GetHitstreakBonus(void) {
    if(!CVAR(g_balance_uzi_hitstreak_bonus))
        return 0;

    if(time > self.uzi_hitstreak_expiretime) {
        self.uzi_hitstreak = 0;
        return 0;
    }

    float streak = bound(0, self.uzi_hitstreak, self.w_clip_limit_stat);
    return streak * CVAR(g_balance_uzi_hitstreak_bonus);
}

void W_Uzi_RegisterHitForHitstreak(entity attacker, float deathtype) {
    if(!DEATH_ISWEAPON(deathtype, WEP_UZI))
        return;

    attacker.uzi_hitstreak += 1;
    attacker.uzi_hitstreak_expiretime = max(
        attacker.uzi_hitstreak_expiretime, 
        time + CVAR(g_balance_uzi_hitstreak_resettime)
    );
}

.float uzi_bulletcounter;
float W_Uzi_Attack (float deathtype)
{
	entity flash;
    float cost;

	if(self.uzi_bulletcounter == 1)
		cost = CVAR(g_balance_uzi_first_ammo);
	else
		cost = CVAR(g_balance_uzi_sustained_ammo);

    if(!W_Clip_Consume(cost))
        return FALSE;

    float dmgbonus = W_Uzi_GetHitstreakBonus();

    if(!(self.items & IT_UNLIMITED_WEAPON_AMMO))
        self.ammo_nails -= cost;

	W_SetupShot (self, CVAR(g_antilag_bullets) && CVAR(g_balance_uzi_speed) >= CVAR(g_antilag_bullets), 0, "weapons/uzi_fire.wav", CVAR(g_balance_uzi_first_damage));
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	// this attack_finished just enforces a cooldown at the end of a burst
	ATTACK_FINISHED(self) = time + CVAR(g_balance_uzi_first_refire) * W_WeaponRateFactor();

	if (self.uzi_bulletcounter == 1)
		fireBallisticBullet(w_shotorg, w_shotdir, CVAR(g_balance_uzi_first_spread), CVAR(g_balance_uzi_speed), 5, CVAR(g_balance_uzi_first_damage) + dmgbonus, 0, CVAR(g_balance_uzi_first_force), deathtype, 0, 1, CVAR(g_balance_uzi_bulletconstant));
	else
		fireBallisticBullet(w_shotorg, w_shotdir, CVAR(g_balance_uzi_sustained_spread), CVAR(g_balance_uzi_speed), 5, CVAR(g_balance_uzi_sustained_damage) + dmgbonus, 0, CVAR(g_balance_uzi_sustained_force), deathtype, 0, 1, CVAR(g_balance_uzi_bulletconstant));
	endFireBallisticBullet();

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg_visual, w_shotdir_visual * 1000, 1);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	//SUB_SetFade(flash, time + 0.06, 0);
	flash.think = W_Uzi_Flash_Go;
	flash.nextthink = time + 0.02;
	flash.frame = 2;
	flash.alpha = 1;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '5 0 0');

	// casing code
	if (CVAR(g_casings) >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, self);

    return TRUE;
}

void W_Uzi_SetClipContext(void) {
    W_Clip_SetWeaponContext(
        WEP_UZI,
        CVAR(g_balance_uzi_magazinecapacity),
        CVAR(g_balance_uzi_reloadtime),
        ammo_nails,
        1
    );
}

// weapon frames
void uzi_fire1_02()
{
	if(self.weapon != self.switchweapon || !PlayerMayFire(self)) // abort immediately if switching
	{
		w_ready();
		return;
	}

    W_SetButtonFields(CVAR(g_balance_uzi_swapshotmodes));

	if (self.w_button_primary)
	{
		if (!weapon_action(self.weapon, WR_CHECKAMMO2))
		{
			W_SwitchWeapon_OutOfAmmo(self);
			w_ready();
			return;
		}
		self.uzi_bulletcounter = self.uzi_bulletcounter + 1;

		if(!W_Uzi_Attack(WEP_UZI))
            return;

		weapon_thinkf(WFRAME_FIRE1, CVAR(g_balance_uzi_sustained_refire), uzi_fire1_02);
	}
	else
		weapon_thinkf(WFRAME_FIRE1, CVAR(g_balance_uzi_sustained_refire), w_ready);
};

float w_uzi(float req)
{
    W_SetButtonFields(CVAR(g_balance_uzi_swapshotmodes));
    W_Uzi_SetClipContext();

	if (req == WR_AIM)
		if(vlen(self.origin-self.enemy.origin) < 3000 - bound(0, skill, 10) * 200)
			self.w_button_primary = bot_aim(1000000, 0, 0.001, FALSE);
		else
		{
			self.w_button_secondary = bot_aim(1000000, 0, 0.001, FALSE);
		}
	else if (req == WR_THINK)
	{
        if(W_Clip_TryWeaponAction()) {
            if(self.w_button_primary)
            if(weapon_prepareattack(0, 0))
            if(W_Clip_TryAttackOrReload()) {
                self.uzi_bulletcounter = 1;
                W_Uzi_Attack(WEP_UZI); // sets attack_finished
                weapon_thinkf(WFRAME_FIRE1, CVAR(g_balance_uzi_sustained_refire), uzi_fire1_02);
            }

            if(self.w_button_secondary)
            if(CVAR(g_balance_uzi_first))
            if(weapon_prepareattack(1, 0))
            if(W_Clip_TryAttackOrReload()) {
                self.uzi_bulletcounter = 1;
                W_Uzi_Attack(WEP_UZI | HITTYPE_SECONDARY); // sets attack_finished
                weapon_thinkf(WFRAME_FIRE2, CVAR(g_balance_uzi_first_refire), w_ready);
            }

            W_Clip_FinishWeaponAction();
        }
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_sound ("weapons/uzi_fire.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_UZI);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_nails >= CVAR(g_balance_uzi_first_ammo);
	else if (req == WR_CHECKAMMO2)
		return self.ammo_nails >= CVAR(g_balance_uzi_first_ammo);

    W_Clip_WeaponRequestHook(req);
	return TRUE;
};
