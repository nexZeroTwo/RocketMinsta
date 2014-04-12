
void DamageTracker_Print(entity keeper, entity to) {
    float i, j;
    
    DamageTracker_Sort(keeper);
    sprint(to, "\n------------------------------------------------------------\n");
    sprint(to, strcat("^6Damage statistics for ^7", keeper.owner.netname, "^6:\n"));
    sprint(to, "------------------------------------------------------------\n");
    
    FOR_DTRAK_ENTRIES(keeper, i) {
        float damage = keeper.(dtrack_damage[i]);
        string ratio = ftos((damage / keeper.dtrack_totaldamage) * 100);
        ratio = substring(ratio, 0, strstrofs(ratio, ".", 0) + 3);
        string srcname = DamageSourceName(keeper.(dtrack_type[i]), TRUE);
        sprint(to, strcat(ftos(i+1), ". ^2", srcname));
        float spaces = max(1, 45 - strlen(srcname));
        for(j = 0; j < spaces; ++j)
            sprint(to, " ");
        sprint(to, strcat("^3", FormatDamage(damage), "^7 (", ratio, "%)\n"));
    }
    
    sprint(to, "------------------------------------------------------------\n\n");
}

void DamageTracker_RecordAndSend(entity keeper, float dtype, float damage) {
    if(!sv_damagestats)
        return;
    
    if(!keeper.owner.iscreature)
        return;
    
    DamageTracker_Record(keeper, dtype, damage);
    
    if(clienttype(keeper.owner) != CLIENTTYPE_REAL)
        return;
    
    msg_entity = keeper.owner;
    WriteByte(MSG_ONE, SVC_TEMPENTITY);
    WriteByte(MSG_ONE, TE_CSQC_DTRACK);
    WriteShort(MSG_ONE, dtype);
    WriteShort(MSG_ONE, damage);
}
