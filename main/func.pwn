//==========[ Func ]==========

KickEx(playerid, time = 200)
{
    if(PlayerData[playerid][pKicked])
        return 0;

    if(SQL_IsCharacterLogged(playerid)) {
        SQL_SaveAccounts(playerid);
    }

    PlayerData[playerid][pKicked] = 1;
    SetTimerEx("KickTimer", time, false, "d", playerid);
    return 1;
}

ReturnName(playerid, underscore=1, mask = 0)
{
    new
        name[MAX_PLAYER_NAME + 1];

    GetPlayerName(playerid, name, sizeof(name));

    if(!underscore) {
        for (new i = 0, len = strlen(name); i < len; i ++) {
                if(name[i] == '_') name[i] = ' ';
        }
    }

    if(mask){
        if(PlayerData[playerid][pMaskOn] && !AccountData[playerid][uAdminDuty])
            format(name, sizeof(name), "Mask_#%d", PlayerData[playerid][pMaskID]);
    }
    return name;
}

stock SendAdminMessage(color, const str[], {Float,_}:...)
{
    static
        args,
        start,
        end,
        string[144]
    ;
    #emit LOAD.S.pri 8
    #emit STOR.pri args

    if(args > 8)
    {
        #emit ADDR.pri str
        #emit STOR.pri start

        for (end = start + (args - 8); end > start; end -= 4)
        {
            #emit LREF.pri end
            #emit PUSH.pri
        }
        #emit PUSH.S str
        #emit PUSH.C 144
        #emit PUSH.C string

        #emit LOAD.S.pri 8
        #emit ADD.C 4
        #emit PUSH.pri

        #emit SYSREQ.C format
        #emit LCTRL 5
        #emit SCTRL 4

        foreach (new i : Player)
        {
            if(SQL_IsCharacterLogged(i) && AccountData[i][uAdmin] >= 1) {
                SendClientMessage(i, color, string);
            }
        }
        return 1;
    }
    foreach (new i : Player)
    {
        if(SQL_IsCharacterLogged(i) && AccountData[i][uAdmin] >= 1) {
            SendClientMessage(i, color, str);
        }
    }
    return 1;
}
stock ReturnWeaponName(weaponid)
{
    new weapon[22];
    switch(weaponid)
    {
        case 0: weapon = "Fist";
        case 18: weapon = "Molotov Cocktail";
        case 44: weapon = "Night Vision Goggles";
        case 45: weapon = "Thermal Goggles";
        case 54: weapon = "Fall";
        default: GetWeaponName(weaponid, weapon, sizeof(weapon));
    }
    return weapon;
}
GetMonth(bulan)
{
    static
        month[12];

    switch (bulan) {
        case 1: month = "January";
        case 2: month = "February";
        case 3: month = "March";
        case 4: month = "April";
        case 5: month = "May";
        case 6: month = "June";
        case 7: month = "July";
        case 8: month = "August";
        case 9: month = "September";
        case 10: month = "October";
        case 11: month = "November";
        case 12: month = "December";
    }
    return month;
}
ReturnDate()
{
    static date[6], string[72];

    getdate(date[2], date[1], date[0]);
    gettime(date[3], date[4], date[5]);

    format(string, sizeof(string), "%02d %s %d, %02d:%02d:%02d", date[0],GetMonth(date[1]), date[2], date[3], date[4], date[5]);
    return string;
}
SendNearbyMessage(playerid, Float:radius, color, const str[], {Float,_}:...)
{
    static
        args,
        start,
        end,
        string[144]
    ;
    #emit LOAD.S.pri 8
    #emit STOR.pri args

    if(args > 16)
    {
        #emit ADDR.pri str
        #emit STOR.pri start

        for (end = start + (args - 16); end > start; end -= 4)
        {
            #emit LREF.pri end
            #emit PUSH.pri
        }
        #emit PUSH.S str
        #emit PUSH.C 144
        #emit PUSH.C string

        #emit LOAD.S.pri 8
        #emit CONST.alt 4
        #emit SUB
        #emit PUSH.pri

        #emit SYSREQ.C format
        #emit LCTRL 5
        #emit SCTRL 4

        foreach (new i : Player)
        {
            if(IsPlayerNearPlayer(i, playerid, radius)) {
                SendClientMessage(i, color, string);
            }
        }
        return 1;
    }
    foreach (new i : Player)
    {
        if(IsPlayerNearPlayer(i, playerid, radius)) {
            SendClientMessage(i, color, str);
        }
    }
    return 1;
}

stock IsPlayerNearPlayer(playerid, targetid, Float:radius)
{
    static
        Float:fX,
        Float:fY,
        Float:fZ;

    GetPlayerPos(targetid, fX, fY, fZ);

    return (GetPlayerInterior(playerid) == GetPlayerInterior(targetid) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(targetid)) && IsPlayerInRangeOfPoint(playerid, radius, fX, fY, fZ);
}

stock SendClientMessageToAllEx(color, const text[], {Float, _}:...)
{
    static
        args,
        str[144];

    /*
         *  Custom Function:that uses #emit to format variables into a string.
         *  This code is very fragile; touching any code here will cause crashing!
    */
    if((args = numargs()) == 2)
    {
        SendClientMessageToAll(color, text);
    }
    else
    {
        while (--args >= 2)
        {
            #emit LCTRL 5
            #emit LOAD.alt args
            #emit SHL.C.alt 2
            #emit ADD.C 12
            #emit ADD
            #emit LOAD.I
            #emit PUSH.pri
        }
        #emit PUSH.S text
        #emit PUSH.C 144
        #emit PUSH.C str
        #emit LOAD.S.pri 8
        #emit ADD.C 4
        #emit PUSH.pri
        #emit SYSREQ.C format
        #emit LCTRL 5
        #emit SCTRL 4

        SendClientMessageToAll(color, str);

        #emit RETN
    }
    return 1;
}

stock RemoveAlpha(color) {
    return (color & ~0xFF);
}

ColouredText(text[])
{
    new
        pos = -1,
        string[144]
    ;
    strmid(string, text, 0, 128, (sizeof(string) - 16));

    while((pos = strfind(string, "#", true, (pos + 1))) != -1)
    {
        new
            i = (pos + 1),
            hexCount
        ;
        for( ; ((string[i] != 0) && (hexCount < 6)); ++i, ++hexCount)
        {
            if(!(('a' <= string[i] <= 'f') || ('A' <= string[i] <= 'F') || ('0' <= string[i] <= '9')))
            {
                    break;
            }
        }
        if((hexCount == 6) && !(hexCount < 6))
        {
            string[pos] = '{';
            strins(string, "}", i);
        }
    }
    return string;
}

ReturnIP(playerid)
{
    new ip[16];
    GetPlayerIp(playerid, ip, sizeof(ip));

    return ip;
}

stock SendClientMessageEx(playerid, color, const text[], {Float, _}:...)
{
    static
        args,
        str[144];

    if((args = numargs()) == 3)
    {
        SendClientMessage(playerid, color, text);
    }
    else
    {
        while (--args >= 3)
        {
            #emit LCTRL 5
            #emit LOAD.alt args
            #emit SHL.C.alt 2
            #emit ADD.C 12
            #emit ADD
            #emit LOAD.I
            #emit PUSH.pri
        }
        #emit PUSH.S text
        #emit PUSH.C 144
        #emit PUSH.C str
        #emit PUSH.S 8
        #emit SYSREQ.C format
        #emit LCTRL 5
        #emit SCTRL 4

        SendClientMessage(playerid, color, str);

        #emit RETN
    }
    return 1;
}

ShowPlayerFooter(playerid, string[], time = 1500, sound = 0) {
    if(PlayerData[playerid][pShowFooter]) {
        PlayerTextDrawHide(playerid, PlayerTextdraws[playerid][textdraw_footer]);
        KillTimer(PlayerData[playerid][pFooterTimer]);
    }
    PlayerTextDrawSetString(playerid, PlayerTextdraws[playerid][textdraw_footer], string);
    PlayerTextDrawShow(playerid, PlayerTextdraws[playerid][textdraw_footer]);
    PlayerData[playerid][pShowFooter] = true;
    PlayerData[playerid][pFooterTimer] = SetTimerEx("HidePlayerFooter", time, false, "d", playerid);

    if(sound) PlayerPlaySoundEx(playerid, 1085, 1);
    return 1;
}

FUNC::HidePlayerFooter(playerid) {

    if(!PlayerData[playerid][pShowFooter])
        return 0;

    PlayerData[playerid][pShowFooter] = false;
    KillTimer(PlayerData[playerid][pFooterTimer]);
    PlayerData[playerid][pFooterTimer] = 0;
    return PlayerTextDrawHide(playerid, PlayerTextdraws[playerid][textdraw_footer]);
}

IsValidRoleplayName(const name[]) {
    if(!name[0] || strfind(name, "_") == -1)
        return 0;

    else for (new i = 0, len = strlen(name); i != len; i ++) {
    if((i == 0) && (name[i] < 'A' || name[i] > 'Z'))
            return 0;

        else if((i != 0 && i < len  && name[i] == '_') && (name[i + 1] < 'A' || name[i + 1] > 'Z'))
            return 0;

        else if((name[i] < 'A' || name[i] > 'Z') && (name[i] < 'a' || name[i] > 'z') && name[i] != '_' && name[i] != '.')
            return 0;
    }
    return 1;
}
FUNC::OnCharacterCheck(playerid, charaname[])
{
    if (!cache_num_rows())
    {
        new create_char[200];

        mysql_format(sqlcon, create_char, sizeof(create_char), "INSERT INTO `ucp_characters` (`Username`, `Character`, `CreateDate`) VALUES ('%s', '%s', '%i')", AccountData[playerid][uUsername], charaname, gettime());
        mysql_tquery(sqlcon, create_char);

        for (new i; i < MAX_CHARACTERS; i ++) if(CharacterList[playerid][i][0] == EOS) {
            strcat(CharacterList[playerid][i], charaname);
            break;
        }

        ShowCharacterMenu(playerid);
        SendServerMessage(playerid, "Karakter baru telah dibuat, kami akan memuat ulang semua karaktermu.");
        return 1;
    }

    SendClientMessage(playerid, COLOR_WHITE, "Nama tersebut sudah terpakai! Silahkan ganti nama yang lain.");
    ShowPlayerDialog(playerid, DIALOG_CREATECHAR, DIALOG_STYLE_INPUT, "Create Character","Masukkan nama karakter, maksimal 24 karakter\n\nContoh: "YELLOW_E"Kimberly_Summers, Rein_Styles, Paul_Rostislav dan lainnya.", "Create", "Back");
    return 1;
}
PlayerPlaySoundEx(playerid, sound, forall = 0)
{
    new
        Float:x,
        Float:y,
        Float:z;

    GetPlayerPos(playerid, x, y, z);

    if(forall) return PlayerPlaySound(playerid, sound, x, y, z);

    foreach (new i : Player) if(IsPlayerInRangeOfPoint(i, 20.0, x, y, z)) {
        PlayerPlaySound(i, sound, x, y, z);
    }
    return 1;
}

stock SetPlayerSkinEx(playerid, skin, choice = 0, update = 0)
{
    if(!update) {
        if(!choice) PlayerData[playerid][pSkin] = skin;
    }
    SetPlayerSkin(playerid,skin);
    return 1;
}
stock SetHealth(playerid, Float:health)
{
    PlayerData[playerid][pHealth] = health;

    if(PlayerData[playerid][pHealth] > 100)
    {
        PlayerData[playerid][pHealth] = 100.0;
        SetPlayerHealth(playerid, 100);
    }
    else if(PlayerData[playerid][pHealth] <= 5)
    {
        PlayerData[playerid][pHealth] = 1;
        SetPlayerHealth(playerid, 1);
        if(!PlayerData[playerid][pInjured])
        {
            SetPlayerInjured(playerid);
        }
    }
    else
    {
        SetPlayerHealth(playerid, PlayerData[playerid][pHealth]);
    }
    return 1;
}

IsNumeric(const str[])
{
	for (new i = 0, l = strlen(str); i != l; i ++)
	{
	    if (i == 0 && str[0] == '-')
			continue;

	    else if (str[i] < '0' || str[i] > '9')
			return 0;
	}
	return 1;
}

stock SetPlayerPosEx(playerid, Float:x, Float:y, Float:z, time = 500)
{
    if(PlayerData[playerid][pFreeze])
    {
        stop PlayerData[playerid][pFreezeTimer];
        PlayerData[playerid][pFreeze] = 0;
        TogglePlayerControllable(playerid, 1);
    }
    Streamer_ToggleIdleUpdate(playerid,1);
    TogglePlayerControllable(playerid, 0);
    Streamer_UpdateEx(playerid, x, y, z);
    SetCameraBehindPlayer(playerid);
    PlayerData[playerid][pFreeze] = 1;
    SetPlayerPos(playerid, x, y, z + 0.5);
    PlayerData[playerid][pFreezeTimer] = defer SetPlayerToUnfreeze[time](playerid);
    return 1;
}

stock FormatMoney(amount, delimiter[2]=".", comma[2]=",") // first type data on stock variable amount just has a integer.
// make stock for head new fungsition formating how money cent read with coma and dot
{
  #define MAX_MONEY_String 16
  new MoneyAtString[MAX_MONEY_String];
  format(MoneyAtString, MAX_MONEY_String, "$%d", amount);
  new l = strlen(MoneyAtString);
  if (amount < 0) // - value (minus)
  {
    if (l > 2) strins(MoneyAtString,delimiter,l-2); // cent
    if (l > 5) strins(MoneyAtString,comma,l-5); // tousand
    if (l > 8) strins(MoneyAtString,comma,l-8); // million
  }
  else
  {//1000000 , so strins is adding new chacter like (,) or (.)
    if (l > 2) strins(MoneyAtString,delimiter,l-2);
    if (l > 5) strins(MoneyAtString,comma,l-5);
    if (l > 9) strins(MoneyAtString,comma,l-8);
  }
  if (l <= 2) format(MoneyAtString,sizeof( MoneyAtString),"00,%s",MoneyAtString);
  return MoneyAtString; // this value integer has been changed to string.
}

GiveMoney(playerid, amount, E_SERVER_ECONOMY_FLOW:economy_flow = ECONOMY_FLOW_NONE, string:source[] = "")
{
    if (playerid != INVALID_PLAYER_ID)
    {
        PlayerData[playerid][pMoney] += amount;
        UpdateCharacterInt(playerid, "Money", PlayerData[playerid][pMoney]);

        if (economy_flow == ECONOMY_ADD_SUPPLY)
        {
            Economy_AddSupplyAmount(abs(amount));

            if (strlen(source) > 0)
            {
                printf("[ECONOMY]: %s (%d) spents money %s for \"%s\"", ReturnName(playerid, 0), playerid, FormatMoney(abs(amount)), source);
            }
        }
        else if (economy_flow == ECONOMY_TAKE_SUPPLY)
        {
            Economy_RequestSupply(abs(amount));

            if (strlen(source) > 0)
            {
                printf("[ECONOMY]: %s (%d) receives money %s from \"%s\"", ReturnName(playerid, 0), playerid, FormatMoney(abs(amount)), source);
            }
        }

        GivePlayerMoney(playerid, amount);

        //stop HideHUDMoney(playerid);
/*
        PlayerTextDrawColor(playerid, PlayerTextdraws[playerid][textdraw_moneyhud], (amount > 0) ? 14053887 : -1523963137);
        PlayerTextDrawSetString(playerid, PlayerTextdraws[playerid][textdraw_moneyhud], sprintf("%s%s", (amount > 0) ? ("+") : (""), FormatMoney(amount)));
        PlayerTextDrawShow(playerid, PlayerTextdraws[playerid][textdraw_moneyhud]);*/

        //defer HideHUDMoney(playerid);
    }
    return 1;
}
stock abs(value)
{
    return ((value < 0 ) ? (-value) : (value));
}

ConvertToMinutes(time)
{
// http://forum.sa-mp.c...97&postcount=11
new string[15];//-2000000000:00 could happen, so make the string 15 chars to avoid any errors
format(string, sizeof(string), "%02d:%02d", time / 60, time % 60);
return string;
}

function RandomEx(min, max)
{
    return random(max - min) + min;
}