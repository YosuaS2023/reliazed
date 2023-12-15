FUNC::OnQueryFinished(extraid, threadid, race_check)
{
    if(!IsPlayerConnected(extraid))
        return 0;

    new rows, fields;
    switch (threadid)
    {
        case THREAD_CREATE_CHAR:
        {
            if (GetPVarInt(extraid, "Verifikasi") == 1) {
                new query[128];

                SetPVarInt(extraid, "Verifikasi", 0);
                AccountData[extraid][uLogged] = 1;

                stop AccountData[extraid][uLoginTimer];

                format(query, sizeof(query), "SELECT `Character` FROM `ucp_characters` WHERE `Username` = '%s' LIMIT %d;", ReturnName(extraid), MAX_CHARACTERS);
                mysql_tquery(sqlcon, query, "OnQueryFinished", "dd", extraid, THREAD_LIST_CHARACTERS);
            }
        }
        case THREAD_LIST_CHARACTERS: {
            for (new i = 0; i < MAX_CHARACTERS; i ++) {
                CharacterList[extraid][i][0] = EOS;
            }

            for (new i = 0; i < cache_num_rows(); i ++) {
                cache_get_field_content(i, "Character", CharacterList[extraid][i], MAX_PLAYER_NAME + 1);
            }
            ShowCharacterMenu(extraid);
        }
        case THREAD_LOAD_CHARACTERS:
        {
            cache_get_data(rows, fields);

            if(rows)
            {
                new query[128];

                PlayerData[extraid][pID] = cache_get_field_int(0, "ID");
                PlayerData[extraid][pGender] = cache_get_field_int(0, "Gender");
                PlayerData[extraid][pCreated] = cache_get_field_int(0, "Created");

                cache_get_field_content(0, "Played", query, 64);
                sscanf(query, "p<|>ddd", PlayerData[extraid][pSecond], PlayerData[extraid][pMinute], PlayerData[extraid][pHour]);

                cache_get_field_content(0, "Birthdate", PlayerData[extraid][pBirthdate], 24);
                cache_get_field_content(0, "Origin", PlayerData[extraid][pOrigin], 32);
                cache_get_field_content(0, "Alias", PlayerData[extraid][pAlias], 25);

                new
                    bool:is_alias_null
                ;
                cache_is_value_name_null(0, "Alias", is_alias_null);

                if (is_alias_null)
                {
                    format(PlayerData[extraid][pAlias], 25, "Player");
                }
                else
                {
                    cache_get_field_content(0, "Alias", PlayerData[extraid][pAlias], 25);
                }
                PlayerData[extraid][pGasPump] = cache_get_field_int(0, "GasPump");
                PlayerData[extraid][pSkin] = cache_get_field_int(0, "Skin");
                PlayerData[extraid][pPos][0] = cache_get_field_float(0, "PosX");
                PlayerData[extraid][pPos][1] = cache_get_field_float(0, "PosY");
                PlayerData[extraid][pPos][2] = cache_get_field_float(0, "PosZ");
                PlayerData[extraid][pPos][3] = cache_get_field_float(0, "PosA");
                PlayerData[extraid][pHealth] = cache_get_field_float(0, "Health");
                PlayerData[extraid][pArmorStatus] = cache_get_field_float(0, "Armour");
                PlayerData[extraid][pInterior] = cache_get_field_int(0, "Interior");
                PlayerData[extraid][pRegisterDate] = cache_get_field_int(0, "RegisterDate");
                PlayerData[extraid][pWorld] = cache_get_field_int(0, "World");
                PlayerData[extraid][pMoney] = cache_get_field_int(0, "Money");
                PlayerData[extraid][pBankMoney] = cache_get_field_int(0, "BankMoney");

                PlayerData[extraid][pLogged] = 1;
                PlayerData[extraid][pScore] = cache_get_field_int(0, "pScore");
                PlayerData[extraid][pExp] = cache_get_field_int(0, "pExp");
                PlayerData[extraid][pSalary] = cache_get_field_int(0, "pSalary");
                PlayerData[extraid][pPaycheck] = cache_get_field_int(0, "pPaycheck");

                PlayerData[extraid][pStory] = cache_get_field_int(0, "Story");
                PlayerData[extraid][pDutyTime] = cache_get_field_int(0, "DutyTime");
                PlayerData[extraid][pDutySecond] = cache_get_field_int(0, "DutySecond");
                PlayerData[extraid][pDutyMinute] = cache_get_field_int(0, "DutyMinute");
                PlayerData[extraid][pDutyHour] = cache_get_field_int(0, "DutyHour");

                PlayerData[extraid][pFaction] = cache_get_field_int(0, "Faction");
                PlayerData[extraid][pFactionID] = cache_get_field_int(0, "FactionID");
                PlayerData[extraid][pFactionSkin] = cache_get_field_int(0, "FactionSkin");
                PlayerData[extraid][pFactionRank] = cache_get_field_int(0, "FactionRank");

                PlayerData[extraid][pJob] = cache_get_field_int(0, "Job");
                PlayerData[extraid][pInjured] = cache_get_field_int(0, "Injured");
                PlayerData[extraid][pGiveupTime] = cache_get_field_int(0, "InjuredTime");
                PlayerData[extraid][pDead] = cache_get_field_float(0, "Dead");
                mysql_tquery(sqlcon, sprintf("SELECT * FROM `damages` WHERE `IDs` = '%d' ORDER BY `time` DESC LIMIT %d", PlayerData[extraid][pID], MAX_DAMAGE), "OnQueryFinished", "dd", extraid, THREAD_LOAD_DAMAGES);
                mysql_tquery(sqlcon, sprintf("SELECT * FROM `inventory` WHERE `ID` = '%d'", PlayerData[extraid][pID]), "OnQueryFinished", "dd", extraid, THREAD_LOAD_INVENTORY);
                if(!PlayerData[extraid][pCreated])
                {
                    new string[200], header[50];
                    format(header, sizeof header, "Nama : {37DB45}%s", NormalName(extraid));
                    format(string, sizeof string, "Jenis Kelamin\t ({37DB45}None{ffffff})\nTanggal Lahir\t ({37DB45}None{ffffff})\nAsal Karakter\t ({37DB45}None{ffffff})\nSelesai");
                    ShowPlayerDialog(extraid, DIALOG_PERSONAL, DIALOG_STYLE_LIST, header, string,"select","Kembali");


                    SetSpawnInfo(extraid, 0, 98, 258.0770, -42.3550, 1002.0234, 0.0, 0, 0, 0, 0, 0, 0);
                    TogglePlayerSpectating(extraid, 0);
                    TogglePlayerControllable(extraid, 0);
                }
                else
                {
                    SetSpawnInfo(extraid, 0, PlayerData[extraid][pSkin], PlayerData[extraid][pPos][0], PlayerData[extraid][pPos][1], PlayerData[extraid][pPos][2], 0.0, 0, 0, 0, 0, 0, 0);

                    TogglePlayerSpectating(extraid, 0);
                    TogglePlayerControllable(extraid, 0);

                    SetTimerEx("SpawnTimer", 1000, false, "d", extraid);
                }
            }
        }
        case THREAD_FIND_USERNAME:
        {
            new string[MAX_PLAYER_NAME+1];
            if (race_check != g_RaceCheck[extraid])
                return KickEx(extraid);

            format(string, sizeof(string), "Basic - %s", ReturnName(extraid));

            if(cache_num_rows()) {
                GetPlayerName(extraid, AccountData[extraid][uUsername], MAX_PLAYER_NAME + 1);

                AccountData[extraid][uID] = cache_get_field_int(0, "ID");
                AccountData[extraid][uAdmin] = cache_get_field_int(0, "Admin");
                AccountData[extraid][uDeveloper] = cache_get_field_int(0, "Developer");
                AccountData[extraid][uAdminHide] = cache_get_field_int(0, "AdminHide");
                //Admin Activity
                AccountData[extraid][uAdminDutyTime] = cache_get_field_int(0, "AdminDutyTime");
                AccountData[extraid][uAdminAcceptReport] = cache_get_field_int(0, "AdminAcceptReport");
                AccountData[extraid][uAdminDeniedReport] = cache_get_field_int(0, "AdminDeniedReport");
                AccountData[extraid][uAdminAcceptStuck] = cache_get_field_int(0, "AdminAcceptStuck");
                AccountData[extraid][uAdminDeniedStuck] = cache_get_field_int(0, "AdminDeniedStuck");
                AccountData[extraid][uAdminBanned] = cache_get_field_int(0, "AdminBanned");
                AccountData[extraid][uAdminUnbanned] = cache_get_field_int(0, "AdminUnbanned");
                AccountData[extraid][uAdminJail] = cache_get_field_int(0, "AdminJail");
                AccountData[extraid][uAdminAnswer] = cache_get_field_int(0, "AdminAnswer");

                AccountData[extraid][uLoginDate] = cache_get_field_int(0, "LoginDate");
                AccountData[extraid][uRegisterDate] = cache_get_field_int(0, "RegisterDate");

                cache_get_field_content(0, "IP", AccountData[extraid][uIP], 17);
                cache_get_field_content(0, "Salt", AccountData[extraid][uSalt], 65);
                cache_get_field_content(0, "Password", AccountData[extraid][uPassword], 65);
                cache_get_field_content(0, "AdminRankName", AccountData[extraid][uAdminRankName], 32);
                
                AccountData[extraid][uLoginTimer] = defer refuseLogin(extraid);
                new str[500];
                format(str, sizeof(str), ""WHITE_E"Selamat datang kembali "YELLOW_E"%s.\n"WHITE_E"Versi Server: "GREEN_E"%s\n\n"WHITE"Anda di beri waktu "YELLOW_E"5 menit "WHITE_E"untuk login, atau akan di keluarkan dari server.\nSilahkan login dengan memasukkan password ke kolom di bawah ini", ReturnName(extraid,0), SERVER_REVISION);
                ShowPlayerDialog(extraid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "LOGIN", str, "Masuk", "Keluar");
            }
            else {
                new str[500];
                format(str, sizeof(str), ""WHITE_E"Selamat datang di Basic Roleplay "YELLOW_E"%s"WHITE_E".\n\nMasukkan password untuk mendaftarkan akun: (password minimal 8 sampai dengan 32 karakter).", ReturnName(extraid));
                ShowPlayerDialog(extraid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "REGISTER", str, "Daftarkan", "Keluar");
            }
        }
        case THREAD_LOAD_DAMAGES:
        {
            cache_get_data(rows, fields);

            for (new i = 0; i < rows && i < MAX_DAMAGE; i ++) if(!DamageData[extraid][i][damageExists]) {
                DamageData[extraid][i][damageExists] = true;
                DamageData[extraid][i][damageID] = cache_get_field_int(i, "ID");
                DamageData[extraid][i][damageAmount] = cache_get_field_float(i, "amount");
                DamageData[extraid][i][damageKevlar] = cache_get_field_float(i, "amountkevlar");
                DamageData[extraid][i][damageWeapon] = cache_get_field_int(i, "weapon");
                DamageData[extraid][i][damageBodypart] = cache_get_field_int(i, "bodypart");
                DamageData[extraid][i][damageTime] = cache_get_field_int(i, "time");
            }
        }
    }
    return 1;
}

function ResetVariable_Account(playerid)
{
    return 1;
}