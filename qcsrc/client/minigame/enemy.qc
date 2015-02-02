
void MG_Enemy_Kill(entity e) {
    entity o = self;
    self = e;
    self.mg_enemy_think(MG_ENEMY_DEATH);
    self = o;

    e.mg_enemy_health = 0;
    MG_Remove(e);
}

void MG_Enemy_Damage(entity targ, entity attacker, entity inflictor, float damage) {
    if(targ.mg_enemy_health <= 0)
        return;

    targ.mg_enemy_health -= damage;
    
    print(ftos(targ.mg_enemy_health), "\n");

    if(targ.mg_enemy_health <= 0)
        MG_Enemy_Kill(targ);
}

void MG_Enemy_Think(void) {
    float t = mg_time - self.mg_spawntime;

    if(self.mg_move)
        self.origin = self.mg_move(self.origin, mg_time - self.mg_move_starttime, mg_frametime);

    if(self.mg_enemy_nextthink >= 0 && t >= self.mg_enemy_nextthink) {
        self.mg_enemy_nextthink = -self.mg_enemy_nextthink;
        self.mg_enemy_think(t);
    }

    entity p;

    FOR_EACH_MG_ENT(p) if(p.mg_class == MG_ENT_PROJECTILE && p.owner.mg_class == MG_ENT_PLAYER) {
        if(MG_CheckCollision(self, p)) {
            MG_Enemy_Damage(self, p.owner, p, MG_Projectile_CalculateDamage(p, self));
            MG_Projectile_Explode(p);
        }
    }

    self.mg_nextthink = mg_time;
}

entity MG_Enemy_Spawn(vector org, float sz, float hp, mg_enemy_thinkfunc_t thinkfunc, mg_movefunc_t movefunc) {
    entity e = MG_Spawn(MG_ENT_ENEMY);
    e.origin = org;
    e.mg_enemy_health = hp;

    e.mg_draw = MG_Draw_Box;
    e.mg_radius = e.mg_boxsize = sz;
    e.mg_boxcolor = '1 1 0';

    e.mg_think = MG_Enemy_Think;
    e.mg_nextthink = mg_time;

    e.mg_enemy_think = thinkfunc;
    e.mg_enemy_nextthink = -1;

    MG_Move_Set(e, movefunc);
    
    entity o = self;
    self = e;
    self.mg_enemy_think(MG_ENEMY_SPAWN);
    self = o;

    return e;
}
