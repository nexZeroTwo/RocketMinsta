
entity DamageTracker_CreateKeeper(entity own) {
    entity k = spawn();
    k.owner = own;
    return k;
}

float DamageTracker_GetEntryId(entity keeper, float dtype) {
    float i;
    
    for(i = 0; i < DTRACK_ENTRIES; ++i) {
        if(!keeper.(dtrack_type[i]) || keeper.(dtrack_type[i]) == dtype)
            return i;
    }
    
    return -1;
}

void DamageTracker_Sort_Swap(entity keeper, float i, float j) {
    float tmp_t1, tmp_d1;
    float tmp_t2, tmp_d2;
    
    tmp_t1 = keeper.(dtrack_type[i]);
    tmp_d1 = keeper.(dtrack_damage[i]);
    tmp_t2 = keeper.(dtrack_type[j]);
    tmp_d2 = keeper.(dtrack_damage[j]);
    
    keeper.(dtrack_type[i]) = tmp_t2;
    keeper.(dtrack_damage[i]) = tmp_d2;
    keeper.(dtrack_type[j]) = tmp_t1;
    keeper.(dtrack_damage[j]) = tmp_d1;
}

void DamageTracker_Sort(entity keeper) {
    float i, j, maxidx;
    
    FOR_DTRAK_ENTRIES(keeper, i) {
        maxidx = i;
        
        for(j = i + 1; j < DTRACK_ENTRIES && keeper.(dtrack_type[j]); ++j) {
            if(keeper.(dtrack_damage[j]) > keeper.dtrack_damage[maxidx])
                maxidx = j;
        }
        
        if(i != maxidx)
            DamageTracker_Sort_Swap(keeper, i, maxidx);
    }
}

void DamageTracker_Record(entity keeper, float dtype, float damage) {
    float i = DamageTracker_GetEntryId(keeper, dtype);
    keeper.(dtrack_type[i]) = dtype;
    keeper.(dtrack_damage[i]) += damage;
    keeper.dtrack_totaldamage += damage;
    
    if(keeper.(dtrack_damage[i]) > keeper.dtrack_highestdamage)
        keeper.dtrack_highestdamage = keeper.(dtrack_damage[i]);
}
