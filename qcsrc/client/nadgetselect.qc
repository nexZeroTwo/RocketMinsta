
#define NS_MAX_OPTIONS 16
#define NS_SCALE 24
#define NS_MARGIN 10

float ns_options[NS_MAX_OPTIONS*2];
float ns_selalpha[NS_MAX_OPTIONS*2];
float ns_numoptions;
float ns_active;
float ns_alpha;
float ns_width;
float ns_height;
float ns_selected;
float ns_selected_in;
float ns_confirmed1;
float ns_confirmed2;

void NS_UpdateSelection(vector o, vector s) {
    if(g_nadgets_double)
        ns_selected_in = (mv_mousepos_x > vid_conwidth * 0.5);
    else
        ns_selected_in = 0;

    ns_selected = floor(ns_numoptions * ((bound(o_y, mv_mousepos_y, o_y + s_y) - o_y) / s_y));
    ns_selected = min(ns_numoptions - 1, ns_selected);
}

void NS_Draw(void) {
    if(ns_active)
        ns_alpha = approach(ns_alpha, 1, frametime * 5);
    else
        ns_alpha = approach(ns_alpha, 0, frametime * 7);

    if(!ns_alpha)
        return;

    var a = ns_alpha;

    mv_mousepos = mv_mousepos + getmousepos();
    mv_mousepos = [bound(0, mv_mousepos_x, vid_conwidth),
                   bound(0, mv_mousepos_y, vid_conheight)];

    drawfont = sbar_bigfont;
    drawfill('0 0', [vid_conwidth, vid_conheight], '0 0 0', 0.5 * a, DRAWFLAG_NORMAL);

    vector o = [vid_conwidth - ns_width, vid_conheight - ns_height] * 0.5;
    vector s = [ns_width, ns_height];

    if(ns_active)
        NS_UpdateSelection(o, s);

    vector sz = [NS_SCALE, NS_SCALE];
    drawstringcenter([o_x, o_y - sz_y * (1.25 + 2 * g_nadgets_double)], "Nadget Selection", sz, '1 1 1', a, DRAWFLAG_NORMAL);

    for(var table = 0; table < (var tables = g_nadgets_double + 1); ++table) {
        o_x = (vid_conwidth * 0.5) - (1 * tables * 0.5 - 1 * table) * (ns_width + NS_MARGIN);

        drawfill(o, s, '0 0 0', 0.3, DRAWFLAG_NORMAL);
        drawborderlines(2, o, s, '0 0 0', a, DRAWFLAG_NORMAL);

        string txt;
        float txtw;

        if(g_nadgets_double) {
            txt = if(table) "Secondary" else "Primary";
            txtw = stringwidth_svn(txt, FALSE, sz);
            drawstring([o_x + (s_x - txtw) * 0.5, o_y - sz_y * 1.25], txt, sz, '1 1 1', a, DRAWFLAG_NORMAL);
        }

        txt = strcat("Key: ^2", strtoupper(firstkeyfor(
            if(table)
                "'+nadget2' '+button9'"
            else
                "'+nadget' '+hook' '+button6'"
        )));

        txtw = stringwidth_svn(txt, TRUE, sz);
        drawcolorcodedstring([o_x + (s_x - txtw) * 0.5, o_y + s_y + NS_MARGIN * 0.5], txt, sz, a, DRAWFLAG_NORMAL);

        float confirmed = if(table) ns_confirmed2 else ns_confirmed1;
        float confirmedOther = if(table) ns_confirmed1 else ns_confirmed2;

        for(var i = 0; i < ns_numoptions; ++i) {
            var sidx = i + NS_MAX_OPTIONS * table;
            var t = ns_options[sidx];

            if(t < 0)
                break;

            vector p;
            float a2 = ns_selalpha[sidx];
            float isConfirmed = t == confirmed;
            float isSelected = i == ns_selected && ns_selected_in == table;

            vector clr = if((confirmed < 0 || isConfirmed || isSelected) && (t != confirmedOther || t == HG_RANDOM))
                HG_TypeToColor(t) * (0.5 + 0.5 * a2)
            else
                '0.1 0.1 0.1';

            if(isConfirmed || isSelected) {
                ns_selalpha[sidx] = approach(ns_selalpha[sidx], 1, frametime * 3);
                p = [o_x, o_y + i * sz_y + NS_MARGIN * 0.5];
                drawfill(p, [s_x, sz_y], clr, 0.2 * a, DRAWFLAG_NORMAL);
            } else
                ns_selalpha[sidx] = approach(ns_selalpha[sidx], 0, frametime * 3);

            p = [o_x + NS_MARGIN * 0.5, o_y + i * sz_y + NS_MARGIN * 0.5];

            if(t == HG_RANDOM) {
                p_x = p_x + (sz_x - stringwidth_svn("?", FALSE, sz)) * 0.5;
                drawstring(p, "?", sz, clr, a, DRAWFLAG_NORMAL);
            } else {
                drawpic(p, HG_TypeToIcon(t, TRUE, FALSE), sz, '1 1 1' * (0.5 + 0.5 * a2), a, DRAWFLAG_NORMAL);
            }

            p_x = NS_MARGIN * 0.5 + o_x + sz_x;
            drawstring(p, HG_TypeToExpandedName(t), sz, clr, a, DRAWFLAG_NORMAL);

            if(i < 10) {
                txt = if(i == 9) "0" else ftos(i + 1);
                txtw = stringwidth_svn(txt, FALSE, sz * 0.5);
                drawstring([o_x + s_x - txtw, p_y], txt, sz * 0.5, '0.2 0.2 0.2', a, DRAWFLAG_NORMAL);     
            }
        }
    }

    drawfont = sbar_font;

    if(ns_active)
        drawpic(mv_mousepos, strcat("gfx/menu/", CVAR_STR(menu_rmskin), "/cursor.tga"), '32 32 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
}

void NS_ConfirmSelection(void) {
    if(ns_selected_in) {
        ns_confirmed2 = ns_options[NS_MAX_OPTIONS + ns_selected];
        if(ns_confirmed2 == ns_confirmed1 && ns_confirmed2 != HG_RANDOM)
            ns_confirmed1 = -1;
    } else {
        ns_confirmed1 = ns_options[ns_selected];
        if(ns_confirmed1 == ns_confirmed2 && ns_confirmed1 != HG_RANDOM)
            ns_confirmed2 = -1;
    }

    if(!g_nadgets_double || (ns_confirmed1 >= 0 && ns_confirmed2 >= 0)) {
        var cmd = strcat("cmd picknade ", HG_TypeToName(ns_confirmed1));
        if(ns_confirmed2 >= 0)
            cmd = strcat(cmd, " ", HG_TypeToName(ns_confirmed2));
        cmd = strcat(cmd, "; cmd join\n");
        localcmd(cmd);
        ns_active = FALSE;
    }
}

float NS_InputEvent(float bInputType, float nPrimary, float nSecondary) {
    if(!ns_active)
        return FALSE;

    if(bInputType == 2)
        return TRUE;

    if(bInputType == 0) {
        if(nPrimary == K_ESCAPE) {
            if(ns_confirmed2 >= 0)
                ns_confirmed2 = -1;
            else if(ns_confirmed1 >= 0)
                ns_confirmed1 = -1;
            else
                ns_active = FALSE;

            return TRUE;
        }

        if(nPrimary == K_MOUSE1) {
            NS_ConfirmSelection();
            return TRUE;
        }

        if(nPrimary >= '0' && nPrimary <= '9') {
            ns_selected = nPrimary - '0';

            if(!ns_selected)
                ns_selected = 10;
            else
                --ns_selected;

            ns_selected = bound(0, ns_selected, ns_numoptions - 1);
            ns_selected_in = 0;

            if(ns_confirmed1 >= 0)
                ++ns_selected_in;

            NS_ConfirmSelection();
        }
    }

    return FALSE;
}

void Net_ReadNadgetSelect(void) {
    string opts_pri, opts_sec;

    opts_pri = ReadString();
    if(g_nadgets_double)
        opts_sec = ReadString();

    if(isdemo())
        return;

    if(!ns_active) {
        mv_mousepos = [vid_conwidth, vid_conheight] * 0.5;
        ns_confirmed1 = ns_confirmed2 = -1;
    }

    ns_width = 0;
    ns_numoptions = 0;

    using(drawfont = sbar_bigfont) for(var table = 0; table < 2; ++table) {
        ns_numoptions = max(ns_numoptions, tokenizebyseparator(if(table) opts_sec else opts_pri, " "));

        for(var i = 0; i < NS_MAX_OPTIONS; ++i) {
            var typename = argv(i);
            var idx = i + table * NS_MAX_OPTIONS;
            var valid = (typename != "");

            if(valid)
                ns_options[idx] = HG_NameToType(typename);
            else
                ns_options[idx] = -1;

            if(!ns_active)
                ns_selalpha[idx] = 0;

            if(!valid)
                continue;

            ns_width = max(ns_width, NS_SCALE + stringwidth_svn(HG_TypeToExpandedName(ns_options[idx]), FALSE, [NS_SCALE, NS_SCALE]));
        }
    }

    ns_height = NS_SCALE * ns_numoptions + NS_MARGIN;
    ns_width += NS_MARGIN;
    ns_active = TRUE;
}
