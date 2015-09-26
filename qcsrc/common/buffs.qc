
string Buffs_TypeToName(float buff) {
    switch(buff) {
        #define BUFFDEF(id,shortname,longname,color) \
            case id: return #shortname;
        BUFFDEFS
        #undef BUFFDEF

        default: return "unknown";
    }
}

float Buffs_NameToType(string name) {
    switch(name) {
        #define BUFFDEF(id,shortname,longname,color) \
            case #shortname: return id;
        BUFFDEFS
        #undef BUFFDEF

        // compatibility
        case "bash": return BUFF_IGNITE;
        
        default: return 0;
    }
}

string Buffs_TypeToExpandedName(float buff) {
    switch(buff) {
        #define BUFFDEF(id,shortname,longname,color) \
            case id: return longname;
        BUFFDEFS
        #undef BUFFDEF

        default: {
            string r;
            float o, first = TRUE;
            
            for(o = BUFF_FIRST; o <= BUFF_LAST; o *= 2) {
                if(buff & o) {
                    if(first) {
                        r = Buffs_TypeToExpandedName(o);
                        first = FALSE;
                    } else {
                        r = strcat(r, " + ", Buffs_TypeToExpandedName(o));
                    }
                }
            }
            
            if(!r)
                return "Unknown";

            return r;
        }
    }
}

string Buffs_NameToExpandedName(string t) {
    switch(t) {
        #define BUFFDEF(id,shortname,longname,color) \
            case #shortname: return longname;
        BUFFDEFS
        #undef BUFFDEF

        default: return "Unknown Buff";
    }
}

vector Buffs_TypeToColor(float buff) {
    switch(buff) {
        #define BUFFDEF(id,shortname,longname,color) \
            case id: return color;
        BUFFDEFS
        #undef BUFFDEF

        default: {
            vector c;
            float o, n;

            for(o = BUFF_FIRST; o <= BUFF_LAST; o *= 2) {
                if(buff & o) {
                    c += Buffs_TypeToColor(o);
                    ++n;
                }
            }

            return c * (1/n);
        }
    }
}

float Buffs_TypeToIndex(float buff) {
    #define BUFFDEF(id,shortname,longname,color) \
        if(buff == id) return id##_ID;
    BUFFDEFS
    #undef BUFFDEF

    return -1;
}
