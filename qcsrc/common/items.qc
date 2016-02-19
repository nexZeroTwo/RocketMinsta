// WEAPON PLUGIN SYSTEM
entity weapon_info[24];
entity dummy_weapon_info;

void register_weapon_real(float id, float(float) func, float ammotype, float i, float normalweapon, float canclimb, float weapontype, float pickupbasevalue, string shortname, string wname, string shortcode, vector clr)
{
	entity e;
	weapon_info[id - 1] = e = spawn();
	e.classname = "weapon_info";
	e.weapon = id;
	e.weapons = power2of(id - 1);
	e.netname = shortname;
	e.message = wname;
    e.message2 = shortcode;
    e.w_color = clr;
	e.items = ammotype;
	e.weapon_func = func;
#ifdef SVQC
    var modelname = cvar_string("sv_weaponmodel_" + shortname);
	e.model = strzone(pickfile("models/weapons/g_" + modelname, "iqm", "md3", NULL));
	e.mdl = strzone(modelname);
#else
    // CSQC and MENUQC shouldn't need these
	e.model = NULL;
	e.mdl = NULL;
#endif
	e.spawnflags = 0;
	e.model2 = strzone(strcat("wpn-", e.mdl));
	if(normalweapon > 0)
		e.spawnflags |= WEPSPAWNFLAG_NORMAL;
	if(normalweapon < 0)
		e.spawnflags |= WEPSPAWNFLAG_HIDDEN;
	if(canclimb)
		e.spawnflags |= WEPSPAWNFLAG_CANCLIMB;
	e.impulse = i;
	e.weapon_type = weapontype;
	e.bot_pickupbasevalue = pickupbasevalue;
}
float w_null(float dummy)
{
	return 0;
}
void register_weapons_done()
{
	entity wi;

	dummy_weapon_info = spawn();
	dummy_weapon_info.classname = "weapon_info";
	dummy_weapon_info.weapon = 0; // you can recognize dummies by this
	dummy_weapon_info.weapons = 0; // you can recognize dummies by this too
	dummy_weapon_info.netname = "@!#%'n Tuba";
	dummy_weapon_info.items = 0;
	dummy_weapon_info.weapon_func = w_null;
	dummy_weapon_info.mdl = "";
	dummy_weapon_info.model = "";
	dummy_weapon_info.spawnflags = 0;
	dummy_weapon_info.impulse = -1;
	dummy_weapon_info.weapon_type = WEP_TYPE_OTHER;
	dummy_weapon_info.bot_pickupbasevalue = 0;
	dummy_weapon_info.model2 = "";

	float i;
	weaponpriority_hudselector_0 = "";
	for(i = 24; i >= 1; --i)
		if(weapon_info[i-1])
			weaponpriority_hudselector_0 = strcat(weaponpriority_hudselector_0, " ", ftos(i));

	float imp;
	weaponpriority_hudselector_1 = "";
	for(i = 1; i <= 24; ++i)
	{
		wi = weapon_info[i-1];
		if(wi && wi.impulse == 0)
			weaponpriority_hudselector_1 = strcat(weaponpriority_hudselector_1, " ", ftos(i));
	}
	for(imp = 9; imp > 0; --imp)
		for(i = 1; i <= 24; ++i)
		{
			wi = weapon_info[i-1];
			if(wi && wi.impulse == imp)
				weaponpriority_hudselector_1 = strcat(weaponpriority_hudselector_1, " ", ftos(i));
		}

	weaponpriority_hudselector_0 = strzone(substring(weaponpriority_hudselector_0, 1, strlen(weaponpriority_hudselector_0) - 1));
	weaponpriority_hudselector_1 = strzone(substring(weaponpriority_hudselector_1, 1, strlen(weaponpriority_hudselector_1) - 1));
}

entity get_weaponinfo(float id)
{
	entity w;
	if(id < WEP_FIRST || id > WEP_LAST)
		return dummy_weapon_info;
	w = weapon_info[id - 1];
	if(w)
		return w;
	return dummy_weapon_info;
}

entity find_weaponinfo(string shortname) {
    entity w;

    for(var i = 0; i <= WEP_LAST; ++i) {
        w = weapon_info[i];
        if(w.netname == shortname)
            return w;
    }

    return world;
}

string W_FixWeaponOrder(string order, float complete)
{
	return fixPriorityList(order, WEP_FIRST, WEP_LAST, 230 - WEP_FIRST, complete);
}

#ifdef SVQC
#define register_weapon(id,func,ammotype,i,normalweapon,canclimb,weapontype,pickupbasevalue,shortname,wname,shortcode,clr) \
	register_weapon_real(id,func,ammotype,i,normalweapon,canclimb,weapontype,pickupbasevalue,shortname,wname,shortcode,clr)
#else
// no weapon funcs here!
#define register_weapon(id,func,ammotype,i,normalweapon,canclimb,weapontype,pickupbasevalue,shortname,wname,shortcode,clr) \
	register_weapon_real(id,w_null,ammotype,i,normalweapon,canclimb,weapontype,pickupbasevalue,shortname,wname,shortcode,clr)
#endif

void RegisterWeapons()
{
    // %weaponaddpoint
    register_weapon(WEP_LASER,            w_laser,        0,                1,  1, 1, WEP_TYPE_SPLASH,  0,                      "laser",           "Laser", "L", '1.0 0.5 0.0');
    register_weapon(WEP_SHOTGUN,          w_shotgun,      IT_SHELLS,        2,  1, 0, WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW,  "shotgun",         "Shotgun", "S", '0.2 1.0 0.2');
    register_weapon(WEP_UZI,              w_uzi,          IT_NAILS,         3,  1, 0, WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_MID,  "uzi",             "Machine Gun", "M", '1.0 0.7 0.2');
    register_weapon(WEP_GRENADE_LAUNCHER, w_glauncher,    IT_ROCKETS,       4,  1, 1, WEP_TYPE_SPLASH , BOT_PICKUP_RATING_MID,  "grenadelauncher", "Mortar", "G", '1.0 0.4 0.5');
    register_weapon(WEP_ELECTRO,          w_electro,      IT_CELLS,         5,  1, 0, WEP_TYPE_SPLASH , BOT_PICKUP_RATING_MID,  "electro",         "Electro", "E", '0.1 1.0 1.0');
    register_weapon(WEP_CRYLINK,          w_crylink,      IT_CELLS,         6,  1, 0, WEP_TYPE_SPLASH , BOT_PICKUP_RATING_MID,  "crylink",         "Crylink", "C", '1.0 0.3 0.9');
    register_weapon(WEP_NEX,              w_nex,          IT_CELLS,         7,  1, 0, WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_HIGH, "nex",             "Nex", "N", '1.0 0.3 0.3');
    register_weapon(WEP_HAGAR,            w_hagar,        IT_ROCKETS,       8,  1, 1, WEP_TYPE_SPLASH , BOT_PICKUP_RATING_MID,  "hagar",           "Hagar", "H", '1.0 0.5 0.0');
    register_weapon(WEP_ROCKET_LAUNCHER,  w_rlauncher,    IT_ROCKETS,       9,  1, 1, WEP_TYPE_SPLASH , BOT_PICKUP_RATING_HIGH, "rocketlauncher",  "Rocket Launcher", "R", '1.0 0.2 0.2');
    register_weapon(WEP_PORTO,            w_porto,        0,                0,  0, 0, WEP_TYPE_OTHER,   0,                      "porto",           "Port-O-Launch", "P", '0.5 0.5 0.5');
    register_weapon(WEP_MINSTANEX,        w_minstanex,    IT_CELLS,         7, -1, 1, WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_HIGH, "minstanex",       "MinstaNex", "Mn", '0.5 0.5 0.5');
    register_weapon(WEP_HOOK,             w_hook,         IT_CELLS|IT_FUEL, 0,  0, 1, WEP_TYPE_SPLASH,  0,                      "hook",            "Grappling Hook", "Hk", '0.5 0.5 0.5');
    register_weapon(WEP_HLAC,             w_hlac,         IT_CELLS,         6,  1, 0, WEP_TYPE_SPLASH,  BOT_PICKUP_RATING_MID,  "hlac",            "Heavy Laser Assault Cannon", "A", '1.0 0.4 0.5');
    register_weapon(WEP_TUBA,             w_tuba,         0,                1, -1, 0, WEP_TYPE_SPLASH,  BOT_PICKUP_RATING_MID,  "tuba",            "@!#%'n Tuba", "T", '1.0 1.0 0.0');
    register_weapon(WEP_CAMPINGRIFLE,     w_campingrifle, IT_NAILS,         3,  1, 0, WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_MID,  "campingrifle",    "Rifle", "Cr", '0.7 0.7 0.7');
    register_weapon(WEP_FIREBALL,         w_fireball,     IT_ROCKETS,       9,  0, 0, WEP_TYPE_SPLASH,  BOT_PICKUP_RATING_MID,  "fireball",        "Fireball", "F", '1.0 1.0 0.2');
    register_weapon(WEP_ZAPPER,           w_zapper,       IT_CELLS,         5,  1, 0, WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_MID,  "zapper",          "Zapper", "Z", '0.1 1.0 1.0');
    register_weapon(WEP_FLAK,             w_flak,         IT_SHELLS,        8,  1, 0, WEP_TYPE_SPLASH,  BOT_PICKUP_RATING_MID,  "flak",            "Flak Cannon", "F", '1.0 1.0 0.0');
    register_weapon(WEP_PRYAXE,           w_pryaxe,       0,                1,  1, 0, WEP_TYPE_HITSCAN, 0,                      "pryaxe",          "Pryaxe", "A", '0.8 0.8 0.8');

    register_weapons_done();
}
