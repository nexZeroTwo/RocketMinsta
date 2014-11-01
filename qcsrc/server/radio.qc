
float radio_playing;
float radio_looping;
float radio_starttime;
string radio_url;
string radio_filename;

void Radio_SendPreload(entity e, string url) {
    msg_entity = e;
    WriteByte(MSG_ONE, SVC_TEMPENTITY);
    WriteByte(MSG_ONE, TE_CSQC_RADIO);
    WriteByte(MSG_ONE, TRUE);
    WriteString(MSG_ONE, url);
}

void Radio_SendPlay(entity e) {
    if(!radio_playing)
        return;

    msg_entity = e;
    WriteByte(MSG_ONE, SVC_TEMPENTITY);
    WriteByte(MSG_ONE, TE_CSQC_RADIO);
    WriteByte(MSG_ONE, FALSE);
    WriteString(MSG_ONE, radio_url);
    WriteString(MSG_ONE, radio_filename);
    WriteByte(MSG_ONE, radio_looping);
    if(!radio_looping)
        WriteCoord(MSG_ONE, radio_starttime);
}

void Radio_Preload(string url) {
    entity e; FOR_EACH_REALCLIENT(e)
        Radio_SendPreload(e, url);
}

void Radio_Play(string url, string fname, float loop) {
    if(radio_url)       strunzone(radio_url);
    if(radio_filename)  strunzone(radio_filename);

    radio_url = strzone(url);
    radio_filename = strzone(fname);
    radio_looping = loop;
    radio_starttime = time;
    radio_playing = TRUE;

    dprint("URL: ", radio_url, "\n");
    dprint("File: ", radio_filename, "\n");
    dprint("Loop: ", ftos(radio_looping), "\n");
    dprint("Start: ", ftos(radio_starttime), "\n");

    entity e; FOR_EACH_REALCLIENT(e)
        Radio_SendPlay(e);
}

void Radio_Stop(void) {
    if(radio_url)       strunzone(radio_url);
    if(radio_filename)  strunzone(radio_filename);

    radio_playing = FALSE;
    radio_url = radio_filename = string_null;

    entity e; FOR_EACH_REALCLIENT(e)
        stuffcmd(e, "cd reset\n");
}

void Radio_ClientConnect(void) {
    if(clienttype(self) == CLIENTTYPE_REAL)
        Radio_SendPlay(self);
}
