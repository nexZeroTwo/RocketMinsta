
string HG_TypeToExpandedName(float t) {
	switch(t) {
		case HG_NORMAL      :   return "Hand Grenade";
		case HG_NAPALM      :   return "Napalm Grenade";
		case HG_REMOTE      :   return "Fire Trap";
        case HG_PLASMA      :   return "Plasma Bomb";
        case HG_PLASMA_SHARD:   return "Plasma Bomb";
        case HG_TRANSLOC    :   return "Translocator";
        case HG_SHIELD      :   return "Reflective Shield";
		default             :   return "Fuckoff Grenade";
	}
}

string HG_TypeToName(float t) {
	switch(t) {
		case HG_NORMAL      :   return "normal";
		case HG_NAPALM      :   return "napalm";
		case HG_REMOTE      :   return "remote";
        case HG_PLASMA      :   return "plasma";
        case HG_TRANSLOC    :   return "transloc";
        case HG_SHIELD      :   return "shield";
		default             :   return strcat("fuckoff", ftos(t));
	}
}

float HG_NameToType(string t) {
	switch(t) {
		case "napalm"       :   return HG_NAPALM;
        case "remote"       :   return HG_REMOTE;
        case "plasma"       :   return HG_PLASMA;
        case "transloc"     :   return HG_TRANSLOC;
        case "shield"       :   return HG_SHIELD;
		default             :   return HG_NORMAL;
	}
}

string HG_NameToExpandedName(string t) {
    return HG_TypeToExpandedName(HG_NameToType(t));
}

vector HG_TypeToColor(float t) {
    switch(t) {
        case HG_NORMAL:     return '0.2 1 0.2';
        case HG_NAPALM:     return '1 0.5 0';
        case HG_REMOTE:     return '1 0.3 0.3';
        case HG_PLASMA:     return '0.1 1 1';
        case HG_TRANSLOC:   return '1 0.1 1';
        case HG_SHIELD:     return '1 1 0';
        default:            return '0.5 0.5 0.5';
    }
}
