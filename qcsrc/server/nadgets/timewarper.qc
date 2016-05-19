
void HG_TimeWarper_Abort(void) {
    HG_TimeWarper_EraseMoment();
    HG_TimeWarper_StopTimer();
    self.hg_twarp_expiretime = 0;
}

void HG_TimeWarper_EraseMoment(void) {
    if(self.hg_twarp_moment) {
        TimeTravel_EraseMoment(self.hg_twarp_moment);
        self.hg_twarp_moment = world;
    }
}

void HG_TimeWarper_SaveMoment(void) {
    HG_TimeWarper_EraseMoment();
    self.hg_twarp_moment = TimeTravel_SaveMoment(self);
}

float HG_TimeWarper_Trigger(void) {
    if(self.hg_twarp_moment) {
        if(self.flagcarried)
            DropFlag(self.flagcarried, world, world);

        sound(self, CHAN_TRIGGER, "misc/teleport.wav", VOL_BASE, ATTN_NORM);
        pointparticles(particleeffectnum("teleport"), self.origin, '0 0 0', 1);
        TimeTravel_TakeBack(self, self.hg_twarp_moment);
        self.hg_twarp_warptime = time;
        sound(self, CHAN_AUTO, "misc/timewarp.wav", VOL_BASE * 0.8, ATTN_NORM);
        pointparticles(particleeffectnum("teleport"), self.origin, '0 0 0', 1);
        HG_TimeWarper_Abort();

        return TRUE;
    }

    return FALSE;
}

void HG_TimeWarper_StopTimer(void) {
    if(self.hg_twarp_timer) {
        remove(self.hg_twarp_timer);
        self.hg_twarp_timer = world;
    }
}

entity HG_TimeWarper_StartTimer(void) {
    HG_TimeWarper_StopTimer();

    var e = spawn() {
        owner: self,
        origin: self.origin,
        nextthink: self.hg_twarp_expiretime,
        think: inline void(void) {
            using(self = self.owner) {
                if(Buffs_Present(self, BUFF_ADEPT))
                    HG_TimeWarper_Abort();
                else
                    HG_TimeWarper_Trigger();
            }
        },
        reset: SUB_Remove,
    };

    Net_LinkEntity(e, FALSE, 0, inline float(entity to, float sf) {
        WriteByte(MSG_ENTITY, ENT_CLIENT_HGTWARP_INDICATOR);
        WriteByte(MSG_ENTITY, if(teams_matter) self.owner.team else COLOR_TEAM2);
        WriteCoord(MSG_ENTITY, self.origin_x);
        WriteCoord(MSG_ENTITY, self.origin_y);
        WriteCoord(MSG_ENTITY, self.origin_z);
        return TRUE;
    });

    self.hg_twarp_timer = e;
    return e;
}

HG_HOOKFUNCTION(timewarper, Attack) {
    HG_TimeWarper_Abort();

    // Do it in the next frame, so that the timewarper nadget ammo is saved as consumed
    defer(0, inline void(void) {
        HG_TimeWarper_SaveMoment();
        self.hg_twarp_expiretime = time + (
            if(Buffs_Present(self, BUFF_ADEPT))
                CVAR(g_nadgets_timewarper_adept_duration)
            else
                CVAR(g_nadgets_timewarper_duration)
        );
        HG_TimeWarper_StartTimer();
    });

    return HG_ATTACK_OK;
}

HG_HOOKFUNCTION(timewarper, Init) {
    addstat(STAT_HGTWARP_EXPIRETIME, AS_FLOAT, hg_twarp_expiretime);
    addstat(STAT_HGTWARP_WARPTIME, AS_FLOAT, hg_twarp_warptime);
    precache_sound("misc/timewarp.wav");
    return HG_INIT_OK;
}
