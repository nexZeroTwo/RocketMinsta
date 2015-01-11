
string WeaponSuicideString(float deathtype) {
    // TODO: weapon-specific suicide strings here
    return "couldn't resist the urge to self-destruct";
}

string WeaponDeathString(float deathtype) {
    // TODO: weapon-specific frag strings here
    return "was blasted by";
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
                    if(g_minstagib && cvar("_g_rocketminsta")) {    // g_rocketminsta bullshit
                        if(DEATH_ISWEAPON(deathtype, WEP_LASER) || DEATH_ISWEAPON(deathtype, WEP_ELECTRO)) {
                            if(iKilled)
                                announce("announcer/male/awesome.wav");

                            fragmod = "^xF80laser";
                        } else if(deathtype == DEATH_HOOKFRAG) {
                            if(iKilled) {                            
                                announce("announcer/male/awesome.wav");
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
            announce("announcer/male/05kills.wav");
            bigprint("^xFA0Rage!", strcat(ftos(longspree), " frags in a row"), 1);
        }
    } else if(longspree == 10) {
        print(a, "^7 starts the ^1MASSACRE!\n");

        if(iKilled) {
            announce("announcer/male/10kills.wav");
            bigprint("^xF80Massacre!", strcat(ftos(longspree), " frags in a row"), 1);
        }
    } else if(longspree == 15) {
        print(a, "^7 executes ^1MAYHEM!\n");

        if(iKilled) {
            announce("announcer/male/15kills.wav");
            bigprint("^xF60Mayhem!", strcat(ftos(longspree), " frags in a row"), 1);
        }
    } else if(longspree == 20) {
        print(a, "^7 is a ^1BERSERKER!\n");

        if(iKilled) {
            announce("announcer/male/20kills.wav");
            bigprint("^xF40Berserker!", strcat(ftos(longspree), " frags in a row"), 1);
        }
    } else if(longspree == 25) {
        print(a, "^7 inflicts ^1CARNAGE!\n");

        if(iKilled) {
            announce("announcer/male/25kills.wav");
            bigprint("^xF20Carnage!", strcat(ftos(longspree), " frags in a row"), 1);
        }
    } else if(longspree == 30) {
        print(a, "^7 unleashes ^1ARMAGEDDON!\n");

        if(iKilled) {
            announce("announcer/male/30kills.wav");
            bigprint("^1Armageddon!", strcat(ftos(longspree), " frags in a row"), 1);
        }
    }

    if(shortspree < 2)
        return;

    string spreebar = "^1\x1d\x1e";
    float i = 2;

    while(i < 5) {
        if(shortspree == i)
            spreebar = strcat(spreebar, "^0\x1e\x1e");
        else
            spreebar = strcat(spreebar, "\x1e\x1e");

        ++i;
    }

    if(shortspree - 1 >= 5)
        spreebar = strcat(spreebar, "\x1e\x1f");
    else
        spreebar = strcat(spreebar, "^0\x1e\x1f");

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
