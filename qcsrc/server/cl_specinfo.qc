
float SpecInfo_SendEntity(entity to, float sf) {
    var specs = 0;
    var plr = to.clientcamera;
    var spec;

    if(!sv_showspecs_extra || to == plr)
        sf &~= SPECINFO_HUD;

    WriteByte(MSG_ENTITY, ENT_CLIENT_SPECINFO);
    WriteByte(MSG_ENTITY, sf);

    if(sf & SPECINFO_LIST) {
        if(CVAR(sv_showspecs_hidefromplayers)) {
            WriteByte(MSG_ENTITY, 0);
        } else {
            FOR_EACH_SPECOF(plr, spec) if(!IS_ANONSPEC(spec))
                ++specs;

            WriteByte(MSG_ENTITY, specs);

            FOR_EACH_SPECOF(plr, spec) if(!IS_ANONSPEC(spec))
                WriteByte(MSG_ENTITY, num_for_edict(spec));
        }
    }

    if(sf & SPECINFO_HUD) {
        WriteByte(MSG_ENTITY, plr.madoka);
        WriteByte(MSG_ENTITY, plr.hud_old);
        WriteByte(MSG_ENTITY, plr.hud_alt);
        WriteString(MSG_ENTITY, plr.hudskin);
        WriteByte(MSG_ENTITY, plr.clientfov);
        WriteByte(MSG_ENTITY, plr.speczoom_speed * 10);
        WriteByte(MSG_ENTITY, plr.speczoom_factor * 10);
    }

    return TRUE;
}

void SpecInfo_Attach(entity plr) {
    if(clienttype(plr) != CLIENTTYPE_REAL)
        return;

    var i = spawn() {
        classname: "specinfo",
        owner: plr,
        drawonlytoclient: plr,
    };

    plr.specinfo = i;
    Net_LinkEntity(i, FALSE, 0, SpecInfo_SendEntity);
}

void SpecInfo_Remove(entity plr) {
    if(plr.specinfo) {
        remove(plr.specinfo);
        plr.specinfo = world;
    }
}

void SpecInfo_Touch(entity plr, float uflags) {
    if(plr.specinfo) {
        // print("SpecInfo_Touch(" + plr.netname + "^7, " + uflags + ")\n");
        plr.specinfo.SendFlags |= uflags;
    }
}

void SpecInfo_Update(entity plr, float uflags) {
    plr = plr.clientcamera;
    SpecInfo_Touch(plr, uflags);
    FOR_EACH_SPECOF(plr, var spec)
        SpecInfo_Touch(spec, uflags);
}
