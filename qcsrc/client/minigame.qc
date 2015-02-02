
entity mg_main;
entity mg_plr;

float mg_enabled;
float mg_time;
float mg_frametime;
float mg_keyflags;

void MG_Draw_Box(void);

/*
 * MG_Think
 * 
 * The think function of the Minigame control entity.
 * Called every frame, sets mg_time and mg_frametime, 
 * runs think functions of Minigame entities.
 * 
 * Will try to keep mg_frametime close to MG_TARGET_FRAMETIME,
 * steps multiple times if necessary.
 */

void MG_Think(void) {
    if(!mg_enabled) {
        self.nextthink = time;
        return;
    }

    // If the framerate is too low to run at the intended accuracy, step multiple times.
    // (and it will be too low because we want like 1000 fps)

    float totaltime;

    while(totaltime < frametime) {
        entity oldself = self;

        mg_frametime = min3(MG_TARGET_FRAMETIME, frametime, frametime - totaltime);
        mg_time += mg_frametime;

        // print("STEP ", ftos(mg_frametime), "\n");

        entity e;

        FOR_EACH_MG_ENT(e) {
            //print("I SEE ", ftos(num_for_edict(e)), "\n");
            if(e.mg_think && e.mg_nextthink >= 0 && e.mg_nextthink <= mg_time) {
                self = e;
                self.mg_nextthink = -1;
                self.mg_think();
            }
        }

        totaltime += mg_frametime;
        self = oldself;
    }

    self.nextthink = time;
}

/*
 * MG_Spawn
 *
 * Spawns a Minigame-managed entity.
 * Do not change its classname.
 *
 * Returns: the new entity.
 */

entity MG_Spawn(float cls) {
    entity e = spawn();
    e.classname = "mg_ent";
    e.mg_spawntime = mg_time;
    e.mg_class = cls;

    if(!mg_ent_first)
        mg_ent_first = e;

    if(mg_ent_last) {
        e.mg_ent_prev = mg_ent_last;
        mg_ent_last.mg_ent_next = e;
    }

    mg_ent_last = e;

    return e;
}


/*
 * MG_Remove
 *
 * Removes a Minigame-managed entity.
 */

void MG_Remove_Do(void) {

    entity prev = self.mg_ent_prev;
    entity next = self.mg_ent_next;

    if(prev)
        prev.mg_ent_next = next;

    if(next)
        next.mg_ent_prev = prev;

    if(mg_ent_first == self)
        mg_ent_first = next;

    if(mg_ent_last == self)
        mg_ent_last = prev;

    remove(self);
}

void MG_Remove(entity e) {
    if(e.classname != "mg_ent")
        error("MG_Remove on non-mg_ent");

    e.mg_class = MG_ENT_REMOVED;
    e.classname = "mg_ent_removed";

    e.mg_think = SUB_Null;
    e.mg_nextthink = -1;

    e.think = MG_Remove_Do;
    e.nextthink = time;
}

/*
 * MG_ClampOrigin
 *
 * Clamps a square to the boundaries of the world.
 * Point o is the center, sz is the size of an edge.
 *
 * If o needs clamping, callback is invoked.
 * The first parameter is the original o, the second is the new clamped origin.
 * The result of the callback is returned.
 *
 * If callback is a null function (MG_ClampOrigin_Pass),
 * the clamped origin will be returned instead. 
 */

var vector(vector, vector) MG_ClampOrigin_Pass;

vector MG_ClampOrigin(vector o, float sz, vector(vector, vector) callback) {
    float clamped;

    vector p = o;
    sz = sz * 0.5;

    if(o_x < sz) {
        o_x = sz;
        clamped = TRUE;
    } else if(o_x > MG_WORLD_X - sz) {
        o_x = MG_WORLD_X - sz;
        clamped = TRUE;
    }

    if(o_y < sz) {
        o_y = sz;
        clamped = TRUE;
    } else if(o_y > MG_WORLD_Y - sz) {
        o_y = MG_WORLD_Y - sz;
        clamped = TRUE;
    }

    if(!clamped)
        return p;

    if(!callback)
        return o;

    return callback(p, o);
}

/*
 * MG_CheckCollision
 *
 * Returns TRUE if e1 and e2 collide or intersect with each other.
 * At this moment, this assumes both entities are circles.
 * THe radii are taken from the mg_radius field.
 *
 * This always returns FALSE if either of the radii are 0.
 */

float MG_CheckCollision(entity e1, entity e2) {
    float r1 = e1.mg_radius;
    float r2 = e2.mg_radius;

    if(!r1 || !r2)
        return FALSE;

    return vlen(e1.origin - e2.origin) < (r1 + r2);
}

/*
 * MG_Init
 *
 * Initializes the Minigame subsystem.
 * Spawns the control entity, starts running its think function,
 * spawns other Minigame entities, etc.
 */

void MG_TestEnemy1_Think(float t) {
    if(t == MG_ENEMY_SPAWN) {
        self.mg_enemy_nextthink = 0;
        return;
    } else if(t < 0)
        return;

    entity p = MG_Projectile_Spawn(self, self.origin, 8, 1, MG_Move_Linear);
    p.velocity = normalize(mg_plr.origin - self.origin + '200 0' * crandom() + '0 200' * crandom()) * 125;

    self.mg_enemy_nextthink = t + 0.1;
}

void MG_TestEnemy2_Think(float t) {
    if(t == MG_ENEMY_SPAWN) {
        self.mg_enemy_nextthink = 0;
        return;
    } else if(t < 0)
        return;

    entity p = MG_Projectile_Spawn(self, self.origin, 8, 1, MG_Move_Linear);
    p.velocity = self.movedir * 300;

    self.mg_enemy_nextthink = t + 0.1;
}

vector MG_TestEnemy1_Move(vector oldpos, float t, float dt) {
    return oldpos;
}

vector MG_TestEnemy2_Move(vector oldpos, float t, float dt) {
    return oldpos - '0 20 0' * dt;
}

void MG_SetupWorld(void) {
    mg_plr = MG_Player_Spawn();

    entity e;

    e = MG_Enemy_Spawn('0.5 0 0' * MG_WORLD_X + '0 0.3 0' * MG_WORLD_Y, 48, 2000, MG_TestEnemy1_Think, MG_TestEnemy1_Move);


    e = MG_Enemy_Spawn('30 0 0' + '0 1 0' * MG_WORLD_Y, 48, 500, MG_TestEnemy2_Think, MG_TestEnemy2_Move);
    e.movedir = '1 0 0';

    e = MG_Enemy_Spawn('1 0 0' * (MG_WORLD_X - 30) + '0 1 0' * MG_WORLD_Y, 48, 500, MG_TestEnemy2_Think, MG_TestEnemy2_Move);
    e.movedir = '-1 0 0';

}

void MG_Init(void) {
    if(mg_main)
        return;

    entity e = spawn();
    e.think = MG_Think;
    e.nextthink = time;

    mg_main = e;

    //defer(1, MG_SetupWorld);
    MG_SetupWorld();
}


/*
 * MG_Enable
 *
 * Activates the Minigame.
 * If the control entity wasn't spawned yet,
 * MG_Init() will be called automatically.
 */

void MG_Enable(void) {
    if(mg_enabled)
        return;

    mg_enabled = TRUE;

    if(!mg_main)
        MG_Init();

    //mg_main.nextthink = time;
}

/*
 * MG_Disable
 *
 * Suspends the Minigame. Can be resumed by calling MG_Enable().
 */

void MG_Disable(void) {
    mg_enabled = FALSE;
}

/*
 * MG_Input
 *
 * Called by CSQC_InputEvent.
 * Processes user input and updates mg_keyflags.
 */

float MG_Input(float type, float key, float ignore) {
    if(!mg_enabled || type == 2)
        return FALSE;

    // print("KEY: ", ftos(key), " ", ftos(type), "\n");

    float kflag = 0;

    switch(key) {
        case MG_KEY_UP:         kflag = MG_KEYFLAG_UP;        break;
        case MG_KEY_DOWN:       kflag = MG_KEYFLAG_DOWN;      break;
        case MG_KEY_LEFT:       kflag = MG_KEYFLAG_LEFT;      break;
        case MG_KEY_RIGHT:      kflag = MG_KEYFLAG_RIGHT;     break;
        case MG_KEY_FIRE:       kflag = MG_KEYFLAG_FIRE;      break;
        case MG_KEY_FOCUS:      kflag = MG_KEYFLAG_FOCUS;     break;

        default:
            return FALSE;
    }

    if(type == 0)
        mg_keyflags |= kflag;
    else if(type == 1)
        mg_keyflags &~= kflag;

    return TRUE;
}
