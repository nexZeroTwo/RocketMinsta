
void HG_Waypoint_Update(string wpname) {
    if(!self.hg_waypoint) {
        float ownerhack = (self.hg_type == HG_BAIT || self.hg_type == HG_SENTRY);

        WaypointSprite_Spawn(wpname, 0, 0, self, '0 0 32' * (1 + 1 * ownerhack + 1 * (self.hg_type == HG_SENTRY)), (if(ownerhack) self.realowner else self.owner), 0, self, hg_waypoint, 1);

        if(self.hg_type == HG_SENTRY) {
            WaypointSprite_UpdateMaxHealth(self.hg_waypoint, self.hg_wp_state);
            WaypointSprite_UpdateTeamRadar(self.hg_waypoint, 0, '1 0.5 0');
        } else if(self.hg_detonateready > time) {
            WaypointSprite_UpdateTeamRadar(self.hg_waypoint, 0, '0 1 1');
            WaypointSprite_UpdateBuildFinished(self.hg_waypoint, self.hg_detonateready);
        } else if(self.hg_type == HG_TRANSLOC || self.hg_type == HG_BAIT) {
            WaypointSprite_UpdateTeamRadar(self.hg_waypoint, 0, '0 1 1');
            WaypointSprite_UpdateBuildFinished(self.hg_waypoint, self.hg_deathtime);
        }
    } else {
        WaypointSprite_UpdateSprites(self.hg_waypoint, wpname, "", "");

        if(self.hg_type == HG_SENTRY) {
            if(self.hg_wp_state) {
                WaypointSprite_UpdateMaxHealth(self.hg_waypoint, 1);
                WaypointSprite_UpdateHealth(self.hg_waypoint, self.hg_sentry_energy);
            } else
                WaypointSprite_UpdateMaxHealth(self.hg_waypoint, 0);
        }
    }
}

void HG_Waypoint(void) {
    entity plr;
    float detected;
    float rng;

    if(time < self.hg_wp_nextthink)
        return;

    if(self.hg_type == HG_SENTRY) {
        if(self.hg_waypoint)
            WaypointSprite_UpdateHealth(self.hg_waypoint, self.hg_sentry_energy);

        detected = (self.hg_sentry_energy < 1);
    } else if(self.hg_type == HG_BAIT)
        detected = self.revprogress;
    else {
        if(self.hg_adept && GRENVAR(self.hg_type, "adept_detect_enemies"))
            rng = GRENVAR(self.hg_type, "adept_detect_enemies");
        else
            rng = GRENVAR(self.hg_type, "detect_enemies");

        if(!rng) {
            if(self.hg_waypoint)
                WaypointSprite_Disown(self.hg_waypoint, 0.5);
            return;
        }

        if(rng > 0) FOR_EACH_PLAYER(plr) {
            if(plr.team != self.team || !teams_matter)
            if(plr != self.owner)
            if(!(g_freeze && plr.frozen))
            if(vlen(self.origin - plr.origin) < rng)
            if(checkpvs(self.origin, plr)) {
                detected = TRUE;
                break;
            }
        }
    }

    if(detected) {
        if(!self.hg_wp_state) {
            self.hg_wp_state = TRUE;
            HG_Waypoint_Update("pointer_red");
        }
    } else if(self.hg_wp_state || !self.hg_waypoint) {
        self.hg_wp_state = FALSE;
        HG_Waypoint_Update("pointer_cyan");
    }

    self.hg_wp_nextthink = time + 0.1;
}

void HG_Waypoint_Remove(entity wp) {
    if(wp)
        WaypointSprite_Disown(wp, 0.5);
}
