
void W_Flak_Projectile_Touch(void) {
    PROJECTILE_TOUCH;

    if(other.takedamage) {
        float damage, frc;

        if(self.projectiledeathtype & HITTYPE_SECONDARY) {
            damage = cvar("g_balance_flak_secondary_damage") * pow(cvar("g_balance_flak_secondary_damage_bouncefactor"), self.cnt);
            frc = cvar("g_balanace_flag_secondary_force");
        } else {
            damage = cvar("g_balance_flak_primary_damage") * pow(cvar("g_balance_flak_primary_damage_bouncefactor"), self.cnt);
            frc = cvar("g_balanace_flag_primary_force");
        }

        vector center = other.origin + (other.mins + other.maxs) * 0.5;
        if(other.classname == "player")
            center = other.origin + other.view_ofs;
        vector force = normalize(center - self.origin) * frc;

        Damage(other, self, self.realowner, damage, self.projectiledeathtype, self.origin, force);

        if(W_Accuracy_IsGoodHit(self.realowner, other))
            W_Accuracy_RegisterActualDamage(self.realowner, WEP_FLAK, damage);

        remove(self);
        return;
    } else if(other.solid == SOLID_BSP) {   
        spamsound(self, CHAN_PROJECTILE, strcat("weapons/casings", ftos(floor(random() * 3) + 1), ".wav"), VOL_BASE * 0.7, ATTN_NORM);
    }
    
    pointparticles(particleeffectnum("hagar_bounce"), self.origin, self.velocity, 1);
    self.owner = world;
    self.projectiledeathtype |= HITTYPE_BOUNCE;
    self.cnt += 1;
}

void W_Flak_Projectile(float damage, float grav, float lt, float spd, float upspd, float deathtype) {
    entity e = spawn();
    e.owner = e.realowner = self;
    e.classname = "flak_proj";
    e.bot_dodge = TRUE;
    e.bot_dodgerating = damage;
    e.movetype = MOVETYPE_BOUNCE;
    PROJECTILE_MAKETRIGGER(e);
    e.projectiledeathtype = deathtype;
    e.gravity = grav;
    setorigin(e, w_shotorg);
    setsize(e, '0 0 -3', '0 0 -3');
    PROJECTILE_FIX(e)

    e.nextthink = time + lt;
    e.think = SUB_Remove;
    e.touch = W_Flak_Projectile_Touch;
    e.velocity = v_forward * spd + v_up * upspd;
    W_SetupProjectileVelocity(e);

    e.angles = vectoangles(e.velocity);
    e.flags = FL_PROJECTILE;

    CSQCProjectile(e, TRUE, PROJECTILE_FLAK, TRUE);   
}

void W_Flak_Attack1(void) {
    float pcount = cvar("g_balance_flak_primary_projectiles"), i;

    if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
        self.ammo_shells -= cvar("g_balance_flak_primary_ammo");

    W_SetupShot_ProjectileSize(self, '0 0 -3', '0 0 -3', FALSE, 4, "weapons/flak_fire.wav", cvar("g_balance_flak_primary_damage") * pcount);
    w_shotdir = v_forward;

    for(i = 0; i < pcount; ++i) {
        vector a = vectoangles(w_shotdir);

        fixedmakevectors(a + '1 0 0' *  random() * cvar("g_balance_flak_primary_spread_up")
                           + '0 1 0' * crandom() * cvar("g_balance_flak_primary_spread_side"));

        W_Flak_Projectile(cvar("g_balance_flak_primary_damage"),
                          cvar("g_balance_flak_primary_gravity"),
                          cvar("g_balance_flak_primary_lifetime"),
                          cvar("g_balance_flak_primary_speed"),
                          cvar("g_balance_flak_primary_speed_up"),
                          WEP_FLAK);
    }

    entity flash = spawn();
    setmodel(flash, "models/uziflash.md3");
    flash.think = SUB_Remove;
    flash.nextthink = time + 0.06;
    flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
    W_AttachToShotorg(flash, '5 0 0');
}

void W_Flak_Attack2(void) {
    if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
        self.ammo_shells -= cvar("g_balance_flak_secondary_ammo");

    W_SetupShot_ProjectileSize(self, '0 0 -3', '0 0 -3', FALSE, 4, "weapons/flak_fire2.wav", cvar("g_balance_flak_secondary_damage"));
    w_shotdir = v_forward;

    W_Flak_Projectile(cvar("g_balance_flak_secondary_damage"),
                      cvar("g_balance_flak_secondary_gravity"),
                      cvar("g_balance_flak_secondary_lifetime"),
                      cvar("g_balance_flak_secondary_speed"),
                      cvar("g_balance_flak_secondary_speed_up"),
                      WEP_FLAK | HITTYPE_SECONDARY);

    entity flash = spawn();
    setmodel(flash, "models/uziflash.md3");
    flash.think = SUB_Remove;
    flash.nextthink = time + 0.06;
    flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
    W_AttachToShotorg(flash, '5 0 0');
}

void spawnfunc_weapon_flak(void) {
    weapon_defaultspawnfunc(WEP_FLAK);
}

float w_flak(float req) {
    if(req == WR_AIM) {
        self.BUTTON_ATCK = bot_aim(cvar("g_balance_flak_primary_speed"), cvar("g_balance_flak_primary_speed_up"), cvar("g_balance_flak_primary_lifetime"), TRUE);
    } else if(req == WR_THINK) {
        if(self.BUTTON_ATCK)
        if(weapon_prepareattack(0, cvar("g_balance_flak_primary_refire"))) {
            W_Flak_Attack1();
            weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_flak_primary_animtime"), w_ready);
        }

        if(self.BUTTON_ATCK2)
        if(weapon_prepareattack(1, cvar("g_balance_flak_secondary_refire"))) {
            W_Flak_Attack2();
            weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_flak_secondary_animtime"), w_ready);
        }
    } else if(req == WR_PRECACHE) {
        precache_model("models/weapons/g_flak.md3");
        precache_model("models/weapons/v_flak.md3");
        precache_model("models/weapons/h_flak.dpm");
        precache_sound("weapons/flak_fire.wav");
        precache_sound("weapons/flak_fire2.wav");
        precache_sound("weapons/casings1.wav");
        precache_sound("weapons/casings2.wav");
        precache_sound("weapons/casings3.wav");
    } else if(req == WR_SETUP)
        weapon_setup(WEP_FLAK);
    else if(req == WR_CHECKAMMO1)
        return self.ammo_shells >= cvar("g_balance_flak_primary_ammo");
    else if(req == WR_CHECKAMMO2)
        return self.ammo_shells >= cvar("g_balance_flak_secondary_ammo");
    else if(req == WR_SUICIDEMESSAGE) {
        w_deathtypestring = "was mutilated by his own Flak Cannon";
    } else if(req == WR_KILLMESSAGE) {
        if(w_deathtype & HITTYPE_BOUNCE)
            w_deathtypestring = "could not hide from #'s Flak Cannon";
        else if(w_deathtype & HITTYPE_SPLASH)
            w_deathtypestring = "was blown away by #'s Flak Cannon";
        else
            w_deathtypestring = "was shredded by #'s Flak Cannon";
    }

    return TRUE;
}
