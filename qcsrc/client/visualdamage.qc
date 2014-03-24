
.float vd_damage;
.float vd_armordamage;
.float vd_type;
.float vd_flag;
.vector vd_projected;
.string vd_str;
.float vd_width;
.float vd_fullwidth;
.float vd_culled;

entity vd_head;
entity vd_tail;
.entity  vd_next;
float vd_cnt;

float rm_visualdamage_fontsize;

#define VDMG_FONTSIZE rm_visualdamage_fontsize
#define VDMG_ALPHAOFFSET '0 -50 0'
#define VDMG_ALPHA 0.8

void VisualDamage_FixPositions(void) {
    entity e, p;
    
    for(e = vd_head; e; e = e.vd_next) if(!e.vd_culled) {
        for(p = e.vd_next; p; p = p.vd_next) if(!p.vd_culled) {
            float dst = p.vd_projected_y - e.vd_projected_y;
            if(dst > -VDMG_FONTSIZE && dst < VDMG_FONTSIZE) {
                float x1 = e.vd_projected_x - 0.5 * e.vd_fullwidth;
                float o1 = x1 + e.vd_fullwidth;
                float x2 = p.vd_projected_x - 0.5 * p.vd_fullwidth;
                float o2 = x2 + p.vd_fullwidth;
                
                if((x1 >= x2 && x1 <= o2) || (x2 >= x1 && x2 <= o1)) {
                    p.vd_projected_y = e.vd_projected_y - VDMG_FONTSIZE - 1;
                }
            }
        }
    }
}

void VisualDamage_PreDraw(void) {
    entity e;
    string s;
    vector o;
    
    drawfont = sbar_bigfont;
    rm_visualdamage_fontsize = cvar("rm_visualdamage_fontsize");
    for(e = vd_head; e; e = e.vd_next) {
        o = e.vd_projected = project_3d_to_2d(e.origin);
        if(o_z < 0 || o_x < 0 || o_y < 0 || o_x > vid_conwidth || o_y > vid_conheight) {
            e.vd_culled = TRUE;
            continue;
        }
        
        if(!e.vd_damage && !e.vd_armordamage)
            s = "Immune";
        else {
            s = ftos(e.vd_damage);
            if(e.vd_armordamage)
                s = strcat(s, " [", ftos(e.vd_armordamage), "]");
        }
        
        e.vd_str = s;
        e.vd_width = stringwidth(s, FALSE);
        e.vd_fullwidth = e.vd_width * VDMG_FONTSIZE;
        e.vd_culled = FALSE;
    }
    
    VisualDamage_FixPositions();
    drawfont = sbar_font;
}

void VisualDamage_Draw(void) {
    float a = ipol_swingInOut(self.alpha), sw;
    vector o, oldo, clr;
    vector offs = VDMG_ALPHAOFFSET * (1 - self.alpha);
    float fs = VDMG_FONTSIZE * max(1, a * ((self.vd_type & VDMG_TYPE_CRIT)? 2 : 1));
    
    o = self.vd_projected + offs - '0 0.5 0' * fs;
    
    if not(self.vd_culled) {
        o_z = 0;
        drawfont = sbar_bigfont;
        sw = self.vd_width * fs;
        
        if(self.vd_type & VDMG_TYPE_HEAL)
            clr = '0.0 1.0 0.0';
        else if(self.vd_type & VDMG_TYPE_TEAMHIT)
            clr = '1.0 0.0 0.0';
        else if(self.vd_type & VDMG_TYPE_CRIT)
            clr = '1.0 0.3 0.0';
        else
            clr = '1.0 0.7 0.0';
        
        drawstring(o - sw * '0.5 0 0', self.vd_str, fs * '1 1 0', clr, VDMG_ALPHA * a, DRAWFLAG_NORMAL);
        drawfont = sbar_font;
    }
    
    self.alpha = approach(self.alpha, 0, frametime);
    
    if(self.alpha <= 0 && !wasfreed(self)) {
        if(self == vd_head) {
            vd_head = vd_tail = vd_head.vd_next;
        } else {
            entity e; for(e = vd_head; e; e = e.vd_next)
                if(e.vd_next == self) {
                    e.vd_next = self.vd_next;
                    if(self == vd_tail)
                        vd_tail = e;
                    break;
                }
        }
        --vd_cnt;
        remove(self);
    }
}

void VisualDamage_Spawn(float dmg, float admg, float type, vector org) {
    if(!rm_showdamage)
        return;
    
    entity p, e = spawn();
    e.vd_damage = dmg;
    e.vd_armordamage = admg;
    e.vd_type = type;
    e.alpha = 1;
    e.draw2d = VisualDamage_Draw;
    e.vd_flag = TRUE;
    setorigin(e, org);
    
    e.vd_next = vd_head;
    vd_head = e;
    
    if(!e.vd_next)
        vd_tail = e;
    
    ++vd_cnt;
    
    if(vd_cnt > cvar("rm_visualdamage_limit")) {
        entity oldtail = vd_tail;
        for(p = vd_head; p; p = p.vd_next) {
            if(p.vd_next == vd_tail) {
                p.vd_next = world;
                vd_tail = p;
            }
        }
        remove(oldtail);
        --vd_cnt;
    }
}

void Net_VisualDamage(void) {
    vector org;
    float dmg = ReadShort();
    float admg = ReadShort();
    float type = ReadByte();
    org_x = ReadCoord();
    org_y = ReadCoord();
    org_z = ReadCoord();
    VisualDamage_Spawn(dmg, admg, type, org);
}
