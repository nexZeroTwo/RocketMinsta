
.float w_accuracy_fired[WEP_COUNT];
.float w_accuracy_hit[WEP_COUNT];

.float w_accuracy_fired_prev[WEP_COUNT];
.float w_accuracy_hit_prev[WEP_COUNT];

.entity accstats;

void W_Accuracy_Update(entity plr, float wflags) {
    if(plr.accstats)
        plr.accstats.SendFlags |= wflags;
}

void W_Accuracy_UpdateWeapon(entity plr, float w) {
    return W_Accuracy_Update(plr, W_WeaponBit(w));
}

float W_Accuracy_SendEntity(entity plr, float wflags) {
    var w, i;
    var src = plr.clientcamera;

    wflags = wflags & (pow(2, WEP_COUNT - 1) - 1);

    for(w = WEP_FIRST; w <= WEP_LAST; ++w) {
        var drop = TRUE;

        i = get_weaponinfo(w);

        if(!(wflags & i.weapons))
            continue;

        if(i.weapon_type != WEP_TYPE_OTHER) {
            if(plr.(w_accuracy_fired_prev[w]) != src.(w_accuracy_fired[w])) {
                drop = FALSE;
                plr.(w_accuracy_fired_prev[w]) = src.(w_accuracy_fired[w]);
            }

            if(plr.(w_accuracy_hit_prev[w]) != src.(w_accuracy_hit[w])) {
                drop = FALSE;
                plr.(w_accuracy_hit_prev[w]) = src.(w_accuracy_hit[w]);
            }
        }

        if(drop)
            wflags &~= i.weapons;
    }

    if(!wflags)
        return FALSE;

    WriteByte(MSG_ENTITY, ENT_CLIENT_ACCSTATS);
    WriteInt24_t(MSG_ENTITY, wflags);

    for(w = WEP_FIRST; w <= WEP_LAST; ++w) {
        i = get_weaponinfo(w);
        if(i.weapons & wflags) {
            switch(i.weapon_type) {
                case WEP_TYPE_SPLASH:
                    WriteInt24_t(MSG_ENTITY, src.w_accuracy_fired[w]);
                    WriteInt24_t(MSG_ENTITY, src.w_accuracy_hit[w]);
                    break;

                case WEP_TYPE_HITSCAN:
                    WriteShort(MSG_ENTITY, src.w_accuracy_fired[w]);
                    WriteShort(MSG_ENTITY, src.w_accuracy_hit[w]);
                    break;

                default:
                    error("Weapon " + w + " has invalid weapon_type = " + i.weapon_type);
                    break;
            }
        }
    }

    return TRUE;
}

void W_Accuracy_Remove(entity plr) {
    if(plr.accstats)
        remove(plr.accstats);
}

void W_Accuracy_Attach(entity plr) {
    if(clienttype(plr) != CLIENTTYPE_REAL)
        return;

    var i = spawn() {
        classname: "accstats",
        owner: plr,
        customizeentityforclient: inline float(void) { return self.owner == other.clientcamera; },
    };

    plr.accstats = i;
    Net_LinkEntity(i, FALSE, 0, W_Accuracy_SendEntity);
}

float W_Accuracy_IsGoodHit(entity attacker, entity ent) {
    float did_hit;

    if(ent.takedamage == DAMAGE_NO)
        return FALSE;

    float sameteam = !IsDifferentTeam(ent, attacker);

    if(ent.flags & FL_CLIENT) {
        if(ent.deadflag == DEAD_NO)
            did_hit = TRUE;
    } else if(ent.flags & FL_PROJECTILE) {
        if(ent.owner == attacker)
            return TRUE;
        did_hit = TRUE;
    } else if(ent.classname == "meodp_point") {
        return TRUE;
    }

    if(sameteam && !Buffs_Present(attacker, BUFF_MEDIC))
        did_hit = FALSE;

    return did_hit;
}

float W_Accuracy_MayRegister(entity attacker, float w, float wtype) {
    if(roundstate != ROUNDSTATE_GAME)
        return FALSE;

    if(w < WEP_FIRST || w > WEP_LAST)
        return FALSE;

    if(clienttype(attacker) != CLIENTTYPE_REAL)
        return FALSE;

    if(get_weaponinfo(w).weapon_type != wtype)
        return FALSE;

    return TRUE;
}

void W_Accuracy_RegisterShot(entity attacker, float w) {
    if(!W_Accuracy_MayRegister(attacker, w, WEP_TYPE_HITSCAN))
        return;

    attacker.w_accuracy_fired[w] += 1;

    if(!(pow(2, w-1) & g_weaponarena_secondary))
        attacker.accstat_shots = attacker.w_accuracy_fired[w];

    W_Accuracy_UpdateWeapon(attacker, w);
}

void W_Accuracy_RegisterHit(entity attacker, entity targ, float w) {
    if(!W_Accuracy_MayRegister(attacker, w, WEP_TYPE_HITSCAN))
        return;

    if(!W_Accuracy_IsGoodHit(attacker, targ))
        return;

    attacker.w_accuracy_hit[w] += 1;

    if(!(pow(2, w-1) & g_weaponarena_secondary))
        attacker.accstat_hits = attacker.w_accuracy_hit[w];

    W_Accuracy_UpdateWeapon(attacker, w);
}

void W_Accuracy_RegisterPotentialDamage(entity attacker, float w, float damage) {
    if(!W_Accuracy_MayRegister(attacker, w, WEP_TYPE_SPLASH))
        return;

    attacker.w_accuracy_fired[w] += damage;

    if(!(pow(2, w-1) & g_weaponarena_secondary))
        attacker.accstat_shots = attacker.w_accuracy_fired[w];

    W_Accuracy_UpdateWeapon(attacker, w);
}

void W_Accuracy_RegisterActualDamage(entity attacker, float w, float damage) {
    if(!W_Accuracy_MayRegister(attacker, w, WEP_TYPE_SPLASH))
        return;

    attacker.w_accuracy_hit[w] += damage;

    if(!(pow(2, w-1) & g_weaponarena_secondary))
        attacker.accstat_hits = attacker.w_accuracy_hit[w];

    W_Accuracy_UpdateWeapon(attacker, w);
}
