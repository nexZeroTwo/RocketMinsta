
.float zapper_range;
.vector zapper_start;
.vector zapper_end;
.vector zapper_offs;

vector Zapper_BeamRGB(float t) {
    switch(self.team) {
        case COLOR_TEAM1:            return '5.0   1.0   0.5';
        case COLOR_TEAM2: default:   return '0.5   1.0   5.0';
        case COLOR_TEAM3:            return '4.0   2.5   0.5';
        case COLOR_TEAM4:            return '5.0   0.7   3.0';
    }
}

void Zapper_Draw(void) {
    vector start;

    InterpolateOrigin_Do();
    self.zapper_end = self.origin;

    float me = ((spectatee_status > 0)? spectatee_status : player_localentnum);

    start = self.zapper_start;
    if(self.sv_entnum == me) if(!cvar("chase_active")) {
        start = view_origin + view_forward * (zapper_shotorigin_x - 1) + view_right * zapper_shotorigin_y + view_up * zapper_shotorigin_z;
        self.zapper_start = start;
    }

    self.zapper_offs += (randomvec() - self.zapper_offs) * drawframetime * 10;

    vector end1 = self.zapper_end;
    vector end2 = self.zapper_end + self.zapper_offs * 70;
    vector d = end2 - start;
    float maxlen = vlen(end1 - start);

    if(vlen(d) > maxlen)
        end2 = start + normalize(d) * maxlen;

    string tex = "particles/zapper";
    vector rgb = Zapper_BeamRGB(self.team);

    Draw_CylindricLine(end1, start, 12, "particles/zapper", 0.03, 5 * time, rgb, self.alpha, DRAWFLAG_ADDITIVE);
    Draw_CylindricLine(end2, start,  7, "particles/zapper", 0.03, 7 * time, rgb, self.alpha, DRAWFLAG_ADDITIVE);

    if(self.alpha < 1)
        return;

    float eff_zap = rm_particleeffectnum_team("RM_ZAPPER", self.team, 2);
    float eff_muz = rm_particleeffectnum_team("RM_ZAPPER_MUZZLEFLASH", self.team, 2);
    float pcount = frametime * 300;

    pointparticles(eff_zap, end1, '0 0 0', pcount);
    pointparticles(eff_zap, end2, '0 0 0', pcount);
    pointparticles(eff_muz, start, end1 - start, pcount);
}

void Zapper_Fader_Think(void) {
    self.alpha = approach(self.alpha, 0, frametime * 10);

    if(!self.alpha) {
        remove(self);
        return;
    }

    self.nextthink = time;
}

void Zapper_Fader_Spawn(entity ref) {
    entity e = spawn();
    e.draw = ref.draw;
    e.sv_entnum = ref.sv_entnum;
    e.team = ref.team;
    e.zapper_start = ref.zapper_start;
    e.zapper_end = ref.zapper_end;
    e.origin = ref.origin;
    e.alpha = 1;
    e.think = Zapper_Fader_Think;
    e.nextthink = time;
}

.float snd_looping;
void Zapper_Remove(void) {
    Zapper_Fader_Spawn(self);
    sound(self, CHAN_PROJECTILE, "misc/null.wav", VOL_BASE, ATTN_NORM);
}

void Zapper_Read(void) {
    float sf = ReadByte();

    if(sf & 1) {
        self.draw = Zapper_Draw;
        self.entremove = Zapper_Remove;
        self.sv_entnum = ReadByte();
        self.team = GetPlayerColor(self.sv_entnum - 1);
        self.alpha = 1;

        if(!rm_teamlasers)
            self.team = COLOR_TEAM2;

        sound(self, CHAN_PROJECTILE, "weapons/zapper_fly.wav", VOL_BASE, ATTN_NORM);
    }

    if(sf & 2) {
        self.zapper_start_x = ReadCoord();
        self.zapper_start_y = ReadCoord();
        self.zapper_start_z = ReadCoord();
    }

    if(sf & 4) {
        self.zapper_end_x = ReadCoord();
        self.zapper_end_y = ReadCoord();
        self.zapper_end_z = ReadCoord();
        setorigin(self, self.zapper_end);
        InterpolateOrigin_Note();
    }
    
    if(sf & 8) {
        zapper_shotorigin = decompressShotOrigin(ReadInt24_t());
    }
}

void Zapper_ReadLightning(void) {
    float ateam;
    vector from, to;
    
    ateam  = ReadByte();
    from_x = ReadCoord(); from_y = ReadCoord(); from_z = ReadCoord();
    to_x   = ReadCoord(); to_y   = ReadCoord(); to_z   = ReadCoord();

    if(!rm_teamlasers)
        ateam = COLOR_TEAM2;

    pointparticles(rm_particleeffectnum_team("RM_HG_PLASMA_SHARD_EXPLODE", ateam, 2), to, '0 0 0', 1);

    if(cvar("cl_effects_lightningarc_simple")) {
        LightingArc_Segment(from, to, ateam);
    } else {
        float seglength, drifts, drifte, branchfactor, branchfactor_add, lcount;

        seglength        = 24;
        drifts           = 0.1;
        drifte           = 0.25;
        branchfactor     = 0;
        branchfactor_add = 0;
        lcount           = cvar("cl_effects_lightningarc_count");
        
        for(; lcount; --lcount)
            LightingArc_Full(from, to, seglength, drifts, drifte, branchfactor, branchfactor_add, ateam);
    }

    pointparticles(particleeffectnum("electro_muzzleflash"), from, normalize(to - from) * 1000, 1);
}
