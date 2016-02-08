
void HG_Shield_Discharge_Arc(entity targ, entity attacker, float damage) {
    ArcDamage(targ, attacker, damage, HG_SHIELD | HITTYPE_SECONDARY | HITTYPE_BOUNCE,
        CVAR(g_nadgets_shield_damage_store_arc_range), CVAR(g_nadgets_shield_damage_store_arc),
        CVAR(g_nadgets_shield_damage_store_arc_pushback), COLOR_TEAM3, shield_arc_hit
    );
}

void HG_Shield_Discharge_Think(void) {
    entity targ;
    vector start, end, end_visual;
    float damage;
    float arc = CVAR(g_nadgets_shield_damage_store_arc);

    var armordrain = CVAR(g_nadgets_shield_damage_store_allow_armor_drain);
    var armorval = if(armordrain) self.owner.armorvalue / armordrain else 0;

    if(self.owner.hg_shield_stored < -1)
        damage = 0;
    else
        damage = min(max(0, self.owner.hg_shield_stored) + armorval, CVAR(g_nadgets_shield_damage_store_burstamount));

    if(damage <= 0 || !self.owner || !self.owner.iscreature || !PlayerMayFire(self.owner)) {
        remove(self);
        return;
    }

    var armordamage = 0;

    if(self.owner.hg_shield_stored < 0) {
        armordamage = damage;
    } else {
        self.owner.hg_shield_stored -= damage;
        armordamage = -max(0, self.owner.hg_shield_stored);
        if(self.owner.hg_shield_stored <= 0)
            self.owner.hg_shield_stored = -1;
    }

    if(armordamage > 0 && armorval) {
        var oldval = self.owner.armorvalue;
        armordamage *= armordrain;
        Damage(self.owner, self.owner, self.owner, armordamage, DEATH_RESOURCE_ARMOR, '0 0 0', '0 0 0');
    }

    makevectors(self.owner.v_angle);
    W_SetupShot(self.owner, TRUE, 0, "weapons/nexfire.wav", -1);
    traceline_antilag(self.owner, w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, MOVE_NORMAL, self.owner);
    targ = trace_ent;
    start = w_shotorg;
    end = trace_endpos;
    end_visual = WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos);

    setorigin(self, end);
    RadiusDamage(self, self.owner, damage, damage * CVAR(g_nadgets_shield_damage_store_edgefactor),
                 CVAR(g_nadgets_shield_damage_store_radius), world,
                 damage * CVAR(g_nadgets_shield_damage_store_forcefactor), HG_SHIELD | HITTYPE_SECONDARY, targ);

    W_SetHitscanVisuals(self.owner, end);
    W_Zapper_Attack2_Effect(if(teams_matter) self.owner.team else COLOR_TEAM3, w_shotorg_visual, w_shotorg, end_visual);

    if(arc && targ && targ.iscreature && (IsDifferentTeam(self.owner, targ) || Buffs_Present(self.owner, BUFF_MEDIC))) {
        HG_Shield_Discharge_Arc(targ, self.owner, damage);
    }

    self.nextthink = time + CVAR(g_nadgets_shield_damage_store_burstdelay);
}

void HG_Shield_Trigger(void) {
    sound(self, CHAN_WEAPON2, "porto/expire.wav", VOL_BASE, ATTN_NORM);

    for(var e = world; (e = find(e, classname, "hg_shield_discharge"));) {
        if(e.owner == self) {
            self.hg_shield_stored = 0;
            remove(e);
            return;
        }
    }

    // Discharge
    if(self.hg_shield_stored) {
        using(self = spawn() {
            classname: "hg_shield_discharge",
            owner: self,
            think: HG_Shield_Discharge_Think,
            reset: SUB_Remove
        }) self.think();
    }

    if(!Buffs_Present(self, BUFF_ADEPT) || self.hg_shield_stored <= 0) {
        self.hg_shield = 0;
        stopsound(self, CHAN_AUTO);
    }
}

void HG_Shield_Adept_ExtendRenew(entity plr) {
    var extend = CVAR(g_nadgets_shield_adept_discharge_extend);
    var renew = CVAR(g_nadgets_shield_adept_discharge_renew);

    if(!extend && !renew)
        return;

    plr.hg_shield = max(plr.hg_shield, renew) + extend;
    stopsound(plr, CHAN_AUTO);
    sound(plr, CHAN_AUTO, "misc/powerup_shield.wav", VOL_BASE, ATTN_NORM);
}

void HG_Shield_Model_Think(void) {
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
    if(self.hg_adept && self.owner.hg_shieldpower == 1)
        self.colormod_z = 1;
    setorigin(self, self.owner.origin);
    self.nextthink = time;
}

void HG_Shield_PlayerFrame(void) {
    if(self.hg_shieldmax && self.hg_shield)
        self.hg_shieldstat = self.hg_shield / self.hg_shieldmax;
    else
        self.hg_shieldstat = 0;

    if((self.hg_shield_stored < 0 || (self.hg_shield_stored && !self.hg_shield))
        && !findfilter(world, inline float(entity e) {
            return e.owner == self && e.classname == "hg_shield_discharge";
        })) self.hg_shield_stored = 0;

    if(!self.hg_shield) {
        self.nobuffs = 0;

        if(self.hg_shield_oldmovetype) {
            self.movetype = self.hg_shield_oldmovetype;
            self.hg_shield_oldmovetype = 0;
        }

        return;
    }

    if(!self.movetype) {
        // with MOVETYPE_NONE the player model rotation will not correspond to the view direction, so fix it here
        self.angles_y = self.v_angle_y;
    }

    if(self.hg_shieldhealth <= 0)
        self.hg_shield = 0;
    else {
        self.hg_shield = max(0, self.hg_shield - frametime);
        if(CVAR(g_nadgets_shield_diminish))
            self.hg_shieldpower = self.hg_shield / self.hg_shieldmax;
    }
}

float HG_Shield_Damage(entity attacker, float damage, float deathtype, vector hitloc) {
    if not(g_nadgets && damage && attacker.iscreature && self.hg_shield)
        return damage;

    if(DEATH_HGTYPE(deathtype) == HG_TRANSLOC && CVAR(g_nadgets_transloc_counters_shield)) {
        self.hg_shield = 0;
        return damage;
    }

    if not(DEATH_HGTYPE(deathtype) != HG_SHIELD && deathtype != DEATH_NOISE && deathtype != DEATH_ARC && DEATH_HGTYPE(deathtype) != HG_GG)
        return damage;

    vector offs = '0 0 1' * self.maxs_z * 0.5;
    float reflect    = damage * CVAR(g_nadgets_shield_damage_reflect) * self.hg_shieldpower;
    float takefactor = 1 - (1 - CVAR(g_nadgets_shield_damage_take))   * self.hg_shieldpower;
    float absorb     = damage * (1 - takefactor);

    float o = self.hg_shield_stored;
    self.hg_shield_stored = min(CVAR(g_nadgets_shield_damage_store_limit), self.hg_shield_stored + damage * CVAR(g_nadgets_shield_damage_store));
    damage *= takefactor;

    if(self.hg_shield_stored > o)
        te_eleblast(hitloc, if(teams_matter) self.team else 0);

    if(DEATH_HGTYPE(deathtype) == HG_TRANSLOC)
        reflect = 0;
    else if(DEATH_ISHG(deathtype))
        reflect *= CVAR(g_nadgets_shield_damage_reflect_hg);

    if(reflect) {
        vector start = self.origin + offs;
        vector end   = attacker.origin + offs;

        traceline(start, end, FALSE, self);
        end = trace_endpos;

        if(trace_ent.takedamage)
            Damage(trace_ent, self, self, reflect, HG_SHIELD, end, '0 0 0');

        trailparticles(world, particleeffectnum("TE_TEI_G3YELLOW"), start, end);
    }

    self.hg_shieldhealth -= absorb;
    if(self.hg_shieldhealth <= 0)
        self.hg_shield = 0;

    return damage;
}

HG_HOOKFUNCTION(shield, Attack) {
    entity e;
    float d;
    float adept = Buffs_Present(self, BUFF_ADEPT);

    if(adept) {
        d = CVAR(g_nadgets_shield_adept_duration);
    } else {
        d = CVAR(g_nadgets_shield_duration);

        if(CVAR(g_nadgets_shield_immobile)) {
            self.hg_shield_oldmovetype = self.movetype;
            self.movetype = MOVETYPE_NONE;
        }
    }

    self.hg_shieldmax = d * Buffs_NadgetPower(self);
    self.hg_shield = self.hg_shieldmax;
    self.hg_shieldhealth = CVAR(g_nadgets_shield_health);
    self.hg_shieldpower = 1;

    self.hg_shield_stored = CVAR(g_nadgets_shield_damage_store_base);
    self.hg_shield_stored_limit = CVAR(g_nadgets_shield_damage_store_limit);
    self.nobuffs = CVAR(g_nadgets_shield_nobuffs);

    self.hg_shield_damage_per_shot = CVAR(g_nadgets_shield_damage_store_burstamount);

    sound(self, CHAN_AUTO, "misc/powerup_shield.wav", VOL_BASE, ATTN_NORM);

    if(!self.hg_shieldmodel) {
        e = spawn();
        e.classname = "hg_shieldmodel";
        e.owner = self;
        e.think = HG_Shield_Model_Think;
        e.nextthink = time;
        e.alpha = 0.1;
        e.effects = EF_ADDITIVE | EF_FULLBRIGHT;
        e.glow_size = 256;
        e.glow_color = 230;
        e.glow_trail = 1;
        e.avelocity = '14 0 22';
        e.movetype = MOVETYPE_FOLLOW;
        e.aiment = e.owner;
        setorigin(e, self.origin);
        setmodel(e, "models/ctf/shield.md3");
        e.scale = 0.5;
        e.hg_adept = adept;
        e.skin = 10 + !!adept;
        e.exteriormodeltoclient = self;
        setsize(e, e.scale * e.mins, e.scale * e.maxs);

        self.hg_shieldmodel = e;
    }

    return HG_ATTACK_OK;
}
