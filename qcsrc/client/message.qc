
string WeaponSuicideString(float deathtype) {
    // TODO: weapon-specific suicide strings here
    return "couldn't resist the urge to self-destruct";
}

string WeaponDeathString(float deathtype) {
    // TODO: weapon-specific frag strings here
    return "was blasted by";
}

void Message_Obituary(float targ, float attacker, float deathtype, string customMessage) {
    string tname = GetPlayerName(targ - 1);
    string aname = GetPlayerName(attacker - 1);
    float teamkill, suicide;

    float tteam = GetPlayerColorForce(targ - 1);
    float ateam = GetPlayerColorForce(attacker - 1);

    float me = ((spectatee_status > 0)? spectatee_status : player_localentnum);
    float iKilled = (attacker == me);
    float iDied = (targ == me);

    string s = tname;
    string a = aname;

    float spawnfrag = FALSE;

    // TODO: client setting for this
    float extendfragmessages = TRUE;

    if(targ == attacker)
        suicide = TRUE;
    else if(teamplay)
        teamkill = (tteam == ateam);

    print("^5 -- ^6CSQC OBITUARY FOLLOWS ^5 --\n");
    //print("^1", tname, "^1 fragged ", aname, "^1 with ", ftos(deathtype), "\n");

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

        float w = DEATH_WEAPONOF(deathtype);
        if(WEP_VALID(w)) {
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
        else if(deathtype == DEATH_HG_NAPALM)
            print("^1", s, "^1 played with fire\n");
        else if(deathtype == DEATH_NOISE)
            print("^1", s, "^1 was too noisy to live\n");
        else if(deathtype != DEATH_TEAMCHANGE)
            print("^1", s, "^1 couldn't resist the urge to self-destruct\n");
    } else if(attacker) {
        if(teamkill) {
            if(iKilled)
                centerprint(strcat("^1Moron! You fragged ", s, "^1, a team mate!"));
            else if(iDied)
                centerprint(strcat("^1You were fragged by ^7", a, "^1, the teamkilling moron"));

            print("^1", a, "^1 mows down a team mate\n");
        } else {
            if(iKilled || iDied) {
                string fragmod, fragmod_tail;

                if(spawnfrag) {
                    fragmod = "^2spawn";
                } else if(extendfragmessages) {
                    if(g_minstagib) {    // g_rocketminsta bullshit
                        if(DEATH_ISWEAPON(deathtype, WEP_LASER) || DEATH_ISWEAPON(deathtype, WEP_ELECTRO))
                            fragmod = "^xF80laser";
                        else if(deathtype == DEATH_HOOKFRAG)
                            fragmod = "^7hook";
                        else if(DEATH_ISWEAPON(deathtype, WEP_MINSTANEX))
                            fragmod = "^5insta";
                    } else {
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

                float w = DEATH_WEAPONOF(deathtype);
                if(WEP_VALID(w)) {
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
                else if(deathtype == DEATH_HG_NORMAL)
                    print("^1", s, "^1 didn't notice ", a, "^1's grenade\n");
                else if(deathtype == DEATH_HG_NAPALM)
                    print("^1", s, "^1 engaged in ", a, "^1's hot napalm action\n");
                else if(deathtype == DEATH_HG_REMOTE) {
                    /*
                    if(targ == inflictor)   // fire damage does this
                        print("^1", s, "^1 was incinerated by ", a, "^1's fire trap\n");
                    else
                    */
                        print("^1", s, "^1 fell for ", a, "^1's trap\n");
                } else if(deathtype == DEATH_HG_PLASMA)
                    print("^1", s, "^1 was blasted by ", a, "^1's plasma bomb\n");
                else if(deathtype == DEATH_HG_PLASMA_SHARD)
                    print("^1", s, "^1 took a walk over ", a, "^1's hot plasma\n");
                else if(deathtype == DEATH_HG_SHIELD)
                    print("^1", s, "^1 suffered from death feedback induced by ", a, "^1's reflective shield\n");
                else if(deathtype == DEATH_HG_GG)
                    print("^1", s, "^1 has been outskilled by ", a, "^1's gg button, gg!\n");
                else if(deathtype == DEATH_HG_LASER)
                    print("^1", s, "^1 took ", a, "^1's blazing charge\n");
                else if(deathtype == DEATH_MEODP)
                    print("^1", s, "^1 exposed his sensitive spot to ", a, "^1's Mystic Eyes of Death Perception\n");
                else if(deathtype == DEATH_HG_BAIT)
                    print("^1", s, "^1 took ", a, "^1's bait\n");
                else
                    print("^1", s, "^1 was fragged by ", a, "\n");
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
    }
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

            Message_Obituary(targ, attacker, deathtype, customMessage);
            break;
        }

        default: {
            error(strcat("Invalid CSQC message received: ", ftos(type)));
            break;
        }
    }
}
