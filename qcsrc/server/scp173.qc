
#define SCP173_THINKTIME 0.1
#define SCP173_THINKTIME_AFTERKILL 2
#define SCP173_ROAM_ANGLEFACTOR 90
#define SCP173_ROAM_STEPLEN 75
#define SCP173_CHASE_ANGLEFACTOR 15
#define SCP173_CHASE_STEPLEN 100
#define SCP173_CHASE_RANGE 500
#define SCP173_STEP_HOFS_MAX 3
#define SCP173_STEP_HOFS_INCREMENT 0.1

float scp173_check_seen(void) {
    FOR_EACH_CLIENT(var cl) {
        var p = cl.clientcamera;
        makevectors(p.v_angle);

        var v = p.origin + p.view_ofs;

        if(WarpZone_FindLineOfSight(v_forward, v, self.origin + self.view_ofs, MOVE_NOMONSTERS, self))
            return TRUE;

        if(WarpZone_FindLineOfSight(v_forward, v, self.origin, MOVE_NOMONSTERS, self))
            return TRUE;

        if(WarpZone_FindLineOfSight(v_forward, v, self.origin + self.view_ofs * 2, MOVE_NOMONSTERS, self))
            return TRUE;
    }

    return FALSE;
}

float scp173_step_ofs(float dst, float hofs) {
    var ofs = [0, 0, self.maxs_z * hofs];

    WarpZone_TraceBox(self.origin + ofs, self.mins + [0, 0, CVAR(sv_stepheight)], self.maxs, self.origin + ofs + v_forward * dst, MOVE_NOMONSTERS, self);
    var o = self.origin;

    if(!trace_fraction || trace_startsolid)
        return FALSE;

    setorigin(self, trace_endpos);
    self.flags &~= FL_ONGROUND;

    if(!move_out_of_solid(self, MOVE_NOMONSTERS)) {
        setorigin(self, o);
        trace_startsolid = FALSE;
        return FALSE;
    }

    WarpZone_TraceBox(self.origin, self.mins, self.maxs, self.origin - [0, 0, MAX_SHOT_DISTANCE], MOVE_NOMONSTERS, self);
    setorigin(self, trace_endpos);

    if(!boxesoverlap(world.absmin, world.absmax, self.absmin, self.absmax)) {
        setorigin(self, o);
        return FALSE;
    }

    if(scp173_check_seen()) {
        setorigin(self, o);
        return FALSE;
    }

    return TRUE;
}

float scp173_step(float dst) {
    for(var o = 0; o < SCP173_STEP_HOFS_MAX; o = min(SCP173_STEP_HOFS_MAX, o + SCP173_STEP_HOFS_INCREMENT)) {
        if(scp173_step_ofs(dst, o))
            return TRUE;
        if(trace_startsolid)
            return FALSE;
    }
    return FALSE;
}

entity scp173_find_target(void) {
    var targ = world;
    var targdst = SCP173_CHASE_RANGE;

    var o = self.origin + self.view_ofs;

    FOR_EACH_PLAYER(var plr) {
        if(PlayerIsDead(plr) || !plr.takedamage)
            continue;

        var po = plr.origin + plr.view_ofs;
        var dst = vlen(o - po);

        if(dst > targdst)
            continue;

        traceline(o, po, MOVE_NOMONSTERS, self);

        if(trace_fraction < 1)
            continue;

        targ = plr;
        targdst = dst;
    }

    return targ;
}

void scp173_roam(void) {
    var tries = 10;

    do {
        self.angles_y += SCP173_ROAM_ANGLEFACTOR * crandom();
        makevectors(self.angles);
    } while(!scp173_step(SCP173_ROAM_STEPLEN) && (--tries));
}

float scp173_chase(entity targ) {
    var dir = normalize(targ.origin - self.origin);
    var a = vectoangles(dir);
    self.angles_y = a_y + SCP173_CHASE_ANGLEFACTOR * crandom();
    makevectors(self.angles);

    if(!scp173_step(SCP173_CHASE_STEPLEN))
        return FALSE;

    if(vlen(self.origin - targ.origin) < SCP173_CHASE_STEPLEN * 0.75) {
        var o = self.origin;
        setorigin(self, targ.origin);
        if(!move_out_of_solid(self, MOVE_NOMONSTERS))
            setorigin(self, o);

        Damage(targ, self, self, 100000, DEATH_GUARANTEED, targ.origin, '0 0 0');
        self.nextthink = time + SCP173_THINKTIME_AFTERKILL;
    }

    return TRUE;
}

void scp173_think(void) {
    self.nextthink = time + SCP173_THINKTIME;

    if(!scp173_check_seen()) {
        var targ = scp173_find_target();
        if(!targ || !scp173_chase(targ))
            scp173_roam();
    }
}

void scp173_reset(void) {
    setorigin(self, self.aiment.origin);
    self.angles = self.aiment.angles;
    self.nextthink = time;
    self.flags &~= FL_ONGROUND;
    droptofloor();
}

void spawnfunc_scp173(void) {
    self {
        classname: "scp173",
        model: "models/scp173.iqm",
        solid: SOLID_BBOX,
        movetype: MOVETYPE_TOSS,
        think: scp173_think,
        reset: scp173_reset,
        nextthink: time,
    };

    precache_model(self.model);
    setmodel(self, self.model);
    move_out_of_solid(self, MOVE_NOMONSTERS);
    droptofloor();

    self.view_ofs_z = self.maxs_z * 0.5;

    self.aiment = spawn() {
        classname: "scp173_spawnpoint",
        origin: self.origin,
        angles: self.angles,
    };
}
