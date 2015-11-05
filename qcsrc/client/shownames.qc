// plr.isactive = player is in range and coordinates/status (health and armor) are up to date
// plr.origin = player origin TODO: should maybe move this so it's the origin of the shownames tag already in SSQC for culling?
// plr.healthvalue
// plr.armorvalue
// plr.sameteam = player is on same team as local client
//

float Shownames_PreDrawPlayer(entity plr) {
    if(!rm_shownames)
        return FALSE;

    if(rm_shownames_teamonly && !plr.sameteam)
        return FALSE;

    if(plr.iorigin == '0 0 0')
        plr.iorigin = plr.origin;
    else
        plr.iorigin = plr.iorigin + (plr.origin - plr.iorigin) * frametime * 15;
    
    if(self.sn_culled) { // fade out
        plr.alpha = max(0, plr.alpha - 4 * frametime);
        if(!plr.alpha)
            return FALSE;
    } else if(!plr.sameteam) {
        makevectors(view_angles);
        if(WarpZone_FindLineOfSight(v_forward, view_origin, plr.iorigin, MOVE_NOMONSTERS, world) == '0 0 0') { // fade out
            plr.alpha = max(0, plr.alpha - 4 * frametime);
            if(!plr.alpha)
                return FALSE;
        } else // fade in
            plr.alpha = min(1, plr.alpha + 4 * frametime);
    } else // fade in
        plr.alpha = min(1, plr.alpha + 4 * frametime);

    return TRUE;
}

void Shownames_DrawPlayer(entity plr) {
    float oldfont = drawfont;
    float dist = vlen(plr.iorigin - view_origin);
    float a = SHOWNAMES_ALPHA;

    if(plr.alpha)
        a *= plr.alpha;

    //if(dist >= SHOWNAMES_MAXDISTANCE)
        //return;

    a *= ((SHOWNAMES_MAXDISTANCE - SHOWNAMES_MINDISTANCE) - max(0, dist - SHOWNAMES_MINDISTANCE)) / (SHOWNAMES_MAXDISTANCE - SHOWNAMES_MINDISTANCE);

    vector o;
    o = project_3d_to_2d(plr.iorigin + SHOWNAMES_ORIGIN_OFFSET);

    if(o_z < 0 || o_x < 0 || o_y < 0 || o_x > vid_conwidth || o_y > vid_conheight)
        return;

    o_z = 0;

    vector myPos, mySize;
    mySize = (eX * SHOWNAMES_ASPECT + eY) * SHOWNAMES_HEIGHT;
    myPos = o - '0.5 0 0' * mySize_x - '0 1 0' * mySize_y;

    vector namepos; // this is where the origin of the string
    float namesize; // total area where we can draw the string

    namepos = myPos + eY * 0.5 * (SHOWNAMES_HEIGHT - SHOWNAMES_FONTSIZE);
    namesize = mySize_x;

    string s, s2;
    s = GetPlayerName(plr.sv_entnum);
    vector textsz = [SHOWNAMES_FONTSIZE, SHOWNAMES_FONTSIZE];

    if(teamplay) {
        s = strdecolorize(s);
        s = textShortenToWidth_svn(s, namesize, textsz, stringwidth_nocolors_svn);
    } else s = textShortenToWidth_svn(s, namesize, textsz, stringwidth_colors_svn);

    float width = stringwidth_svn(s, TRUE, textsz);

    if(width != namesize)
        namepos_x += (namesize - width) / 2;
    
    vector nds;
    if(g_nadgets)
        nds = HG_DecompressDualType(playerslots[plr.sv_entnum].(scores[SP_NADEMODE]));
    
    if(plr.sameteam) {
        drawfont = GetBigfont();

        vector hScale;

        string txtHealth, txtArmor;
        float szHealth, szArmor;
        vector posCenter, posHealth, posArmor;
        float fade = 0.7;

        float frozen = (plr.sn_forcefrozen || playerslots[plr.sv_entnum].(scores[SP_FLAGS]) & SPFLAG_FROZEN);

        if(frozen) {
            hScale = textsz * 2;
        } else if(getstati(STAT_BUFFS) & BUFF_MEDIC) {
            vector dmg = healtharmor_maxdamage(plr.healthvalue, plr.armorvalue, armorblockpercent);
            float u = 1 - bound(0, dmg_x / sv_nicehealth, 1);
            hScale = textsz * (1.5 + 3 * u);
            fade = fade + (1 - fade) * u;
        } else {
            hScale = textsz * 1.5;
        }

        posCenter = namepos - '0 1 0' * hScale_y + '0.5 0 0' * width;

        if(frozen) {
            s2 = "Frozen!";
            drawstring(posCenter - '0.5 0 0' * stringwidth_svn(s2, TRUE, hScale), s2, hScale, '0.2 1 1', a * fade, DRAWFLAG_NORMAL);
            playerslots[plr.sv_entnum].sn_lastdraw = time;
        } else if(plr.healthvalue) {
            txtHealth = ftos(plr.healthvalue);
            szHealth = stringwidth_svn(txtHealth, TRUE, hScale);

            if(plr.armorvalue) {
                txtArmor  = ftos(plr.armorvalue);
                szArmor   = stringwidth_svn(txtArmor, TRUE, hScale);
                posArmor  = posCenter + '2 0 0';
                posHealth = posCenter - '1 0 0' * (szHealth + 2 + hScale_x);
            } else {
                posHealth = posCenter - '0.5 0 0' * (szHealth + hScale_x);
            }

            drawpic(posHealth, "gfx/hud/sb_health", hScale, '1 1 1', a * 0.7, DRAWFLAG_NORMAL);
            drawstring(posHealth + '1 0 0' * hScale_x, txtHealth, hScale, healthcolor(plr.healthvalue) * fade, a * fade, DRAWFLAG_NORMAL);

            if(plr.armorvalue) {
                drawpic(posArmor,  "gfx/hud/sb_armor",  hScale, '1 1 1', a * 0.7, DRAWFLAG_NORMAL);
                drawstring(posArmor  + '1 0 0' * hScale_x, txtArmor,  hScale, healthcolor(plr.armorvalue) * fade, a * fade, DRAWFLAG_NORMAL);
            }
        }

        drawfont = sbar_font;
    }
    
    if(nds) {
        float icons = textsz_x * (1 + g_nadgets_double);

        drawpic(namepos - '0.5 0 0' * icons - '2 0 0', HG_TypeToIcon(nds_x, FALSE, FALSE), textsz, HG_TypeToColor(nds_x), a * 0.7, DRAWFLAG_NORMAL);

        if(g_nadgets_double) {
            drawpic(namepos - '2 0 0', HG_TypeToIcon(nds_y, FALSE, FALSE), textsz, HG_TypeToColor(nds_y), a * 0.7, DRAWFLAG_NORMAL);
        }

        namepos = '0.5 0 0' * icons + '2 0 0' + namepos;
    }
    
    if(teamplay)
        drawstring(namepos, s, textsz, GetTeamRGB(GetPlayerColorForce(plr.sv_entnum)) + '0.2 0.2 0.2', a, DRAWFLAG_NORMAL);
    else
        drawcolorcodedstring(namepos, s, textsz, a, DRAWFLAG_NORMAL);
    
    drawfont = oldfont;
}

void Shownames_Init(entity plr) {
    plr.draw2d_origin_fld = iorigin;
    plr.draw2d_real = inline void(void) { Shownames_DrawPlayer(self); };
    plr.draw2d_pre = inline float(void) { return Shownames_PreDrawPlayer(self); };
    plr.draw2d = Draw2d_ThroughWarpZones;
}
