
//
// maybe later: client-side weapon functions like in xonotic instead of these switches
//

string WeaponSuicideString(float deathtype) {
    float w = DEATH_WEAPONOFWEAPONDEATH(deathtype);

    switch(w) {
        case WEP_LASER:
            return "lasered himself to hell";

        case WEP_SHOTGUN:
            return "did the impossible";

        case WEP_UZI:
            return "did the impossible";

        case WEP_GRENADE_LAUNCHER:
            if(deathtype & HITTYPE_SECONDARY)
                return "tried out his own grenade";
            else
                return "detonated";

        case WEP_ELECTRO:
            if(deathtype & HITTYPE_SECONDARY)
                return "could not remember where he put plasma";
            else
                return "played with plasma";

        case WEP_CRYLINK:
            return "succeeded at self-destructing himself with the Crylink";

        case WEP_NEX:
            return "did the impossible";

        case WEP_HAGAR:
            return "played with tiny rockets";

        case WEP_ROCKET_LAUNCHER:
            return "exploded";

        case WEP_PORTO:
            return "did the impossible";

        case WEP_MINSTANEX:
            return "should have used a smaller gun";

        case WEP_HOOK:
            return "did the impossible";

        case WEP_HLAC:
            return "should have used a smaller gun";

        case WEP_SEEKER:
            return "played with tiny rockets";

        case WEP_TUBA:
            return "hurt his own ears with the @!#%'n Tuba";

        case WEP_CAMPINGRIFLE:
            if(deathtype & HITTYPE_SECONDARY)
                return "shot himself automatically";
            else
                return "sniped himself somehow";

        case WEP_FIREBALL:
            if(deathtype & HITTYPE_SECONDARY)
                return "should have used a smaller gun";
            else
                return "forgot about some firemine";

        case WEP_ZAPPER:
            return "zapped himself";

        case WEP_FLAK:
            return "was mutilated by his own Flak Cannon";

        //
        // Nadgets
        //

        case HG_NAPALM:
            return "played with fire";

        default:
            return "couldn't resist the urge to self-destruct";
    }
}

string WeaponDeathString(float deathtype) {
    float w = DEATH_WEAPONOFWEAPONDEATH(deathtype);

    switch(w) {
        case WEP_LASER:
            return "was lasered to death by";

        case WEP_SHOTGUN:
            return "was gunned by";

        case WEP_UZI:
            if(deathtype & HITTYPE_SECONDARY)
                return "was sniped by";
            else
                return "was riddled full of holes by";

        case WEP_GRENADE_LAUNCHER:
            if(deathtype & HITTYPE_SPLASH) {
                if(deathtype & HITTYPE_BOUNCE)
                    return "didn't see #'s grenade";
                else
                    return "almost dodged #'s grenade";
            } else
                return "ate #'s grenade";

        case WEP_ELECTRO:
            if(deathtype & HITTYPE_SECONDARY) {
                if(deathtype & HITTYPE_SPLASH)
                    return "just noticed #'s blue ball";
                else
                    return "got in touch with #'s blue ball";
            } else {
                if(!g_minstagib) {
                    if(deathtype & HITTYPE_BOUNCE) // combo
                        return "felt the electrifying air of #'s combo";
                    else if(deathtype & HITTYPE_SPLASH)
                        return "got too close to #'s blue beam";
                    else
                        return "was blasted by #'s blue beam";
                } else
                    return "was blasted by #'s laser";
            }

        case WEP_CRYLINK:
            if(deathtype & HITTYPE_BOUNCE)
                return "could not hide from #'s Crylink";
            else if(deathtype & HITTYPE_SPLASH)
                return "was too close to #'s Crylink";
            else
                return "took a close look at #'s Crylink";

        case WEP_NEX:
            return "has been vaporized by";

        case WEP_HAGAR:
            if(deathtype & HITTYPE_BOUNCE)
                return "hoped #'s missiles wouldn't bounce";
            else
                return "was pummeled by";

        case WEP_ROCKET_LAUNCHER:
            if(!g_minstagib) {
                if(deathtype & HITTYPE_BOUNCE) // (remote detonation)
                    return "got too close to #'s rocket";
                else if(deathtype & HITTYPE_SPLASH)
                    return "almost dodged #'s rocket";
                else
                    return "ate #'s rocket";
            } else
                return "has been blown up by #";

        case WEP_PORTO:
            return "felt # doing the impossible to him";

        case WEP_MINSTANEX:
            return "has been vaporized by";

        case WEP_HOOK:
            return "has run into #'s gravity bomb";

        case WEP_HLAC:
            return "was cut down by";

        case WEP_SEEKER:
            if(deathtype & HITTYPE_SECONDARY)
                return "ran into #'s flac";
            else
                return "was tagged by";

        case WEP_TUBA:
            return "died of #'s great playing on the @!#%'n Tuba";

        case WEP_CAMPINGRIFLE:
            if(deathtype & HITTYPE_SECONDARY) {
                if(deathtype & HITTYPE_BOUNCE)
                    return "failed to hide from #'s bullet hail";
                else
                    return "died in #'s bullet hail";
            } else {
                if(deathtype & HITTYPE_BOUNCE) {
                    // TODO special headshot message here too?
                    return "failed to hide from #'s rifle";
                } else {
                    if(deathtype & HITTYPE_HEADSHOT)
                        return "got hit in the head by #";
                    else
                        return "was sniped by #";
                }
            }

        case WEP_FIREBALL:
            if(deathtype & HITTYPE_SECONDARY) {
                if(deathtype & HITTYPE_BOUNCE) {
                    if(deathtype & HITTYPE_SPLASH) // BFG effect
                        return "could not hide from #'s fireball";
                    else // laser
                        return "saw the pretty lights of #'s fireball";
                } else if(deathtype & HITTYPE_SPLASH)
                    return "got too close to #'s fireball";
                else
                    return "tasted #'s fireball";
            } else {
                if(deathtype & HITTYPE_HEADSHOT)
                    return "tried to catch #'s firemine";
                else
                    return "fatefully ignored #'s firemine";
            }

        case WEP_ZAPPER:
            if(deathtype & HITTYPE_SECONDARY) {
                if(deathtype & HITTYPE_BOUNCE)
                    return "couldn't hide from #'s chain lightning";
                else
                    return "was struck by #'s lightning bolt";
            } else
                return "has been zapped by";

        case WEP_FLAK:
            if(deathtype & HITTYPE_BOUNCE)
                return "could not hide from #'s Flak Cannon";
            else if(deathtype & HITTYPE_SPLASH)
                return "was blown away by #'s Flak Cannon";
            else
                return "was shredded by #'s Flak Cannon";

        //
        // Nadgets
        //

        case HG_NORMAL:
            return "didn't notice #'s grenade";

        case HG_REMOTE:
            if(deathtype & HITTYPE_SECONDARY)
                return "was incinerated by #'s fire trap";
            else
                return "fell for #'s trap";

        case HG_PLASMA:
            if(deathtype & HITTYPE_SECONDARY)
                return "took a walk over #'s hot plasma";
            else
                return "was blasted by #'s plasma bomb";

        case HG_SHIELD:
            return "suffered from death feedback induced by #'s reflective shield";

        case HG_GG:
            return "has been outskilled by #'s gg button, gg!";

        case HG_LASER:
            return "took #'s blazing charge";

        case HG_BAIT:
            return "took #'s bait";

        default:
            return "was blasted by";
    }
}

void Message_Obituary(float targ, float attacker, float deathtype, string customMessage, float attackerSpree, float targetSpree, float attackerSpreeShort) {
    string tname = GetPlayerName(targ - 1);
    string aname = GetPlayerName(attacker - 1);
    float teamkill, suicide;

    float tteam = GetPlayerColorForce(targ - 1);
    float ateam = GetPlayerColorForce(attacker - 1);

    float me = ID_ME;
    float iKilled = (attacker == me);
    float iDied = (targ == me);

    string s = tname;
    string a = aname;

    float spawnfrag = FALSE;

    float extendfragmessages = CVAR(cl_extendfragmessages);

    if(targ == attacker)
        suicide = TRUE;
    else if(teamplay)
        teamkill = (tteam == ateam);

    if(suicide) {
        if(iDied) {
            if(deathtype == DEATH_TEAMCHANGE) {
                centerprint(strcat("You are now on: ", ColoredTeamName(tteam)));
            } else if(deathtype == DEATH_AUTOTEAMCHANGE) {
                centerprint(strcat("You have been moved into a different team to improve team balance\nYou are now on: ", ColoredTeamName(tteam)));
            } else if(deathtype == DEATH_CAMP) {
                centerprint("^1Die camper!");
            } else if(deathtype == DEATH_NOAMMO) {
                centerprint("^1You were killed for running out of ammo...");
            } else if(deathtype == DEATH_ROT) {
                centerprint("^1You grew too old without taking your medicine");
            } else if(deathtype == DEATH_MIRRORDAMAGE) {
                centerprint("^1Don't shoot your team mates!");
            } else if(deathtype == DEATH_NOISE) {
                centerprint("^1You were too noisy to live");
            } else {
                centerprint("^1You killed your own dumb self!");
            }
        }

        float w = DEATH_WEAPONOFWEAPONDEATH(deathtype);
        
        if(WEP_VALID(w) || DEATH_ISHG(w)) {
            print("^1", s, "^1 ", WeaponSuicideString(deathtype), "\n");
        } else if(deathtype == DEATH_KILL)
            print("^1", s, "^1 couldn't take it anymore\n");
        else if(deathtype == DEATH_ROT)
            print("^1", s, "^1 died\n");
        else if(deathtype == DEATH_NOAMMO)
            print("^7", s, "^7 committed suicide. What's the point of living without ammo?\n");
        else if(deathtype == DEATH_CAMP)
            print("^1", s, "^1 thought he found a nice camping ground\n");
        else if(deathtype == DEATH_MIRRORDAMAGE)
            print("^1", s, "^1 didn't become friends with the Lord of Teamplay\n");
        else if(deathtype == DEATH_CHEAT)
            print("^1", s, "^1 unfairly eliminated himself\n");
        else if(deathtype == DEATH_FIRE)
            print("^1", s, "^1 burned to death\n");
        else if(deathtype == DEATH_NOISE)
            print("^1", s, "^1 was too noisy to live\n");
        else if(deathtype != DEATH_TEAMCHANGE)
            print("^1", s, "^1 couldn't resist the urge to self-destruct\n");

        if(targetSpree > 2 && deathtype != DEATH_AUTOTEAMCHANGE)
            print("^1", s, "^1 ended it all after a ", ftos(targetSpree), " kill spree\n");
    } else if(attacker) {
        if(teamkill) {
            if(iKilled)
                centerprint(strcat("^1Moron! You fragged ", s, "^1, a team mate!"));
            else if(iDied)
                centerprint(strcat("^1You were fragged by ^7", a, "^1, the teamkilling moron"));

            print("^1", a, "^1 mows down a team mate\n");

            if(targetSpree > 2)
                print("^1", s, "'s ^1", ftos(targetSpree), " kill spree was ended by a team mate!\n");

            if(attackerSpree > 2)
                print("^1", a, "^1 ended a ", ftos(attackerSpree), " kill spree by killing a team mate\n");
        } else {
            if(iKilled || iDied) {
                string fragmod, fragmod_tail;

                if(spawnfrag) {
                    fragmod = "^2spawn";
                } else if(extendfragmessages) {
                    if(g_minstagib && CVAR(_g_rocketminsta)) {    // g_rocketminsta bullshit
                        if(DEATH_ISWEAPON(deathtype, WEP_LASER) || DEATH_ISWEAPON(deathtype, WEP_ELECTRO)) {
                            if(iKilled)
                                announce("awesome.wav");

                            fragmod = "^xF80laser";
                        } else if(deathtype == DEATH_HOOKFRAG) {
                            if(iKilled) {                            
                                announce("awesome.wav");
                                bigprint("Holy ^1Shit", "Awesome frag", 1);
                            }

                            fragmod = "^7hook";
                        } else if(DEATH_ISWEAPON(deathtype, WEP_MINSTANEX)) {
                            fragmod = "^5insta";
                        }
                    } else if(!g_minstagib) {
                        fragmod_tail = DamageTracker_DamageSourceName(deathtype, FALSE);
                            
                        if(fragmod_tail != "")
                            fragmod_tail = strcat(" with ^7", fragmod_tail);
                    }
                }

                if(iKilled)
                    centerprint(strcat("^4You ", fragmod, "^4fragged ^7", s, "^4", fragmod_tail));
                else if(iDied)
                    centerprint(strcat("^1You were ", fragmod, "^1fragged by ^7", a, "^1", fragmod_tail));
            }

                float w = DEATH_WEAPONOFWEAPONDEATH(deathtype);

                if(WEP_VALID(w) || DEATH_ISHG(w)) {
                    string w_deathtypestring = WeaponDeathString(deathtype);
                    float p = strstrofs(w_deathtypestring, "#", 0);
                    if(p < 0)
                        print("^1", s, "^1 ", w_deathtypestring, " ", a, "\n");
                    else
                        print("^1", s, "^1 ", substring(w_deathtypestring, 0, p), a, "^1", substring(w_deathtypestring, p+1, strlen(w_deathtypestring) - (p+1)), "\n");
                }
                else if(deathtype == DEATH_TELEFRAG || deathtype == HG_TRANSLOC)
                    print("^1", s, "^1 was telefragged by ", a, "\n");
                else if(deathtype == DEATH_DROWN)
                    print("^1", s, "^1 was drowned by ", a, "\n");
                else if(deathtype == DEATH_SLIME)
                    print("^1", s, "^1 was slimed by ", a, "\n");
                else if(deathtype == DEATH_LAVA)
                    print("^1", s, "^1 was cooked by ", a, "\n");
                else if(deathtype == DEATH_FALL)
                    print("^1", s, "^1 was grounded by ", a, "\n");
                else if(deathtype == DEATH_SHOOTING_STAR)
                    print("^1", s, "^1 was shot into space by ", a, "\n");
                else if(deathtype == DEATH_SWAMP)
                    print("^1", s, "^1 was conserved by ", a, "\n");
                else if(deathtype == DEATH_HOOKFRAG)
                    print("^1", s, "^1 was hookfragged by ", a, "\n");
                else if(deathtype == DEATH_HURTTRIGGER && customMessage) {
                    float p = strstrofs(customMessage, "#", 0);
                    if(p < 0)
                        print("^1", s, "^1 ", customMessage, " ", a, "\n");
                    else
                        print("^1", s, "^1 ", substring(customMessage, 0, p), a, "^1", substring(customMessage, p+1, strlen(customMessage) - (p+1)), "\n");
                }
                else if(deathtype == DEATH_TURRET)
                    print("^1", s, "^1 was pushed into the line of fire by ^1", a, "\n");
                else if(deathtype == DEATH_TOUCHEXPLODE)
                    print("^1", s, "^1 was pushed into an accident by ^1", a, "\n");
                else if(deathtype == DEATH_CHEAT)
                    print("^1", s, "^1 was unfairly eliminated by ^1", a, "\n");
                else if(deathtype == DEATH_FIRE)
                    print("^1", s, "^1 was burnt to death by ^1", a, "\n");
                else if(deathtype == DEATH_MEODP)
                        print("^1", s, "^1 exposed his sensitive spot to ", a, "^1's Mystic Eyes of Death Perception\n");
                else
                    print("^1", s, "^1 was fragged by ", a, "\n");

                if(targetSpree > 2)
                    print("^1", s, "'s ^1", ftos(targetSpree), " kill spree was ended by ", a, "\n");

                // server sends this message before registering the spree
                ++attackerSpree;

                if(attackerSpree > 2)
                    print("^1", a, "^1 has ", ftos(attackerSpree), " frags in a row\n");

                Message_KillingSpree(attacker, attackerSpree, attackerSpreeShort);
        }
    } else {
        if(iDied)
            centerprint("^1Watch your step!");

        if(deathtype == DEATH_HURTTRIGGER && customMessage != "")
            print("^1", s, "^1 ", customMessage, "\n");
        else if(deathtype == DEATH_DROWN)
            print("^1", s, "^1 drowned\n");
        else if(deathtype == DEATH_SLIME)
            print("^1", s, "^1 was slimed\n");
        else if(deathtype == DEATH_LAVA)
            print("^1", s, "^1 turned into hot slag\n");
        else if(deathtype == DEATH_FALL)
            print("^1", s, "^1 hit the ground with a crunch\n");
        else if(deathtype == DEATH_SHOOTING_STAR)
            print("^1", s, "^1 became a shooting star\n");
        else if(deathtype == DEATH_SWAMP)
            print("^1", s, "^1 is now conserved for centuries to come\n");
        else if(deathtype == DEATH_TURRET)
            print("^1", s, "^1 was mowed down by a turret \n");
        else if(deathtype == DEATH_TOUCHEXPLODE)
            print("^1", s, "^1 died in an accident\n");
        else if(deathtype == DEATH_CHEAT)
            print("^1", s, "^1 was unfairly eliminated\n");
        else if(deathtype == DEATH_FIRE)
            print("^1", s, "^1 burnt to death\n");
        else if(getstati(STAT_ROUNDSTATE) != ROUNDSTATE_OVER)
            print("^1", s, "^1 died\n");

        if(targetSpree > 2)
            print("^1", s, "^1 died with a ", ftos(targetSpree), " kill spree\n");
    }
}

void Message_KillingSpree(float attacker, float longspree, float shortspree) {
    float me = ID_ME;
    float iKilled = (me == attacker);

    string a = GetPlayerName(attacker - 1);

    if(longspree == 5) {
        print(a, "^7 unleashes ^1RAGE\n");

        if(iKilled) {
            announce("05kills.wav");
            bigprint("^xFA0Rage!", strcat(ftos(longspree), " frags in a row"), 1);
        }
    } else if(longspree == 10) {
        print(a, "^7 starts the ^1MASSACRE!\n");

        if(iKilled) {
            announce("10kills.wav");
            bigprint("^xF80Massacre!", strcat(ftos(longspree), " frags in a row"), 1);
        }
    } else if(longspree == 15) {
        print(a, "^7 executes ^1MAYHEM!\n");

        if(iKilled) {
            announce("15kills.wav");
            bigprint("^xF60Mayhem!", strcat(ftos(longspree), " frags in a row"), 1);
        }
    } else if(longspree == 20) {
        print(a, "^7 is a ^1BERSERKER!\n");

        if(iKilled) {
            announce("20kills.wav");
            bigprint("^xF40Berserker!", strcat(ftos(longspree), " frags in a row"), 1);
        }
    } else if(longspree == 25) {
        print(a, "^7 inflicts ^1CARNAGE!\n");

        if(iKilled) {
            announce("25kills.wav");
            bigprint("^xF20Carnage!", strcat(ftos(longspree), " frags in a row"), 1);
        }
    } else if(longspree == 30) {
        print(a, "^7 unleashes ^1ARMAGEDDON!\n");

        if(iKilled) {
            announce("30kills.wav");
            bigprint("^1Armageddon!", strcat(ftos(longspree), " frags in a row"), 1);
        }
    } else if(longspree == 50) {
        print(a, "^7 is ^1BOTLIKE!\n");

        if(iKilled) {
            announce("botlike.wav");
            bigprint("^1Botlike!", strcat(ftos(longspree), " frags in a row"), 1);
        }
    }

    if(shortspree < 2)
        return;

    string spreebar = "^1\xee\x80\x9d\xee\x80\x9e";
    float i = 2;

    while(i < 5) {
        if(shortspree == i)
            spreebar = strcat(spreebar, "^0\xee\x80\x9e\xee\x80\x9e");
        else
            spreebar = strcat(spreebar, "\xee\x80\x9e\xee\x80\x9e");

        ++i;
    }

    if(shortspree - 1 >= 5)
        spreebar = strcat(spreebar, "\xee\x80\x9e\xee\x80\x9f");
    else
        spreebar = strcat(spreebar, "^0\xee\x80\x9e\xee\x80\x9f");

    switch(shortspree) {
        case 2:
            if(iKilled) bigprint("^2Double ^7Kill!", spreebar, 1);
            print(a, " ^7scored a ^2DOUBLE ^7KILL!\n");
            break;
        case 3:
            if(iKilled) bigprint("^3Triple ^7Kill!", spreebar, 1);
            print(a, " ^7scored a ^3TRIPLE ^7KILL!\n");
            break;
        case 4:
            if(iKilled) bigprint("^6Quad ^7Kill!", spreebar, 1);
            print(a, " ^7scored a ^6QUAD ^7KILL!\n");
            break;
        case 5:
            if(iKilled) bigprint("^5Ultra ^7Kill!", spreebar, 1);
            print(a, " ^7scored an ^5ULTRA ^7KILL!\n");
            break;
        default: case 6:
            if(iKilled) bigprint("^1Monster ^7Kill!", spreebar, 1);
            print(a, " ^7scored a ^1MONSTER ^7KILL!\n");
            break;
    }

    if(iKilled)
        sound(world, CHAN_AUTO, "porto/fire.wav", VOL_BASE, ATTN_NONE);
}

void Message_Read(void) {
    float type = ReadByte();

    switch(type) {
        case CSQCMSG_OBITUARY:
        case CSQCMSG_OBITUARY_CUSTOM: {
            float targ = ReadByte();
            float attacker = ReadByte();
            float deathtype = ReadShort();
            string customMessage;

            if(type == CSQCMSG_OBITUARY_CUSTOM)
                customMessage = ReadString();

            float attackerSpree = ReadByte();
            float targetSpree = ReadByte();
            float attackerSpreeShort = ReadByte();

            Message_Obituary(targ, attacker, deathtype, customMessage, attackerSpree, targetSpree, attackerSpreeShort);
            break;
        }

        default: {
            error(strcat("Invalid CSQC message received: ", ftos(type)));
            break;
        }
    }
}
