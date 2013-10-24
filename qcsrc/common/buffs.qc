
string Buffs_TypeToName(float buff) {
    switch(buff) {
        case BUFF_ARC       :      return "arc";
        case BUFF_SUPPLY    :      return "supply";
        case BUFF_GUARD     :      return "guard";
        case BUFF_HASTE     :      return "haste";
        case BUFF_MEDIC     :      return "medic";
        case BUFF_BASH      :      return "bash";
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
        case "bash"         :      return BUFF_BASH;
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
        case BUFF_BASH      :      return "Bash";
        default             :      return "Unknown";
    }
}

string Buffs_NameToExpandedName(string t) {
    return Buffs_TypeToExpandedName(Buffs_NameToType(t));
}

vector Buffs_TypeToColor(float buff) {
    switch(buff) {
        case BUFF_ARC       :      return '0.2 0.7 1.0';
        case BUFF_SUPPLY    :      return '0.2 1.0 0.2';
        case BUFF_GUARD     :      return '0.3 0.2 1.0';
        case BUFF_HASTE     :      return '1.0 1.0 0.2';
        case BUFF_MEDIC     :      return '1.0 0.3 1.0';
        case BUFF_BASH      :      return '1.0 0.4 0.0';
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
