void SendCSQCNexBeamParticle(float theteam, float secondary) {
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_CSQC_NEXGUNBEAMPARTICLE);

	WriteCoord(MSG_BROADCAST, w_shotorg_visual_x);
	WriteCoord(MSG_BROADCAST, w_shotorg_visual_y);
	WriteCoord(MSG_BROADCAST, w_shotorg_visual_z);
	WriteCoord(MSG_BROADCAST, trace_endpos_x);
	WriteCoord(MSG_BROADCAST, trace_endpos_y);
	WriteCoord(MSG_BROADCAST, trace_endpos_z);
    WriteByte(MSG_BROADCAST, theteam);
    WriteByte(MSG_BROADCAST, secondary);
}

void W_Nex_Attack (void)
{
	float flying;
	flying = IsFlying(self); // do this BEFORE to make the trace values from FireRailgunBullet last

	W_SetupShot(self, TRUE, 5, "weapons/nexfire.wav", CVAR(g_balance_nex_damage));

	yoda = 0;
	FireRailgunBullet(w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, CVAR(g_balance_nex_damage), CVAR(g_balance_nex_force), CVAR(g_balance_nex_damagefalloff_mindist), CVAR(g_balance_nex_damagefalloff_maxdist), CVAR(g_balance_nex_damagefalloff_halflife), CVAR(g_balance_nex_damagefalloff_forcehalflife), WEP_NEX);

	if(yoda && flying)
        CSQCMessage_Praise(self, CSQCMSG_PRAISEFLAG_AMAZING);

    W_SetHitscanVisuals(self, trace_endpos);

	//beam and muzzle flash done on client
	SendCSQCNexBeamParticle(self.team, FALSE);
	
	// flash and burn the wall
	if (trace_ent.solid == SOLID_BSP && !(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		Damage_DamageInfo(trace_endpos, CVAR(g_balance_nex_damage), 0, 0, CVAR(g_balance_nex_force) * w_shotdir, WEP_NEX, self);

	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_cells = self.ammo_cells - CVAR(g_balance_nex_ammo);
}

void W_Nex_Attack2(void) {
    float flying;
    flying = IsFlying(self); // do this BEFORE to make the trace values from FireRailgunBullet last

    W_SetupShot(self, TRUE, 5, "weapons/rm_minsta.wav", CVAR(g_balance_nex_secondary_damage));

    yoda = 0;
    FireRailgunBullet(w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, CVAR(g_balance_nex_secondary_damage), CVAR(g_balance_nex_secondary_force), CVAR(g_balance_nex_secondary_damagefalloff_mindist), CVAR(g_balance_nex_secondary_damagefalloff_maxdist), CVAR(g_balance_nex_secondary_damagefalloff_halflife), CVAR(g_balance_nex_secondary_damagefalloff_forcehalflife), WEP_NEX | HITTYPE_SECONDARY);

    if(yoda && flying)
        CSQCMessage_Praise(self, CSQCMSG_PRAISEFLAG_AMAZING);

    W_SetHitscanVisuals(self, trace_endpos);

    //beam and muzzle flash done on client
    SendCSQCNexBeamParticle(self.team, TRUE);
    
    // flash and burn the wall
    if (trace_ent.solid == SOLID_BSP && !(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
        Damage_DamageInfo(trace_endpos, CVAR(g_balance_nex_secondary_damage), 0, 0, CVAR(g_balance_nex_secondary_force) * w_shotdir, WEP_NEX, self);

    if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
        self.ammo_cells = self.ammo_cells - CVAR(g_balance_nex_secondary_ammo);
}

.entity nex_charge_effect;
.float nex_charge_expiretime;

void W_Nex_ChargeEffect_Think(void) {
    if(!self.owner.iscreature || !PlayerMayFire(self.owner)) {
        if(self == self.owner.nex_charge_effect)
            self.owner.nex_charge_effect = world;

        stopsound(self, CHAN_PROJECTILE);
        remove(self);
        return;
    }

    if(self.enemy.cnt < 0) {
        stopsound(self, CHAN_PROJECTILE);

        self.scale = approach(self.scale, 10, frametime * 50);
        self.alpha = 1 - self.scale / 10;
        self.alpha *= self.alpha;

        if(self.scale >= 10)
            remove(self);
        else
            self.nextthink = time;

        return;
    }

    self.scale = approach(self.scale, 1, (1 / self.cnt) * frametime);

    self.light_lev = self.scale * 200;
    self.nextthink = time;
}

void W_Nex_ChargeEffect_Spawn(float ct) {
    if(self.nex_charge_effect)
        self.nex_charge_effect.cnt = -1;

    entity e = spawn();
    setmodel(e, "models/ebomb.mdl");
    e.skin = TeamColorSkin(self.team);
    if(!e.skin)
        e.skin = 2;
    e.cnt = ct;
    e.think = W_Nex_ChargeEffect_Think;
    e.nextthink = time;
    e.scale = 0.01;
    e.enemy = e;
    e.pflags = PFLAGS_FULLDYNAMIC | PFLAGS_CORONA;
    e.color = '0.3 0.3 0.3' + 0.7 * TeamColor(if(self.team > 0) self.team else COLOR_TEAM2);
    W_AttachToShotorg(e, '5 0 0');

    // needs to be done AFTER W_AttachToShotorg
    e.customizeentityforclient = CL_Weaponentity_CustomizeEntityForClient;

    sound(e, CHAN_PROJECTILE, "weapons/electro_fly.wav", VOL_BASE, ATTN_NORM);
    self.nex_charge_effect = e;
}

void W_Nex_Attack2_Wait(void) {
    if(self.BUTTON_ATCK2 && time < self.nex_charge_expiretime) {
        return;
    }

    if(self.nex_charge_effect) {
        self.nex_charge_effect.cnt = -1;
        self.nex_charge_effect = world;
    }

    W_Nex_Attack2();
    ATTACK_FINISHED(self) = time + CVAR(g_balance_nex_secondary_refire) * W_WeaponRateFactor();

    weapon_thinkf(WFRAME_FIRE1, CVAR(g_balance_nex_secondary_animtime), w_ready);
}

void spawnfunc_weapon_nex (void); // defined in t_items.qc

.float timer_cl_hook_nex;
float w_nex(float req)
{
	if (req == WR_AIM)
		self.BUTTON_ATCK = bot_aim(1000000, 0, 1, FALSE);
	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK)
		{
			if (weapon_prepareattack(0, CVAR(g_balance_nex_refire)))
			{
				W_Nex_Attack();
				weapon_thinkf(WFRAME_FIRE1, CVAR(g_balance_nex_animtime), w_ready);
			}
		}

        if(self.BUTTON_ATCK2 && CVAR(g_balance_nex_secondary)) {
            if(weapon_prepareattack(1, CVAR(g_balance_nex_secondary_refire))) {
                float ct = CVAR(g_balance_nex_secondary_chargetime);
                weapon_thinkf(WFRAME_FIRE2, ct, W_Nex_Attack2_Wait);
                ct *= W_WeaponRateFactor();

                self.nex_charge_expiretime = time + ct + CVAR(g_balance_nex_secondary_chargeholdtime);
                sound(self, CHAN_WEAPON, "weapons/nex_charge.wav", VOL_BASE, ATTN_NORM);
                W_Nex_ChargeEffect_Spawn(ct);
            }
        }
	}
	else if (req == WR_PRECACHE)
	{
		precache_model("models/nexflash.md3");
		precache_sound("weapons/nexfire.wav");
		precache_sound("weapons/nexwhoosh1.wav");
		precache_sound("weapons/nexwhoosh2.wav");
		precache_sound("weapons/nexwhoosh3.wav");
        precache_sound("weapons/rm_minsta.wav");
        precache_sound("weapons/nex_charge.wav");
        precache_sound("weapons/electro_fly.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_NEX);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_cells >= CVAR(g_balance_nex_ammo);
	else if (req == WR_CHECKAMMO2)
		return self.ammo_cells >= CVAR(g_balance_nex_secondary_ammo);
	return TRUE;
};
