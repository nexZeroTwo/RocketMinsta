// self.isactive = player is in range and coordinates/status (health and armor) are up to date
// self.origin = player origin TODO: should maybe move this so it's the origin of the shownames tag already in SSQC for culling?
// self.healthvalue
// self.armorvalue
// self.sameteam = player is on same team as local client
//

.float health_v;

void Draw_ShowNames()
{
    if(!autocvar_hud_shownames)
        return;

    float oldfont;
    oldfont = drawfont;
    
    if(self.sameteam || (!self.sameteam && !rm_shownames_teamonly))
    {
        //InterpolateOrigin_Do();
        
        if(self.iorigin == '0 0 0')
            self.iorigin = self.origin;
        else
            self.iorigin = self.iorigin + (self.origin - self.iorigin) * frametime * 15;
        

        if(!self.sameteam)
        {
            traceline(self.iorigin, view_origin, 1, self);
            if(trace_endpos != view_origin) // fade out
            {
                self.alpha = max(0, self.alpha - 4 * frametime);
                if(!self.alpha)
                    return;
            }
            else // fade in
                self.alpha = min(1, self.alpha + 4 * frametime);


            /* WIP, why does trace_ent != self not work as intended here?
            if(autocvar_hud_shownames_enemies != 2) // player has to point at enemy if so
            {
                traceline(view_origin, view_origin + view_forward * MAX_SHOT_DISTANCE, MOVETYPE_FLY, world);
                print("trace_endpos: ", vtos(trace_endpos), " view_origin: ", vtos(view_origin), "\n");
                if(trace_ent != self)
                    return;
            }*/
        }

        // otherwise, increase alpha until 1

        float dist;
        dist = vlen(self.iorigin - view_origin);

        float a;
        a = autocvar_hud_shownames_alpha;
        if(self.alpha)
            a *= self.alpha;
        //if(autocvar_hud_shownames_maxdistance)
        {
            if(dist >= autocvar_hud_shownames_maxdistance)
                return;
            a *= ((autocvar_hud_shownames_maxdistance - autocvar_hud_shownames_mindistance) - max(0, dist - autocvar_hud_shownames_mindistance)) / (autocvar_hud_shownames_maxdistance - autocvar_hud_shownames_mindistance);
        }

        float resize;
        resize = 1;
        //if(autocvar_hud_shownames_resize) // limit resize so its never smaller than 0.5... gets unreadable
        //    resize = 0.5 + 0.5 * ((autocvar_hud_shownames_maxdistance - autocvar_hud_shownames_mindistance) - max(0, dist - autocvar_hud_shownames_mindistance)) / (autocvar_hud_shownames_maxdistance - autocvar_hud_shownames_mindistance);

        // draw the sprite image
        vector o;
        o = project_3d_to_2d(self.iorigin);

        if not(o_z < 0 || o_x < 0 || o_y < 0 || o_x > vid_conwidth || o_y > vid_conheight)
        {
            o_z = 0;

            vector myPos, mySize;
            mySize = (eX * autocvar_hud_shownames_aspect + eY) * autocvar_hud_shownames_height;
            myPos = o - '0.5 0 0' * mySize_x - '0 1 0' * mySize_y;

            // size scaling
            mySize_x *= resize;
            mySize_y *= resize;

            myPos_x += 0.5 * (mySize_x / resize - mySize_x);
            myPos_y += (mySize_y / resize - mySize_y);

            vector namepos; // this is where the origin of the string
            float namesize; // total area where we can draw the string

            namepos = myPos + eY * 0.5 * resize * (autocvar_hud_shownames_height - autocvar_hud_shownames_fontsize);
            namesize = mySize_x;

            string s, s2;
            s = GetPlayerName(self.the_entnum-1);
            vector textsz = '1 1 0' * autocvar_hud_shownames_fontsize * resize;

            if(teamplay) {
                s = strdecolorize(s);
                s = textShortenToWidth_svn(s, namesize, textsz, stringwidth_nocolors_svn);
            } else s = textShortenToWidth_svn(s, namesize, textsz, stringwidth_colors_svn);

            float width;
            width = stringwidth_svn(s, TRUE, textsz);

            if (width != namesize)
                namepos_x += (namesize - width) / 2;
            
            float nade;
            if(g_nadgets)
                nade = playerslots[self.the_entnum-1].(scores[SP_NADEMODE]);
            
            if(self.sameteam) {
                drawfont = GetBigfont();

                vector hScale;

                string txtHealth, txtArmor;
                float szHealth, szArmor;
                vector posCenter, posHealth, posArmor;
                float fade = 0.7;

                float frozen = (self.sn_forcefrozen || playerslots[self.the_entnum-1].(scores[SP_FLAGS]) & SPFLAG_FROZEN);

                if(frozen) {
                    hScale = textsz * 2;
                } else if(getstati(STAT_BUFFS) & BUFF_MEDIC) {
                    vector dmg = healtharmor_maxdamage(self.healthvalue, self.armorvalue, armorblockpercent);
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
                    playerslots[self.the_entnum-1].sn_lastdraw = time;
                } else if(self.healthvalue) {
                    txtHealth = ftos(self.healthvalue);
                    szHealth = stringwidth_svn(txtHealth, TRUE, hScale);

                    if(self.armorvalue) {
                        txtArmor  = ftos(self.armorvalue);
                        szArmor   = stringwidth_svn(txtArmor, TRUE, hScale);
                        posArmor  = posCenter + '2 0 0';
                        posHealth = posCenter - '1 0 0' * (szHealth + 2 + hScale_x);
                    } else {
                        posHealth = posCenter - '0.5 0 0' * (szHealth + hScale_x);
                    }

                    drawpic(posHealth, "gfx/hud/sb_health", hScale, '1 1 1', a * 0.7, DRAWFLAG_NORMAL);
                    drawstring(posHealth + '1 0 0' * hScale_x, txtHealth, hScale, healthcolor(self.healthvalue) * fade, a * fade, DRAWFLAG_NORMAL);

                    if(self.armorvalue) {
                        drawpic(posArmor,  "gfx/hud/sb_armor",  hScale, '1 1 1', a * 0.7, DRAWFLAG_NORMAL);
                        drawstring(posArmor  + '1 0 0' * hScale_x, txtArmor,  hScale, healthcolor(self.armorvalue) * fade, a * fade, DRAWFLAG_NORMAL);
                    }
                }

                drawfont = sbar_font;
            }            
            
            if(nade) {
                drawpic(namepos - '0.5 0 0' * textsz_x - '2 0 0', HG_TypeToIcon(nade, FALSE, FALSE), textsz, HG_TypeToColor(nade), a * 0.7, DRAWFLAG_NORMAL);
                namepos = '0.5 0 0' * textsz_x + '2 0 0' + namepos;
            }
            
            if(teamplay)
                drawstring(namepos, s, textsz, GetTeamRGB(GetPlayerColorForce(self.the_entnum - 1)) + '0.2 0.2 0.2', a, DRAWFLAG_NORMAL);
            else
                drawcolorcodedstring(namepos, s, textsz, a, DRAWFLAG_NORMAL);
            
            drawfont = oldfont;
        }
    }
}
