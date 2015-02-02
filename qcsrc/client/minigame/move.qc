
void MG_Move_Set(entity ent, mg_movefunc_t move) {
    ent.mg_move = move;
    ent.mg_move_starttime = mg_time;
}

vector MG_Move_Linear(vector oldpos, float t, float dt) {
    return oldpos + self.velocity * dt;
}

vector MG_Move_Morph(vector oldpos, float t, float dt) {
    float a = bound(0, t * self.mg_move_morph_speed, 1);

    if(self.mg_move_morph_modifier)
        a = self.mg_move_morph_modifier(a);
    
    return oldpos + dt * (self.mg_move_morph_vel0 * (1 - a) + self.mg_move_morph_vel1 * a);
}
