
#define MG_FAMILIAR_DISTANCE 100

.vector mg_fam_dir;
.vector mg_fam_target;
.vector mg_fam_oldplrpos;
.float mg_fam_refire;

void MG_Familiar_Think(void) {
    vector o = vec2(sin(mg_time * 2), cos(mg_time * 2)) * 10;

    self.mg_fam_target = self.owner.origin + o + normalize(self.mg_fam_dir) * MG_FAMILIAR_DISTANCE;
    self.origin = self.origin + (self.mg_fam_target - self.origin) * mg_frametime * 3;

    if(!(mg_keyflags & MG_KEYFLAG_FOCUS)) {
        vector delta = self.mg_fam_oldplrpos - self.owner.origin;

        if(delta != '0 0 0') {
            self.mg_fam_oldplrpos = self.owner.origin;
            delta = normalize(delta);
            self.mg_fam_dir = self.mg_fam_dir + (delta - self.mg_fam_dir) * mg_frametime * 2;
            print(vtos(self.mg_fam_dir), "\n");
        }
    }

    if(mg_keyflags & MG_KEYFLAG_FIRE && mg_time > self.mg_fam_refire) {
        entity e = MG_Projectile_Spawn(self, self.origin, 8, 10, MG_Move_Linear);
        e.velocity = normalize(self.mg_fam_dir) * 1000;
        self.mg_fam_refire = mg_time + 0.1;
    }

    self.mg_nextthink = mg_time;
}

entity MG_Familiar_Spawn(entity plr) {
    entity e = MG_Spawn(MG_ENT_PLAYER);

    e.owner = plr;
    e.mg_draw = MG_Draw_Box;
    e.mg_radius = 0;
    e.mg_boxsize = 8;
    e.mg_boxcolor = '0.0 0.7 0.7';

    e.mg_think = MG_Familiar_Think;
    e.mg_nextthink = mg_time;

    e.mg_fam_dir = '0 1';
    e.origin = plr.origin;

    return e;
}
