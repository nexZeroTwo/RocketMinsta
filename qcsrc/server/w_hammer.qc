
.float hammer_attackdone;
.float hammer_throwed;

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

void W_Hammer_Return() {
    //Return hammer to owner
    self.owner.hammer_throwed = FALSE;
    if (!self.owner.weapon)
        W_SwitchWeapon_Force(self.owner, WEP_HAMMER);
    remove(self);
}

void W_Hammer_Flyback_Think() {
    vector owner_path = self.owner.origin - self.origin;
    if (vlen(owner_path) < 100) { //close enough
        W_Hammer_Return();
        return;
    }
    vector owner_dir = normalize(owner_path);
    self.velocity = WEP_CVAR_SEC(hammer, speed) * owner_dir;
    UpdateCSQCProjectile(self);
    self.nextthink = time + 0.1;
}

void W_Hammer_Flyback() {
    self.movetype = MOVETYPE_NOCLIP;
    self.solid = SOLID_NOT;
    self.think = W_Hammer_Flyback_Think;
    self.nextthink = time + 0.1;
}

void W_Hammer_Touch() {
    PROJECTILE_SKIPNONSOLID
#if 0
    //What we should do when this happens?
    if(SUB_OwnerCheck())
        return;
    if(SUB_NoImpactCheck())
        return;
#endif
    self.use();
    if(trace_ent && trace_ent.solid > SOLID_TRIGGER)
         UpdateCSQCProjectileNextFrame(self);
    if (other.takedamage == DAMAGE_AIM) {
        W_Accuracy_RegisterHit(self, other, WEP_HAMMER);
        Damage(other, self.owner, self.owner, WEP_CVAR_SEC(hammer, damage),
                WEP_HAMMER | HITTYPE_SECONDARY, self.origin, normalize(self.velocity) * WEP_CVAR_SEC(hammer, force));
        if (other.classname == "player")
        if (IsDifferentTeam(self.owner, other))
        if (other.deadflag == DEAD_NO)
        if (IsFlying(other))
            CSQCMessage_Praise(self.owner, CSQCMSG_PRAISEFLAG_AIRSHOT);
    }
}

void W_Hammer_Throw() {
    self.hammer_throwed = TRUE;
    entity proj = spawn();
    W_SetupShot_ProjectileSize (self, '0 0 -3', '0 0 -3', FALSE, 4, "weapons/grenade_fire.wav", 0);
    W_Accuracy_RegisterShot(self, WEP_HAMMER);
    proj.owner = self;
    proj.classname = "hammer";
    proj.movetype = MOVETYPE_FLY;
    PROJECTILE_MAKETRIGGER(proj);
    proj.projectiledeathtype = WEP_HAMMER | HITTYPE_SECONDARY;
    proj.touch = W_Hammer_Touch;
    proj.velocity = WEP_CVAR_SEC(hammer, speed) * w_shotdir;
    proj.use = (if (WEP_CVAR_SEC(hammer, flyback)) W_Hammer_Flyback else W_Hammer_Return);
    proj.think = adaptor_think2use;
    proj.nextthink = time + WEP_CVAR_SEC(hammer, lifetime);
    setsize(proj, '-1 -1 -1', '1 1 1');
    setorigin(proj, w_shotorg);
    W_SetupProjectileVelocity(proj);
    proj.angles = vectoangles (proj.velocity);
    proj.flags = FL_PROJECTILE;
    CSQCProjectile(proj, TRUE, PROJECTILE_HAMMER, TRUE);

    //Throw out hammer
    self.weaponentity.state = WS_CLEAR;
    W_SwitchWeapon_Force(self, 0);
    weapon_thinkf(WFRAME_IDLE, 0, w_ready);
}

void W_Hammer_Attack1(void) {
    W_Hammer_Attack(TRUE);
}

void W_Hammer_Attack2(void) {
    if (WEP_CVAR_SEC(hammer, throw)) {
        W_Hammer_Throw();
        return;
    }
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
    } else if(req == WR_SETUP) {
        if (self.hammer_throwed)
        {
            self.weaponentity.state = WS_CLEAR;
            W_SwitchWeapon_Force(self, 0);
            return FALSE;
        }
        weapon_setup(WEP_HAMMER);
    } else if(req == WR_CHECKAMMO1)
        return TRUE;
    else if(req == WR_CHECKAMMO2)
        return TRUE;

    return TRUE;
}
