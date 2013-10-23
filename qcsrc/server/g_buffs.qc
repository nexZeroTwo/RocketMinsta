
#define ON_BUFF_ADDED(b) if(self.buffs & (b)) if not(self.oldbuffs & (b))
#define ON_BUFF_REMOVED(b) if(self.oldbuffs & (b)) if not(self.buffs & (b))

void Buffs_Init(void) {
    float i, b;
    
    g_buffs = cvar("g_buffs");
    g_buffs_team_only = cvar("g_buffs_team_only");
    g_buffs_stack = cvar("g_buffs_stack");
    g_buffs_noteam = cvar("g_buffs_noteam");
    g_buffs_randomize = cvar("g_buffs_randomize");
    
    precache_sound("misc/strength_respawn.wav");
    precache_sound("misc/shield_respawn.wav");
    precache_sound("misc/arc1.wav");
    precache_sound("misc/arc2.wav");
    precache_model("models/buffs/buff.md3");
    precache_model("models/buffs/buff_ring.md3");
    
    addstat(STAT_BUFFS, AS_INT, buffs);
    
    for(i = 0, b = 1; i < BUFF_COUNT; ++i, b *= 2)
        g_buffs_enabled[i] = cvar(strcat("g_buffs_", Buffs_TypeToName(b)));
    
    InitializeEntity(world, Buffs_Init_Delayed, INITPRIO_LAST);
}

void Buffs_Randomize_Reset(void) {
    float i;
    
    for(i = 0; i < BUFF_COUNT; ++i) {
        g_buffs_replacements[i] = 0;
        g_buffs_used[i] = 0;
    }
}

void Buffs_Randomize(entity blist) {
    float i, j;
    float found;
    float ulevel = 1;
    entity b;
    
    Buffs_Randomize_Reset();
    
    for(i = 0; i < BUFF_COUNT; ++i) {
        RandomSelection_Init();
        found = 0;
        
        while(!found) {
            for(j = 0; j < BUFF_COUNT; ++j)
                if(g_buffs_enabled[j] && g_buffs_used[j] < ulevel) {
                    RandomSelection_Add(world, j, string_null, 1, 1);
                    ++found;
                }
            
            if(!found)
                ++ulevel;
        }
        
        g_buffs_used[RandomSelection_chosen_float] = ulevel;
        g_buffs_replacements[i] = pow(2, RandomSelection_chosen_float);
    }
    
    if(!blist)
        blist = findchain(classname, "item_buff");
    
    for(b = blist; b; b = b.chain) {
        i = Buffs_TypeToIndex(b.origbuffs);
        j = g_buffs_replacements[i];
        if(j) b.buffs = j;
    }
}

float buff_teamfound[4];
void Buffs_Init_Delayed(void) {
    entity blist, b;
    float idx, teams_found, teams_total;
    
    if(!teams_matter)
        return;
    
    teams_total = TeamCount_TotalTeams();
    
    blist = findchain(classname, "item_buff");
    for(b = blist; b; b = b.chain) if(b.team) {
        idx = Team_Index(b.team);
        if(!buff_teamfound[idx]) {
            buff_teamfound[idx] = TRUE;
            ++teams_found;
        }
        
        if(b.team == COLOR_TEAM3 && teams_total < 3 || b.team == COLOR_TEAM4 && teams_total < 4) {
            b.think = Buffs_BuffPickup_Remove;
            b.nextthink = time;
        }
    }
    
    if(teams_total > teams_found)
    for(b = blist; b; b = b.chain) if(b.team) {
        b.think = Buffs_BuffPickup_Remove;
        b.nextthink = time;
    }
    
    if(g_buffs_randomize)
        Buffs_Randomize(blist);
}

float Buffs_BuffModel_Customize(void) {
    if(other == self.owner || (other.classname == "spectator" && other.enemy == self.owner)) {
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

void Buffs_ArcEffect(vector from, vector to, float t) {
    te_csqc_lightningarc(from, to, TRUE, t);
}

void Buffs_ArcDamage(entity targ, entity attacker, float damage, float deathtype) {
    entity oldself = self;
    entity plr, newtarget;
    float dist, shortest;
    
    float arcfactor = cvar("g_buffs_arc_multiplier");
    float arcrange = cvar("g_buffs_arc_range");
    float archgfactor = cvar("g_buffs_arc_multiplier_hg");
    vector arcoffset = attacker.maxs_z * '0 0 0.5';
    
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
    if(!plr.jb_isprisoned)
    if(!plr.buffs_arc_hit)
    if(!plr.frozen || !newtarget || newtarget.frozen)
    if(!teams_matter || plr.team != attacker.team) {
        dist = vlen(plr.origin - targ.origin);
        
        if(!shortest || dist < shortest || (newtarget.frozen && !plr.frozen)) {
            traceline(targ.origin + arcoffset, plr.origin + arcoffset, MOVE_NORMAL, targ);
            
            if(trace_fraction != 1 && trace_ent == plr) {
                shortest = dist;
                newtarget = plr;
            }
        }
    }
    
    if(newtarget) {
        Buffs_ArcEffect(targ.origin + arcoffset, newtarget.origin + arcoffset, attacker.team);
        Damage(newtarget, attacker, attacker, damage, DEATH_ARC, '0 0 0', normalize(newtarget.origin - targ.origin) * cvar("g_buffs_arc_pushback"));
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

float Buffs_BuffPickup_Waypoint_VisibleForPlayer(entity plr) {
    if(self.team && (plr.buffs & self.owner.buffs || (plr.buffs && !g_buffs_stack)))
        return FALSE;
    return WaypointSprite_visible_for_player(plr);
}

void Buffs_BuffPickup_SpawnWaypoint(entity e) {
    WaypointSprite_Spawn(Buffs_TypeToExpandedName(e.buffs), 0, 0, world, e.origin + '0 0 40', world, e.team, e, buff_waypoint, TRUE);
    WaypointSprite_UpdateTextColors(e.buff_waypoint, e.colormod, '0 0 0', '0 0 0');
    WaypointSprite_UpdateTeamRadar(e.buff_waypoint, RADARICON_FLAG, e.colormod);
    e.buff_waypoint.waypointsprite_visible_for_player = Buffs_BuffPickup_Waypoint_VisibleForPlayer;
}

void Buffs_BuffPickup_Think(void) {
    if(time < 1)
        return;
    
    if(self.buffs != self.oldbuffs) {
        self.glow_color = Buffs_TypeToPaletteColor(self.buffs);
        self.colormod = Buffs_TypeToColor(self.buffs);
        self.enemy.colormod = (self.team? TeamColor(self.team) + '0.1 0.1 0.1' : self.colormod);
        
        if(self.buff_waypoint) {
            WaypointSprite_Disown(self.buff_waypoint, 1);
            Buffs_BuffPickup_SpawnWaypoint(self);
        }
        
        self.oldbuffs = self.buffs;
    }
    
    if(!self.buff_active && !self.buff_activetime)
    if(!self.owner || self.owner.frozen || self.owner.jb_isprisoned || self.owner.deadflag != DEAD_NO || !self.owner.iscreature || !(self.owner.buffs & self.buffs)) {
        if(self.owner.buff_cdoverride) {
            self.buff_activetime = max(0, self.owner.buff_cdoverride) + frametime;
            self.owner.buff_cdoverride = 0;
        } else
            self.buff_activetime = cvar("g_buffs_reactivate_delay") + frametime;
        self.owner = world;
    }
    
    if(self.buff_activetime) {
        if(!self.buff_waypoint && self.buff_activetime > frametime) {
            Buffs_BuffPickup_SpawnWaypoint(self);
        }
        
        if(roundstate == ROUNDSTATE_GAME) {
            if(self.buff_activetime > frametime) {
                if(!self.buff_waypoint.max_health)
                    WaypointSprite_UpdateMaxHealth(self.buff_waypoint, self.buff_activetime);
                WaypointSprite_UpdateHealth(self.buff_waypoint, self.buff_waypoint.max_health - self.buff_activetime);
            }
            
            self.buff_activetime = max(0, self.buff_activetime - frametime);
            
            if(!self.buff_activetime) {
                self.buff_active = TRUE;
                WaypointSprite_Disown(self.buff_waypoint, 1);
                sound(self, CHAN_TRIGGER, "misc/strength_respawn.wav", VOL_BASE, ATTN_NORM); 
            }
        }
    }
    
    if(!self.buff_active) {
        if(self.buff_waypoint && !self.buff_activetime)
            WaypointSprite_Disown(self.buff_waypoint, 1);
        
        self.alpha = 0.3;
        self.effects &~= EF_FULLBRIGHT | EF_ADDITIVE;
        self.glow_size_saved = 0;
    } else {
        self.alpha = 1;
        self.effects |= EF_FULLBRIGHT | EF_ADDITIVE;
        self.glow_size_saved = 220 + 36 * sin(time);
        
        if(self.team && !self.buff_waypoint)
            Buffs_BuffPickup_SpawnWaypoint(self);
    }
    
    self.nextthink = time;
    self.angles_y = time * 110.1;
}

void Buffs_BuffPickup_Ring_Think(void) {
    self.nextthink = time;
    self.angles_y = time * 157.1;
    self.alpha = self.owner.alpha;
    self.effects = self.owner.effects - EF_STARDUST;
    
    if(self.owner.team)
        self.effects &~= EF_ADDITIVE;
    
    setorigin(self, self.owner.origin + '0 0 15');
}

float Buffs_BuffPickup_Customize(void) {
    entity e = other;
    if(e.classname == "spectator")
        e = e.enemy;
    
    if(self.team && self.team != e.team) {
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
    
    if(self.buff_waypoint)
        WaypointSprite_Kill(self.buff_waypoint);
    
    if(self.buff_activetime)
        Buffs_BuffPickup_SpawnWaypoint(self);
}

void Buffs_BuffPickup_GiveTo(entity plr) {
    if(self.owner || BUFFS_PRESENT(plr, self.buffs) || (plr.buffs && !g_buffs_stack))
        return;
    
    self.owner = plr;
    self.buff_active = FALSE;
    
    string bname = strcat(rgb_to_hexcolor(Buffs_TypeToColor(self.buffs)), Buffs_TypeToExpandedName(self.buffs), "^7 Buff!");
    string tn = (self.team? strcat(Team_ColorCode(self.team), strtoupper(Team_ColorName(self.team)), " ") : "");
    
    bprint("^3", plr.netname, " ^7got the ", tn, bname, "\n");
    bigprint_spec(plr, strcat("You got the ", bname), "", 3);
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
    
    if not(g_buffs_randomize)
    if not(g_buffs_enabled[Buffs_TypeToIndex(self.buffs)]) {
        remove(self);
        return;
    }
    
    if(g_buffs_noteam)
        self.team = 0;
    
    self.origbuffs = self.buffs;
    self.classname = "item_buff";
    self.flags = FL_ITEM;
    self.solid = SOLID_TRIGGER;
    self.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY;
    self.movetype = MOVETYPE_TOSS;
    self.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_STARDUST;
    self.think = Buffs_BuffPickup_Think;
    self.touch = Buffs_BuffPickup_Touch;
    self.reset = Buffs_BuffPickup_Reset;
    self.nextthink = time;
    self.scale = 1.5;
    self.buff_activetime = cvar("g_buffs_activate_delay");
    self.buff_active = !self.buff_activetime;
    self.glow_color = Buffs_TypeToPaletteColor(self.buffs);
    self.colormod = Buffs_TypeToColor(self.buffs);
    self.gravity = 100;
    setmodel(self, "models/buffs/buff.md3");
    setsize(self, '-15 -15 -40', '15 15 40');
    
    self.enemy = spawn();
    self.enemy.owner = self;
    self.enemy.think = Buffs_BuffPickup_Ring_Think;
    self.enemy.nextthink = time;
    self.enemy.effects = self.effects;
    self.enemy.alpha = self.alpha;
    self.enemy.scale = self.scale * 1.2;
    self.enemy.team = self.team;
    self.enemy.gravity = self.gravity;
    self.enemy.colormod = (self.team? TeamColor(self.team) + '0.1 0.1 0.1' : self.colormod);
    
    move_out_of_solid(self);
    droptofloor();
    
    SetCustomizer(self, Buffs_BuffPickup_Customize, SUB_Nullpointer);
    
    setsize(self.enemy, self.mins, self.maxs);
    setorigin(self.enemy, self.origin + self.maxs * 0.5 * self.scale);
    setmodel(self.enemy, "models/buffs/buff_ring.md3");
}

void Buffs_BuffPickup_Remove(void) {
    if(self.buff_waypoint)
        WaypointSprite_Kill(self.buff_waypoint);
    if(self.enemy)
        remove(self.enemy);
    remove(self);
}

// NOTE: Quake III: Team Arena compatibility is untested

#define BUFF_SPAWNFUNC(e,b,t) void spawnfunc_item_buff_##e() { self.buffs = b; self.team = t; Buffs_BuffPickup_Setup(); }
#define BUFF_SPAWNFUNC_Q3TA_COMPAT(o,e) void spawnfunc_##o() {                        \
                                            if(self.spawnflags & 2)                   \
                                                spawnfunc_item_buff_##e##_team1();    \
                                            else if(self.spawnflags & 4)              \
                                                spawnfunc_item_buff_##e##_team2();    \
                                            else                                      \
                                                spawnfunc_item_buff_##e();            \
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

BUFF_SPAWNFUNC(medic,           BUFF_MEDIC,     0)
BUFF_SPAWNFUNC(medic_team1,     BUFF_MEDIC,     COLOR_TEAM1)
BUFF_SPAWNFUNC(medic_team2,     BUFF_MEDIC,     COLOR_TEAM2)
BUFF_SPAWNFUNC(medic_team3,     BUFF_MEDIC,     COLOR_TEAM3)
BUFF_SPAWNFUNC(medic_team4,     BUFF_MEDIC,     COLOR_TEAM4)

BUFF_SPAWNFUNC_Q3TA_COMPAT(item_doubler,    arc)
BUFF_SPAWNFUNC_Q3TA_COMPAT(item_guard,      guard)
BUFF_SPAWNFUNC_Q3TA_COMPAT(item_scout,      haste)
BUFF_SPAWNFUNC_Q3TA_COMPAT(item_ammoregen,  supply)


