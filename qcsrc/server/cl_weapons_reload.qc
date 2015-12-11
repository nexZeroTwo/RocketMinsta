
var .float __dummy_field;

void W_Clip_SetWeaponContext(float wep, float cliplimit, float reloadtime, .float ammofield, float ammo_per_unit) {
    if(wep == w_clip_context)
        return;

    wep -= 1;

    w_clip_context = wep;

    w_clip_loaded = w_clip_loaded_array[wep];
    w_clip_limit = w_clip_limit_array[wep];
    w_clip_saved = w_clip_saved_array[wep];
    w_clip_reloadfinished = w_clip_reloadfinished_array[wep];

    w_clip_context_limit = cliplimit;
    w_clip_context_reloadtime = reloadtime;
    w_clip_context_ammofield = ammofield;
    w_clip_context_ammo_per_unit = ammo_per_unit;
}

void W_Clip_UnsetWeaponContext(void) {
    w_clip_context = -1;
    
    w_clip_loaded = __dummy_field;
    w_clip_limit = __dummy_field;
    w_clip_saved = __dummy_field;
    w_clip_reloadfinished = __dummy_field;

    w_clip_context_limit = 0;
    w_clip_context_reloadtime = 0;
    w_clip_context_ammofield = __dummy_field;
    w_clip_context_ammo_per_unit = 0;
}

void W_Clip_CurrentWeaponContext(void) {
    W_Clip_UnsetWeaponContext();
    weapon_action(self.weapon, WR_SETCLIPCONTEXT);
}

void W_Clip_Stats_Init(void) {
    addstat(STAT_CLIP_LOADED, AS_INT, w_clip_loaded_stat);
    addstat(STAT_CLIP_LIMIT, AS_INT, w_clip_limit_stat);
}

void W_Clip_Stats_Update(void) {
    var wep = self.switchweapon - 1;
    self.w_clip_loaded_stat = self.w_clip_loaded_array[wep];
    self.w_clip_limit_stat = self.w_clip_limit_array[wep];
}

void W_Clip_ResetPlayer(void) {
    for(var w = 0; w < WEP_LAST; ++w) {
        self.(w_clip_limit_array[w]) = 0;
        self.(w_clip_loaded_array[w]) = 0;
    }
}

float W_Clip_CheckFull(void) {
    var lim = self.w_clip_limit;

    if(lim <= 0)
        return TRUE;

    if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
        lim = min(lim, floor(self.w_clip_context_ammofield / w_clip_context_ammo_per_unit));

    if(self.w_clip_loaded > lim || !self.w_clip_limit)
        self.w_clip_loaded = lim;

    return (self.w_clip_loaded == lim);
}

void W_Clip_ReloadedAndReady(void) {
    self.w_clip_loaded = self.w_clip_limit;
    W_Clip_CheckFull();

    var t = ATTACK_FINISHED(self) - w_clip_context_reloadtime - 1;
    ATTACK_FINISHED(self) = t;

    w_ready();
}

void W_Clip_Reload(void) {
    float t;

    if(W_Clip_CheckFull())
        return;

    if(self.w_clip_context_ammofield < w_clip_context_ammo_per_unit) {
        self.w_clip_loaded = -1; // reload later
        W_SwitchWeapon_OutOfAmmo(self);
        return;
    }
    
    if(self.weaponentity) {
        if(self.weaponentity.wframe == WFRAME_RELOAD)
            return;

        if(CVAR(g_balance_reload_switch_while_reloading))
            self.weaponentity.state = WS_READY;
        else
            self.weaponentity.state = WS_INUSE;

        self.weaponentity.state = WS_READY;
    }

    sound(self, CHAN_WEAPON2, "weapons/campingrifle_reload.wav", VOL_BASE, ATTN_NORM);

    t = max(time, ATTACK_FINISHED(self)) + w_clip_context_reloadtime;
    self.w_clip_reloadfinished = t * W_WeaponRateFactor();

    weapon_thinkf(WFRAME_RELOAD, w_clip_context_reloadtime, W_Clip_ReloadedAndReady);

    self.w_clip_saved = self.w_clip_loaded;
    self.w_clip_loaded = -1;
}

void W_Clip_CheckReloadAndReady(void)
{
    w_ready();
    if(self.w_clip_loaded <= 0)
        W_Clip_Reload();
    else
        w_ready();
}

float W_Clip_TryAttackOrReload(void) {
    if(w_clip_context_limit <= 0)
        return TRUE;

    if(self.w_clip_loaded > 0)
        return TRUE;

    W_Clip_Reload();
    return FALSE;
}

float W_Clip_TryWeaponAction(void) {
    if(w_clip_context_limit <= 0)
        return TRUE;

    if(self.w_clip_limit <= 0) {
        self.w_clip_limit = w_clip_context_limit;
        self.w_clip_loaded = w_clip_context_limit;
    }

    self.w_clip_loaded = min(self.w_clip_loaded, self.w_clip_limit);

    if(self.w_clip_loaded <= 0) {
        if(self.switchweapon == self.weapon && self.weaponentity.state == WS_READY)
            W_Clip_Reload();
        return FALSE;
    }

    if(time > self.w_clip_reloadfinished)
        return TRUE;

    return FALSE;
}

void W_Clip_FinishWeaponAction(void) {
    self.w_clip_saved = self.w_clip_loaded;
}

void W_Clip_Reset(void) {
    self.w_clip_loaded = self.w_clip_limit;
    self.w_clip_reloadfinished = time;
}

void W_Clip_Consume(float cost) {
    if(w_clip_context_limit <= 0)
        return;

    self.w_clip_loaded = max(0, self.w_clip_loaded - cost);
    W_Clip_CheckFull();
}

void W_Clip_WeaponRequestHook(float req) {
    if(req == WR_RELOAD) {
        W_Clip_Reload();
    } else if(req == WR_RESETPLAYER) {
        W_Clip_Reset();
    } else if(req == WR_SETUP) {
        var full = W_Clip_CheckFull();
        if(CVAR(g_balance_reload_after_changing_weapons))
            if(!full)
                self.w_clip_loaded = -1;
    } else if(req == WR_LOWER) {
        if(CVAR(g_balance_reload_cancel_by_switch)) {
            if(self.w_clip_loaded <= 0) {
                self.w_clip_loaded = self.w_clip_saved;
                self.w_clip_reloadfinished = time;
            } else
                self.w_clip_saved = self.w_clip_loaded;
        }
    }
}
