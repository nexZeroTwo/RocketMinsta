

#define ON_BUFF_ADDED(b) if(self.buffs & (b)) if not(self.oldbuffs & (b))
#define ON_BUFF_REMOVED(b) if(self.oldbuffs & (b)) if not(self.buffs & (b))

void Buffs_Init(void) {
    g_buffs = cvar("g_buffs");
    g_buffs_team_only = cvar("g_buffs_team_only");
    g_buffs_stack = cvar("g_buffs_stack");
    
    precache_sound("misc/strength_respawn.wav");
    precache_sound("misc/shield_respawn.wav");
    precache_sound("misc/arc1.wav");
    precache_sound("misc/arc2.wav");
    precache_model("models/buffs/buff.md3");
    precache_model("models/buffs/buff_ring.md3");
    
    addstat(STAT_BUFFS, AS_INT, buffs);
}

float Buffs_BuffModel_Customize(void) {
    if(other == self.owner || other.enemy == self.owner) {
        // somewhat hide the model, but keep the glow
        self.effects = 0;
        self.alpha = 0.01;
    } else {
        self.effects = EF_ADDITIVE | EF_FULLBRIGHT;
        self.alpha = 1;
    }
    return TRUE;
}

void Buffs_ClientFrame(void) {
    if(self.classname != "player") {
        if(self.buff_model) {
            remove(self.buff_model);
            self.buff_model = world;
        }
        return;
    }
    
    if(self.buffs != self.oldbuffs) {
        ON_BUFF_ADDED(BUFF_SUPPLY) {
            self.campingrifle_bulletcounter = 9001;
            
            if(!g_weaponarena) {
                float a = cvar("g_buffs_supply_grant_ammo");
                self.ammo_cells += a;
                self.ammo_shells += a;
                self.ammo_rockets += a;
                self.ammo_nails += a;
            }
        }
        
        ON_BUFF_ADDED(BUFF_GUARD) {
            self.health = max(cvar("g_buffs_guard_pickup_health"), self.health);
            self.armorvalue = max(cvar("g_buffs_guard_pickup_armor"), self.armorvalue);
        }
        
        self.oldbuffs = self.buffs;
    }
    
    if(self.buffs) {
        if(!self.buff_model) {
            entity m = spawn();
            setsize(m, '0 0 -40', '0 0 40');
            setmodel(m, "models/buffs/buff.md3");
            m.customizeentityforclient = Buffs_BuffModel_Customize;
            m.owner = self;
            self.buff_model = m;
        }
        
        setorigin(self.buff_model, self.origin + '0 0 70');
        self.buff_model.angles_y = 200 * time;
        
        float b; for(b = BUFF_FIRST; b <= BUFF_LAST; b *= 2)
            if(self.buffs & b) {
                self.buff_model.colormod = Buffs_TypeToColor(b);
                self.buff_model.glow_color = Buffs_TypeToPaletteColor(b);
                self.buff_model.glow_size = 200;
                break;
            }
    } else if(self.buff_model) {
        remove(self.buff_model);
        self.buff_model = world;
    }
}

#undef ON_BUFF_ADDED
#undef ON_BUFF_REMOVED

void Buffs_ArcEffect(vector from, vector to) {
    WriteByte(MSG_ALL, SVC_TEMPENTITY);
    WriteByte(MSG_ALL, TE_CSQC_ARC);
    WriteCoord(MSG_ALL, from_x);
    WriteCoord(MSG_ALL, from_y);
    WriteCoord(MSG_ALL, from_z);
    WriteCoord(MSG_ALL, to_x);
    WriteCoord(MSG_ALL, to_y);
    WriteCoord(MSG_ALL, to_z);
}

void Buffs_ArcDamage(entity targ, entity attacker, float damage, float deathtype) {
    entity oldself = self;
    entity plr, newtarget;
    float dist, shortest;
    
    float arcfactor = cvar("g_buffs_arc_multiplier");
    float arcrange = cvar("g_buffs_arc_range");
    float archgfactor = cvar("g_buffs_arc_multiplier_hg");
    
    if(DEATH_ISHG(deathtype))
        damage = damage * archgfactor;
    damage = damage * arcfactor;
    
    newtarget = world;
    shortest = arcrange;
    targ.buffs_arc_hit = TRUE;
    
    if(damage < 1)
        return;
    
    FOR_EACH_PLAYER(plr)
    if(plr != attacker)
    if(plr != targ)
    if(plr.deadflag == DEAD_NO)
    if(!plr.frozen)
    if(!plr.jb_isprisoned)
    if(!plr.buffs_arc_hit)
    if(!teams_matter || plr.team != attacker.team) {
        dist = vlen(plr.origin - targ.origin);
        
        if(!shortest || dist < shortest) {
            traceline(targ.origin, plr.origin, MOVE_NORMAL, targ);
            
            if(trace_fraction != 1 && trace_ent == plr) {
                shortest = dist;
                newtarget = plr;
            }
        }
    }
    
    if(newtarget) {
        vector offs = '0 0 1' * targ.maxs_z * 0.5;
        Damage(newtarget, attacker, attacker, damage, DEATH_ARC, '0 0 0', '0 0 0');
        Buffs_ArcEffect(targ.origin + offs, newtarget.origin + offs);
        Buffs_ArcDamage(newtarget, attacker, damage, DEATH_ARC);
        sound(newtarget, CHAN_PROJECTILE, strcat("misc/arc", ftos(1 + (random() > 0.5)), ".wav"), VOL_BASE, ATTN_NONE);
    }
    self = oldself;
}

void Buffs_ArcDamage_Finalize(void) {
    entity e; for(e = world; (e = findfloat(e, buffs_arc_hit, TRUE));)
        e.buffs_arc_hit = FALSE;
}

.float glow_size_saved;

void Buffs_BuffPickup_Think(void) {
    if(!self.buff_active && !self.buff_activetime)
    if(!self.owner || self.owner.frozen || self.owner.jb_isprisoned || self.owner.deadflag != DEAD_NO || self.owner.classname != "player") {
        self.owner = world;
        self.buff_activetime = cvar("g_buffs_reactivate_delay") + frametime;
    }
    
    if(self.buff_activetime && roundstate == ROUNDSTATE_GAME) {
        if(!self.buff_waypoint) {
            WaypointSprite_Spawn(Buffs_TypeToExpandedName(self.buffs), 0, 0, world, self.origin + '0 0 40', world, self.team, self, buff_waypoint, TRUE);
            WaypointSprite_UpdateTextColors(self.buff_waypoint, self.colormod, '0 0 0', '0 0 0');
            WaypointSprite_UpdateMaxHealth(self.buff_waypoint, self.buff_activetime);
            WaypointSprite_UpdateTeamRadar(self.buff_waypoint, RADARICON_FLAG, self.colormod);
        }
        
        WaypointSprite_UpdateHealth(self.buff_waypoint, self.buff_waypoint.max_health - self.buff_activetime);
        self.buff_activetime = max(0, self.buff_activetime - frametime);
        
        if(!self.buff_activetime) {
            self.buff_active = TRUE;
            WaypointSprite_Disown(self.buff_waypoint, 1);
            sound(self, CHAN_TRIGGER, "misc/strength_respawn.wav", VOL_BASE, ATTN_NORM); 
        }
    }
    
    if(!self.buff_active) {
        self.alpha = 0.5;
        self.effects &~= EF_FULLBRIGHT | EF_ADDITIVE;
        self.glow_size_saved = 0;
    } else {
        self.alpha = 1;
        self.effects |= EF_FULLBRIGHT | EF_ADDITIVE;
        self.glow_size_saved = 220 + 36 * sin(time);
    }
    
    self.nextthink = time;
    self.angles_y = time * 110.1;
}

void Buffs_BuffPickup_Ring_Think(void) {
    self.nextthink = time;
    self.angles_y = time * 157.1;
    self.colormod = self.owner.colormod;
    self.alpha = self.owner.alpha;
    self.effects = self.owner.effects - EF_STARDUST;
    setorigin(self, self.owner.origin + '0 0 15');
}

float Buffs_BuffPickup_Customize(void) {
    entity e = other;
    if(e.classname == "spectator")
        e = e.enemy;
    
    if(self.team && self.team != e.team) {
        if(self.cnt)
            return FALSE;
            
        self.glow_size = 0;
    } else {
        self.glow_size = self.glow_size_saved;
    }
    
    return TRUE;
}

void Buffs_BuffPickup_Reset(void) {
    self.owner = world;
    self.buff_activetime = cvar("g_buffs_activate_delay");
    self.buff_active = !self.buff_activetime;
}

void Buffs_BuffPickup_GiveTo(entity plr) {
    if(self.owner || BUFFS_PRESENT(plr, self.buffs) || (plr.buffs && !g_buffs_stack))
        return;
    
    self.owner = plr;
    self.buff_active = FALSE;
    
    bigprint(plr, strcat("You got the ", rgb_to_hexcolor(Buffs_TypeToColor(self.buffs)), Buffs_TypeToExpandedName(self.buffs), "^7 Buff!"), "", 3);
    sound(other, CHAN_TRIGGER, "misc/shield_respawn.wav", VOL_BASE, ATTN_NORM); 
    BUFFS_GIVE(plr, self.buffs);
}

void Buffs_BuffPickup_Touch(void) {
    if(!self.buff_active)
        return;
    
    if(self.team && other.team != self.team)
        return;
    
    if(other.deadflag != DEAD_NO)
        return;
    
    if(other.frozen)
        return;
    
    if(other.jb_isprisoned)
        return;
    
    if(other.classname != "player")
        return;
    
    Buffs_BuffPickup_GiveTo(other);
}

void Buffs_BuffPickup_Setup(void) {
    if(!g_buffs || (self.team && !teams_matter) || (g_buffs_team_only && !self.team)) {
        remove(self);
        return;
    }
    
    self.classname = "item_buff";
    self.flags = FL_ITEM;
    self.solid = SOLID_TRIGGER;
    self.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY;
    self.movetype = MOVETYPE_TOSS;
    self.glow_color = Buffs_TypeToPaletteColor(self.buffs);
    self.colormod = Buffs_TypeToColor(self.buffs);
    self.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_STARDUST;
    self.think = Buffs_BuffPickup_Think;
    self.touch = Buffs_BuffPickup_Touch;
    self.reset = Buffs_BuffPickup_Reset;
    self.nextthink = time;
    self.scale = 1.5;
    self.buff_activetime = cvar("g_buffs_activate_delay");
    self.buff_active = !self.buff_activetime;
    setmodel(self, "models/buffs/buff.md3");
    setsize(self, '0 0 -40', '0 0 40');
    
    self.enemy = spawn();
    self.enemy.owner = self;
    self.enemy.think = Buffs_BuffPickup_Ring_Think;
    self.enemy.nextthink = time;
    self.enemy.effects = self.effects;
    self.enemy.colormod = self.colormod;
    self.enemy.alpha = self.alpha;
    self.enemy.scale = self.scale * 1.2;
    self.enemy.team = self.team;
    self.enemy.cnt = TRUE;
    
    SetCustomizer(self,         Buffs_BuffPickup_Customize, SUB_Nullpointer);
    SetCustomizer(self.enemy,   Buffs_BuffPickup_Customize, SUB_Nullpointer);
    
    setsize(self.enemy, self.mins, self.maxs);
    setorigin(self.enemy, self.origin + self.maxs * 0.5 * self.scale);
    setmodel(self.enemy, "models/buffs/buff_ring.md3");
}

// NOTE: Quake III: Team Arena compatibility is untested

#define BUFF_SPAWNFUNC(e,b,t) void spawnfunc_item_buff_##e() { self.buffs = b; self.team = t; Buffs_BuffPickup_Setup(); }
#define BUFF_SPAWNFUNC_Q3TA_COMPAT(o,e) void spawnfunc_##o() {                      \
                                            if(self.spawnflags & 2)                 \
                                                spawnfunc_item_buff_##e##_team1();    \
                                            else if(self.spawnflags & 4)            \
                                                spawnfunc_item_buff_##e##_team2();    \
                                        }

BUFF_SPAWNFUNC(arc,             BUFF_ARC,       0)
BUFF_SPAWNFUNC(arc_team1,       BUFF_ARC,       COLOR_TEAM1)
BUFF_SPAWNFUNC(arc_team2,       BUFF_ARC,       COLOR_TEAM2)
BUFF_SPAWNFUNC(arc_team3,       BUFF_ARC,       COLOR_TEAM3)
BUFF_SPAWNFUNC(arc_team4,       BUFF_ARC,       COLOR_TEAM4)

BUFF_SPAWNFUNC(guard,           BUFF_GUARD,     0)
BUFF_SPAWNFUNC(guard_team1,     BUFF_GUARD,     COLOR_TEAM1)
BUFF_SPAWNFUNC(guard_team2,     BUFF_GUARD,     COLOR_TEAM2)
BUFF_SPAWNFUNC(guard_team3,     BUFF_GUARD,     COLOR_TEAM3)
BUFF_SPAWNFUNC(guard_team4,     BUFF_GUARD,     COLOR_TEAM4)

BUFF_SPAWNFUNC(supply,          BUFF_SUPPLY,    0)
BUFF_SPAWNFUNC(supply_team1,    BUFF_SUPPLY,    COLOR_TEAM1)
BUFF_SPAWNFUNC(supply_team2,    BUFF_SUPPLY,    COLOR_TEAM2)
BUFF_SPAWNFUNC(supply_team3,    BUFF_SUPPLY,    COLOR_TEAM3)
BUFF_SPAWNFUNC(supply_team4,    BUFF_SUPPLY,    COLOR_TEAM4)

BUFF_SPAWNFUNC(haste,           BUFF_HASTE,     0)
BUFF_SPAWNFUNC(haste_team1,     BUFF_HASTE,     COLOR_TEAM1)
BUFF_SPAWNFUNC(haste_team2,     BUFF_HASTE,     COLOR_TEAM2)
BUFF_SPAWNFUNC(haste_team3,     BUFF_HASTE,     COLOR_TEAM3)
BUFF_SPAWNFUNC(haste_team4,     BUFF_HASTE,     COLOR_TEAM4)

BUFF_SPAWNFUNC_Q3TA_COMPAT(item_doubler,    arc)
BUFF_SPAWNFUNC_Q3TA_COMPAT(item_guard,      guard)
BUFF_SPAWNFUNC_Q3TA_COMPAT(item_scout,      haste)
BUFF_SPAWNFUNC_Q3TA_COMPAT(item_ammoregen,  supply)
