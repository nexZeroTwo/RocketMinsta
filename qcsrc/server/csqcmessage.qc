
void CSQCMessage_Write_Begin(float msg, float type) {
    WriteByte(msg, SVC_TEMPENTITY);
    WriteByte(msg, TE_CSQC_MESSAGE);
    WriteByte(msg, type);
}

void CSQCMessage_Write_Obituary(float msg, entity targ, entity attacker, float deathtype, string custmsg) {
    float t = num_for_edict(targ);
    float a = num_for_edict(attacker);

    if(t > maxclients) t = 0;
    if(a > maxclients) a = 0;

    if(custmsg)
        CSQCMessage_Write_Begin(msg, CSQCMSG_OBITUARY_CUSTOM);
    else
        CSQCMessage_Write_Begin(msg, CSQCMSG_OBITUARY);

    WriteByte(msg, t);
    WriteByte(msg, a);
    WriteShort(msg, deathtype);

    if(custmsg)
        WriteString(msg, custmsg);
}

void CSQCMessage_Write_KillingSpree(float msg, entity attacker, float longspree, float shortspree) {
    float a = num_for_edict(attacker);

    CSQCMessage_Write_Begin(msg, CSQCMSG_KILLINGSPREE);
    WriteByte(msg, a);
    WriteByte(msg, longspree);
    WriteByte(msg, shortspree);
}

void CSQCMessage_Obituary(entity targ, entity attacker, float deathtype, string custmsg) {
    CSQCMessage_Write_Obituary(MSG_ALL, targ, attacker, deathtype, custmsg);
}

void CSQCMessage_KillingSpree(entity attacker, float longspree, float shortspree) {
    CSQCMessage_Write_KillingSpree(MSG_ALL, attacker, longspree, shortspree);
}
