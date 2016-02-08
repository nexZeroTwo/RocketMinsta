
void HG_Plasma_Shard_Explode(void) {
    if(self.meodp_point.enemy) {
        self.realowner = self.meodp_point.enemy;
        self.team = self.meodp_point.enemy.team;
    }

    self.event_damage = SUB_Null;
    self.takedamage = DAMAGE_NO;
    self.damage_noinfo = FALSE;
    float p = Buffs_NadgetPower(self.realowner);

    RadiusDamage(self, self.realowner,
        CVAR(g_nadgets_plasma_projectile_damage) * p,
        CVAR(g_nadgets_plasma_projectile_edgedamage) * p,
        CVAR(g_nadgets_plasma_projectile_radius),
        world,
        CVAR(g_nadgets_plasma_projectile_force) * p,
        HG_PLASMA | HITTYPE_BOUNCE,
        other
    );

    remove(self);
}

void HG_Plasma_Shard_Think(void) {
    entity e;
    float found;

    if(time >= self.hg_detonatetime) {
        HG_Plasma_Shard_Explode();
        return;
    }

    if(self.hg_plasma_projdist) {
        for(e = world; (e = findfloat(e, csqcprojectile_extradata, self.csqcprojectile_extradata));) if(e != self)
            if(e.realowner == self.realowner) if(e.projectiledeathtype == self.projectiledeathtype) {
                WarpZone_FindNearestOrigin(self.origin, e.origin, 0);
                if(WarpZone_FindNearestOrigin_length < self.hg_plasma_projdist) {
                    found = TRUE;
                    break;
                }
            }

        if(!found) {
            HG_Plasma_Shard_Explode();
            return;
        }
    }

    if(time > self.hg_plasma_projdps_next) {
        float pdmg = self.hg_plasma_projdps * (time - self.hg_plasma_projdps_last);
        RadiusDamage(self, self.realowner, pdmg, pdmg, self.hg_plasma_projrange, world, 0, self.projectiledeathtype, world);
        self.hg_plasma_projdps_next = time + self.hg_plasma_projdps_delay;
        self.hg_plasma_projdps_last = time;
    }

    HealParticleEmitter(self.realowner);

    self.nextthink = time;
}

void HG_Plasma_Shard_Touch(void) {
    PROJECTILE_TOUCH;
    spamsound(self, CHAN_PROJECTILE, "weapons/electro_bounce.wav", VOL_BASE, ATTN_NORM);
}

void HG_Plasma_Shard(float kickangle) {
    entity proj;
    vector kick;

    proj = spawn();
    proj.classname = "hg_plasma";
    proj.owner = self;
    proj.realowner = self.owner;
    proj.team = proj.owner.team;
    proj.use = HG_Plasma_Shard_Explode;
    proj.think = HG_Plasma_Shard_Think;
    proj.nextthink = time;
    proj.bot_dodge = TRUE;
    proj.bot_dodgerating = CVAR(g_nadgets_plasma_projectile_damage) + 300; // just avoid plasma
    proj.hg_detonatetime = time + CVAR(g_nadgets_plasma_projectile_lifetime) + random() * CVAR(g_nadgets_plasma_projectile_lifetime_randomfactor);

    PROJECTILE_MAKETRIGGER(proj);
    proj.projectiledeathtype = HG_PLASMA | HITTYPE_SECONDARY;
    setorigin(proj, self.origin);

    proj.movetype = MOVETYPE_BOUNCE;

    if(CVAR(g_nadgets_plasma_spread_circle)) {
        kick = CircleSpreadVector(
            CVAR(g_nadgets_plasma_spread_xy),
            CVAR(g_nadgets_plasma_spread_z_min),
            kickangle
        );
    } else {
        kick = RandomSpreadVector(
            CVAR(g_nadgets_plasma_spread_xy),
            cvar("g_nadgets_plasma_spread_z"),   // FIXME: globals ending with _[xyz] wreak havoc...
            CVAR(g_nadgets_plasma_spread_z_min),
            CVAR(g_nadgets_plasma_spread_z_min_randomfactor)
        );
    }

    proj.velocity = kick + self.velocity;
    proj.touch = HG_Plasma_Shard_Touch;
    setsize(proj, '0 0 -3', '0 0 -3');
    proj.takedamage = DAMAGE_NO;
    proj.flags = FL_PROJECTILE;
    proj.hg_plasma_projrange = CVAR(g_nadgets_plasma_projectile_dps_range);
    proj.hg_plasma_projdps = CVAR(g_nadgets_plasma_projectile_dps) * Buffs_NadgetPower(self.realowner);
    proj.hg_plasma_projdps_delay = CVAR(g_nadgets_plasma_projectile_dps_delay);
    proj.hg_plasma_projdist = CVAR(g_nadgets_plasma_projectile_maxdistance);
    proj.hg_plasma_projdps_next = time + CVAR(g_nadgets_plasma_projectile_dps_pause) + random() * CVAR(g_nadgets_plasma_projectile_dps_pause_randomfactor);
    proj.hg_plasma_projdps_last = proj.hg_plasma_projdps_next - proj.hg_plasma_projdps_delay;
    proj.csqcprojectile_extradata = hg_plasma_group & 0xFF;
    proj.heal_emitter_radius = proj.hg_plasma_projrange;
    proj.damage_noinfo = TRUE;

    Buffs_MEODP_Point_Attach(proj, Buffs_MEODP_Death_Use_Multiple);
    proj.meodp_point_offs = '0 0 16';

    sound(proj, CHAN_WEAPON, "weapons/electro_fire2.wav", VOL_BASE, ATTN_NORM);
    CSQCProjectile(proj, TRUE, PROJECTILE_HG_PLASMA_SHARD, FALSE);
    proj.jb_proj_ownerstate = self.jb_proj_ownerstate;
}

void HG_Plasma_Explode(void) {
    float c;

    if(self.hg_adept && CVAR(g_nadgets_plasma_adept_stun))
        return;

    vectorvectors(normalize([self.hg_lastvel.x, self.hg_lastvel.y, 0]));

    ++hg_plasma_group;
    for (c = 0; c < CVAR(g_nadgets_plasma_projectile_count); c ++)
        HG_Plasma_Shard(2 * M_PI * (c / CVAR(g_nadgets_plasma_projectile_count)));
}
