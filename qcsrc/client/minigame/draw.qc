
vector mg_draw_tf_offset;
float mg_draw_ft_scale;

/*
 * MG_Draw_TransformOrigin
 *
 * Transforms an absolute vector v from world coordinates to screen coordinates.
 */

vector MG_Draw_TransformOrigin(vector v) {
    return v * mg_draw_ft_scale + mg_draw_tf_offset;
}

/*
 * MG_Draw_TransformDelta
 *
 * Transforms a relative vector v from world coordinates to screen coordinates.
 */

vector MG_Draw_TransformDelta(vector v) {
    return v * mg_draw_ft_scale;
}

/*
 * MG_DrawEnts
 *
 * Draws all Minigame-managed entities of a specific class.
 */

void MG_DrawEnts(float t) {
    FOR_EACH_MG_ENT(self) {
        if(self.mg_draw && self.mg_class == t) {
            self.mg_draw();

            if(self.mg_draw != MG_Draw_Box && self.mg_boxsize && cvar("developer"))
                MG_Draw_Box();
        }
    }
}

/*
 * MG_Draw
 *
 * Called by CSQC_UpdateView every frame.
 * Draws the bounding box and all Minigame-managed entities
 * that have an mg_draw function.
 */

void MG_Draw(void) {
    if(!mg_enabled)
        return;

    float aspect = MG_WORLD_X / MG_WORLD_Y;
    float sc = min(vid_conwidth / MG_WORLD_X, vid_conheight / MG_WORLD_Y);

    vector s = 0.85 * ('1 0 0' * MG_WORLD_X * sc + '0 1 0' * MG_WORLD_Y * sc);
    vector o = '0.5 0 0' * (vid_conwidth - s_x) + '0 0.5 0' * (vid_conheight - s_y);

    drawfill('0 0 0', '1 0 0' * vid_conwidth + '0 1 0' * vid_conheight, '0 0 0', 0.7, DRAWFLAG_NORMAL);
    drawborderlines(2, o, s, '0 0 0', 1, DRAWFLAG_NORMAL);
    drawfill(o, s, '0.35 0.35 0.35', 1, DRAWFLAG_NORMAL);

    mg_draw_tf_offset = o;
    mg_draw_ft_scale = max(s_x / MG_WORLD_X, s_y / MG_WORLD_Y);

    //drawfill(MG_Draw_TransformOrigin(vec2(MG_WORLD_X/2, MG_WORLD_Y/2)), MG_Draw_TransformDelta(vec2(MG_WORLD_X/2, MG_WORLD_Y/2)), '1 0 0', 1, DRAWFLAG_NORMAL);

    entity e, oldself = self;

    // TODO: optimize this. Maybe just spawn them in the correct order?

    float clip = !cvar("developer");

    if(clip)
        drawsetcliparea(o_x, o_y, s_x, s_y);

    MG_DrawEnts(MG_ENT_NOCLASS);
    MG_DrawEnts(MG_ENT_PARTICLE);
    MG_DrawEnts(MG_ENT_PLAYER);
    MG_DrawEnts(MG_ENT_PROJECTILE);
    MG_DrawEnts(MG_ENT_ENEMY);

    if(clip)
        drawresetcliparea();

    self = oldself;
}

/*
 * MG_Draw_Box
 *
 * A placeholder/debug draw function.
 * This will draw a square with an edge size of mg_boxsize, filled with mg_boxcolor
 */
 
void MG_Draw_Box(void) {
    float sz = self.mg_boxsize * 2;

    vector o = MG_Draw_TransformOrigin(self.origin - '0.5 0 0' * sz - '0 0.5 0' * sz);
    vector s = MG_Draw_TransformDelta(vec2(sz, sz));

    drawfill(o, s, self.mg_boxcolor, 1, DRAWFLAG_NORMAL);
}

void MG_Draw_Picture_Raw(vector pos, string pic, vector psize, float rotation, vector hotspot, vector rgb, float palpha, float drawflag) {
    if(cvar("developer"))
        drawfill(pos, psize, '0 1 1', 0.3, DRAWFLAG_ADDITIVE);

    if(rotation) {
        hotspot_x *= psize_x;
        hotspot_y *= psize_y;
        drawrotpic(pos + hotspot, rotation, pic, psize, hotspot, rgb, palpha, drawflag);
    } else
        drawpic(pos, pic, psize, rgb, palpha, drawflag);
}

void MG_Draw_Picture(vector pos, string pic, vector psize, float rotation, vector hotspot, vector rgb, float palpha, float drawflag) {
    psize = MG_Draw_TransformDelta(psize);
    pos = MG_Draw_TransformOrigin(pos);

    MG_Draw_Picture_Raw(pos, pic, psize, rotation, hotspot, rgb, palpha, drawflag);
}

void MG_Draw_Picture_Centered(vector pos, string pic, vector psize, float rotation, vector hotspot, vector rgb, float palpha, float drawflag) {
    psize = MG_Draw_TransformDelta(psize);
    pos = MG_Draw_TransformOrigin(pos) - psize * 0.5;

    MG_Draw_Picture_Raw(pos, pic, psize, rotation, hotspot, rgb, palpha, drawflag);
}
