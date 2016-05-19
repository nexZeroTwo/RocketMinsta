
void Ent_TimeWarperIndicator(void) {
    self.team = ReadByte() - 1;
    self.origin_x = ReadCoord();
    self.origin_y = ReadCoord();
    self.origin_z = ReadCoord();
    setorigin(self, self.origin);

    sound(self, CHAN_AUTO, "weapons/electro_impact.wav", 0.2, 1.0);
    pointparticles(rm_particleeffectnum_team("RM_HG_PLASMA_SHARD_EXPLODE", self.team, 2), self.origin, '0 0 0', 10);

    self.think = inline void(void) {
        var o1, o2;

        for(var i = 0; i < 2 + 2 * random(); ++i) {
            o1 = 50 * randomvec() + self.origin;
            o2 = 2  * randomvec() + self.origin;
            LightingArc_Default(o1, o2, self.team);
            pointparticles(rm_particleeffectnum_team("RM_CRYLINK_IMPACT", self.team, 2), o1, '0 0 0', 1);
        }

        pointparticles(rm_particleeffectnum_team("RM_CRYLINK_IMPACT", self.team, 2), o2, '0 0 0', 10);
        sound(self, CHAN_TRIGGER, "weapons/crylink_impact.wav", 0.2, 1.0);
        self.nextthink = time + 0.15;
    };

    self.nextthink = time + 0.15;
}
