
.float pryaxe_attackdone;
.float pryaxe_thrown;
.float pryaxe_hit;
.float pryaxe_oldsolid;

void spawnfunc_weapon_pryaxe(void) {
    weapon_defaultspawnfunc(WEP_PRYAXE);
}

void W_Pryaxe_Throw(float);
void W_Pryaxe_Melee(float);

void W_Pryaxe_Melee_Damage(float isprim) {
    const boxsize = 32;
    var fract, targ, endpos, hitcreature;

    var damage = WEP_CVAR_BOTH(pryaxe, isprim, damage);
    var theforce = WEP_CVAR_BOTH(pryaxe, isprim, force);

    makevectors(self.v_angle);
    W_SetupShot(self, FALSE, 0, "", 0);
    W_Accuracy_RegisterShot(self, WEP_PRYAXE);

    traceline_antilag(self, w_shotorg - (w_shotdir * 20), w_shotorg + w_shotdir * WEP_CVAR_BOTH(pryaxe, isprim, range), MOVE_NORMAL, self);
    fract = trace_fraction;
    endpos = trace_endpos;

    while(TRUE) {
        tracebox_antilag(self, trace_endpos, '-1 -1 -1' * boxsize, '1 1 1' * boxsize, trace_endpos, MOVE_NORMAL, self, TRUE);

        if(!trace_ent)
            break;

        trace_ent.pryaxe_oldsolid = trace_ent.solid;
        trace_ent.solid = SOLID_NOT;
        trace_ent.pryaxe_hit = TRUE;
    }

    while((targ = findfloat(targ, pryaxe_hit, TRUE))) {
        targ.solid = targ.pryaxe_oldsolid;
        targ.pryaxe_oldsolid = 0;
        targ.pryaxe_hit = FALSE;

        if(targ.takedamage) {
            if(targ.iscreature)
                hitcreature = TRUE;

            W_Accuracy_RegisterHit(self, targ, WEP_PRYAXE);
            Damage(targ, self, self, damage,
                    WEP_PRYAXE | (if (isprim) 0 else HITTYPE_SECONDARY), endpos, w_shotdir * theforce);
        }
    }

    if(!hitcreature && fract < 1)
        Damage_DamageInfo(endpos, damage, damage, 0, w_shotdir * theforce, WEP_PRYAXE, self);
}

void W_Pryaxe_Melee(float isprim) {
    if(!self.pryaxe_attackdone) {
        self.pryaxe_attackdone = TRUE;
        W_Pryaxe_Melee_Damage(isprim);
    }

    weapon_thinkf(WFRAME_DONTCHANGE, WEP_CVAR_BOTH(pryaxe, isprim, animtime), inline void(void) {
        self.pryaxe_attackdone = FALSE;
        weapon_thinkf(WFRAME_IDLE, frametime, w_ready);
    });
}

void W_Pryaxe_Attack(float isprim) {
    var throw = WEP_CVAR_BOTH(pryaxe, isprim, throw);

    if(throw) {
        if(throw & 2) {
            W_SetButtonFields(self, CVAR(g_balance_pryaxe_swapshotmodes));
            if(self.(if(isprim) w_button_primary else w_button_secondary)) {
                if(throw & 1)
                    W_Pryaxe_Melee(isprim);
                else
                    W_Pryaxe_Throw(isprim);
            } else {
                if(throw & 1)
                    W_Pryaxe_Throw(isprim);
                else
                    W_Pryaxe_Melee(isprim);
            }
        } else
            W_Pryaxe_Throw(isprim);
    } else {
        W_Pryaxe_Melee(isprim);
    }
}

void W_Pryaxe_Return() {
    if(self.owner.iscreature) {
        //Return pryaxe to owner
        self.owner.pryaxe_thrown = FALSE;
        if (!self.owner.weapon)
            W_SwitchWeapon_Force(self.owner, WEP_PRYAXE);
        sound(self.owner, CHAN_AUTO, "weapons/weaponpickup.wav", VOL_BASE, ATTN_NORM);
    }

    remove(self);
}

void W_Pryaxe_Flyback_Think() {
    var isprim = !(self.projectiledeathtype & HITTYPE_SECONDARY);
    vector owner_path = self.owner.origin - self.origin;

    if (vlen(owner_path) < 100) { //close enough
        W_Pryaxe_Return();
        return;
    }
    vector owner_dir = normalize(owner_path);
    self.velocity = WEP_CVAR_BOTH(pryaxe, isprim, throw_speed) * owner_dir;
    UpdateCSQCProjectile(self);
    self.nextthink = time;
}

void W_Pryaxe_Flyback() {
    self.movetype = MOVETYPE_NOCLIP;
    self.solid = SOLID_NOT;
    self.think = W_Pryaxe_Flyback_Think;
    self.nextthink = time; //+ 0.1;
}

void W_Pryaxe_Touch() {
    var dir, isprim = !(self.projectiledeathtype & HITTYPE_SECONDARY);
    PROJECTILE_SKIPNONSOLID

    if(SUB_OwnerCheck()) {
        return;
    }

    if(SUB_NoImpactCheck()) {
        self.use();
        return;
    }

    if(trace_ent && trace_ent.solid > SOLID_TRIGGER)
         UpdateCSQCProjectileNextFrame(self);

    if (other.takedamage) {
        var hloc = NearestPointOnBox(other, trace_endpos);
        W_Accuracy_RegisterHit(self.owner, other, WEP_PRYAXE);

        if(WEP_CVAR_BOTH(pryaxe, isprim, throw_pull_to_owner))
            dir = self.owner.origin + self.owner.view_ofs - hloc;
        else
            dir = self.velocity;
        dir = normalize(dir);

        Damage(other, self.owner, self.owner, WEP_CVAR_BOTH(pryaxe, isprim, throw_damage),
               self.projectiledeathtype, hloc,
               dir * WEP_CVAR_BOTH(pryaxe, isprim, throw_force));

        if (other.classname == "player")
        if (IsDifferentTeam(self.owner, other))
        if (other.deadflag == DEAD_NO)
        if (IsFlying(other))
            CSQCMessage_Praise(self.owner, CSQCMSG_PRAISEFLAG_AIRSHOT);

    }

    if(!other.iscreature) {
        dir = normalize(self.velocity);
        traceline(trace_endpos, trace_endpos + dir * 24, MOVE_NORMAL, self);
        Damage_DamageInfo(trace_endpos, WEP_CVAR_BOTH(pryaxe, isprim, throw_damage), WEP_CVAR_BOTH(pryaxe, isprim, throw_damage), 0, dir * WEP_CVAR_BOTH(pryaxe, isprim, throw_force), WEP_PRYAXE, self);
    }

    self.use();
}

void W_Pryaxe_Throw(float isprim) {
    self.pryaxe_thrown = TRUE;
    entity proj = spawn();

    const pr_min = '-16 -16 -4';
    const pr_max = ' 16  16  4';

    W_SetupShot_ProjectileSize (self, pr_min, pr_max, FALSE, 4, "", 0);

    tracebox(w_shotorg, pr_min, pr_max, w_shotorg, MOVE_NOMONSTERS, self);

    if(trace_startsolid) {
        W_Pryaxe_Melee(FALSE);
        return;
    }

    W_Accuracy_RegisterShot(self, WEP_PRYAXE);
    proj.owner = self;
    proj.classname = "pryaxe";
    proj.movetype = MOVETYPE_FLY;
    PROJECTILE_MAKETRIGGER(proj);
    proj.projectiledeathtype = WEP_PRYAXE | (if(isprim) 0 else HITTYPE_SECONDARY) | HITTYPE_BOUNCE;
    proj.touch = W_Pryaxe_Touch;
    proj.velocity = WEP_CVAR_BOTH(pryaxe, isprim, throw_speed) * w_shotdir;
    proj.use = (if (WEP_CVAR_BOTH(pryaxe, isprim, throw_flyback)) W_Pryaxe_Flyback else W_Pryaxe_Return);
    proj.think = adaptor_think2use;
    proj.nextthink = time + WEP_CVAR_BOTH(pryaxe, isprim, throw_lifetime);
    setsize(proj, pr_min, pr_max);
    setorigin(proj, w_shotorg);
    W_SetupProjectileVelocity(proj);
    proj.angles = vectoangles (proj.velocity);
    proj.flags = FL_PROJECTILE;
    proj.reset = W_Pryaxe_Return;
    CSQCProjectile(proj, TRUE, PROJECTILE_PRYAXE, TRUE);

    //Throw out pryaxe
    self.weaponentity.state = WS_CLEAR;
    W_SwitchWeapon_Force(self, 0);
    weapon_thinkf(WFRAME_IDLE, 0, w_ready);
    ATTACK_FINISHED(self) = time;
}

void W_Pryaxe_Attack1(void) {
    W_Pryaxe_Attack(TRUE);
}

void W_Pryaxe_Attack2(void) {
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
        if(self.pryaxe_thrown) {
            while((var e = find(e, classname, "pryaxe"))) if(e.owner == self) {
                self.pryaxe_thrown = FALSE;
                break;
            }
        }

        if (self.pryaxe_thrown)
        {
            self.weaponentity.state = WS_CLEAR;
            W_SwitchWeapon_Force(self, 0);
            return FALSE;
        }

        weapon_setup(WEP_PRYAXE);
    } else if(req == WR_CHECKAMMO1)
        return !self.pryaxe_thrown;
    else if(req == WR_CHECKAMMO2)
        return !self.pryaxe_thrown;

    return TRUE;
}
