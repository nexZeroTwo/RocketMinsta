
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

string Buffs_TypeToFullName(float buff) {
    switch(buff) {
        #define BUFFDEF(id,shortname,longname,color) \
            case id: return longname;
        BUFFDEFS
        #undef BUFFDEF

        default: return NULL;
    }
}

string Buffs_TypeToExpandedName(float buff, string sep, float colorfactor) {
    var n = Buffs_TypeToFullName(buff);

    if(n) {
        if(colorfactor) {
            var i = 1 - colorfactor;
            n = strcat(rgb_to_hexcolor(Buffs_TypeToColor(buff) * colorfactor + [i, i, i]), n);
        }

        return n;
    }

    string r;
    float o, first = TRUE;

    for(o = BUFF_FIRST; o <= BUFF_LAST; o *= 2) {
        if(buff & o) {
            if(first) {
                r = Buffs_TypeToExpandedName(o, sep, colorfactor);
                first = FALSE;
            } else {
                r = strcat(r, sep, Buffs_TypeToExpandedName(o, sep, colorfactor));
            }
        }
    }

    if(!r)
        return "Unknown";

    return r;
}

string Buffs_NameToFullName(string t) {
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

float Buffs_ParseList(string bufflist) {
    var tokens = tokenize(bufflist);
    var bffs = 0;

    for(var i = 0; i < tokens; ++i) {
        if(argv(i) == "all")
            return BUFF_LAST * 2 - 1;

        bffs |= Buffs_NameToType(argv(i));
    }

    return bffs;
}

string Buffs_TypeToList(float bffs) {
    var s = "";

    for(var b = BUFF_FIRST; b <= BUFF_LAST; b *= 2) {
        if(bffs & b) {
            var n = Buffs_TypeToName(b);

            if(s == "")
                s = n;
            else
                s = s + " " + n;
        }
    }

    return s;
}
