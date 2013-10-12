
string Buffs_TypeToName(float buff) {
    switch(buff) {
        case BUFF_ARC       :      return "arc";
        case BUFF_SUPPLY    :      return "supply";
        case BUFF_GUARD     :      return "guard";
        case BUFF_HASTE     :      return "haste";
        case BUFF_MEDIC     :      return "medic";
        default             :      return "unknown";
    }
}

float Buffs_NameToType(string name) {
    switch(name) {
        case "arc"          :      return BUFF_ARC;
        case "supply"       :      return BUFF_SUPPLY;
        case "guard"        :      return BUFF_GUARD;
        case "haste"        :      return BUFF_HASTE;
        case "medic"        :      return BUFF_MEDIC;
        default             :      return 0;
    }
}

string Buffs_TypeToExpandedName(float buff) {
    switch(buff) {
        case BUFF_ARC       :      return "Arc";
        case BUFF_SUPPLY    :      return "Supply";
        case BUFF_GUARD     :      return "Guard";
        case BUFF_HASTE     :      return "Haste";
        case BUFF_MEDIC     :      return "Medic";
        default             :      return "Unknown";
    }
}

string Buffs_NameToExpandedName(string t) {
    return Buffs_TypeToExpandedName(Buffs_NameToType(t));
}

float Buffs_TypeToPaletteColor(float buff) {
    switch(buff) {
        case BUFF_ARC       :      return 0xF5;
        case BUFF_SUPPLY    :      return 0x3E;
        case BUFF_GUARD     :      return 0xD0;
        case BUFF_HASTE     :      return 0xFC;
        case BUFF_MEDIC     :      return 0x90;
        default             :      return 0x00;
    }
}

vector Buffs_TypeToColor(float buff) {
    switch(buff) {
        case BUFF_ARC       :      return '0.2 0.7 1.0';
        case BUFF_SUPPLY    :      return '0.2 1.0 0.2';
        case BUFF_GUARD     :      return '0.3 0.2 1.0';
        case BUFF_HASTE     :      return '1.0 0.9 0.2';
        case BUFF_MEDIC     :      return '1.0 0.3 1.0';
        default             :      return '0.0 0.0 0.0';
    }
}

float Buffs_TypeToIndex(float buff) {
    float b, i;
    for(b = BUFF_FIRST; b <= BUFF_LAST; b *= 2, ++i)
        if(buff == b)
            return i;
    return -1;
}
