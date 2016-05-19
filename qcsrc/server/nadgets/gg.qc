
HG_HOOKFUNCTION(gg, Attack) {
    entity p;
    float pwned;
    float allow;

    float damage = CVAR(g_nadgets_gg_damage);
    float range  = CVAR(g_nadgets_gg_range);

    FOR_EACH_PLAYER(p)
    if(p != self)
    if(!PlayerIsDead(p))
    if(!teams_matter || p.team != self.team || Buffs_Present(self, BUFF_MEDIC) || Buffs_Present(self, BUFF_ADEPT))
    if(vlen(self.origin - p.origin) < range) {
        vector o = self.origin + self.view_ofs;
        vector e = p.origin + p.view_ofs;
        traceline(o, e, TRUE, self);

        allow = (trace_endpos == e);
        if(!allow)
            allow = (vlen(trace_endpos - e) < 5);

        if(allow) {
            Damage(p, world, self, damage, HG_GG, e, normalize(e - o) * 1000);
            trailparticles(world, particleeffectnum("TE_TEI_G3RED_HIT"), o, e + randomvec() * 10);
            trailparticles(world, particleeffectnum("TE_TEI_G3BLUE_HIT"), o, e + randomvec() * 10);
            trailparticles(world, particleeffectnum("TE_TEI_G3YELLOW_HIT"), o, e + randomvec() * 10);
            trailparticles(world, particleeffectnum("TE_TEI_G3PINK_HIT"), o, e + randomvec() * 10);

            if(Buffs_Present(self, BUFF_ADEPT)) {
                float i; for(i = 0; i < 4; ++i)
                    te_csqc_lightningarc(o, e + randomvec() * 10, TRUE, Team_FromIndex(i));
            }

            ++pwned;
        }
    }

    if(pwned) {
        sound(self, CHAN_AUTO, "misc/gg.wav", 1, ATTN_NORM);
        return HG_ATTACK_OK;
    } else {
        bigprint_spec(self, "Nobody to win against!", "", 1);
        return HG_ATTACK_FAIL_COOLDOWN;
    }
}

HG_EMPTY_INITFUNC(gg)
