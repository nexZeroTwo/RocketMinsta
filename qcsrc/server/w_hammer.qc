
.float hammer_attackdone;

void spawnfunc_weapon_hammer(void) {
    weapon_defaultspawnfunc(WEP_HAMMER);
}

void W_Hammer_Attack_Real(float isprim) {
    const boxsize = 32;
    var fract, targ, endpos;

    var damage = WEP_CVAR_BOTH(hammer, isprim, damage);
    var theforce = WEP_CVAR_BOTH(hammer, isprim, force);

    makevectors(self.v_angle);
    W_SetupShot(self, FALSE, 0, "", 0);

    traceline_antilag(self, w_shotorg - (w_shotdir * 20), w_shotorg + w_shotdir * WEP_CVAR_BOTH(hammer, isprim, range), MOVE_NORMAL, self);
    fract = trace_fraction;
    tracebox_antilag(self, trace_endpos, '-1 -1 -1' * boxsize, '1 1 1' * boxsize, trace_endpos, MOVE_NORMAL, self, TRUE);
    targ = trace_ent;
    endpos = trace_endpos;

    W_Accuracy_RegisterShot(self, WEP_HAMMER);

    if(targ.takedamage) {
        W_Accuracy_RegisterHit(self, targ, WEP_HAMMER);
        Damage(targ, self, self, damage,
                WEP_HAMMER | (if (isprim) 0 else HITTYPE_SECONDARY), endpos, w_shotdir * theforce);
    }

    if(!targ.iscreature && fract < 1)
        Damage_DamageInfo(endpos, damage, damage, 0, w_shotdir * theforce, WEP_HAMMER, self);
}

void W_Hammer_Attack(float isprim) {
    if(!self.hammer_attackdone) {
        self.hammer_attackdone = TRUE;
        W_Hammer_Attack_Real(isprim);
    }

    if(time > ATTACK_FINISHED(self)) {
        self.hammer_attackdone = FALSE;
        weapon_thinkf(WFRAME_IDLE, WEP_CVAR_BOTH(hammer, isprim, animtime), w_ready);
    }
}

void W_Hammer_Attack1(void) {
    W_Hammer_Attack(TRUE);
}

void W_Hammer_Attack2(void) {
    W_Hammer_Attack(FALSE);
}

void W_Hammer_Attack_Sound(void) {
    sound(self, CHAN_WEAPON, "weapons/swing.wav", VOL_BASE, ATTN_NORM);
}

float w_hammer(float req) {
    W_SetButtonFields(self, CVAR(g_balance_hammer_swapshotmodes));

    if(req == WR_AIM) {
        self.w_button_primary = bot_aim(100000, 0, 0.01, FALSE);
    } else if(req == WR_THINK) {
        if(self.w_button_primary)
        if(weapon_prepareattack(0, CVAR(g_balance_hammer_primary_refire))) {
            W_Hammer_Attack_Sound();
            weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(hammer, delay), W_Hammer_Attack1);
        }

        if(self.w_button_secondary && CVAR(g_balance_hammer_secondary))
        if(weapon_prepareattack(0, CVAR(g_balance_hammer_secondary_refire))) {
            W_Hammer_Attack_Sound();
            weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_SEC(hammer, delay), W_Hammer_Attack2);
        }
    }
    else if(req == WR_PRECACHE) {
        precache_sound("weapons/swing.wav");
    } else if(req == WR_SETUP)
        weapon_setup(WEP_HAMMER);
    else if(req == WR_CHECKAMMO1)
        return TRUE;
    else if(req == WR_CHECKAMMO2)
        return TRUE;

    return TRUE;
}
