
.float pryaxe_attackdone;
.float pryaxe_thrown;

void spawnfunc_weapon_pryaxe(void) {
    weapon_defaultspawnfunc(WEP_PRYAXE);
}

void W_Pryaxe_Attack_Real(float isprim) {
    const boxsize = 32;
    var fract, targ, endpos;

    var damage = WEP_CVAR_BOTH(pryaxe, isprim, damage);
    var theforce = WEP_CVAR_BOTH(pryaxe, isprim, force);

    makevectors(self.v_angle);
    W_SetupShot(self, FALSE, 0, "", 0);

    traceline_antilag(self, w_shotorg - (w_shotdir * 20), w_shotorg + w_shotdir * WEP_CVAR_BOTH(pryaxe, isprim, range), MOVE_NORMAL, self);
    fract = trace_fraction;
    tracebox_antilag(self, trace_endpos, '-1 -1 -1' * boxsize, '1 1 1' * boxsize, trace_endpos, MOVE_NORMAL, self, TRUE);
    targ = trace_ent;
    endpos = trace_endpos;

    W_Accuracy_RegisterShot(self, WEP_PRYAXE);

    if(targ.takedamage) {
        W_Accuracy_RegisterHit(self, targ, WEP_PRYAXE);
        Damage(targ, self, self, damage,
                WEP_PRYAXE | (if (isprim) 0 else HITTYPE_SECONDARY), endpos, w_shotdir * theforce);
    }

    if(!targ.iscreature && fract < 1)
        Damage_DamageInfo(endpos, damage, damage, 0, w_shotdir * theforce, WEP_PRYAXE, self);
}

void W_Pryaxe_Attack(float isprim) {
    if(!self.pryaxe_attackdone) {
        self.pryaxe_attackdone = TRUE;
        W_Pryaxe_Attack_Real(isprim);
    }

    if(time > ATTACK_FINISHED(self)) {
        self.pryaxe_attackdone = FALSE;
        weapon_thinkf(WFRAME_IDLE, WEP_CVAR_BOTH(pryaxe, isprim, animtime), w_ready);
    }
}

void W_Pryaxe_Return() {
    //Return pryaxe to owner
    self.owner.pryaxe_thrown = FALSE;
    if (!self.owner.weapon)
        W_SwitchWeapon_Force(self.owner, WEP_PRYAXE);
    remove(self);
}

void W_Pryaxe_Flyback_Think() {
    vector owner_path = self.owner.origin - self.origin;
    if (vlen(owner_path) < 100) { //close enough
        W_Pryaxe_Return();
        return;
    }
    vector owner_dir = normalize(owner_path);
    self.velocity = WEP_CVAR_SEC(pryaxe, speed) * owner_dir;
    UpdateCSQCProjectile(self);
    self.nextthink = time + 0.1;
}

void W_Pryaxe_Flyback() {
    self.movetype = MOVETYPE_NOCLIP;
    self.solid = SOLID_NOT;
    self.think = W_Pryaxe_Flyback_Think;
    self.nextthink = time + 0.1;
}

void W_Pryaxe_Touch() {
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
        W_Accuracy_RegisterHit(self, other, WEP_PRYAXE);
        Damage(other, self.owner, self.owner, WEP_CVAR_SEC(pryaxe, damage),
                WEP_PRYAXE | HITTYPE_SECONDARY, self.origin, normalize(self.velocity) * WEP_CVAR_SEC(pryaxe, force));
        if (other.classname == "player")
        if (IsDifferentTeam(self.owner, other))
        if (other.deadflag == DEAD_NO)
        if (IsFlying(other))
            CSQCMessage_Praise(self.owner, CSQCMSG_PRAISEFLAG_AIRSHOT);
    }
}

void W_Pryaxe_Throw() {
    self.pryaxe_thrown = TRUE;
    entity proj = spawn();
    W_SetupShot_ProjectileSize (self, '0 0 -3', '0 0 -3', FALSE, 4, "weapons/grenade_fire.wav", 0);
    W_Accuracy_RegisterShot(self, WEP_PRYAXE);
    proj.owner = self;
    proj.classname = "pryaxe";
    proj.movetype = MOVETYPE_FLY;
    PROJECTILE_MAKETRIGGER(proj);
    proj.projectiledeathtype = WEP_PRYAXE | HITTYPE_SECONDARY;
    proj.touch = W_Pryaxe_Touch;
    proj.velocity = WEP_CVAR_SEC(pryaxe, speed) * w_shotdir;
    proj.use = (if (WEP_CVAR_SEC(pryaxe, flyback)) W_Pryaxe_Flyback else W_Pryaxe_Return);
    proj.think = adaptor_think2use;
    proj.nextthink = time + WEP_CVAR_SEC(pryaxe, lifetime);
    setsize(proj, '-1 -1 -1', '1 1 1');
    setorigin(proj, w_shotorg);
    W_SetupProjectileVelocity(proj);
    proj.angles = vectoangles (proj.velocity);
    proj.flags = FL_PROJECTILE;
    CSQCProjectile(proj, TRUE, PROJECTILE_PRYAXE, TRUE);

    //Throw out pryaxe
    self.weaponentity.state = WS_CLEAR;
    W_SwitchWeapon_Force(self, 0);
    weapon_thinkf(WFRAME_IDLE, 0, w_ready);
}

void W_Pryaxe_Attack1(void) {
    W_Pryaxe_Attack(TRUE);
}

void W_Pryaxe_Attack2(void) {
    if (WEP_CVAR_SEC(pryaxe, throw)) {
        W_Pryaxe_Throw();
        return;
    }
    W_Pryaxe_Attack(FALSE);
}

void W_Pryaxe_Attack_Sound(void) {
    sound(self, CHAN_WEAPON, "weapons/swing.wav", VOL_BASE, ATTN_NORM);
}

float w_pryaxe(float req) {
    W_SetButtonFields(self, CVAR(g_balance_pryaxe_swapshotmodes));

    if(req == WR_AIM) {
        self.w_button_primary = bot_aim(100000, 0, 0.01, FALSE);
    } else if(req == WR_THINK) {
        if(self.w_button_primary)
        if(weapon_prepareattack(0, CVAR(g_balance_pryaxe_primary_refire))) {
            W_Pryaxe_Attack_Sound();
            weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(pryaxe, delay), W_Pryaxe_Attack1);
        }

        if(self.w_button_secondary && CVAR(g_balance_pryaxe_secondary))
        if(weapon_prepareattack(0, CVAR(g_balance_pryaxe_secondary_refire))) {
            W_Pryaxe_Attack_Sound();
            weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_SEC(pryaxe, delay), W_Pryaxe_Attack2);
        }
    }
    else if(req == WR_PRECACHE) {
        precache_sound("weapons/swing.wav");
    } else if(req == WR_SETUP) {
        if (self.pryaxe_thrown)
        {
            self.weaponentity.state = WS_CLEAR;
            W_SwitchWeapon_Force(self, 0);
            return FALSE;
        }
        weapon_setup(WEP_PRYAXE);
    } else if(req == WR_CHECKAMMO1)
        return TRUE;
    else if(req == WR_CHECKAMMO2)
        return TRUE;

    return TRUE;
}
