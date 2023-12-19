#ifdef USE_DPRM

void DPRM_Start() {
    dprm_version = DPRM_GetVersion();

    if(!DPRM_VersionIsSuitable()) {
        print("\n====================================================================\n"
              "^1WARNING: ^3You're running Xonotic or Nexuiz 2.5.2!\n^3Bugs may occur, you may have more stability with Rexuiz.^2"
              "\n====================================================================\n\n");
    } else if(!DPRM_VersionIsRecommended()) {
        print("\n====================================================================\n"
              "^3A recommended engine update is available at ^2" DPRM_WEBSITE_URL "^7"
              "\n====================================================================\n\n");
    }

    if(checkextension("DP_RM_REGEX"))
        regex_match = regex_match_642;
    else if(checkextension("DP_RM_REGEX2"))
        regex_match = regex_match_800;

    if(cvar_string("sys_project_name") == "Xonotic") {
        dprm_basegame = BASEGAME_XONOTIC;
    } else {
        dprm_basegame = BASEGAME_NEXUIZ;
    }
}

float DPRM_GetVersion() {
    if(!(cvar_type("dprm_version") & CVAR_TYPEFLAG_ENGINE))
        return 0;
    return CVAR(dprm_version);
}

float DPRM_VersionIsSuitable() {
    return dprm_version >= DPRM_MINVERSION;
}

float DPRM_VersionIsRecommended() {
    return dprm_version >= DPRM_MINRECOMMENDEDVERSION;
}

#else
    #include "dprm_stub.qc"
#endif

float DPRM_IsDPRMEngine() {
    return dprm_version;
}
