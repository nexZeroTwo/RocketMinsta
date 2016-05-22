
#define TIMETRAVEL_HANDLE_ALL \
        TIMETRAVEL_HANDLE(health,                       Float)      \
        TIMETRAVEL_HANDLE(armorvalue,                   Float)      \
        TIMETRAVEL_HANDLE(pushltime,                    Time)       \
        TIMETRAVEL_HANDLE(origin,                       Origin)     \
        TIMETRAVEL_HANDLE(angles,                       Angles)     \
        TIMETRAVEL_HANDLE(velocity,                     Vector)     \
        TIMETRAVEL_HANDLE(strength_finished,            Time)       \
        TIMETRAVEL_HANDLE(invincible_finished,          Time)       \
        TIMETRAVEL_HANDLE(jump_interval,                Time)       \
        TIMETRAVEL_HANDLE(ammo_shells,                  Float)      \
        TIMETRAVEL_HANDLE(ammo_nails,                   Float)      \
        TIMETRAVEL_HANDLE(ammo_rockets,                 Float)      \
        TIMETRAVEL_HANDLE(ammo_cells,                   Float)      \
        TIMETRAVEL_HANDLE(ammo_fuel,                    Float)      \
        TIMETRAVEL_HANDLE(weapons,                      Float)      \
        TIMETRAVEL_HANDLE(items,                        Float)      \
        TIMETRAVEL_HANDLE(cnt,                          Float)      \
        TIMETRAVEL_HANDLE(spawnshieldtime,              Time)       \
        TIMETRAVEL_HANDLE(pauserotarmor_finished,       Time)       \
        TIMETRAVEL_HANDLE(pauserothealth_finished,      Time)       \
        TIMETRAVEL_HANDLE(pauserotfuel_finished,        Time)       \
        TIMETRAVEL_HANDLE(pauseregen_finished,          Time)       \
        TIMETRAVEL_HANDLE(avelocity,                    Vector)     \
        TIMETRAVEL_HANDLE(punchangle,                   Vector)     \
        TIMETRAVEL_HANDLE(punchvector,                  Vector)     \
        TIMETRAVEL_HANDLE(oldvelocity,                  Vector)     \
        TIMETRAVEL_HANDLE(crouch,                       Float)      \
        TIMETRAVEL_HANDLE(lastdamage,                   Time)       \
        TIMETRAVEL_HANDLE(last_dodging_time,            Time)       \
        TIMETRAVEL_HANDLE(lastwj,                       Time)       \
        TIMETRAVEL_HANDLE(weapon_nextthink,             Time)       \
        TIMETRAVEL_HANDLE(weapon_think,                 VoidFunc)   \
        TIMETRAVEL_HANDLE(frozen,                       Float)      \
        TIMETRAVEL_HANDLE(freezetime,                   Time)       \
        TIMETRAVEL_HANDLE(jb_isprisoned,                Float)      \
        TIMETRAVEL_HANDLE(jb_prisontime,                Time)       \
        TIMETRAVEL_HANDLE(disableclientprediction,      Float)      \
        TIMETRAVEL_HANDLE(buff_vamp_ticks,              Float)      \
        TIMETRAVEL_HANDLE(buff_vamp_healthpool,         Float)      \
        TIMETRAVEL_HANDLE(buff_vamp_nexttick,           Time)       \
        TIMETRAVEL_HANDLE(hg_power,                     Float)      \
        TIMETRAVEL_HANDLE(hg_state,                     Float)      \
        TIMETRAVEL_HANDLE(hg_altstate,                  Float)      \
        TIMETRAVEL_HANDLE(hg_next1,                     Time)       \
        TIMETRAVEL_HANDLE(hg_next2,                     Time)       \
        TIMETRAVEL_HANDLE(hg_bonus_next,                Time)       \
        TIMETRAVEL_HANDLE(hg_ammo1,                     Float)      \
        TIMETRAVEL_HANDLE(hg_ammo2,                     Float)      \
        TIMETRAVEL_HANDLE(hg_bonus,                     Float)      \
        TIMETRAVEL_HANDLE(hg_bonustype,                 Float)      \
        TIMETRAVEL_HANDLE(hg_regentime1,                Float)      \
        TIMETRAVEL_HANDLE(hg_maxregentime1,             Float)      \
        TIMETRAVEL_HANDLE(hg_regentime2,                Float)      \
        TIMETRAVEL_HANDLE(hg_maxregentime2,             Float)      \
        TIMETRAVEL_HANDLE(buff_conduit_hpool,           Float)      \
        TIMETRAVEL_HANDLE(buff_conduit_apool,           Float)      \
        TIMETRAVEL_HANDLE(buff_conduit_dpool,           Float)      \
        TIMETRAVEL_HANDLE(buff_conduit_next,            Time)       \
        TIMETRAVEL_HANDLE(zapper_heat,                  Float)      \
        TIMETRAVEL_HANDLE(zapper_coolofftime,           Time)       \
        TIMETRAVEL_HANDLE_SPECIAL(WeaponState)


        /*
         * TODO: handle Endurance correctly
         *

        TIMETRAVEL_HANDLE(buff_endur_ticks,             Float)      \
        TIMETRAVEL_HANDLE(buff_endur_dmgpool,           Float)      \
        TIMETRAVEL_HANDLE(buff_endur_nexttick,          Time)       \

         */



.float tt_weaponentity_state;
void TimeTravel_StoreWeaponState(entity e, entity moment) {
    if(!e.weaponentity)
        return;
    
    moment.tt_weaponentity_state = e.weaponentity.state;
    moment.weapon = e.weapon;
    
    entity oldself = self;
    self = e;
    tt_moment = moment;
    float w; for(w = WEP_FIRST; w <= WEP_LAST; ++w) {
        weapon_action(w, WR_TT_STORE);
        ATTACK_FINISHED_FOR(moment, w) = ATTACK_FINISHED_FOR(e, w) - time;
    }
    self = oldself;
}

void TimeTravel_RestoreWeaponState(entity e, entity moment) {
    if(!e.weaponentity)
        return;
    
    e.weaponentity.state = moment.tt_weaponentity_state;
    W_SwitchWeapon_Force(e, moment.weapon);
    e.w_instaswitch = TRUE;
    
    entity oldself = self;
    self = e;
    tt_moment = moment;
    float w; for(w = WEP_FIRST; w <= WEP_LAST; ++w) {
        weapon_action(w, WR_TT_RESTORE);
        ATTACK_FINISHED_FOR(e, w) = ATTACK_FINISHED_FOR(moment, w) + time;
    }
    self = oldself;
}

#define TIMETRAVEL_HANDLE(f,t) TimeTravel_Store##t(e, moment, f);
#define TIMETRAVEL_HANDLE_SPECIAL(t) TimeTravel_Store##t(e, moment);
entity TimeTravel_SaveMoment(entity e) {
    entity moment;
    
    if(!e)
        return world;
    
    moment = spawn() {
        classname     : "tt_moment",
        tt_momenttime : time,
        reset         : SUB_Remove
    };

    TIMETRAVEL_HANDLE_ALL
    return moment;
}
#undef TIMETRAVEL_HANDLE_SPECIAL
#undef TIMETRAVEL_HANDLE

#define TIMETRAVEL_HANDLE(f,t) TimeTravel_Restore##t(e, moment, f);
#define TIMETRAVEL_HANDLE_SPECIAL(t) TimeTravel_Restore##t(e, moment);
void TimeTravel_TakeBack(entity e, entity moment) {
    if(!e || !moment)
        return;
    
    TIMETRAVEL_HANDLE_ALL
}
#undef TIMETRAVEL_HANDLE_SPECIAL
#undef TIMETRAVEL_HANDLE

void TimeTravel_EraseMoment(entity moment) {
    if(moment.classname != "tt_moment") {
        error("TimeTravel_EraseMoment: not a moment (" + moment + ")");
    }

    if(!moment.reset) {
        error("TimeTravel_EraseMoment: moment has no reset function (" + moment + ")");
    }

    using(self = moment) {
        moment.reset();
    }
}

#undef TIMETRAVEL_HANDLE_ALL
#undef TIMETRAVEL_STORE_IDENTITY
#undef TIMETRAVEL_RESTORE_IDENTITY
#undef TIMETRAVEL_HANDLER

entity TimeTravel_Track(entity e, float maxtime, float accuracy) {
    if(e.tt_lastmoment && time - e.tt_lastmoment.tt_momenttime < accuracy)
        return e.tt_lastmoment;

    if(!(var moment = TimeTravel_SaveMoment(e)))
        return world;

    moment.tt_lastmoment = e.tt_lastmoment;
    e.tt_lastmoment = moment;

    var lastmoment_owner = e;
    for(var lastmoment = var m = moment; (m = m.tt_lastmoment);) {
        lastmoment_owner = lastmoment;
        lastmoment = m;
    }

    if(lastmoment && time - lastmoment.tt_momenttime > maxtime) {
        TimeTravel_EraseMoment(lastmoment);
        lastmoment_owner.tt_lastmoment = world;
    }

    return moment;
}

void TimeTravel_TakeBack_ToTracked(entity e, float mtime) {
    var moment = world;
    var mindiff = mtime;

    for(var m = e.tt_lastmoment; (m = m.tt_lastmoment);) {
        if((var d = fabs(mtime - m.tt_momenttime)) < mindiff) {
            mindiff = d;
            moment = m;
        }
    }

    if(!moment)
        return;

    TimeTravel_TakeBack(e, moment);
}
