
float radio_playing;
float radio_looping;
float radio_starttime;
float radio_tracklen;
float radio_playing_queue;
float radio_queue_advanceat;
string radio_url;
string radio_filename;

void Radio_Init(void) {
    registercvar("_radio_queue", "");
    registercvar("_radio_queue_left", "0");
    radio_playing_queue = -1;

    if(cvar_string("_radio_queue") != "")
        defer(5, Radio_Queue_PlayFirst);
}

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
    radio_tracklen = 0;
    radio_playing_queue = -1;

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
    radio_playing_queue = -1;

    entity e; FOR_EACH_REALCLIENT(e)
        stuffcmd(e, "cd reset\n");
}

void Radio_Queue_PlayFirst(void) {
    string q = cvar_string("_radio_queue");

    if(q == "") {
        Radio_Stop();
        return;
    }

    float n = tokenizebyseparator(q, " ");

    string id    = argv(0);
    string url   = cvar_string(strcat("_radio_queue_", id, "_url"));
    string fname = cvar_string(strcat("_radio_queue_", id, "_fname"));

    Radio_Play(url, fname, FALSE);

    radio_tracklen = cvar(strcat("_radio_queue_", id, "_len"));
    radio_playing_queue = stof(id);
    radio_queue_advanceat = radio_starttime + radio_tracklen * 0.4;

    // preload next track
    id = argv(1);
    if(id != "")
        Radio_Preload(cvar_string(strcat("_radio_queue_", id, "_url")));

    cvar_set("_radio_queue_left", ftos(n-1));
}

string Radio_Queue_GetFreeID(void) {
    float id;
    string qs = strcat(" ", cvar_string("_radio_queue"), " ");

    for(id = 0 ;; ++id) {
        string s = ftos(id);
        if(strstrofs(qs, strcat(" ", s, " "), 0) < 0)
            return s;
    }

    return "";
}

void Radio_Queue(string url, string fname, float len) {
    string id = Radio_Queue_GetFreeID();

    string url_var   = strcat("_radio_queue_", id, "_url");
    string fname_var = strcat("_radio_queue_", id, "_fname");
    string len_var   = strcat("_radio_queue_", id, "_len");

    registercvar(url_var, "");
    registercvar(fname_var, "");
    registercvar(len_var, "");

    cvar_set(url_var, url);
    cvar_set(fname_var, fname);
    cvar_set(len_var, ftos(len));

    string q = cvar_string("_radio_queue");
    if(q == "")
        cvar_set("_radio_queue", id);
    else
        cvar_set("_radio_queue", strcat(q, " ", id));

    cvar_set("_radio_queue_left", ftos(cvar("_radio_queue_left") + 1));

    if(radio_playing_queue < 0)
        Radio_Queue_PlayFirst();
    else if(strstrofs(q, " ", 0) < 0)
        Radio_Preload(url);
}

void Radio_Queue_Advance(void) {
    string q = cvar_string("_radio_queue");
    float sp = strstrofs(q, " ", 0);

    if(sp < 0) {
        cvar_set("_radio_queue", "");
        return;
    }

    cvar_set("_radio_queue", substring(q, sp+1, strlen(q)));
}

void Radio_Queue_Skip(void) {
    if(radio_playing_queue < 0)
        return;

    if(radio_queue_advanceat)
        Radio_Queue_Advance();
    Radio_Queue_PlayFirst();
}

void Radio_Frame(void) {
    if(radio_playing_queue < 0)
        return;

    if(radio_queue_advanceat > 0)
    if(time > radio_queue_advanceat) {
        Radio_Queue_Advance();
        radio_queue_advanceat = 0;
    }

    if(time > radio_starttime + radio_tracklen)
        Radio_Queue_PlayFirst();
}

void Radio_ClientConnect_Delayed(void) {
    Radio_SendPlay(self);
}

void Radio_ClientConnect(void) {
    if(!radio_playing)
        return;

    if(clienttype(self) != CLIENTTYPE_REAL)
        return;

    Radio_SendPreload(self, radio_url);
    defer(3, Radio_ClientConnect_Delayed);
}
