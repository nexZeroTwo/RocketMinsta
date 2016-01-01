.float melee_damage;
.float melee_force;
.float melee_distance;
.float melee_time;
.float melee_lastthink;
.float melee_startthink;
.float melee_ticrate;
.float melee_secondary;

void W_Hammer_Attack_Think()
{
	float melee_frame;
	melee_frame = min(time - self.melee_lastthink, self.melee_startthink + self.melee_time - self.melee_lastthink);
	if (melee_frame < 0)
	{
		remove(self);
		return;
	}
	float damage_factor = melee_frame / self.melee_time;
	float frame_damage = self.melee_damage * damage_factor;
	float frame_force = self.melee_force * damage_factor;
	makevectors(self.owner.angles);
	W_SetupShot(self.owner, FALSE, 0, "", frame_damage);
	traceline(w_shotorg - (w_shotdir * 20), w_shotorg + w_shotdir * self.melee_distance, MOVE_NORMAL, self);
	if (trace_fraction < 1)
	if (trace_ent)
	if (trace_ent.takedamage)
	{
		Damage (trace_ent, self.owner, self.owner, frame_damage,
				WEP_HAMMER | (if (self.melee_secondary) HITTYPE_SECONDARY else 0), trace_endpos, w_shotdir * frame_force);
		Damage_RecordDamage(self.owner, WEP_HAMMER, frame_damage);
	}
	self.melee_lastthink = time;
	self.nextthink = time + self.melee_ticrate;
}

void W_Hammer_Attack (float issecondary)
{
	sound (self, CHAN_WEAPON, CVAR_STR(sv_sound_hammer_attack), VOL_BASE, ATTN_NORM);
	entity melee = spawn();
	melee.owner = self;
	melee.think = W_Hammer_Attack_Think;
	melee.melee_secondary = issecondary;
	melee.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	float rate_factor = W_WeaponRateFactorFor(self);
	if (issecondary)
	{
		melee.nextthink = time + CVAR(g_balance_hammer_secondary_delay) * rate_factor;
		melee.melee_damage = CVAR(g_balance_hammer_secondary_damage);
		melee.melee_force = CVAR(g_balance_hammer_secondary_force);
		melee.melee_distance = CVAR(g_balance_hammer_secondary_radius);
		melee.melee_time = CVAR(g_balance_hammer_secondary_time) * rate_factor;
		melee.melee_ticrate = CVAR(g_balance_hammer_secondary_ticrate) * rate_factor;
	}
	else
	{
		melee.nextthink = time + CVAR(g_balance_hammer_primary_delay) * rate_factor;
		melee.melee_damage = CVAR(g_balance_hammer_primary_damage);
		melee.melee_force = CVAR(g_balance_hammer_primary_force);
		melee.melee_distance = CVAR(g_balance_hammer_primary_radius);
		melee.melee_time = CVAR(g_balance_hammer_primary_time) * rate_factor;
		melee.melee_ticrate = CVAR(g_balance_hammer_primary_ticrate) * rate_factor;
	}
	melee.melee_startthink = melee.nextthink;
	melee.melee_lastthink = melee.nextthink;
	melee.nextthink += melee.melee_ticrate; //avoid frame with zero melee_frame
}

float w_hammer(float req)
{
    W_SetButtonFields(self, CVAR(g_balance_hammer_swapshotmodes));

	if (req == WR_AIM)
	{
		self.w_button_primary = bot_aim(100000, 0, 0.01, FALSE);
	}
	else if (req == WR_THINK)
	{
		if (self.w_button_primary)
		if (weapon_prepareattack(0, CVAR(g_balance_hammer_primary_refire)))
		{
			W_Hammer_Attack(FALSE);
			weapon_thinkf(WFRAME_FIRE1, CVAR(g_balance_hammer_primary_animtime), w_ready);
		}
		if (self.w_button_secondary)
		{
			if(CVAR(g_balance_hammer_secondary))
			{
				if (weapon_prepareattack(0, CVAR(g_balance_hammer_secondary_refire)))
				{
					W_Hammer_Attack(TRUE);
					weapon_thinkf(WFRAME_FIRE2, CVAR(g_balance_hammer_secondary_animtime), w_ready);
				}
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_sound (CVAR_STR(sv_sound_hammer_attack));
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_HAMMER);
	else if (req == WR_CHECKAMMO1)
		return TRUE;
	else if (req == WR_CHECKAMMO2)
		return TRUE;
	return TRUE;
};
