.float silent;

void Ent_DamageInfo(float isNew)
{
	float hittype, dmg, rad, edge, thisdmg, forcemul;
	float issilent;
	vector force, org, thisforce;
	entity oldself;

	oldself = self;

	hittype = ReadShort();

	issilent = (hittype & 0x8000);
	hittype = (hittype & 0x7FFF);

	org_x = ReadCoord();
	org_y = ReadCoord();
	org_z = ReadCoord();

	dmg = ReadByte();
	rad = ReadByte();
	edge = ReadByte();
	force = decompressShortVector(ReadShort());
    
    self.team = ReadByte();

	if not(isNew)
		return;

	if(rad < 0)
	{
		rad = -rad;
		forcemul = -1;
	}
	else
		forcemul = 1;
	
	for(self = findradius(org, rad); self; self = self.chain)
	{
		if(rad)
		{
			thisdmg = vlen(self.origin - org) / rad;
			if(thisdmg >= 1)
				continue;
			if(dmg)
			{
				thisdmg = dmg + (edge - dmg) * thisdmg;
				thisforce = forcemul * vlen(force) * (thisdmg / dmg) * normalize(self.origin - org);
			}
			else
			{
				thisdmg = 0;
				thisforce = forcemul * vlen(force) * normalize(self.origin - org);
			}
		}
		else
		{
			thisdmg = dmg;
			thisforce = forcemul * force;
		}

		if(self.damageforcescale)
			if(vlen(thisforce))
			{
				self.move_velocity = self.move_velocity + self.damageforcescale * thisforce;
				self.move_flags &~= FL_ONGROUND;
			}

		if(issilent)
			self.silent = 1;

		if(self.event_damage)
			self.event_damage(thisdmg, hittype, org, thisforce);
	}

	self = oldself;
    
	if(!DEATH_ISSPECIAL(hittype))
	{
		float hitwep, secondary, bounce, headshot;
		vector org2, backoff;
		float r;

		hitwep = DEATH_WEAPONOFWEAPONDEATH(hittype);
		secondary = hittype & HITTYPE_SECONDARY;
		bounce = hittype & HITTYPE_BOUNCE;
		headshot = hittype & HITTYPE_HEADSHOT;
		r = prandom();

		traceline(org - normalize(force) * 16, org + normalize(force) * 16, MOVE_NOMONSTERS, world);
		if(trace_fraction < 1 && hitwep != WEP_NEX && hitwep != WEP_MINSTANEX)
			backoff = trace_plane_normal;
		else
			backoff = -1 * normalize(force);

		setorigin(self, org + backoff * 2); // for sound() calls

        if(DEATH_ISHG(hittype))
		{
			if (!issilent)
				WarpZone_Sound(self, CHAN_AUTO, "weapons/grenade_impact.wav", VOL_BASE, ATTN_NORM);

			hittype &~= DEATH_HITTYPEMASK;
			switch (hittype)
			{
                case HG_NORMAL:
                case HG_REMOTE:
                case HG_NAPALM:
                case HG_BAIT:
                case HG_RAZE:
                    pointparticles(rm_particleeffectnum("RM_EXPLOSION"), self.origin, '0 0 0', 1);
                    break;
                
                case HG_PLASMA: case HG_LASER:
                    if((hittype == HG_PLASMA && (secondary || bounce)) || hittype == HG_LASER) {
                        org2 = org + backoff * 6;
                        pointparticles(rm_particleeffectnum_team("RM_HG_PLASMA_SHARD_EXPLODE", self.team, 2 - (hittype == HG_LASER)), org2, '0 0 0', 1);
                        if(!issilent)
                            ImpactSound(self, "weapons/electro_impact.wav");
                    } else { // plasma bomb explosion
                        org2 = org + backoff * 2;
                        pointparticles(rm_particleeffectnum_team("RM_HG_PLASMA_EXPLODE", self.team, 2), org2, '0 0 0', 1);
                        if(!issilent)
                            ImpactSound(self, "weapons/hookbomb_impact.wav");
                    }
                    break;
			}
		}
		else switch (hitwep)
		{
			case WEP_LASER:
				org2 = org + backoff * 6;
				pointparticles(particleeffectnum("laser_impact"), org2, backoff * 1000, 1);
				if(!issilent)
					ImpactSound(self, "weapons/laserimpact.wav");
				break;
			case WEP_SHOTGUN:
				org2 = org + backoff * 2;
				pointparticles(particleeffectnum("shotgun_impact"), org2, backoff * 1000, 1);
				if(!issilent)
				{
					if(r < 0.05)
						ImpactSound(self, "weapons/ric1.wav");
					else if(r < 0.1)
						ImpactSound(self, "weapons/ric2.wav");
					else if(r < 0.2)
						ImpactSound(self, "weapons/ric3.wav");
				}
				break;
			case WEP_UZI:
				org2 = org + backoff * 2;
				pointparticles(particleeffectnum("machinegun_impact"), org2, backoff * 1000, 1);
				if(!issilent)
					if(r < 0.05)
						ImpactSound(self, "weapons/ric1.wav");
					else if(r < 0.1)
						ImpactSound(self, "weapons/ric2.wav");
					else if(r < 0.2)
						ImpactSound(self, "weapons/ric3.wav");
				break;
			case WEP_GRENADE_LAUNCHER:
				org2 = org + backoff * 12;
				pointparticles(particleeffectnum("grenade_explode"), org2, '0 0 0', 1);
				if(!issilent)
					ImpactSound(self, "weapons/grenade_impact.wav");
				break;
			case WEP_ELECTRO:
				org2 = org + backoff * 6;
				if(secondary)
				{
					pointparticles(rm_particleeffectnum_team("RM_HG_PLASMA_SHARD_EXPLODE", self.team, 2), org2, '0 0 0', 1);
					if(!issilent)
						ImpactSound(self, "weapons/electro_impact.wav");
				}
				else
				{
					if(bounce)
					{
						// this is sent as "primary bounce" to distinguish it from secondary bounced balls
						pointparticles(rm_particleeffectnum_team("RM_ELECTRO_COMBO", self.team, 2), org2, '0 0 0', 1);
						if(!issilent)
							ImpactSound(self, "weapons/electro_impact_combo.wav");
					}
					else
					{
						pointparticles(rm_particleeffectnum_team("RM_ELECTRO_IMPACT", self.team, 2), org2, '0 0 0', 1);
						//if(!issilent)
							//sound(self, CHAN_PROJECTILE, "weapons/electro_impact.wav", VOL_BASE, ATTN_NORM);
						if(!issilent)
							ImpactSound(self, "weapons/crylink_impact2.wav");
					}
				}
				break;
			case WEP_CRYLINK:
				org2 = org + backoff * 2;
				if(secondary)
				{
					pointparticles(rm_particleeffectnum_team("RM_CRYLINK_IMPACT", self.team, 4), org2, '0 0 0', 1);
					if(!issilent)
						ImpactSound(self, "weapons/crylink_impact2.wav");
				}
				else
				{
					pointparticles(rm_particleeffectnum_team("RM_CRYLINK_IMPACT_BIG", self.team, 4), org2, '0 0 0', 1);
					if(!issilent)
						ImpactSound(self, "weapons/crylink_impact.wav");
				}
				break;
			case WEP_NEX:
				org2 = org + backoff * 6;
				pointparticles(particleeffectnum("nex_impact"), org2, '0 0 0', 1);
				if(!issilent)
					ImpactSound(self, "weapons/neximpact.wav");
				break;
            case WEP_ZAPPER:
                org2 = org + backoff * 6;
                if(secondary) {
                    pointparticles(particleeffectnum("nex_impact"), org2, '0 0 0', 1);
                    if(!issilent)
                        ImpactSound(self, "weapons/neximpact.wav");
                } else if(!issilent) {
                    ImpactSound(self, "weapons/zapper_impact.wav");
                }
                break;
			case WEP_HAGAR:
				org2 = org + backoff * 6;
				pointparticles(particleeffectnum("hagar_explode"), org2, '0 0 0', 1);
				if(!issilent)
				{
					if (r<0.15)
						ImpactSound(self, "weapons/hagexp1.wav");
					else if (r<0.7)
						ImpactSound(self, "weapons/hagexp2.wav");
					else
						ImpactSound(self, "weapons/hagexp3.wav");
				}
				break;
			case WEP_ROCKET_LAUNCHER: case WEP_FLAK:
				org2 = org + backoff * 12;
				pointparticles(particleeffectnum("rocket_explode"), org2, '0 0 0', 1);
				if(!issilent)
					ImpactSound(self, "weapons/rocket_impact.wav");
				break;
			case WEP_PORTO:
				print("Since when does Porto send DamageInfo?\n");
				break;
			case WEP_MINSTANEX:
				org2 = org + backoff * 6;
				pointparticles(particleeffectnum("nex_impact"), org2, '0 0 0', 1);
				if(!issilent)
					ImpactSound(self, "weapons/neximpact.wav");
				break;
			case WEP_HOOK:
				org2 = org + backoff * 2;
				pointparticles(particleeffectnum("hookbomb_explode"), org2, '0 0 0', 1);
				if(!issilent)
					ImpactSound(self, "weapons/hookbomb_impact.wav");
				break;
			case WEP_HLAC:
				org2 = org + backoff * 6;
				pointparticles(particleeffectnum("laser_impact"), org2, backoff * 1000, 1);
				if(!issilent)
					ImpactSound(self, "weapons/laserimpact.wav");
				break;
			case WEP_CAMPINGRIFLE:
				org2 = org + backoff * 2;
				pointparticles(particleeffectnum("machinegun_impact"), org2, backoff * 1000, 1);
				if(!issilent)
				{
					if(r < 0.2)
						ImpactSound(self, "weapons/ric1.wav");
					else if(r < 0.4)
						ImpactSound(self, "weapons/ric2.wav");
					else if(r < 0.5)
						ImpactSound(self, "weapons/ric3.wav");
				}
				break;
			case WEP_TUBA:
				break;
			case WEP_FIREBALL:
				if(secondary)
				{
					org2 = org + backoff * 16;
					pointparticles(particleeffectnum("fireball_explode"), org2, '0 0 0', 1);
					if(!issilent)
						WarpZone_Sound(self, CHAN_PROJECTILE, "weapons/fireball_impact2.wav", VOL_BASE, ATTN_NORM * 0.25); // long range boom
				}
				break;
            case WEP_HAMMER:
                pointparticles(particleeffectnum("hagar_bounce"), org, backoff * 1000, 5);
                ImpactSound(self, strcat("weapons/hammer_impact", ftos(floor(random() * 3) + 1), ".wav"));
                break;
			default:
				dprint("Unhandled damage of weapon ", ftos(hitwep), "\n");
				break;
		}
	}
}

void DamageInfo_Precache()
{
	precache_sound("weapons/crylink_impact2.wav");
	precache_sound("weapons/crylink_impact.wav");
	precache_sound("weapons/electro_impact.wav");
	precache_sound("weapons/electro_impact_combo.wav");
	precache_sound("weapons/grenade_impact.wav");
	precache_sound("weapons/hagexp1.wav");
	precache_sound("weapons/hagexp2.wav");
	precache_sound("weapons/hagexp3.wav");
	precache_sound("weapons/flacexp1.wav");
	precache_sound("weapons/flacexp2.wav");
	precache_sound("weapons/flacexp3.wav");
	precache_sound("weapons/hookbomb_impact.wav");
	precache_sound("weapons/laserimpact.wav");
	precache_sound("weapons/neximpact.wav");
	precache_sound("weapons/ric1.wav");
	precache_sound("weapons/ric2.wav");
	precache_sound("weapons/ric3.wav");
	precache_sound("weapons/rocket_impact.wav");
	precache_sound("weapons/fireball_impact.wav");
	precache_sound("weapons/fireball_impact2.wav");
    precache_sound("weapons/hammer_impact1.wav");
    precache_sound("weapons/hammer_impact2.wav");
    precache_sound("weapons/hammer_impact3.wav");
	precache_sound(RM_SOUND_LASER_PRIMARY);
	precache_sound(RM_SOUND_LASER_SECONDARY);
	precache_sound(RM_SOUND_MINSTA);
}
