
void MG_Projectile_Explode(entity p) {
    MG_Remove(p);
}

vector MG_Projectile_BoundaryCollision(vector o, vector n) {
    self.origin = n;
    MG_Projectile_Explode(self);
    return n;
}

void MG_Projectile_Think(void) {
    if(self.mg_move)
        self.origin = self.mg_move(self.origin, mg_time - self.mg_move_starttime, mg_frametime);

    MG_ClampOrigin(self.origin, self.mg_radius, MG_Projectile_BoundaryCollision);

    self.mg_nextthink = mg_time;
}

float MG_Projectile_CalculateDamage(entity p, entity o) {
    return p.mg_proj_damage;
}

entity MG_Projectile_Spawn(entity own, vector org, float sz, float damage, mg_movefunc_t movefunc) {
    entity e = MG_Spawn(MG_ENT_PROJECTILE);
    e.owner = own;
    e.origin = org;

    e.mg_draw = MG_Draw_Box;
    e.mg_radius = e.mg_boxsize = sz;
    e.mg_boxcolor = '1 0 0';

    e.mg_think = MG_Projectile_Think;
    e.mg_nextthink = mg_time;
    e.mg_proj_damage = damage;

    MG_Move_Set(e, movefunc);

    return e;
}
