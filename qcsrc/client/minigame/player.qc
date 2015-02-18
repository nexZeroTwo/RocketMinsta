
.float mg_plr_refire;
.float mg_plr_refire2;
.float mg_plr_focusalpha;
.float mg_plr_spawnshield;

void MG_Player_Reset(void) {
    self.origin = '0.5 0 0' * MG_WORLD_X + '0 0.5 0' * MG_WORLD_Y;
    self.mg_plr_refire = 0;
    self.mg_plr_refire2 = 0;
    self.mg_plr_focusalpha = 0;
    self.mg_plr_spawnshield = mg_time + 1;
}

void MG_Player_Die(void) {
    print("boom!\n");
    MG_Player_Reset();
}

void MG_Player_Proj2_Trail_Draw(void) {
    float a = 1 - bound(0, (mg_time - self.mg_spawntime) * 13, 1);

    if(!a) {
        MG_Remove(self);
        return;
    }

    MG_Draw_Picture_Centered(self.origin, MG_Draw_Animation_GetFrame("gfx/minigame/energy_idle", self.frame, 8, 0, 25), '48 48' * a, mg_time, '0.5 0.5', '1 1 1', 0.3 * a, DRAWFLAG_NORMAL);
}

void MG_Player_Proj2_Think(void) {
    if(mg_time > self.cnt) {
        entity e = MG_Spawn(MG_ENT_PARTICLE);
        e.mg_draw = MG_Player_Proj2_Trail_Draw;
        e.frame = mg_time;
        e.origin = self.origin;

        self.cnt = mg_time + 0.01;
    }

    MG_Projectile_Think();
}

void MG_Player_Proj2_Blast_Draw(void) {
    float a = 1 - bound(0, (mg_time - self.mg_spawntime) * 10, 1);

    if(!a) {
        MG_Remove(self);
        return;
    }

    MG_Draw_Picture_Centered(self.origin, MG_Draw_Animation_GetFrame("gfx/minigame/energy_idle", self.frame, 8, 0, 25), '48 48' * (4 - 4 * a), mg_time, '0.5 0.5', '1 1 1', 0.3 * a, DRAWFLAG_NORMAL);
}

void MG_Player_Proj2_Explode(void) {
    entity e = MG_Spawn(MG_ENT_PARTICLE);
    e.mg_draw = MG_Player_Proj2_Blast_Draw;
    e.frame = mg_time;
    e.origin = self.origin;
}

void MG_Player_Proj2_Draw(void) {
    MG_Draw_Animation_Centered(self.origin, "gfx/minigame/energy_idle", '48 48', mg_time, '0.5 0.5', '1 1 1', 0.5, DRAWFLAG_NORMAL, 8, 0, 25);
}

void MG_Player_Think(void) {
    vector dir;

    // Think every frame.

    self.mg_nextthink = mg_time;

    // Move according to user input.

    float up = (mg_keyflags & MG_KEYFLAG_UP);
    float dn = (mg_keyflags & MG_KEYFLAG_DOWN);
    float lt = (mg_keyflags & MG_KEYFLAG_LEFT);
    float rt = (mg_keyflags & MG_KEYFLAG_RIGHT);

    float spd;

    vector o0, o1, deltao;

    if(mg_keyflags & MG_KEYFLAG_FOCUS)
        spd = 250;
    else
        spd = 800;

    if(up && !dn)
        dir_y = -1;
    else if(dn && !up)
        dir_y = +1;

    if(lt && !rt)
        dir_x = -1;
    else if(rt && !lt)
        dir_x = +1;

    self.origin = MG_ClampOrigin(self.origin + normalize(dir) * mg_frametime * spd, self.mg_boxsize, MG_ClampOrigin_Pass);

    // Die if touching an enemy projectile.

    entity e;

    FOR_EACH_MG_ENT(e) {
        if((e.mg_class == MG_ENT_PROJECTILE || e.mg_class == MG_ENT_ENEMY) && e.owner.mg_class != MG_ENT_PLAYER && MG_CheckCollision(self, e)) {
            if(self.mg_plr_spawnshield > mg_time) {
                if(e.mg_class == MG_ENT_PROJECTILE)
                    MG_Projectile_Explode(e);
            } else {
                MG_Player_Die();
                return;
            }
        }
    }

    // Smooth focus/unfocus transitions.

    self.mg_plr_focusalpha = approach(self.mg_plr_focusalpha, !!(mg_keyflags & MG_KEYFLAG_FOCUS), mg_frametime * 7);

    // Pew pew pew!

    if(mg_keyflags & MG_KEYFLAG_FIRE) {
        vector shotorg = self.origin - '0 40';
        float s = 2000;

        if(mg_time > self.mg_plr_refire) {
            e = MG_Projectile_Spawn(self, shotorg, 8, 10, MG_Move_Linear);
            e.velocity = normalize('0 -10 0' + '0.5 0 0' * cos(mg_time * 10)) * s;
            self.mg_plr_refire = mg_time + 0.1;
        }

        if(mg_time > self.mg_plr_refire2) {

            float a1 = self.mg_plr_focusalpha;
            float a2 = (1 - self.mg_plr_focusalpha);

            e = MG_Projectile_Spawn(self, shotorg, 8, 15, MG_Move_Morph);
            e.mg_move_morph_vel0 = ('-1 -0.5 0'  * a1 + '-0.5 -1 0' * a2);
            e.mg_move_morph_vel1 = (' 1 -0.5 0') * a1 + e.mg_move_morph_vel0 * a2;
            e.mg_move_morph_vel0 = normalize(e.mg_move_morph_vel0) * s;
            e.mg_move_morph_vel1 = normalize(e.mg_move_morph_vel1) * s;
            e.mg_move_morph_speed = 1.5;
            e.mg_move_morph_modifier = ipol_pow2Out;
            e.mg_draw = MG_Player_Proj2_Draw;
            e.mg_think = MG_Player_Proj2_Think;
            e.mg_proj_explode = MG_Player_Proj2_Explode;

            e = MG_Projectile_Spawn(self, shotorg, 8, 15, MG_Move_Morph);
            e.mg_move_morph_vel0 = (' 1 -0.5 0'  * a1 + ' 0.5 -1 0' * a2);
            e.mg_move_morph_vel1 = ('-1 -0.5 0') * a1 + e.mg_move_morph_vel0 * a2;
            e.mg_move_morph_vel0 = normalize(e.mg_move_morph_vel0) * s;
            e.mg_move_morph_vel1 = normalize(e.mg_move_morph_vel1) * s;
            e.mg_move_morph_speed = 1.5;
            e.mg_move_morph_modifier = ipol_pow2Out;
            e.mg_draw = MG_Player_Proj2_Draw;
            e.mg_think = MG_Player_Proj2_Think;
            e.mg_proj_explode = MG_Player_Proj2_Explode;

            self.mg_plr_refire2 = mg_time + 0.2;
        }
    }
}

void MG_Player_Draw(void) {
    MG_Draw_Animation_Centered(self.origin, "gfx/minigame/pepper_idle", '120 120', 0, '0.5 0.5', '1 1 1', 1, DRAWFLAG_NORMAL, 8, 0, 10);
}

entity MG_Player_Spawn(void) {
    entity p = MG_Spawn(MG_ENT_PLAYER);
    p.mg_draw = MG_Player_Draw;
    p.mg_radius = p.mg_boxsize = 8;
    p.mg_boxcolor = '1 0.5 0.3';

    p.mg_think = MG_Player_Think;
    p.mg_nextthink = mg_time;
    p.mg_plr_spawnshield = mg_time + 1;

    p.origin = '0.5 0 0' * MG_WORLD_X + '0 0.5 0' * MG_WORLD_Y;
    MG_Familiar_Spawn(p);

    return p;
}
