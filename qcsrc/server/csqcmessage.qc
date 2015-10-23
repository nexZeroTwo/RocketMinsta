
void CSQCMessage_Write_Begin(float msg, float type) {
    WriteByte(msg, SVC_TEMPENTITY);
    WriteByte(msg, TE_CSQC_MESSAGE);
    WriteByte(msg, type);
}

void CSQCMessage_Write_Obituary(float msg, entity targ, entity attacker, float deathtype, string custmsg, float aspree, float tspree, float aspreeshort) {
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

    WriteByte(msg, aspree);
    WriteByte(msg, tspree);
    WriteByte(msg, aspreeshort);
}

void CSQCMessage_Obituary(entity targ, entity attacker, float deathtype, string custmsg, float aspree, float tspree, float aspreeshort) {
    CSQCMessage_Write_Obituary(MSG_ALL, targ, attacker, deathtype, custmsg, aspree, tspree, aspreeshort);
}

void CSQCMessage_Write_Praise(float msg, float praiseflags) {
    CSQCMessage_Write_Begin(msg, CSQCMSG_PRAISE);
    WriteByte(msg, praiseflags);
}

void CSQCMessage_Praise(entity plr, float praiseflags) {
    if(!praiseflags)
        return;

    CSQCMESSAGE_SPECTATABLE(plr, {
        CSQCMessage_Write_Praise(MSG_ONE, praiseflags);
    })
}

void CSQCMessage_Praise2(entity plr, float hst, float aws, float imp, float amz, float air) {
    CSQCMessage_Praise(plr, 
        (if(hst) CSQCMSG_PRAISEFLAG_HEADSHOT    else 0) |
        (if(aws) CSQCMSG_PRAISEFLAG_AWESOME     else 0) |
        (if(imp) CSQCMSG_PRAISEFLAG_IMPRESSIVE  else 0) |
        (if(amz) CSQCMSG_PRAISEFLAG_AMAZING     else 0) |
        (if(air) CSQCMSG_PRAISEFLAG_AIRSHOT     else 0));
}
